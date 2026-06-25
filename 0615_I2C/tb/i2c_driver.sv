class i2c_driver extends uvm_driver #(i2c_seq_item);
    `uvm_component_utils(i2c_driver)

    virtual i2c_if m_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "m_if", m_if))
            `uvm_fatal(get_type_name(), "virtual interface(m_if)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        // 초기화 및 리셋
        m_if.drv_cb.rst           <= 1'b1;
        m_if.drv_cb.cmd_start     <= 1'b0;
        m_if.drv_cb.cmd_write     <= 1'b0;
        m_if.drv_cb.cmd_read      <= 1'b0;
        m_if.drv_cb.cmd_stop      <= 1'b0;
        m_if.drv_cb.tx_data       <= 8'h00;
        m_if.drv_cb.ack_in        <= 1'b1;
        m_if.drv_cb.slave_tx_data <= 8'h00;

        repeat (5) @(m_if.drv_cb);
        m_if.drv_cb.rst <= 1'b0;
        @(m_if.drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    // done 1클럭 펄스 대기 (drv_cb 기준)
    task wait_done();
        do @(m_if.drv_cb); while (!m_if.drv_cb.done);
    endtask

    task drive_transaction(i2c_seq_item item);
        // slave READ용 데이터 미리 설정 (slave RTL의 tx_data 포트)
        m_if.drv_cb.slave_tx_data <= item.slave_tx;
        @(m_if.drv_cb);

        // ── 1. START ─────────────────────────────────────────────
        m_if.drv_cb.cmd_start <= 1'b1;
        @(m_if.drv_cb);
        m_if.drv_cb.cmd_start <= 1'b0;
        wait_done();

        // ── 2. 주소 + R/W 전송 (항상 cmd_write) ──────────────────
        @(m_if.drv_cb);
        m_if.drv_cb.cmd_write <= 1'b1;
        m_if.drv_cb.tx_data   <= {item.addr, item.rw};
        @(m_if.drv_cb);
        m_if.drv_cb.cmd_write <= 1'b0;
        wait_done();
        item.addr_acked = ~m_if.drv_cb.ack_out;  // ack_out=0 → ACK

        // ── 3. 데이터 페이즈 ──────────────────────────────────────
        @(m_if.drv_cb);
        if (!item.rw) begin
            // WRITE: 데이터 1바이트 전송
            m_if.drv_cb.cmd_write <= 1'b1;
            m_if.drv_cb.tx_data   <= item.wdata;
            @(m_if.drv_cb);
            m_if.drv_cb.cmd_write <= 1'b0;
        end else begin
            // READ: 데이터 1바이트 수신 (NACK=전송 종료)
            m_if.drv_cb.cmd_read <= 1'b1;
            m_if.drv_cb.ack_in   <= 1'b1;  // NACK: 1바이트만 읽음
            @(m_if.drv_cb);
            m_if.drv_cb.cmd_read <= 1'b0;
        end
        wait_done();
        item.rdata = m_if.drv_cb.rx_data;

        // ── 4. STOP ───────────────────────────────────────────────
        @(m_if.drv_cb);
        m_if.drv_cb.cmd_stop <= 1'b1;
        @(m_if.drv_cb);
        m_if.drv_cb.cmd_stop <= 1'b0;
        wait_done();

        `uvm_info(get_type_name(), $sformatf("완료: %s", item.convert2string()), UVM_HIGH)
    endtask
endclass
