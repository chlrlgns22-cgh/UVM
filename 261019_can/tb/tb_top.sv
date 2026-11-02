`timescale 1ns / 1ps
import uvm_pkg::*;
import can_pkg::*;

module tb_top;
    logic clk;

    initial clk = 1'b0;
    always #6.25 clk = ~clk;

    can_tx_if tx_if (.clk(clk));
    can_rx_if rx_if (.clk(clk));

    assign rx_if.resetn   = tx_if.resetn;
    assign rx_if.sw_reset = tx_if.sw_reset;

    localparam [7:0] BRP = 8'd9;
    localparam [7:0] TSEG1 = 8'd13;
    localparam [7:0] TSEG2 = 8'd2;
    localparam [7:0] SJW = 8'd1;

    wire tx_a;
    wire tx_b;
    wire can_bus;

    assign can_bus = tx_a & tx_b;

    can_controller dut (
        .clk(clk),
        .resetn(tx_if.resetn),
        .axi_lite_sw_reset_can_controller(tx_if.sw_reset),

        .axi_lite_brp_can_bit_timing  (BRP),
        .axi_lite_tseg1_can_bit_timing(TSEG1),
        .axi_lite_tseg2_can_bit_timing(TSEG2),
        .axi_lite_sjw_can_bit_timing  (SJW),

        // input from cpu
        .axi_lite_tx_id_can_tx   (tx_if.tx_id),
        .axi_lite_tx_valid_can_tx(tx_if.tx_valid),
        .axi_lite_tx_rtr_can_tx  (tx_if.tx_rtr),
        .axi_lite_tx_ide_can_tx  (tx_if.tx_ide),
        .axi_lite_tx_dlc_can_tx  (tx_if.tx_dlc),
        .axi_lite_tx_data_can_tx (tx_if.tx_data),

        // output to cpu
        .can_tx_bus_off_flag_axi_lite       (),
        .can_tx_tx_error_state_flag_axi_lite(),
        .can_tx_tx_ready_axi_lite           (tx_if.tx_ready),
        .can_tx_tec_axi_lite                (),
        .can_tx_last_error_state_axi_lite   (),
        .can_tx_sticky_peak_tec_axi_lite    (),
        .can_tx_sticky_error_state_axi_lite (),
        .can_tx_sticky_bus_off_axi_lite     (),

        // output to axi_lite
        .can_rx_frame_done_axi_lite(),
        .can_rx_rx_id_axi_lite     (),
        .can_rx_rx_dlc_axi_lite    (),
        .can_rx_rx_data_axi_lite   (),
        .can_rx_rx_rtr_axi_lite    (),
        .can_rx_rx_ide_axi_lite    (),

        .rx(can_bus),
        .tx(tx_a)
    );

    can_controller dut2 (
        .clk(clk),
        .resetn(tx_if.resetn),
        .axi_lite_sw_reset_can_controller(tx_if.sw_reset),

        .axi_lite_brp_can_bit_timing  (BRP),
        .axi_lite_tseg1_can_bit_timing(TSEG1),
        .axi_lite_tseg2_can_bit_timing(TSEG2),
        .axi_lite_sjw_can_bit_timing  (SJW),

        // input from cpu
        .axi_lite_tx_id_can_tx   (11'b0),
        .axi_lite_tx_valid_can_tx(1'b0),
        .axi_lite_tx_rtr_can_tx  (1'b0),
        .axi_lite_tx_ide_can_tx  (1'b0),
        .axi_lite_tx_dlc_can_tx  (4'b0),
        .axi_lite_tx_data_can_tx (64'b0),

        // output to cpu
        .can_tx_bus_off_flag_axi_lite       (),
        .can_tx_tx_error_state_flag_axi_lite(),
        .can_tx_tx_ready_axi_lite           (),
        .can_tx_tec_axi_lite                (),
        .can_tx_last_error_state_axi_lite   (),
        .can_tx_sticky_peak_tec_axi_lite    (),
        .can_tx_sticky_error_state_axi_lite (),
        .can_tx_sticky_bus_off_axi_lite     (),

        // output to axi_lite
        .can_rx_frame_done_axi_lite(rx_if.rx_frame_done),
        .can_rx_rx_id_axi_lite     (rx_if.rx_id),
        .can_rx_rx_dlc_axi_lite    (rx_if.rx_dlc),
        .can_rx_rx_data_axi_lite   (rx_if.rx_data),
        .can_rx_rx_rtr_axi_lite    (rx_if.rx_rtr),
        .can_rx_rx_ide_axi_lite    (rx_if.rx_ide),

        .rx(can_bus),
        .tx(tx_b)
    );

    initial begin
        uvm_config_db#(virtual can_tx_if)::set(null, "*", "tx_if", tx_if);
        uvm_config_db#(virtual can_rx_if)::set(null, "*", "rx_if", rx_if);

        run_test("can_test");
    end
endmodule
