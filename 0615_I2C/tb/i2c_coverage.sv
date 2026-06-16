class i2c_coverage extends uvm_subscriber #(i2c_seq_item);
    `uvm_component_utils(i2c_coverage)

    i2c_seq_item tr;

    covergroup i2c_cg;
        option.per_instance = 1;

        cp_rw: coverpoint tr.rw {
            bins write_op = {1'b0};
            bins read_op  = {1'b1};
        }

        cp_wdata: coverpoint tr.wdata iff (!tr.rw) {
            bins data_zero = {8'h00};
            bins data_low  = {[8'h01 : 8'h7F]};
            bins data_high = {[8'h80 : 8'hFE]};
            bins data_max  = {8'hFF};
        }

        cp_rdata: coverpoint tr.slave_resp iff (tr.rw) {
            bins resp_zero = {8'h00};
            bins resp_low  = {[8'h01 : 8'h7F]};
            bins resp_high = {[8'h80 : 8'hFE]};
            bins resp_max  = {8'hFF};
        }

        cp_ack: coverpoint tr.addr_acked {
            bins acked = {1'b1};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        i2c_cg = new();
    endfunction

    function void write(i2c_seq_item t);
        tr = t;
        i2c_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", "=====================================", UVM_LOW)
        `uvm_info("COV", "==== Functional Coverage 결과 =======", UVM_LOW)
        `uvm_info("COV", $sformatf("  전체          : %6.2f %%",
                  i2c_cg.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  동작(R/W)     : %6.2f %%",
                  i2c_cg.cp_rw.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  WRITE 데이터  : %6.2f %%",
                  i2c_cg.cp_wdata.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  READ  응답    : %6.2f %%",
                  i2c_cg.cp_rdata.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  주소 ACK      : %6.2f %%",
                  i2c_cg.cp_ack.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", "=====================================", UVM_LOW)
        if (i2c_cg.get_inst_coverage() < 100.0)
            `uvm_warning("COV", "커버리지 100% 미달! 시나리오를 추가하시오.")
    endfunction
endclass