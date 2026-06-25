import uvm_pkg::*;
import gpio_pkg::*;

module tb_top ();
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    gpio_if m_if (.aclk(clk));

    // io_port tri-state 버스
    // cr[i]=1 (출력) → DUT가 구동, cr[i]=0 (입력) → TB가 구동
    wire [7:0] io_port;

    genvar gi;
    generate
        for (gi = 0; gi < 8; gi++) begin : io_port_drive
            assign io_port[gi] = m_if.io_port_tb_en[gi]
                                  ? m_if.io_port_tb[gi]
                                  : 1'bz;
        end
    endgenerate

    // DUT 인스턴스
    gpio_v1_0 #(
        .C_S00_AXI_DATA_WIDTH(32),
        .C_S00_AXI_ADDR_WIDTH(4)
    ) dut (
        .io_port       (io_port),
        .s00_axi_aclk  (m_if.aclk),
        .s00_axi_aresetn(m_if.aresetn),
        .s00_axi_awaddr (m_if.awaddr),
        .s00_axi_awprot (m_if.awprot),
        .s00_axi_awvalid(m_if.awvalid),
        .s00_axi_awready(m_if.awready),
        .s00_axi_wdata  (m_if.wdata),
        .s00_axi_wstrb  (m_if.wstrb),
        .s00_axi_wvalid (m_if.wvalid),
        .s00_axi_wready (m_if.wready),
        .s00_axi_bresp  (m_if.bresp),
        .s00_axi_bvalid (m_if.bvalid),
        .s00_axi_bready (m_if.bready),
        .s00_axi_araddr (m_if.araddr),
        .s00_axi_arprot (m_if.arprot),
        .s00_axi_arvalid(m_if.arvalid),
        .s00_axi_arready(m_if.arready),
        .s00_axi_rdata  (m_if.rdata),
        .s00_axi_rresp  (m_if.rresp),
        .s00_axi_rvalid (m_if.rvalid),
        .s00_axi_rready (m_if.rready)
    );

    initial begin
        uvm_config_db#(virtual gpio_if)::set(null, "", "m_if", m_if);
        run_test("gpio_full_cov_test");
    end

    initial begin
        $fsdbDumpfile("gpio_tb_fsdb");
        $fsdbDumpvars(0);
    end
endmodule
