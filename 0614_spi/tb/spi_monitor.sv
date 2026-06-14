class spi_monitor extends uvm_monitor;
    `uvm_component_utils(spi_monitor)

    virtual spi_if s_if;

    uvm_analysis_port #(spi_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_if))
            `uvm_fatal(get_type_name(), "virtual interface(s_if)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        spi_seq_item tr;

        // 리셋 해제 대기
        @(s_if.mon_cb iff !s_if.mon_cb.rst);

        forever begin
            // start 펄스 감지 → 전송 시작
            @(s_if.mon_cb iff s_if.mon_cb.start);

            tr = spi_seq_item::type_id::create("tr");
            tr.master_tx_data = s_if.mon_cb.master_tx_data;
            tr.slave_tx_data  = s_if.mon_cb.slave_tx_data;

            // 전송 완료(master_done) 대기
            @(s_if.mon_cb iff s_if.mon_cb.master_done);

            tr.master_rx_data = s_if.mon_cb.master_rx_data;
            tr.slave_rx_data  = s_if.mon_cb.slave_rx_data;

            `uvm_info(get_type_name(), tr.convert2string(), UVM_HIGH)
            ap.write(tr);
        end
    endtask
endclass
