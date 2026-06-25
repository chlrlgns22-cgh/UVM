class gpio_base_test extends uvm_test;
    `uvm_component_utils(gpio_base_test)

    gpio_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = gpio_env::type_id::create("env", this);
    endfunction
endclass


class gpio_random_test extends gpio_base_test;
    `uvm_component_utils(gpio_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_random_seq seq;
        phase.raise_objection(this);
        seq = gpio_random_seq::type_id::create("seq");
        seq.num = 100;
        seq.start(env.agt.sqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass


class gpio_directed_test extends gpio_base_test;
    `uvm_component_utils(gpio_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_directed_seq seq;
        phase.raise_objection(this);
        seq = gpio_directed_seq::type_id::create("seq");
        seq.start(env.agt.sqr);
        #100;
        phase.drop_objection(this);
    endtask
endclass


class gpio_full_cov_test extends gpio_base_test;
    `uvm_component_utils(gpio_full_cov_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_directed_seq d_seq;
        gpio_random_seq   r_seq;

        phase.raise_objection(this);

        // 1) directed_seq: 경계값/코너 케이스 보장
        d_seq = gpio_directed_seq::type_id::create("d_seq");
        d_seq.start(env.agt.sqr);

        // 2) random_seq: 나머지 cross bin 채움
        r_seq = gpio_random_seq::type_id::create("r_seq");
        r_seq.num = 1000;
        r_seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass
