class spi_base_seq extends uvm_sequence #(spi_seq_item);
    `uvm_object_utils(spi_base_seq)

    function new(string name = "spi_base_seq");
        super.new(name);
    endfunction

    task do_transfer(bit [7:0] m_tx, bit [7:0] s_tx);
        spi_seq_item item;
        item = spi_seq_item::type_id::create("item");
        start_item(item);
        item.master_tx_data = m_tx;
        item.slave_tx_data  = s_tx;
        finish_item(item);
    endtask
endclass


class spi_random_seq extends spi_base_seq;
    `uvm_object_utils(spi_random_seq)

    rand int num;
    constraint c_num { num inside {[10:30]}; }

    function new(string name = "spi_random_seq");
        super.new(name);
    endfunction

    task body();
        spi_seq_item item;
        `uvm_info(get_type_name(), $sformatf("SPI 랜덤 시나리오 시작 (%0d회)", num), UVM_LOW)

        repeat (num) begin
            item = spi_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_error("SEQ", "randomize 실패")
            finish_item(item);
        end

        `uvm_info(get_type_name(), "SPI 랜덤 시나리오 종료.", UVM_LOW)
    endtask
endclass


class spi_directed_seq extends spi_base_seq;
    `uvm_object_utils(spi_directed_seq)

    function new(string name = "spi_directed_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "SPI 지정 시나리오 시작", UVM_LOW)
        do_transfer(8'h00, 8'h00);  // 경계값: 최솟값
        do_transfer(8'hFF, 8'hFF);  // 경계값: 최댓값
        do_transfer(8'hAA, 8'h55);  // 교번 패턴
        do_transfer(8'h55, 8'hAA);
        do_transfer(8'h12, 8'h34);  // 임의 값
        `uvm_info(get_type_name(), "SPI 지정 시나리오 종료.", UVM_LOW)
    endtask
endclass
