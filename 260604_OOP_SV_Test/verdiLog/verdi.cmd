simSetSimulator "-vcssv" -exec "./simv" -args
debImport "-dbdir" "./simv.daidir"
wvCreateWindow
wvOpenFile -win $_nWave2 {/home/pedu34/workspace/260604_OOP_SV_Test/wave.fsdb}
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "942" "334" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiSetActWin -dock widgetDock_<Watch>
srcHBSelect "tb_ram.ram_if" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
verdiSetActWin -dock widgetDock_<Watch>
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
srcHBSelect "tb_ram.ram_dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBDrag -win $_nTrace1
wvDumpScope "tb_ram.ram_dut"
wvSetPosition -win $_nWave2 {("ram_dut" 0)}
wvRenameGroup -win $_nWave2 {G1} {ram_dut}
wvAddSignal -win $_nWave2 "/tb_ram/ram_dut/clk" "/tb_ram/ram_dut/we" \
           "/tb_ram/ram_dut/addr\[7:0\]" "/tb_ram/ram_dut/wdata\[7:0\]" \
           "/tb_ram/ram_dut/rdata\[7:0\]"
wvSetPosition -win $_nWave2 {("ram_dut" 0)}
wvSetPosition -win $_nWave2 {("ram_dut" 5)}
wvSetPosition -win $_nWave2 {("ram_dut" 5)}
srcTBRunSim
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 13853560.143198 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 13901999.164678 -snap {("G2" 0)}
wvSelectGroup -win $_nWave2 {G2}
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoom -win $_nWave2 9987520.741348 10714106.063544
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 99710.396244 -snap {("G2" 0)}
srcSelect -win $_nTrace1 -range {57 57 1 3 1 1}
srcTBAddBrkPnt -line 57 -file /home/pedu34/workspace/260604_OOP_SV_Test/tb_ram.sv
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {69 69 1 5 1 1}
srcTBAddBrkPnt -line 69 -file /home/pedu34/workspace/260604_OOP_SV_Test/tb_ram.sv
srcSelect -win $_nTrace1 -range {117 117 1 11 1 1}
srcTBAddBrkPnt -line 117 -file \
           /home/pedu34/workspace/260604_OOP_SV_Test/tb_ram.sv
srcSelect -win $_nTrace1 -range {117 117 1 11 1 1}
srcTBSetBrkPnt -disable -index 1
srcSelect -win $_nTrace1 -range {117 117 1 11 1 1}
srcTBSetBrkPnt -delete -index 1
srcSelect -win $_nTrace1 -range {117 117 1 11 1 1}
srcTBAddBrkPnt -line 117 -file \
           /home/pedu34/workspace/260604_OOP_SV_Test/tb_ram.sv
srcSelect -win $_nTrace1 -range {117 117 1 11 1 1}
srcTBSetBrkPnt -disable -index 2
srcSelect -win $_nTrace1 -range {117 117 1 11 1 1}
srcTBSetBrkPnt -delete -index 2
srcSelect -win $_nTrace1 -range {119 119 1 2 1 1}
srcTBAddBrkPnt -line 119 -file \
           /home/pedu34/workspace/260604_OOP_SV_Test/tb_ram.sv
srcSelect -win $_nTrace1 -range {118 118 1 15 1 1}
srcTBAddBrkPnt -line 118 -file \
           /home/pedu34/workspace/260604_OOP_SV_Test/tb_ram.sv
srcSelect -win $_nTrace1 -range {118 118 1 15 1 1}
srcTBSetBrkPnt -disable -index 3
srcTBRunSim
srcTBSimBreak
srcTBRunSim
srcTBSimBreak
srcTBSimReset
srcTBStepNext
srcDeselectAll -win $_nTrace1
srcSelect -word -line 116 -pos 1 -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_ram.IU"
verdiSetActWin -dock widgetDock_<Watch>
srcTBDeleteDataTree -win $_nTrace1 -tab 1 -tree "IU"
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 95.465394 -snap {("ram_dut" 2)}
wvSetCursor -win $_nWave2 0.000000 -snap {("ram_dut" 2)}
wvSelectSignal -win $_nWave2 {( "ram_dut" 3 )} 
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomAll -win $_nWave2
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
debExit
