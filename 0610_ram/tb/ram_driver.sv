class ram_driver extends uvm_driver #(ram_seq_item);
    `uvm_component_utils(ram_driver)

    virtual ram_if r_if;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual ram_if)::get(this, "", "r_if", r_if))
            `uvm_fatal(get_type_name(), "virtual interface(vif)를 config_db에서 찾지 못함.")
    endfunction

    task run_phase(uvm_phase phase);
        r_if.drv_cb.write <= 1'b0;
        r_if.drv_cb.addr  <= 0;
        r_if.drv_cb.wdata <= 0;
        forever begin
            seq_item_port.get_next_item(req);  //req = request
            `uvm_info("driver",$sformatf("get_next_item: %s",req.convert2string()),UVM_DEBUG)
            @(r_if.drv_cb);  // interface의 clocking block 기능을 사용

            r_if.drv_cb.write <= req.write;
            r_if.drv_cb.addr  <= req.addr;
            r_if.drv_cb.wdata <= req.wdata;

            `uvm_info(get_type_name(), $sformatf("구동 %s", req.convert2string()), UVM_HIGH)

            seq_item_port.item_done();
        end
    endtask  //run_phase
endcl