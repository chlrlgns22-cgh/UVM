simSetSimulator "-vcssv" -exec "./simv" -args
debImport "-dbdir" "./simv.daidir"
debLoadSimResult /home/pedu34/workspace/260604_adder/wave.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "942" "334" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "tb_adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_adder" -win $_nTrace1
srcHBDrag -win $_nTrace1
wvSetCursor -win $_nWave2 1306.154910
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 3641.867220
wvSetCursor -win $_nWave2 3549.668050
wvSetCursor -win $_nWave2 3319.170124
wvSetCursor -win $_nWave2 2812.074689
wvZoom -win $_nWave2 1936.182573 2412.544952
wvSetCursor -win $_nWave2 2039.625026
wvPrevView -win $_nWave2
wvSetCursor -win $_nWave2 2612.309820
wvSetCursor -win $_nWave2 2935.006916
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
srcHBDrag -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSetPosition -win $_nWave2 {("tb_adder" 0)}
wvRenameGroup -win $_nWave2 {G1} {tb_adder}
wvSelectGroup -win $_nWave2 {tb_adder}
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSelectGroup -win $_nWave2 {tb_adder}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
srcHBSelect "tb_adder.adder" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcSetScope "tb_adder.adder" -delim "." -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcSetScope "tb_adder.adder" -delim "." -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcHBSelect "tb_adder" -win $_nTrace1
srcSetScope "tb_adder" -delim "." -win $_nTrace1
srcHBSelect "tb_adder" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_adder"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_adder/a\[7:0\]} -height 16 \
{/tb_adder/b\[7:0\]} -height 16 \
{/tb_adder/y\[8:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvGetSignalClose -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 66998.063624 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 81288.934993 -snap {("G2" 0)}
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
verdiDockWidgetSetCurTab -dock windowDock_OneSearch
verdiSetActWin -win $_OneSearch
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
srcTBAddBrkPnt -line 2 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
verdiSetActWin -win $_nWave2
wvSetCursor -win $_nWave2 2342.161139 -snap {("G1" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 1 2 3 )} 
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 0)}
srcTBObjectBrowserSort -column 0 -descending
verdiSetActWin -dock widgetDock_<Object._Tree>
verdiDockWidgetSetCurTab -dock widgetDock_<Stack>
verdiDockWidgetSetCurTab -dock widgetDock_<Inst._Tree>
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
verdiDockWidgetSetCurTab -dock widgetDock_<Stack>
verdiDockWidgetSetCurTab -dock widgetDock_<Class._Tree>
verdiSetActWin -dock widgetDock_<Class._Tree>
verdiDockWidgetSetCurTab -dock widgetDock_<Object._Tree>
verdiSetActWin -dock widgetDock_<Object._Tree>
verdiDockWidgetSetCurTab -dock widgetDock_<Inst._Tree>
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBDrag -win $_nTrace1
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvDumpScope "tb_adder.adder"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1/adder" 0)}
wvAddSubGroup -win $_nWave2 -holdpost {adder}
wvAddSignal -win $_nWave2 "/tb_adder/adder/a\[7:0\]" "/tb_adder/adder/b\[7:0\]" \
           "/tb_adder/adder/y\[8:0\]"
wvSetPosition -win $_nWave2 {("G1/adder" 0)}
wvSetPosition -win $_nWave2 {("G1/adder" 3)}
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
srcTBRunSim
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G1/adder" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1/adder" 1 2 3 )} 
wvSelectSignal -win $_nWave2 {( "G1/adder" 1 2 3 )} 
wvSetRadix -win $_nWave2 -format UDec
wvSetCursor -win $_nWave2 41361.588969 -snap {("G2" 0)}
srcHBSelect "tb_adder.adder" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcHBSelect "tb_adder.adder" -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBAddBrkPnt -line 18 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBSetBrkPnt -disable -index 1
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBSetBrkPnt -delete -index 1
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBAddBrkPnt -line 18 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBSetBrkPnt -disable -index 2
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBSetBrkPnt -delete -index 2
srcSelect -win $_nTrace1 -range {19 19 1 8 1 1}
srcTBAddBrkPnt -line 19 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBAddBrkPnt -line 18 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
srcSelect -win $_nTrace1 -range {19 19 1 8 1 1}
srcTBSetBrkPnt -disable -index 3
srcSelect -win $_nTrace1 -range {19 19 1 8 1 1}
srcTBSetBrkPnt -delete -index 3
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBSetBrkPnt -disable -index 4
srcSelect -win $_nTrace1 -range {18 18 1 8 1 1}
srcTBSetBrkPnt -delete -index 4
srcSelect -win $_nTrace1 -range {24 24 1 8 1 1}
srcTBAddBrkPnt -line 24 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
srcTBSimReset
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "b" -line 19 -pos 1 -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -signal "a" -line 18 -pos 1 -win $_nTrace1
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_adder.a\[7:0\]"
srcDeselectAll -win $_nTrace1
srcSelect -signal "b" -line 19 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 0)}
srcTBInsertDataTree -win $_nTrace1 -tab 1 -tree "tb_adder.b\[7:0\]"
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
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
srcTBStepNext
wvZoomAll -win $_nWave2
verdiSetActWin -win $_nWave2
verdiDockWidgetSetCurTab -dock widgetDock_<Message>
verdiSetActWin -dock widgetDock_<Message>
verdiDockWidgetSetCurTab -dock windowDock_InteractiveConsole_3
verdiSetActWin -win $_InteractiveConsole_3
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
verdiSetActWin -win $_nWave2
srcSelect -win $_nTrace1 -range {24 24 1 8 1 1}
srcTBSetBrkPnt -disable -index 1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_<Member>
wvSetCursor -win $_nWave2 41102.954695 -snap {("G2" 0)}
verdiSetActWin -win $_nWave2
wvZoomAll -win $_nWave2
srcSelect -win $_nTrace1 -range {25 25 1 8 1 1}
srcTBAddBrkPnt -line 25 -file /home/pedu34/workspace/260604_adder/tb_adder.sv
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {25 25 1 8 1 1}
srcTBSetBrkPnt -disable -index 2
srcSelect -win $_nTrace1 -range {25 25 1 8 1 1}
srcTBSetBrkPnt -delete -index 2
srcSelect -win $_nTrace1 -range {24 24 1 8 1 1}
srcTBSetBrkPnt -delete -index 1
srcDeselectAll -win $_nTrace1
debExit
