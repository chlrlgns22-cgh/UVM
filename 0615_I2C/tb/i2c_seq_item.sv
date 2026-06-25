class i2c_seq_item extends uvm_sequence_item;

    rand logic [6:0] addr;        // 슬레이브 주소
    rand logic       rw;          // 0=WRITE, 1=READ
    rand logic [7:0] wdata;       // WRITE 시 master가 전송할 데이터
    rand logic [7:0] slave_tx;    // READ 시 slave가 보낼 데이터 (driver가 slave_tx_data 설정)
    logic      [7:0] rdata;       // READ 시 master가 수신한 데이터 (관측)
    logic      [7:0] slave_rxd;   // WRITE 시 slave가 실제 수신한 데이터 (관측)
    logic            addr_acked;  // 주소 ACK 수신 여부 (1=ACK, 0=NACK)

    // 실제 슬레이브 주소로 고정 (i2c_slave SLAVE_ADDR=7'h12)
    constraint c_addr { addr == 7'h12; }

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(addr,       UVM_ALL_ON)
        `uvm_field_int(rw,         UVM_ALL_ON)
        `uvm_field_int(wdata,      UVM_ALL_ON)
        `uvm_field_int(slave_tx,   UVM_ALL_ON)
        `uvm_field_int(rdata,      UVM_ALL_ON)
        `uvm_field_int(slave_rxd,  UVM_ALL_ON)
        `uvm_field_int(addr_acked, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        if (!rw)
            return $sformatf("WRITE addr=0x%02h wdata=0x%02h slave_rxd=0x%02h ack=%0b",
                             addr, wdata, slave_rxd, addr_acked);
        else
            return $sformatf("READ  addr=0x%02h slave_tx=0x%02h master_rdata=0x%02h ack=%0b",
                             addr, slave_tx, rdata, addr_acked);
    endfunction
endclass
