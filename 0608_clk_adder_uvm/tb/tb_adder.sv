`include "uvm_macros.svh"
import uvm_pkg::*;

interface adder_if (
    input logic clk,
    input logic rst_n
);
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] y;
endinterface  //adder_if(input logic clk, input logic rst_n)

class adder_seq_item extends uvm_sequence_item;
    rand logic [7:0] a;
    rand logic [7:0] b;
    logic [8:0] y;

    function new(string name = "adder_seq_item");
        super.new(name);
    endfunction  //new()

    `uvm_object_utils_begin(adder_seq_item)
        `uvm_field_int(a, UVM_ALL_ON)
        `uvm_field_int(b, UVM_ALL_ON)
        `uvm_field_int(y, UVM_ALL_ON)
    `uvm_object_utils_end

    function string convert2string();
        return $sformatf("a=%0d, b=%0d, y=%0d", a, b, y);
    endfunction
endclass  //adder_sequence extends uvm_sequencw


class adder_sequence extends uvm_sequence #(adder_seq_item);
    `uvm_object_utils(adder_sequence);
    int loop_count;

    function new(string name = "adder_seq");
        super.new(name);
    endfunction  //new()

    virtual task body();  // opearating point
        adder_seq_item item;
        for (int i = 0; i < loop_count; i++) begin
            item = adder_seq_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);  //item 요청 대기
            if (!item.randomize()) `uvm_fatal(get_type_name(), "Randomization failed")
            finish_item(item);  //item 전송
            `uvm_info(get_type_name(), $sformatf(
                      "[%0d/%0d] %s", i + 1, loop_count, item.convert2string()), UVM_HIGH)
        end
    endtask
endclass  //adder_sequence extends uvm_sequencw

class adder_component1 extends uvm_component;
    `uvm_component_utils(adder_component1)  //fatory registering macro
    uvm_analysis_imp #(adder_seq_item, adder_component1) ap_imp_comp1;
    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp_comp1 = new("ap_imp_comp1", this);
    endfunction  //new()

    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf("         ap_imp_comp1: %s", item.convert2string()),
                  UVM_MEDIUM)
    endfunction

endclass  //className

class adder_component2 extends uvm_component;
    `uvm_component_utils(adder_component2)  //fatory registering macro
    uvm_analysis_imp #(adder_seq_item, adder_component2) ap_imp_comp2;
    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp_comp2 = new("ap_imp_comp2", this);
    endfunction  //new()

    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf("         ap_imp_comp2: %s", item.convert2string()),
                  UVM_MEDIUM)
    endfunction
endclass  //className

class adder_subscriber extends uvm_subscriber #(adder_seq_item);
    `uvm_component_utils(adder_subscriber)  //fatory registering macro

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction

    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf("         ap_imp_comp2: %s", item.convert2string()),
                  UVM_MEDIUM)
    endfunction
endclass
class adder_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(adder_scoreboard)  //fatory registering macro
    uvm_analysis_imp #(adder_seq_item, adder_scoreboard) ap_imp;

    int fail_count;
    int pass_count;

    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp = new("ap_imp", this);
        fail_count = 0;
        pass_count = 0;
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask


    virtual function void write(adder_seq_item item);
        `uvm_info(get_type_name(), $sformatf("scoreboard: %s", item.convert2string()), UVM_MEDIUM)
        if (item.y === item.a + item.b) begin
            //    `uvm_info(get_type_name(), $sformatf("Matched: y:%0d == a:%0d + b:%0d", item.y, item.a,
            //                                         item.b), UVM_MEDIUM)
            pass_count++;
        end else begin
            //    `uvm_error(get_type_name(), $sformatf(
            //               "Mismatched: y:%0d == a:%0d + b:%0d", item.y, item.a, item.b))
            fail_count++;
        end
    endfunction
    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "================= Scoreboard Summary ===============", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total transaction: %0d", pass_count + fail_count),
                  UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Pass: %0d", pass_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Fail: %0d", fail_count), UVM_LOW)

        if (fail_count > 0) begin
            `uvm_error(get_type_name(), $sformatf("TEST FAILED: %0d mismatched detected",
                                                  fail_count))
        end else begin
            `uvm_info(get_type_name(), $sformatf("TEST PASSED: %0d all matched detected", pass_count
                      ), UVM_LOW)
        end
    endfunction
endclass  //adder_test

