import uvm_pkg::*;
import spi_pkg::*;

module tb_top ();
    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;

    spi_if s_if (.clk(clk));

    spi_uvm dut (
        .clk           (s_if.clk),
        .rst           (s_if.rst),
        .start         (s_if.start),
        .cpol          (1'b0),
        .cpha          (1'b0),
        .clk_div       (8'd24),
        .master_tx_data(s_if.master_tx_data),
        .master_busy   (),
        .master_rx_data(s_if.master_rx_data),
        .master_done   (s_if.master_done),
        .slave_tx_data (s_if.slave_tx_data),
        .slave_rx_data (s_if.slave_rx_data),
        .slave_busy    (),
        .slave_done    (s_if.slave_done)
    );

    initial begin
        uvm_config_db#(virtual spi_if)::set(null, "", "s_if", s_if);
        run_test("spi_full_cov_test");
    end

    initial begin
        $fsdbDumpfile("spi_tb_fsdb");
        $fsdbDumpvars(0);
    end
endmodule