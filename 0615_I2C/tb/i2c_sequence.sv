class i2c_base_seq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_base_seq)

    function new(string name = "i2c_base_seq");
        super.new(name);
    endfunction

    task do_write(bit [6:0] addr, bit [7:0] data);
        i2c_seq_item item = i2c_seq_item::type_id::create("item");
        start_item(item);
        item.addr  = addr;
        item.rw    = 1'b0;
        item.wdata = data;
        finish_item(item);
    endtask

    task do_read(bit [6:0] addr, bit [7:0] slave_data);
        i2c_seq_item item = i2c_seq_item::type_id::create("item");
        start_item(item);
        item.addr     = addr;
        item.rw       = 1'b1;
        item.slave_tx = slave_data;
        finish_item(item);
    endtask
endclass


class i2c_random_seq extends i2c_base_seq;
    `uvm_object_utils(i2c_random_seq)

    rand int num;
    constraint c_num { num inside {[10:30]}; }

    function new(string name = "i2c_random_seq");
        super.new(name);
    endfunction

    task body();
        i2c_seq_item item;
        `uvm_info(get_type_name(), $sformatf("I2C 랜덤 시나리오 시작 (%0d회)", num), UVM_LOW)
        repeat (num) begin
            item = i2c_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_error("SEQ", "randomize 실패")
            finish_item(item);
        end
        `uvm_info(get_type_name(), "I2C 랜덤 시나리오 종료.", UVM_LOW)
    endtask
endclass


class i2c_directed_seq extends i2c_base_seq;
    `uvm_object_utils(i2c_directed_seq)

    function new(string name = "i2c_directed_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "I2C 지정 시나리오 시작", UVM_LOW)
        do_write(7'h12, 8'h00);   // 경계값 최솟값
        do_write(7'h12, 8'hFF);   // 경계값 최댓값
        do_write(7'h12, 8'hAA);   // 교번 패턴
        do_read (7'h12, 8'h00);   // READ 최솟값
        do_read (7'h12, 8'hFF);   // READ 최댓값
        do_read (7'h12, 8'h55);   // READ 교번 패턴
        `uvm_info(get_type_name(), "I2C 지정 시나리오 종료.", UVM_LOW)
    endtask
endclass
