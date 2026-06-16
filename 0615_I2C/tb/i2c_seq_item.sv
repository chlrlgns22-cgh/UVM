class i2c_seq_item extends uvm_sequence_item;

    rand logic [6:0] addr;          // 슬레이브 주소
    rand logic       rw;            // 0=WRITE, 1=READ
    rand logic [7:0] wdata;         // WRITE 시 전송 데이터
    rand logic [7:0] slave_resp;    // READ 시 슬레이브가 보낼 데이터 (BFM 설정용)
    logic      [7:0] rdata;         // READ 시 master가 수신한 데이터 (관측)
    logic            addr_acked;    // 주소 ACK 수신 여부 (1=ACK, 0=NACK)

    // 주소를 슬레이브 주소로 고정
    constraint c_addr { addr == 7'h50; }

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(addr,       UVM_ALL_ON)
        `uvm_field_int(rw,         UVM_ALL_ON)
        `uvm_field_int(wdata,      UVM_ALL_ON)
        `uvm_field_int(slave_resp, UVM_ALL_ON)
        `uvm_field_int(rdata,      UVM_ALL_ON)
        `uvm_field_int(addr_acked, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        if (!rw)
            return $sformatf("WRITE addr=0x%02h data=0x%02h ack=%0b",
                             addr, wdata, addr_acked);
        else
            return $sformatf("READ  addr=0x%02h slave_resp=0x%02h rdata=0x%02h ack=%0b",
                             addr, slave_resp, rdata, addr_acked);
    endfunction
endclass
