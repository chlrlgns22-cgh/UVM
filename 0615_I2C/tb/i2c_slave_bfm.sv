// I2C Slave BFM: event-driven, open-drain SDA
// SLAVE_ADDR=7'h50, 단일 바이트 WRITE/READ 지원
module i2c_slave_bfm #(
    parameter [6:0] SLAVE_ADDR = 7'h50
)(
    input  wire        rst,
    inout  wire        sda,
    input  wire        scl,
    input  logic [7:0] slave_tx_data   // READ 시 master에게 보낼 데이터
);
    logic sda_en = 1'b0;       // 1=SDA를 0으로 구동 (open-drain)
    assign sda = sda_en ? 1'b0 : 1'bz;

    logic [7:0] shift_reg;
    logic       addr_match;
    logic       rw_bit;

    // ─── 메인 BFM 루프 ────────────────────────────────────────────────
    initial begin
        sda_en = 1'b0;
        wait (!rst);  // 리셋 해제 대기

        forever begin
            // START 조건 대기: SCL=1일 때 SDA 하강 에지
            @(negedge sda);
            if (!scl) continue;  // SCL이 낮으면 데이터 비트 전환 → 무시

            // 8비트 수신 (주소 7비트 + R/W 1비트)
            shift_reg = 8'h00;
            repeat (8) begin
                @(posedge scl);
                #1;  // SDA 안정화 대기
                shift_reg = {shift_reg[6:0], sda};
            end

            addr_match = (shift_reg[7:1] == SLAVE_ADDR);
            rw_bit     = shift_reg[0];  // 0=WRITE, 1=READ

            // 주소 ACK/NACK: SCL LOW 구간에서 SDA 구동
            @(negedge scl);
            sda_en = addr_match;  // 1=ACK(SDA 0), 0=NACK(SDA Z)
            @(posedge scl);       // master가 ACK 샘플링
            @(negedge scl);
            sda_en = 1'b0;        // SDA 해제

            if (!addr_match) continue;

            if (!rw_bit) begin
                // ── WRITE 트랜잭션: 데이터 1바이트 수신 ──────────────
                shift_reg = 8'h00;
                repeat (8) begin
                    @(posedge scl);
                    #1;
                    shift_reg = {shift_reg[6:0], sda};
                end
                // 데이터 ACK
                @(negedge scl);
                sda_en = 1'b1;  // ACK
                @(posedge scl);
                @(negedge scl);
                sda_en = 1'b0;
            end else begin
                // ── READ 트랜잭션: 데이터 1바이트 전송 ───────────────
                // SCL이 이미 LOW인 상태에서 MSB부터 구동
                for (int i = 7; i >= 0; i--) begin
                    sda_en = ~slave_tx_data[i];  // bit=1→Z(pullup high), bit=0→0
                    @(posedge scl);  // master 샘플링
                    @(negedge scl);  // 다음 비트 준비
                end
                sda_en = 1'b0;  // SDA 해제 (master가 ACK/NACK 구동)
                @(posedge scl);  // master의 ACK/NACK 수신
                @(negedge scl);
            end
            // STOP 또는 다음 START를 기다리며 루프 재시작
        end
    end
endmodule
