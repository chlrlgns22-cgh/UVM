`include "uvm_macros.svh"
import uvm_pkg::*;

`define DATA_WIDTH 32
`define ADDR_WIDTH 4

interface axi4_lite_intf (
    input logic aclk
);
    logic                      aresetn;
    //AW Channel
    logic [    ADDR_WIDTH-1:0] awaddr;
    logic [               2:0] awprot;
    logic                      awvalid;
    logic                      awready;
    //W Channel
    logic [    DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                      wvalid;
    logic                      wready;
    //B Channel
    logic [               1:0] bresp;
    logic                      bvalid;
    logic                      bready;
    //AR Channel
    logic [  ADDR_WIDTH-1 : 0] araddr;
    logic [               2:0] arprot;
    logic                      arvalid;
    logic                      arready;
    //R Channel
    logic [    DATA_WIDTH-1:0] rdata;
    logic [               1:0] rresp;
    logic                      rvalid;
    logic                      rready;

    clocking drv_cb @(posedge aclk);
        default input #1step output #0;
        // TB -> DUT
        output aresetn;
        output awaddr, awprot, awvalid;
        output wdata, wstrb, Writevalid;
        output bready;
        output araddr, arprot, arvalid;
        output rready;
        // DUT -> TB
        input awready;
        input wready;
        input bresp;
        input bvalid;
        input arready;
        input rdata, rresp, rvalid;
    endclocking

    clocking mon_cb @(posedge aclk);
        default input #1step;
        input aresetn;
        input awaddr, awprot, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bresp, bvalid, bready;
        input araddr, arprot, arvalid, arready;
        input rdata, rresp, rvalid, rready;
    endclocking

endinterface

class axi4_lite_sequence_item extends uvm_sequence_item;
    rand logic write;
    rand logic [DATA_WIDTH-1:0] wdata;
    rand logic [ADDR_WIDTH-1:0] awaddr;
    rand logic [ADDR_WIDTH-1:0] araddr;
    rand logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0] bresp;
    logic [1:0] rresp;

    `uvm_object_utils_begin(axi4_lite_sequence_item)
        `uvm_field_int(write, UVM_ALL_ON)
        `uvm_field_int(wdata, UVM_ALL_ON)
        `uvm_field_int(awaddr, UVM_ALL_ON)
        `uvm_field_int(araddr, UVM_ALL_ON)
        `uvm_field_int(wstrb, UVM_ALL_ON)
        `uvm_field_int(rdata, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(bresp, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(rresp, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "axi4_lite_sequence_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "write = %d, wdata = %d, awaddr = %d, araddr = %d, wstrb =%d, rdata = %d, bresp = %d , rresp = %d",
            write,
            wdata,
            awaddr,
            araddr,
            wstrb,
            rdata,
            bresp,
            rresp
        );
    endfunction
endclass

class axi4_lite_sequence extends uvm_sequence #(axi4_lite_sequence_item);
    `uvm_object_utils(axi4_lite_sequence);

    function new(string name = "axi4_lite_sequence");
        super.new(name);
    endfunction

    int loop_count;
    virtual task body();
        axi4_lite_sequence_item item;
        for (int i = 0; i < loop_count; i++) begin
            item = axi4_lite_sequence_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);
            if (!item.randomize()) `uvm_fatal(get_type_name, "Randomization failed")
            finish_item(item);
            `uvm_info(get_type_name(), $sformatf(
                      "[%0d/%0d] %s", i + 1, loop_count, item.convert2string()), UVM_HIGH)
        end
    endtask
endclass
class axi4_lite_driver extends uvm_driver #(axi4_lite_sequence_item);
    `uvm_component_utils(axi4_lite_driver)

    virtual axi4_lite_intf axi4_lite_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_lite_intf)::get(this, "", "axi4_lite_if", axi4_lite_if))
            `uvm_fatal(get_type_name(), "axi4_lite_if를 찾을 수없습니다.")
        `uvm_info(get_type_name(), "build_phase 실행 완료", UVM_HIGH);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        axi4_lite_if.drv_cb.aresetn <= 1'b0;
        axi4_lite_if.drv_cb.awvalid <= 1'b0;
        axi4_lite_if.drv_cb.wvalid  <= 1'b0;
        axi4_lite_if.drv_cb.bready  <= 1'b0;
        axi4_lite_if.drv_cb.arvalid <= 1'b0;
        axi4_lite_if.drv_cb.rready  <= 1'b0;
        axi4_lite_if.drv_cb.awaddr  <= 0;
        axi4_lite_if.drv_cb.awprot  <= 3'b0;
        axi4_lite_if.drv_cb.wdata   <= 0;
        axi4_lite_if.drv_cb.wstrb   <= 0;
        axi4_lite_if.drv_cb.araddr  <= 0;
        axi4_lite_if.drv_cb.arprot  <= 3'b0;

        repeat (5) @(axi4_lite_if.drv_cb);
        axi4_lite_if.drv_cb.aresetn <= 1'b1;
        repeat (2) @(axi4_lite_if.drv_cb);

        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task axi_write(input logic [DATA_WIDTH-1:0] data, input logic [ADDR_WIDTH-1:0] addr,
                   input logic [3:0] wstrb, output logic [1:0] resp);
        @(axi4_lite_if.drv_cb);
        axi4_lite_if.drv_cb.awaddr  <= addr;
        axi4_lite_if.drv_cb.awprot  <= 3'b0;
        axi4_lite_if.drv_cb.awvalid <= 1'b1;
        axi4_lite_if.drv_cb.wdata   <= data;
        axi4_lite_if.drv_cb.wstrb   <= wstrb;
        axi4_lite_if.drv_cb.wvalid  <= 1'b1;
        axi4_lite_if.drv_cb.bready  <= 1'b1;

        //AW + W
        do
            @(axi4_lite_if.drv_cb);
        while (!(axi4_lite_if.drv_cb.awready && axi4_lite_if.drv_cb.wready));

        axi4_lite_if.drv_cb.awvalid <= 1'b0;
        axi4_lite_if.drv_cb.wvalid  <= 1'b0;
        //B
        do @(axi4_lite_if.drv_cb); while (!axi4_lite_if.drv_cb.bvalid);

        resp = axi4_lite_if.drv_cb.bresp;
        axi4_lite_if.drv_cb.bready <= 1'b0;
    endtask

    task axi_read(input logic [ADDR_WIDTH-1:0] addr, output logic [31:0] data);
        @(axi4_lite_if.drv_cb);
        axi4_lite_if.drv_cb.araddr  <= addr;
        axi4_lite_if.drv_cb.arprot  <= 3'b0;
        axi4_lite_if.drv_cb.arvalid <= 1'b1;
        axi4_lite_if.drv_cb.rready  <= 1'b1;

        //AR
        do @(axi4_lite_if.drv_cb); while (!(axi4_lite_if.drv_cb.arready));

        axi4_lite_if.drv_cb.arvalid <= 1'b0;
        //R
        do @(axi4_lite_if.drv_cb); while (!(axi4_lite_if.drv_cb.rvalid));
        data = axi4_lite_if.drv_cb.rdata;
        axi4_lite_if.drv_cb.rready <= 1'b0;
    endtask

    task drive_transaction(axi4_lite_sequence_item item);
        if (req.write) axi_write(req.wdata, req.awaddr, req.wstrb, req.bresp);
        else axi_read(req.araddr, rdata);
    endtask
endclass
class axi4_lite_monitor extends uvm_monitor;

endclass

class axi4_lite_scb extends uvm_scoreboard;

endclass
class axi4_lite_agent extends uvm_agent;

endclass
class axi4_lite_env extends uvm_env;

endclass
class axi4_lite_test extends uvm_test;

endclass

module tb_AXI4_LITE ();
    axi4_lite_intf axi4_lite_if ();


    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        uvm_config_db#(virtual axi4_lite_intf)::set(null, "*", "axi4_lite_if", axi4_lite_if);
        run_test("axi4_lite_test");
    end
endmodule
