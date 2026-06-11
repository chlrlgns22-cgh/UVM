simSetSimulator "-vcssv" -exec "simv" -args \
           "+UVM_TESTNAME=ram_random_test +UVM_VERBOSITY=UVM_MEDIUM +ntb_random_seed=1 -cm line+cond+fsm+tgl+branch+assert -cm_dir coverage.vdb -cm_name sim1"
debImport "-dbdir" "simv.daidir/" "-fdNum" "37"
debLoadSimResult /home/pedu34/workspace/0610_ram/ram_tb.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "942" "334" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBDrag -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSetPosition -win $_nWave2 {("r_if(ram_if)" 0)}
wvRenameGroup -win $_nWave2 {G1} {r_if(ram_if)}
wvAddSignal -win $_nWave2 "/tb_top/r_if/clk" "/tb_top/r_if/write" \
           "/tb_top/r_if/addr\[7:0\]" "/tb_top/r_if/wdata\[7:0\]" \
           "/tb_top/r_if/rdata\[7:0\]"
wvSetPosition -win $_nWave2 {("r_if(ram_if)" 0)}
wvSetPosition -win $_nWave2 {("r_if(ram_if)" 5)}
wvSetPosition -win $_nWave2 {("r_if(ram_if)" 5)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
