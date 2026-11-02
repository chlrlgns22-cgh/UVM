interface can_rx_if (
    input clk
);
    logic        resetn;
    logic        sw_reset;
    logic        rx_frame_done;
    logic [10:0] rx_id;
    logic [ 3:0] rx_dlc;
    logic [63:0] rx_data;
    logic        rx_rtr;
    logic        rx_ide;

    clocking mon_cb @(posedge clk);
        default input #1step;
        input resetn;
        input sw_reset;
        input rx_frame_done;
        input rx_id;
        input rx_dlc;
        input rx_data;
        input rx_rtr;
        input rx_ide;
    endclocking

    modport MON(clocking mon_cb, input clk);
endinterface
