class spi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp #(spi_seq_item, spi_scoreboard) imp;

    int transfer_count = 0;
    int pass_count     = 0;
    int fail_count     = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(spi_seq_item tr);
        bit ok = 1;
        transfer_count++;

        // master → slave 경로 확인
        if (tr.slave_rx_data !== tr.master_tx_data) begin
            `uvm_error(get_type_name(),
                $sformatf("FAIL [M->S] 전송%0d: M_TX=0x%02h, S_RX=0x%02h (불일치)",
                           transfer_count, tr.master_tx_data, tr.slave_rx_data))
            ok = 0;
        end

        // slave → master 경로 확인
        if (tr.master_rx_data !== tr.slave_tx_data) begin
            `uvm_error(get_type_name(),
                $sformatf("FAIL [S->M] 전송%0d: S_TX=0x%02h, M_RX=0x%02h (불일치)",
                           transfer_count, tr.slave_tx_data, tr.master_rx_data))
            ok = 0;
        end

        if (ok) begin
            pass_count++;
            `uvm_info(get_type_name(),
                $sformatf("PASS 전송%0d: %s", transfer_count, tr.convert2string()), UVM_HIGH)
        end else begin
            fail_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", "=====================================", UVM_LOW)
        `uvm_info("SCB", "===== Scoreboard 최종 리포트 ========", UVM_LOW)
        `uvm_info("SCB", $sformatf(" 전송 횟수  : %0d", transfer_count), UVM_LOW)
        `uvm_info("SCB", $sformatf(" 통과(PASS) : %0d", pass_count),     UVM_LOW)
        `uvm_info("SCB", $sformatf(" 실패(FAIL) : %0d", fail_count),     UVM_LOW)
        `uvm_info("SCB", "=====================================", UVM_LOW)
    endfunction
endclass
