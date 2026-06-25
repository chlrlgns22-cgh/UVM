class gpio_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(gpio_scoreboard)

    uvm_analysis_imp #(gpio_seq_item, gpio_scoreboard) imp;

    int pass_count = 0;
    int fail_count = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(gpio_seq_item tr);
        bit ok = 1;

        // ── 1. AXI 응답 확인 ─────────────────────────────────────────
        if (tr.bresp !== 2'b00) begin
            `uvm_error(get_type_name(),
                $sformatf("FAIL AXI BRESP: 기대=OKAY(00) 실제=%02b", tr.bresp))
            ok = 0;
        end

        // ── 2. ODR 쓰기-읽기 검증 ────────────────────────────────────
        // ODR 레지스터에 쓴 값이 읽기에서 그대로 나와야 함
        if (tr.odr_readback !== tr.odr_val) begin
            `uvm_error(get_type_name(),
                $sformatf("FAIL ODR 쓰기검증: W=0x%02h R=0x%02h (CR=0x%02h)",
                           tr.odr_val, tr.odr_readback, tr.cr_val))
            ok = 0;
        end

        // ── 3. IDR 읽기 검증 (입력 모드 비트만) ─────────────────────
        // cr_val[i]=0인 비트: IDR[i] == io_drive[i]
        // cr_val[i]=1인 비트: DUT가 Hi-Z → idr은 Z (검사 제외)
        begin
            logic [7:0] input_mask  = ~tr.cr_val;
            logic [7:0] exp_idr     = tr.io_drive & input_mask;
            logic [7:0] act_idr     = tr.idr_readback & input_mask;

            if (act_idr !== exp_idr) begin
                `uvm_error(get_type_name(),
                    $sformatf("FAIL IDR 입력검증: CR=0x%02h MASK=0x%02h 기대=0x%02h 실제=0x%02h",
                               tr.cr_val, input_mask, exp_idr, act_idr))
                ok = 0;
            end
        end

        if (ok) begin
            pass_count++;
            `uvm_info(get_type_name(),
                $sformatf("PASS #%0d: %s", pass_count, tr.convert2string()), UVM_HIGH)
        end else begin
            fail_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", "=====================================", UVM_LOW)
        `uvm_info("SCB", "===== Scoreboard 최종 리포트 ========", UVM_LOW)
        `uvm_info("SCB", $sformatf(" PASS : %0d", pass_count), UVM_LOW)
        `uvm_info("SCB", $sformatf(" FAIL : %0d", fail_count), UVM_LOW)
        `uvm_info("SCB", "=====================================", UVM_LOW)
    endfunction
endclass
