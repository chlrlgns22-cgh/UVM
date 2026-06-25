class gpio_agent extends uvm_agent;
    `uvm_component_utils(gpio_agent)

    gpio_driver  drv;
    gpio_monitor mon;
    uvm_sequencer #(gpio_seq_item) sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = gpio_driver ::type_id::create("drv", this);
        mon = gpio_monitor::type_id::create("mon", this);
        sqr = uvm_sequencer #(gpio_seq_item)::type_id::create("sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass
