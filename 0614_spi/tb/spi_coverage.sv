class spi_coverage extends uvm_subscriber #(spi_seq_item);
    `uvm_component_utils(spi_coverage)

    spi_seq_item tr;

    covergroup spi_cg;
        option.per_instance = 1;

        cp_master_tx: coverpoint tr.master_tx_data {
            bins tx_zero = {8'h00};
            bins tx_low  = {[8'h01 : 8'h7F]};
            bins tx_high = {[8'h80 : 8'hFE]};
            bins tx_max  = {8'hFF};
        }

        cp_slave_tx: coverpoint tr.slave_tx_data {
            bins tx_zero = {8'h00};
            bins tx_low  = {[8'h01 : 8'h7F]};
            bins tx_high = {[8'h80 : 8'hFE]};
            bins tx_max  = {8'hFF};
        }

        // master_tx와 slave_tx의 교차 커버리지
        cx_m_s: cross cp_master_tx, cp_slave_tx;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        spi_cg = new();
    endfunction

    function void write(spi_seq_item t);
        `uvm_info(get_type_name(), t.convert2string(), UVM_HIGH)
        tr = t;
        spi_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", "=====================================", UVM_LOW)
        `uvm_info("COV", "==== Functional Coverage 결과 =======", UVM_LOW)
        `uvm_info("COV", $sformatf("  전체           : %6.2f %%",
                  spi_cg.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  master TX 범위 : %6.2f %%",
                  spi_cg.cp_master_tx.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  slave  TX 범위 : %6.2f %%",
                  spi_cg.cp_slave_tx.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  교차 커버리지  : %6.2f %%",
                  spi_cg.cx_m_s.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", "=====================================", UVM_LOW)

        if (spi_cg.get_inst_coverage() < 100.0)
            `uvm_warning("COV", "커버리지 100% 미달! 시나리오를 추가하거나 더 테스트를 진행하시오.")
    endfunction
endclass
