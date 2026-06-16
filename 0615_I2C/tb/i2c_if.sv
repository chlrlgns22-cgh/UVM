interface i2c_if (
    input logic clk
);
    logic       rst;
    logic       cmd_start;
    logic       cmd_write;
    logic       cmd_read;
    logic       cmd_stop;
    logic [7:0] tx_data;
    logic       ack_in;
    logic [7:0] rx_data;
    logic       ack_out;
    logic       busy;
    logic       done;
    logic       scl;
    logic [7:0] slave_tx_data;  // BFM read data (driver sets before READ)

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output rst;
        output cmd_start;
        output cmd_write;
        output cmd_read;
        output cmd_stop;
        output tx_data;
        output ack_in;
        output slave_tx_data;
        input  rx_data;
        input  ack_out;
        input  busy;
        input  done;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst;
        input cmd_start;
        input cmd_write;
        input cmd_read;
        input cmd_stop;
        input tx_data;
        input ack_in;
        input slave_tx_data;
        input rx_data;
        input ack_out;
        input busy;
        input done;
        input scl;
    endclocking

    modport DRV(clocking drv_cb, input clk);
    modport MON(clocking mon_cb, input clk);
endinterface
