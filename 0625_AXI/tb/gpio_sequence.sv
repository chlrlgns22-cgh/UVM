class gpio_base_seq extends uvm_sequence #(gpio_seq_item);
    `uvm_object_utils(gpio_base_seq)

    function new(string name = "gpio_base_seq");
        super.new(name);
    endfunction

    // 단일 GPIO 트랜잭션 헬퍼
    task do_gpio(logic [7:0] cr, logic [7:0] odr, logic [7:0] io_drv);
        gpio_seq_item item;
        item = gpio_seq_item::type_id::create("item");
        start_item(item);
        item.cr_val   = cr;
        item.odr_val  = odr;
        item.io_drive = io_drv;
        finish_item(item);
    endtask
endclass


class gpio_random_seq extends gpio_base_seq;
    `uvm_object_utils(gpio_random_seq)

    int unsigned num = 100;

    function new(string name = "gpio_random_seq");
        super.new(name);
    endfunction

    task body();
        gpio_seq_item item;
        `uvm_info(get_type_name(), $sformatf("GPIO 랜덤 시퀀스 시작 (%0d회)", num), UVM_LOW)
        repeat (num) begin
            item = gpio_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal(get_type_name(), "랜덤화 실패")
            finish_item(item);
        end
        `uvm_info(get_type_name(), "GPIO 랜덤 시퀀스 종료.", UVM_LOW)
    endtask
endclass


class gpio_directed_seq extends gpio_base_seq;
    `uvm_object_utils(gpio_directed_seq)

    function new(string name = "gpio_directed_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_type_name(), "GPIO 지정 시나리오 시작", UVM_LOW)

        // ── 전체 출력 모드 ──────────────────────────────────────────
        do_gpio(8'hFF, 8'h00, 8'h00);  // 전체 출력, ODR=0x00
        do_gpio(8'hFF, 8'hFF, 8'h00);  // 전체 출력, ODR=0xFF
        do_gpio(8'hFF, 8'h55, 8'h00);  // 전체 출력, ODR=0x55 (교번)
        do_gpio(8'hFF, 8'hAA, 8'h00);  // 전체 출력, ODR=0xAA (교번)

        // ── 전체 입력 모드 ──────────────────────────────────────────
        do_gpio(8'h00, 8'h00, 8'h00);  // 전체 입력, io_drive=0x00
        do_gpio(8'h00, 8'h00, 8'hFF);  // 전체 입력, io_drive=0xFF
        do_gpio(8'h00, 8'h00, 8'h55);  // 전체 입력, io_drive=0x55
        do_gpio(8'h00, 8'h00, 8'hAA);  // 전체 입력, io_drive=0xAA

        // ── 혼합 모드: cx_cr_odr 크로스 bin 완전 커버 ─────────────
        // CR=0xF0 (high_nibble_out) × ODR 경계값 4종
        do_gpio(8'hF0, 8'h00, 8'h0F);  // high_nibble_out × odr_zero
        do_gpio(8'hF0, 8'hFF, 8'h0F);  // high_nibble_out × odr_max
        do_gpio(8'hF0, 8'h55, 8'h0F);  // high_nibble_out × odr_55
        do_gpio(8'hF0, 8'hAA, 8'h0F);  // high_nibble_out × odr_aa
        do_gpio(8'hF0, 8'hA5, 8'h5A);  // high_nibble_out × odr_high (기존)

        // CR=0x0F (low_nibble_out) × ODR 경계값 4종
        do_gpio(8'h0F, 8'h00, 8'hF0);  // low_nibble_out × odr_zero
        do_gpio(8'h0F, 8'hFF, 8'hF0);  // low_nibble_out × odr_max
        do_gpio(8'h0F, 8'h55, 8'hF0);  // low_nibble_out × odr_55
        do_gpio(8'h0F, 8'hAA, 8'hF0);  // low_nibble_out × odr_aa
        do_gpio(8'h0F, 8'h5A, 8'hA5);  // low_nibble_out × odr_low (기존)

        // CR=0xAA (alternating_aa) × ODR 경계값 4종
        do_gpio(8'hAA, 8'h00, 8'h55);  // alternating_aa × odr_zero
        do_gpio(8'hAA, 8'hFF, 8'h55);  // alternating_aa × odr_max
        do_gpio(8'hAA, 8'h55, 8'hCC);  // alternating_aa × odr_55 (기존)
        do_gpio(8'hAA, 8'hAA, 8'h55);  // alternating_aa × odr_aa

        // CR=0x55 (alternating_55) × ODR 경계값 4종
        do_gpio(8'h55, 8'h00, 8'hAA);  // alternating_55 × odr_zero
        do_gpio(8'h55, 8'hFF, 8'hAA);  // alternating_55 × odr_max
        do_gpio(8'h55, 8'h55, 8'hAA);  // alternating_55 × odr_55
        do_gpio(8'h55, 8'hAA, 8'hAA);  // alternating_55 × odr_aa
        do_gpio(8'h55, 8'hCC, 8'h33);  // alternating_55 × odr_high (기존)

        `uvm_info(get_type_name(), "GPIO 지정 시나리오 종료.", UVM_LOW)
    endtask
endclass