class adder_driver extends uvm_driver #(adder_seq_item);
    `uvm_component_utils(adder_driver)  //fatory registering macro

    virtual adder_if a_if;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
            `uvm_fatal(get_type_name(), "a_if를 찾을 수 없습니다")
        `uvm_info(get_type_name(), "build_phase 실행 완료.", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task drive_item(adder_seq_item item);
        @(posedge a_if.clk);
        a_if.a <= item.a;
        a_if.b <= item.b;
        @(posedge a_if.clk);
        @(posedge a_if.clk);
        `uvm_info(get_type_name(), item.convert2string(), UVM_HIGH);
    endtask

    virtual task run_phase(uvm_phase phase);
        adder_seq_item item;
        @(posedge a_if.rst_n);
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask

    virtual function void report_phase(uvm_phase phase);

    endfunction
endclass  //adder_test

class adder_monitor extends uvm_monitor;
    `uvm_component_utils(adder_monitor)  //fatory registering macro
    uvm_analysis_port #(adder_seq_item) ap;

    virtual adder_if a_if;

    function new(string name, uvm_component c);
        super.new(name, c);
        ap = new("ap", this);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual adder_if)::get(this, "", "a_if", a_if))
            `uvm_fatal(get_type_name(), "a_if를 찾을 수 없습니다")
        `uvm_info(get_type_name(), "build_phase 실행 완료.", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

    endfunction

    virtual task run_phase(uvm_phase phase);
        @(posedge a_if.rst_n);
        forever begin
            adder_seq_item item = adder_seq_item::type_id::create("item");
            @(posedge a_if.clk);
            @(posedge a_if.clk);
            item.a = a_if.a;
            item.b = a_if.b;
            @(posedge a_if.clk);
            item.y = a_if.y;
            ap.write(item);
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
        end
    endtask

    virtual function void report_phase(uvm_phase phase);

    endfunction
endclass  //adder_test

class adder_agent extends uvm_agent;
    `uvm_component_utils(adder_agent)  //fatory registering macro

    uvm_sequencer #(adder_seq_item) sqr;
    adder_driver drv;
    adder_monitor mon;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(adder_seq_item)::type_id::create("sqr", this);
        drv = adder_driver::type_id::create("drv", this);
        mon = adder_monitor::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask

    virtual function void report_phase(uvm_phase phase);

    endfunction
endclass  //adder_test

class adder_env extends uvm_env;
    `uvm_component_utils(adder_env)  //fatory registering macro

    adder_agent agt;
    adder_scoreboard scb;
    adder_component1 cmp1;
    adder_component2 cmp2;
    adder_subscriber subs;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt  = adder_agent::type_id::create("agt", this);
        scb  = adder_scoreboard::type_id::create("scb", this);
        cmp1 = adder_component1::type_id::create("cmp1", this);
        cmp2 = adder_component2::type_id::create("cmp2", this);
        subs = adder_subscriber::type_id::create("subs", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
        agt.mon.ap.connect(cmp1.ap_imp_comp1);
        agt.mon.ap.connect(cmp2.ap_imp_comp2);
        agt.mon.ap.connect(subs.analysis_export);
    endfunction

    virtual task run_phase(uvm_phase phase);

    endtask

    virtual function void report_phase(uvm_phase phase);

    endfunction
endclass  //adder_test

class adder_test extends uvm_test;
    `uvm_component_utils(adder_test)

    adder_env env;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = adder_env::type_id::create("env", this);
        `uvm_info(get_type_name(), "build_phase", UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "connect_phase", UVM_HIGH)
    endfunction

    virtual task run_phase(uvm_phase phase);
        adder_sequence seq;
        `uvm_info(get_type_name(), "adeer_sequence seq 실행", UVM_DEBUG)

        phase.raise_objection(this);
        `uvm_info(get_type_name(), "phase.raise objection(this) 실행", UVM_DEBUG)

        seq = adder_sequence::type_id::create("seq");
        `uvm_info(get_type_name(), "seq = adder_sequence::type_id::create(\"seq\") 실행",
                  UVM_DEBUG)
        seq.loop_count = 10;
        `uvm_info(get_type_name(), "seq.loop_count = 10 실행", UVM_DEBUG)
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
        `uvm_info(get_type_name(), "phase.drop_objection(this) 실행", UVM_DEBUG)
    endtask

    virtual function void report_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
endclass  //adder_test

module tb_adder ();
    logic clk;
    logic rst_n;

    initial begin
        clk   = 0;
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
    end

    always #5 clk = ~clk;

    adder_if a_if (
        clk,
        rst_n
    );

    adder dut (
        .clk  (a_if.clk),
        .rst_n(a_if.rst_n),
        .a    (a_if.a),
        .b    (a_if.b),
        .y    (a_if.y)
    );

    initial begin
        uvm_config_db#(virtual adder_if)::set(null, "*", "a_if", a_if);
        run_test("adder_test");
    end
endmodule


