
class weapon;
    string name;
    function new(string name);
        this.name = name;
    endfunction  //new()

    virtual function void shot();
        $display("  [%s] ...  (무기 없음)", name);
    endfunction
endclass  //weapon

class M16 extends weapon;
    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual function void shot();
        $display("  [%s] 탕탕탕 !!!", name);
    endfunction
endclass  //M16 extends weapon

class K2 extends weapon;
    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual function void shot();
        $display("  [%s] 빵빵빵 !!!", name);
    endfunction
endclass  //M16 extends weapon

class AUG extends weapon;
    function new(string name);
        super.new(name);
    endfunction  //new()

    virtual function void shot();
        $display("  [%s] 삐~~익~~~~ 텅텅텅 !!!", name);
    endfunction
endclass  //M16 extends weapon


module tb_weapon ();
    initial begin
        weapon BlackPink = new("No Weapon");

        M16    m16 = new("M16");
        AUG    aug = new("AUG");
        K2     k2 = new("K2");

        $display("======= 다형성 데모 ======");
        BlackPink.shot();

        $display("======= 무기 M16으로 변경 ======");
        BlackPink = m16;
        BlackPink.shot();

        $display("======= 무기 AUG으로 변경 ======");
        BlackPink = aug;
        BlackPink.shot();

        $display("======= 무기 K2으로 변경 ======");
        BlackPink = k2;
        BlackPink.shot();
    end
endmodule
