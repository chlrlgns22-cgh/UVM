interface gpio_if #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
)(
    input logic aclk
);
    logic                       aresetn;

    // Write Address Channel
    logic [ADDR_WIDTH-1:0]      awaddr;
    logic [2:0]                 awprot;
    logic                       awvalid;
    logic                       awready;

    // Write Data Channel
    logic [DATA_WIDTH-1:0]      wdata;
    logic [(DATA_WIDTH/8)-1:0]  wstrb;
    logic                       wvalid;
    logic                       wready;

    // Write Response Channel
    logic [1:0]                 bresp;
    logic                       bvalid;
    logic                       bready;

    // Read Address Channel
    logic [ADDR_WIDTH-1:0]      araddr;
    logic [2:0]                 arprot;
    logic                       arvalid;
    logic                       arready;

    // Read Data Channel
    logic [DATA_WIDTH-1:0]      rdata;
    logic [1:0]                 rresp;
    logic                       rvalid;
    logic                       rready;

    // GPIO 외부 핀 제어 (TB가 입력 모드 핀을 구동)
    logic [7:0]                 io_port_tb;     // TB가 구동할 핀 값
    logic [7:0]                 io_port_tb_en;  // 구동 인에이블 (1=TB 구동, 0=Hi-Z)

    clocking drv_cb @(posedge aclk);
        default input #1step output #0;
        // AXI master 출력 (TB → DUT)
        output aresetn;
        output awaddr, awprot, awvalid;
        output wdata, wstrb, wvalid;
        output bready;
        output araddr, arprot, arvalid;
        output rready;
        output io_port_tb, io_port_tb_en;
        // AXI slave 응답 (DUT → TB)
        input  awready;
        input  wready;
        input  bresp, bvalid;
        input  arready;
        input  rdata, rresp, rvalid;
    endclocking

    clocking mon_cb @(posedge aclk);
        default input #1step;
        input aresetn;
        input awaddr, awprot, awvalid, awready;
        input wdata, wstrb, wvalid, wready;
        input bresp, bvalid, bready;
        input araddr, arprot, arvalid, arready;
        input rdata, rresp, rvalid, rready;
        input io_port_tb, io_port_tb_en;
    endclocking

    modport DRV(clocking drv_cb, input aclk);
    modport MON(clocking mon_cb, input aclk);
endinterface
