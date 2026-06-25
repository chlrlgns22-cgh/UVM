import uvm_pkg::*;
import i2c_pkg::*;

module tb_top ();
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;

    // I2C 오픈드레인 버스: pullup + master/slave 모두 드라이브 가능
    wire  sda;
    logic slave_sda_o;
    pullup (sda);
    assign sda = slave_sda_o ? 1'bz : 1'b0;  // slave 오픈드레인 구동

    i2c_if m_if (.clk(clk));

    // ── DUT: I2C Master ──────────────────────────────────────────
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
        .sda      (sda)           // i2c_master_top 내부에서 오픈드레인 처리
    );

    // ── Slave RTL: I2C Slave (SLAVE_ADDR=7'h12) ──────────────────
    i2c_slave #(.SLAVE_ADDR(7'h12)) u_slave (
        .clk       (m_if.clk),
        .rst       (m_if.rst),
        .scl       (m_if.scl),
        .sda_i     (sda),
        .sda_o     (slave_sda_o),
        .tx_data   (m_if.slave_tx_data),   // driver가 READ 전 설정
        .rx_data   (m_if.slave_rx_data),   // monitor가 WRITE 후 확인
        .done      (m_if.slave_done),
        .read_start(),
        .read_next ()
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
