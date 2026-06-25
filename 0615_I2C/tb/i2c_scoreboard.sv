class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    uvm_analysis_imp #(i2c_seq_item, i2c_scoreboard) imp;

    int write_count = 0;
    int read_count  = 0;
    int pass_count  = 0;
    int fail_count  = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction

    function void write(i2c_seq_item tr);
        bit ok = 1;

        // 주소 ACK 확인
        if (!tr.addr_acked) begin
            `uvm_error(get_type_name(),
                $sformatf("FAIL 주소 NACK: addr=0x%02h", tr.addr))
            ok = 0;
        end

        if (!tr.rw) begin
            write_count++;
            // WRITE: slave가 실제 수신한 데이터 == master가 전송한 데이터
            if (ok && (tr.slave_rxd !== tr.wdata)) begin
                `uvm_error(get_type_name(),
                    $sformatf("FAIL WRITE #%0d: master_tx=0x%02h slave_rx=0x%02h (불일치)",
                               write_count, tr.wdata, tr.slave_rxd))
                ok = 0;
            end
            if (ok) begin
                pass_count++;
                `uvm_info(get_type_name(),
                    $sformatf("PASS WRITE #%0d: %s", write_count, tr.convert2string()),
                    UVM_HIGH)
            end else
                fail_count++;
        end else begin
            read_count++;
            // READ: master가 수신한 데이터 == slave가 전송하도록 설정된 데이터
            if (ok && (tr.rdata !== tr.slave_tx)) begin
                `uvm_error(get_type_name(),
                    $sformatf("FAIL READ #%0d: slave_tx=0x%02h master_rx=0x%02h (불일치)",
                               read_count, tr.slave_tx, tr.rdata))
                ok = 0;
            end
            if (ok) begin
                pass_count++;
                `uvm_info(get_type_name(),
                    $sformatf("PASS READ #%0d: %s", read_count, tr.convert2string()),
                    UVM_HIGH)
            end else
                fail_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCB", "=====================================", UVM_LOW)
        `uvm_info("SCB", "===== Scoreboard 최종 리포트 ========", UVM_LOW)
        `uvm_info("SCB", $sformatf(" WRITE 횟수 : %0d", write_count), UVM_LOW)
        `uvm_info("SCB", $sformatf(" READ  횟수 : %0d", read_count),  UVM_LOW)
        `uvm_info("SCB", $sformatf(" PASS       : %0d", pass_count),  UVM_LOW)
        `uvm_info("SCB", $sformatf(" FAIL       : %0d", fail_count),  UVM_LOW)
        `uvm_info("SCB", "=====================================", UVM_LOW)
    endfunction
endclass
