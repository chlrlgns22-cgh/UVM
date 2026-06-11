`include "uvm_macros.svh"
import uvm_pkg::*;

interface ram_intf (
    input logic clk
);
    logic       we;
    logic [7:0] wdata;
    logic [7:0] addr;
    logic [7:0] rdata;
endinterface  //ram_intf

class ram_sequence_item extends uvm_sequence_item;
    rand logic       we;
    rand logic [7:0] wdata;
    rand logic [7:0] addr;
    logic      [7:0] rdata;

    function new(string name = "ram_sequence_item");
        super.new(name);
    endfunction  //new()

    `uvm_object_utils_begin(ram_sequence_item)
        `uvm_field_int(we, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_object_utils_end

    function string convert2string();
        return $sformatf("we=%0d, wdata=%0d, addr=%0d, rdata=%0d", we, wdata, addr, rdata);
    endfunction
endclass  //ram_test extends uvm_test

class ram_sequence extends uvm_sequence #(ram_sequence_item);
    `uvm_object_utils(ram_sequence);
    int loop_count;

    function new(string name = "ram_sequence");
        super.new(name);
    endfunction  //new()

    virtual task body();
        ram_sequence_item item;
        for (int i = 0; i < loop_count; i++) begin
            item = ram_sequence_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);
            if (!item.randomize()) `uvm_fatal(get_type_name(), "Randomization failed")
            finish_item(item);
            `uvm_info(get_type_name(), $sformatf(
                      "[%0d/%0d] %s", i + 1, loop_count, item.convert2string()), UVM_HIGH)
        end
    endtask
endclass  //ram_test extends uvm_test

class ram_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ram_scoreboard)
    uvm_analysis_imp #(ram_sequence_item, ram_scoreboard) ap_imp;

    int total_count;
    int fail_count;
    int pass_count;
    logic [7:0] memory[255:0];
    function new(string name, uvm_component c);
        super.new(name, c);
        ap_imp = new("ap_imp", this);
        fail_count = 0;
        pass_count = 0;
        total_count=0;
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask

    virtual function void write(ram_sequence_item item);
        `uvm_info(get_type_name(), $sformatf("scoreboard: %s", item.convert2string), UVM_MEDIUM);
        total_count++;
        if (item.we) begin
            memory[item.addr] = item.wdata;
        end else if (memory[item.addr] === item.rdata) begin
            `uvm_info(get_type_name(), $sformatf("Matched:memory_rdata:%0d, rdata:%0d, addr:%0d",memory[item.addr], item.rdata,
                                                 item.addr), UVM_MEDIUM)
            pass_count++;
        end else begin
            `uvm_error(get_type_name(), $sformatf(
                       "Mismatched:memory_rdata:%0d, rdata:%0d, addr:%0d",memory[item.addr], item.rdata, item.addr))
            fail_count++;
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "================= Scoreboard Summary ===============", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total transaction: %0d", total_count),
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


endclass  //ram_test extends uvm_test

class ram_driver extends uvm_driver #(ram_sequence_item);
    `uvm_component_utils(ram_driver)

    virtual ram_intf ram_if;


    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_intf)::get(this, "", "ram_if", ram_if))
            `uvm_fatal(get_type_name(), "ram_if를 찾을 수 없습니다.")
        `uvm_info(get_type_name(), "build_phase 실행 완료", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task drive_item(ram_sequence_item item);
        @(posedge ram_if.clk);
        ram_if.we <= item.we;
        ram_if.wdata <= item.wdata;
        ram_if.addr <= item.addr;
        @(posedge ram_if.clk);
        @(posedge ram_if.clk);
        `uvm_info(get_type_name(), item.convert2string(), UVM_HIGH);
    endtask  //drive_item

    virtual task run_phase(uvm_phase phase);
        ram_sequence_item item;
        forever begin
            seq_item_port.get_next_item(item);
            drive_item(item);
            seq_item_port.item_done();
        end
    endtask


    virtual function void report_phase(uvm_phase phase);

    endfunction
endclass  //

class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)
    uvm_analysis_port #(ram_sequence_item) ap;

    virtual ram_intf ram_if;

    function new(string name, uvm_component c);
        super.new(name, c);
        ap = new("ap", this);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_intf)::get(this, "", "ram_if", ram_if))
            `uvm_fatal(get_type_name(), "ram_if를 찾을 수 없습니다")
        `uvm_info(get_type_name(), " build phase 실행 완료", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            ram_sequence_item item = ram_sequence_item::type_id::create("item");
            @(posedge ram_if.clk);
            @(posedge ram_if.clk);
            item.we = ram_if.we;
            item.wdata = ram_if.wdata;
            item.addr = ram_if.addr;
            @(posedge ram_if.clk);
            item.rdata = ram_if.rdata;
            ap.write(item);
            `uvm_info(get_type_name(), item.convert2string(), UVM_MEDIUM);
        end
    endtask


    virtual function void report_phase(uvm_phase phase);
    endfunction


endclass  //ram_test extends uvm_test

class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)

    uvm_sequencer #(ram_sequence_item) sqr;
    ram_driver drv;
    ram_monitor mon;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = uvm_sequencer#(ram_sequence_item)::type_id::create("sqr", this);
        drv = ram_driver::type_id::create("drv", this);
        mon = ram_monitor::type_id::create("mon", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask


    virtual function void report_phase(uvm_phase phase);
    endfunction


endclass  //ram_test extends uvm_test

class ram_env extends uvm_env;
    `uvm_component_utils(ram_env)

    ram_agent agt;
    ram_scoreboard scb;


    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = ram_agent::type_id::create("agt", this);
        scb = ram_scoreboard::type_id::create("scb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.ap.connect(scb.ap_imp);
    endfunction

    virtual task run_phase(uvm_phase phase);
    endtask


    virtual function void report_phase(uvm_phase phase);
    endfunction


endclass  //ram_test extends uvm_test

class ram_test extends uvm_test;
    `uvm_component_utils(ram_test)
    ram_env env;

    function new(string name, uvm_component c);
        super.new(name, c);
    endfunction  //new()

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ram_env::type_id::create("env", this);
        `uvm_info(get_type_name(), "build_phase", UVM_HIGH)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "connect phase", UVM_HIGH)
    endfunction

    virtual task run_phase(uvm_phase phase);
        ram_sequence seq;
        `uvm_info(get_type_name(), "ram_sequence seq 실행", UVM_DEBUG)

        phase.raise_objection(this);
        `uvm_info(get_type_name(), "phase.raise objection(this) 실행", UVM_DEBUG)

        seq = ram_sequence::type_id::create("seq");
        `uvm_info(get_type_name(), "seq = ram_sequence::type_id::create(\"seq\") 실행", UVM_DEBUG)
        seq.loop_count = 500;
        `uvm_info(get_type_name(), "seq.loop_count = 10 실행", UVM_DEBUG)
        seq.start(env.agt.sqr);

        phase.drop_objection(this);
        `uvm_info(get_type_name(), "phase.drop_objection(this) 실행", UVM_DEBUG)
    endtask


    virtual function void report_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction


endclass  //ram_test extends uvm_test

module tb_ram ();
    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    ram_intf ram_if (clk);

    ram dut (
        .clk  (ram_if.clk),
        .we   (ram_if.we),
        .wdata(ram_if.wdata),
        .addr (ram_if.addr),
        .rdata(ram_if.rdata)
    );

    initial begin
        uvm_config_db#(virtual ram_intf)::set(null, "*", "ram_if", ram_if);
        run_test("ram_test");
    end
endmodule
