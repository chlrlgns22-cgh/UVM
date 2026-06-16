import uvm_pkg::*;
import i2c_pkg::*;

module tb_top ();
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;

    wire sda;
    pullup (sda);  // I2C 오픈드레인 풀업 저항 모델

    i2c_if m_if (.clk(clk));

    i2c_master_top dut (
        .clk      (m_if.clk),
        .rst      (m_if.rst),
        .cmd_start(m_if.cmd_start),
        .cmd_write(m_if.cmd_write),
        .cmd_read (m_if.cmd_read),
        .cmd_stop (m_if.cmd_stop),
        .tx_data  (m_if.tx_data),
        .rx_data  (m_if.rx_data),
        .ack_in   (m_if.ack_in),
        .ack_out  (m_if.ack_out),
        .busy     (m_if.busy),
        .done     (m_if.done),
        .scl      (m_if.scl),
        .sda      (sda)
    );

    i2c_slave_bfm #(.SLAVE_ADDR(7'h50)) u_slave (
        .rst           (m_if.rst),
        .sda           (sda),
        .scl           (m_if.scl),
        .slave_tx_data (m_if.slave_tx_data)
    );

    initial begin
        uvm_config_db#(virtual i2c_if)::set(null, "", "m_if", m_if);
        run_test("i2c_random_test");
    end

    initial begin
        $fsdbDumpfile("i2c_tb_fsdb");
        $fsdbDumpvars(0);
    end
endmodule
