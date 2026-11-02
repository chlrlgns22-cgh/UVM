interface can_tx_if (
    input logic clk
);
    logic        resetn;
    logic        sw_reset;
    logic [10:0] tx_id;
    logic [ 3:0] tx_dlc;
    logic [63:0] tx_data;
    logic        tx_valid;
    logic        tx_rtr;
    logic        tx_ide;
    logic        tx_ready;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        input tx_ready;

        output resetn;
        output sw_reset;
        output tx_id;
        output tx_dlc;
        output tx_data;
        output tx_valid;
        output tx_rtr;
        output tx_ide;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input resetn;
        input sw_reset;
        input tx_id;
        input tx_dlc;
        input tx_data;
        input tx_rtr;
        input tx_ide;
        input tx_valid;
        input tx_ready;
    endclocking

    modport DRV(clocking drv_cb, input clk);
    modport MON(clocking mon_cb, input clk);
endinterface
