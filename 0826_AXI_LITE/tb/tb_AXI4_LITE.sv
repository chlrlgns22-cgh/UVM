`include "uvm_macros.svh"
import uvm_pkg::*;

interface axi4_lite_intf;

endinterface

class axi4_lite_seq_item extends uvm_sequence_item;

endclass

class axi4_lite_seq extends uvm_sequence;

endclass
class axi4_lite_drv extends uvm_driver;

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
    axi4_lite_intf axi4_lite_if();


    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0);
    end

    initial begin
        uvm_config_db#(virtual axi4_lite_intf)::set(null, "*", "axi4_lite_if",axi4_lite_if);
        run_test("axi4_lite_test");
    end
endmodule