class gpio_seq_item extends uvm_sequence_item;
    `uvm_object_utils_begin(gpio_seq_item)
        `uvm_field_int(cr_val,       UVM_ALL_ON)
        `uvm_field_int(odr_val,      UVM_ALL_ON)
        `uvm_field_int(io_drive,     UVM_ALL_ON)
        `uvm_field_int(idr_readback, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(odr_readback, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(bresp,        UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end

    // 드라이버 입력 (시퀀스가 설정)
    rand logic [7:0] cr_val;   // GPIO 방향 레지스터 (1=출력, 0=입력, 비트별)
    rand logic [7:0] odr_val;  // 출력 데이터 레지스터에 쓸 값
    rand logic [7:0] io_drive; // 입력 모드 핀에 TB가 구동할 외부 값

    // 관측 출력 (드라이버/모니터가 기록)
    logic [7:0] idr_readback;  // IDR 레지스터 읽기 결과
    logic [7:0] odr_readback;  // ODR 레지스터 읽기 결과 (write-readback)
    logic [1:0] bresp;         // 마지막 AXI 쓰기 응답

    function new(string name = "gpio_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "CR=0x%02h ODR_W=0x%02h IO_DRV=0x%02h | IDR_R=0x%02h ODR_R=0x%02h BRESP=%02b",
            cr_val, odr_val, io_drive, idr_readback, odr_readback, bresp);
    endfunction
endclass
