interface spi_if (
    input logic clk
);
    logic       rst;
    logic       start;
    logic [7:0] clk_div;
    logic [7:0] master_tx_data;
    logic [7:0] master_rx_data;
    logic       master_done;
    logic [7:0] slave_tx_data;
    logic [7:0] slave_rx_data;
    logic       slave_done;

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output rst;
        output start;
        output master_tx_data;
        input  master_rx_data;
        input  master_done;
        output slave_tx_data;
        input  slave_rx_data;
        input  slave_done;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst;
        input start;
        input master_tx_data;
        input master_rx_data;
        input master_done;
        input slave_tx_data;
        input slave_rx_data;
        input slave_done;
    endclocking

    modport DRV(clocking drv_cb, input clk);
    modport MON(clocking mon_cb, input clk);
endinterface
