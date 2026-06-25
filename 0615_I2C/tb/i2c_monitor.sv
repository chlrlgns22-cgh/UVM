class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)

    virtual i2c_if m_if;
    uvm_analysis_port #(i2c_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "m_if", m_if))
            `uvm_fatal(get_type_name(), "virtual interface(m_if)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        i2c_seq_item tr;

        @(m_if.mon_cb iff !m_if.mon_cb.rst);  // 리셋 해제 대기

        forever begin
            // ── 1. cmd_start 감지 ────────────────────────────────
            @(m_if.mon_cb iff m_if.mon_cb.cmd_start);
            tr = i2c_seq_item::type_id::create("tr");

            // START done 대기
            @(m_if.mon_cb iff m_if.mon_cb.done);

            // ── 2. 주소 + R/W 캡처 (cmd_write) ───────────────────
            @(m_if.mon_cb iff m_if.mon_cb.cmd_write);
            tr.addr = m_if.mon_cb.tx_data[7:1];
            tr.rw   = m_if.mon_cb.tx_data[0];

            @(m_if.mon_cb iff m_if.mon_cb.done);
            tr.addr_acked = ~m_if.mon_cb.ack_out;

            // ── 3. 데이터 페이즈 캡처 ────────────────────────────
            if (!tr.rw) begin
                // WRITE: master 전송 데이터 캡처 → done 후 slave_rxd 캡처
                // (slave_done은 master_done보다 먼저 발생 → done 시점에 slave_rx_data 유효)
                @(m_if.mon_cb iff m_if.mon_cb.cmd_write);
                tr.wdata = m_if.mon_cb.tx_data;
                @(m_if.mon_cb iff m_if.mon_cb.done);
                tr.slave_rxd = m_if.mon_cb.slave_rx_data;
            end else begin
                // READ: slave_tx_data 설정값 캡처 → done 후 master 수신 데이터 캡처
                @(m_if.mon_cb iff m_if.mon_cb.cmd_read);
                tr.slave_tx = m_if.mon_cb.slave_tx_data;
                @(m_if.mon_cb iff m_if.mon_cb.done);
                tr.rdata = m_if.mon_cb.rx_data;
            end

            // ── 4. STOP 대기 ──────────────────────────────────────
            @(m_if.mon_cb iff m_if.mon_cb.cmd_stop);
            @(m_if.mon_cb iff m_if.mon_cb.done);

            `uvm_info(get_type_name(), tr.convert2string(), UVM_HIGH)
            ap.write(tr);
        end
    endtask
endclass
