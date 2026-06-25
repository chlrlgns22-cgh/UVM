class gpio_driver extends uvm_driver #(gpio_seq_item);
    `uvm_component_utils(gpio_driver)

    virtual gpio_if m_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_if)::get(this, "", "m_if", m_if))
            `uvm_fatal(get_type_name(), "virtual interface(m_if)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        // 초기화
        m_if.drv_cb.aresetn      <= 1'b0;
        m_if.drv_cb.awvalid      <= 1'b0;
        m_if.drv_cb.wvalid       <= 1'b0;
        m_if.drv_cb.bready       <= 1'b0;
        m_if.drv_cb.arvalid      <= 1'b0;
        m_if.drv_cb.rready       <= 1'b0;
        m_if.drv_cb.awaddr       <= '0;
        m_if.drv_cb.awprot       <= 3'b0;
        m_if.drv_cb.wdata        <= '0;
        m_if.drv_cb.wstrb        <= '0;
        m_if.drv_cb.araddr       <= '0;
        m_if.drv_cb.arprot       <= 3'b0;
        m_if.drv_cb.io_port_tb   <= 8'h00;
        m_if.drv_cb.io_port_tb_en <= 8'h00;

        repeat (5) @(m_if.drv_cb);
        m_if.drv_cb.aresetn <= 1'b1;
        repeat (2) @(m_if.drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    // AXI4-Lite 쓰기 핸드셰이크
    // 이 DUT는 awvalid & wvalid 동시 어서션 필요
    task axi_write(input logic [3:0] addr,
                   input logic [31:0] data,
                   output logic [1:0] resp);
        @(m_if.drv_cb);
        m_if.drv_cb.awaddr  <= addr;
        m_if.drv_cb.awprot  <= 3'b0;
        m_if.drv_cb.awvalid <= 1'b1;
        m_if.drv_cb.wdata   <= data;
        m_if.drv_cb.wstrb   <= 4'hF;
        m_if.drv_cb.wvalid  <= 1'b1;
        m_if.drv_cb.bready  <= 1'b1;

        // AW + W 핸드셰이크 (DUT는 같은 사이클에 awready+wready 어서션)
        do @(m_if.drv_cb);
        while (!(m_if.drv_cb.awready && m_if.drv_cb.wready));

        m_if.drv_cb.awvalid <= 1'b0;
        m_if.drv_cb.wvalid  <= 1'b0;

        // B 채널 핸드셰이크
        do @(m_if.drv_cb);
        while (!m_if.drv_cb.bvalid);

        resp = m_if.drv_cb.bresp;
        @(m_if.drv_cb);
        m_if.drv_cb.bready <= 1'b0;
    endtask

    // AXI4-Lite 읽기 핸드셰이크
    task axi_read(input logic [3:0] addr, output logic [31:0] data);
        @(m_if.drv_cb);
        m_if.drv_cb.araddr  <= addr;
        m_if.drv_cb.arprot  <= 3'b0;
        m_if.drv_cb.arvalid <= 1'b1;
        m_if.drv_cb.rready  <= 1'b1;

        // AR 핸드셰이크
        do @(m_if.drv_cb);
        while (!m_if.drv_cb.arready);

        m_if.drv_cb.arvalid <= 1'b0;

        // R 채널 핸드셰이크
        do @(m_if.drv_cb);
        while (!m_if.drv_cb.rvalid);

        data = m_if.drv_cb.rdata;
        @(m_if.drv_cb);
        m_if.drv_cb.rready <= 1'b0;
    endtask

    task drive_transaction(gpio_seq_item item);
        logic [1:0] bresp_tmp;
        logic [31:0] rdata_tmp;

        // ── 1. CR 쓰기 (addr=0x0: 방향 설정) ────────────────────────
        axi_write(4'h0, {24'b0, item.cr_val}, bresp_tmp);
        item.bresp = bresp_tmp;

        // ── 2. ODR 쓰기 (addr=0x8: 출력 데이터) ─────────────────────
        axi_write(4'h8, {24'b0, item.odr_val}, bresp_tmp);

        // ── 3. 외부 핀 구동 설정 (입력 모드 비트만 TB가 구동) ────────
        m_if.drv_cb.io_port_tb     <= item.io_drive;
        m_if.drv_cb.io_port_tb_en  <= ~item.cr_val;  // 출력 모드 비트는 DUT가 구동
        repeat(2) @(m_if.drv_cb);  // io_port 안정화 대기

        // ── 4. IDR 읽기 (addr=0x4: 입력 핀 값) ──────────────────────
        axi_read(4'h4, rdata_tmp);
        item.idr_readback = rdata_tmp[7:0];

        // ── 5. ODR 읽기 (addr=0x8: 쓰기 검증) ───────────────────────
        axi_read(4'h8, rdata_tmp);
        item.odr_readback = rdata_tmp[7:0];

        // 다음 트랜잭션 전 외부 핀 구동 해제
        m_if.drv_cb.io_port_tb_en <= 8'h00;
        @(m_if.drv_cb);

        `uvm_info(get_type_name(), $sformatf("완료: %s", item.convert2string()), UVM_HIGH)
    endtask
endclass
