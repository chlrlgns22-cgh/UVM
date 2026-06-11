class c_1_2;
    int num = 0;

    constraint c_num_this    // (constraint_mode = ON) (tb/ram_sequence.sv:33)
    {
       (num inside {[10:30]});
    }
endclass

program p_1_2;
    c_1_2 obj;
    string randState;

    initial
        begin
            obj = new;
            randState = "0zxxzx1zx1zz010x0z1011xx0zxzzx11zzzxxxxxzzzxzzxzxxxxzxzzzzzxzxzx";
            obj.set_randstate(randState);
            obj.randomize();
        end
endprogram
