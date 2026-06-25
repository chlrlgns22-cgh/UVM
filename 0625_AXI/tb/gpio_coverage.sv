class gpio_coverage extends uvm_component;
    `uvm_component_utils(gpio_coverage)

    uvm_analysis_imp #(gpio_seq_item, gpio_coverage) analysis_export;

    int write_count = 0;

    logic [7:0] cr_v;
    logic [7:0] odr_v;
    logic [7:0] io_v;

    covergroup gpio_cg;
        // get_inst_coverage()가 동작하려면 per_instance = 1 필수
        option.per_instance = 1;

        cp_cr: coverpoint cr_v {
            bins all_output      = {8'hFF};
            bins all_input       = {8'h00};
            bins high_nibble_out = {8'hF0};
            bins low_nibble_out  = {8'h0F};
            bins alternating_aa  = {8'hAA};
            bins alternating_55  = {8'h55};
            bins other           = default;
        }

        cp_odr: coverpoint odr_v {
            bins odr_zero = {8'h00};
            bins odr_max  = {8'hFF};
            bins odr_55   = {8'h55};
            bins odr_aa   = {8'hAA};
            bins odr_low  = {[8'h01 : 8'h7F]};
            bins odr_high = {[8'h80 : 8'hFE]};
        }

        cp_io: coverpoint io_v {
            bins io_zero = {8'h00};
            bins io_max  = {8'hFF};
            bins io_55   = {8'h55};
            bins io_aa   = {8'hAA};
            bins io_low  = {[8'h01 : 8'h7F]};
            bins io_high = {[8'h80 : 8'hFE]};
        }

        cx_cr_odr: cross cp_cr, cp_odr {
            // CR=전체입력(0x00)일 때 ODR은 핀에 영향 없음 → 의미 없는 조합 제외
            ignore_bins all_input_x_odr_max  = binsof(cp_cr.all_input) && binsof(cp_odr.odr_max);
            ignore_bins all_input_x_odr_55   = binsof(cp_cr.all_input) && binsof(cp_odr.odr_55);
            ignore_bins all_input_x_odr_aa   = binsof(cp_cr.all_input) && binsof(cp_odr.odr_aa);
            ignore_bins all_input_x_odr_low  = binsof(cp_cr.all_input) && binsof(cp_odr.odr_low);
            ignore_bins all_input_x_odr_high = binsof(cp_cr.all_input) && binsof(cp_odr.odr_high);
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        gpio_cg = new();
    endfunction

    function void write(gpio_seq_item t);
        write_count++;
        cr_v  = t.cr_val;
        odr_v = t.odr_val;
        io_v  = t.io_drive;
        gpio_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV", "=====================================", UVM_LOW)
        `uvm_info("COV", "===== 기능 커버리지 리포트 ==========", UVM_LOW)
        `uvm_info("COV", $sformatf("  write() 호출 횟수: %0d", write_count), UVM_LOW)
        `uvm_info("COV", $sformatf("  전체           : %6.2f %%",
                  gpio_cg.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  CR 방향 설정   : %6.2f %%",
                  gpio_cg.cp_cr.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  ODR 출력 데이터: %6.2f %%",
                  gpio_cg.cp_odr.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", $sformatf("  외부 입력 핀   : %6.2f %%",
                  gpio_cg.cp_io.get_inst_coverage()), UVM_LOW)
        `uvm_info("COV", "=====================================", UVM_LOW)
        if (gpio_cg.get_inst_coverage() < 100.0)
            `uvm_warning("COV", "커버리지 100% 미달! 시나리오를 추가하시오.")
    endfunction
endclass
