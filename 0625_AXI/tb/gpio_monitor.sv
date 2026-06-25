class gpio_monitor extends uvm_monitor;
    `uvm_component_utils(gpio_monitor)

    virtual gpio_if m_if;
    uvm_analysis_port #(gpio_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_if)::get(this, "", "m_if", m_if))
            `uvm_fatal(get_type_name(), "virtual interface(m_if)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        gpio_seq_item tr;

        @(m_if.mon_cb iff m_if.mon_cb.aresetn);  // 리셋 해제 대기

        forever begin
            tr = gpio_seq_item::type_id::create("tr");

            // ── 1. CR 쓰기 감지 (addr=0x0, AW 핸드셰이크) ───────────
            @(m_if.mon_cb iff (m_if.mon_cb.awvalid && m_if.mon_cb.awready
                                && m_if.mon_cb.awaddr == 4'h0));
            tr.cr_val = m_if.mon_cb.wdata[7:0];

            // B 응답 캡처
            @(m_if.mon_cb iff (m_if.mon_cb.bvalid && m_if.mon_cb.bready));
            tr.bresp = m_if.mon_cb.bresp;

            // ── 2. ODR 쓰기 감지 (addr=0x8) ─────────────────────────
            @(m_if.mon_cb iff (m_if.mon_cb.awvalid && m_if.mon_cb.awready
                                && m_if.mon_cb.awaddr == 4'h8));
            tr.odr_val = m_if.mon_cb.wdata[7:0];

            @(m_if.mon_cb iff (m_if.mon_cb.bvalid && m_if.mon_cb.bready));

            // ── 3. IDR 읽기 감지 (addr=0x4) ─────────────────────────
            @(m_if.mon_cb iff (m_if.mon_cb.arvalid && m_if.mon_cb.arready
                                && m_if.mon_cb.araddr == 4'h4));
            // AR 핸드셰이크 시점에 io_port_tb 캡처 (TB가 구동 중인 외부 핀 값)
            tr.io_drive = m_if.mon_cb.io_port_tb & m_if.mon_cb.io_port_tb_en;

            @(m_if.mon_cb iff (m_if.mon_cb.rvalid && m_if.mon_cb.rready));
            tr.idr_readback = m_if.mon_cb.rdata[7:0];

            // ── 4. ODR 읽기 감지 (addr=0x8) ─────────────────────────
            @(m_if.mon_cb iff (m_if.mon_cb.arvalid && m_if.mon_cb.arready
                                && m_if.mon_cb.araddr == 4'h8));

            @(m_if.mon_cb iff (m_if.mon_cb.rvalid && m_if.mon_cb.rready));
            tr.odr_readback = m_if.mon_cb.rdata[7:0];

            `uvm_info(get_type_name(), tr.convert2string(), UVM_HIGH)
            ap.write(tr);
        end
    endtask
endclass
