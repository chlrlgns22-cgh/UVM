class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)

    spi_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
endclass


class spi_random_test extends spi_base_test;
    `uvm_component_utils(spi_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_random_seq seq;

        phase.raise_objection(this);

        seq = spi_random_seq::type_id::create("seq");
        seq.num = 20;
        seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass


class spi_directed_test extends spi_base_test;
    `uvm_component_utils(spi_directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_directed_seq seq;

        phase.raise_objection(this);

        seq = spi_directed_seq::type_id::create("seq");
        seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass


class spi_full_cov_test extends spi_base_test;
    `uvm_component_utils(spi_full_cov_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        spi_directed_seq d_seq;
        spi_random_seq   r_seq;

        phase.raise_objection(this);

        // 1) directed_seq 먼저 실행 -> cx_m_s 코너(0/0, FF/FF, 0/FF, FF/0) 보장
        d_seq = spi_directed_seq::type_id::create("d_seq");
        d_seq.start(env.agt.sqr);

        // 2) 나머지 12개 cross bin은 random_seq 로 채움
        r_seq = spi_random_seq::type_id::create("r_seq");
        r_seq.num = 5000;
        r_seq.start(env.agt.sqr);

        #100;
        phase.drop_objection(this);
    endtask
endclass