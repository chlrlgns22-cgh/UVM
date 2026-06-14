class spi_driver extends uvm_driver #(spi_seq_item);
    `uvm_component_utils(spi_driver)

    virtual spi_if s_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual spi_if)::get(this, "", "s_if", s_if))
            `uvm_fatal(get_type_name(), "virtual interface(s_if)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        // 초기값 설정 (리셋 유지)
        s_if.drv_cb.rst            <= 1'b1;
        s_if.drv_cb.start          <= 1'b0;
        s_if.drv_cb.master_tx_data <= 8'h00;
        s_if.drv_cb.slave_tx_data  <= 8'h00;

        repeat (3) @(s_if.drv_cb);
        s_if.drv_cb.rst <= 1'b0;
        @(s_if.drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(),
                      $sformatf("전송 시작: M_TX=0x%02h S_TX=0x%02h",
                                req.master_tx_data, req.slave_tx_data), UVM_HIGH)
            drive_transfer(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transfer(spi_seq_item item);
        // 데이터 설정 후 start 펄스 (1클럭)
        @(s_if.drv_cb);
        s_if.drv_cb.master_tx_data <= item.master_tx_data;
        s_if.drv_cb.slave_tx_data  <= item.slave_tx_data;

        @(s_if.drv_cb);
        s_if.drv_cb.start <= 1'b1;
        @(s_if.drv_cb);
        s_if.drv_cb.start <= 1'b0;

        // 전송 완료(master_done) 대기
        do @(s_if.drv_cb); while (!s_if.drv_cb.master_done);

        `uvm_info(get_type_name(),
                  $sformatf("전송 완료: M_RX=0x%02h S_RX=0x%02h",
                             s_if.master_rx_data, s_if.slave_rx_data), UVM_HIGH)
    endtask
endclass
