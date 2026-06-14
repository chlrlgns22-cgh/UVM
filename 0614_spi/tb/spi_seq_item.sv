class spi_seq_item extends uvm_sequence_item;

    rand logic [7:0] master_tx_data;  // master → slave
    rand logic [7:0] slave_tx_data;   // slave  → master
    logic      [7:0] master_rx_data;  // master가 수신한 값 (관측)
    logic      [7:0] slave_rx_data;   // slave가  수신한 값 (관측)

    `uvm_object_utils_begin(spi_seq_item)
        `uvm_field_int(master_tx_data, UVM_ALL_ON)
        `uvm_field_int(slave_tx_data,  UVM_ALL_ON)
        `uvm_field_int(master_rx_data, UVM_ALL_ON)
        `uvm_field_int(slave_rx_data,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "spi_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "M->S: tx=0x%02h rx=0x%02h | S->M: tx=0x%02h rx=0x%02h",
            master_tx_data, slave_rx_data, slave_tx_data, master_rx_data
        );
    endfunction
endclass
