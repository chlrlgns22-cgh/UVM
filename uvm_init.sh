#!/bin/bash
# UVM 검증 환경 초기 파일 자동 생성 스크립트
# 사용법: ./uvm_init.sh <prefix> [target_dir]
# 예시 : ./uvm_init.sh uart ./0620_uart

set -e

PREFIX=$1
TARGET=${2:-.}   # 두 번째 인자 없으면 현재 디렉토리

if [[ -z "$PREFIX" ]]; then
    echo "사용법: $0 <prefix> [target_dir]"
    echo "예시 : $0 uart ./0620_uart"
    exit 1
fi

TB_DIR="$TARGET/tb"
mkdir -p "$TB_DIR"

# ──────────────────────────────────────────────────────────────
# 컴포넌트 목록 (pkg.sv include 순서)
# ──────────────────────────────────────────────────────────────
COMPONENTS=(
    "${PREFIX}_seq_item"
    "${PREFIX}_sequence"
    "${PREFIX}_driver"
    "${PREFIX}_monitor"
    "${PREFIX}_agent"
    "${PREFIX}_scoreboard"
    "${PREFIX}_coverage"
    "${PREFIX}_env"
    "${PREFIX}_test"
)

# ── 빈 컴포넌트 파일 생성 ──────────────────────────────────────
for COMP in "${COMPONENTS[@]}"; do
    FILE="$TB_DIR/${COMP}.sv"
    if [[ -f "$FILE" ]]; then
        echo "  [SKIP] $FILE (이미 존재)"
    else
        touch "$FILE"
        echo "  [NEW ] $FILE"
    fi
done

# ── 인터페이스 템플릿 생성 ────────────────────────────────────
IF_FILE="$TB_DIR/${PREFIX}_if.sv"
if [[ ! -f "$IF_FILE" ]]; then
cat > "$IF_FILE" << EOF
interface ${PREFIX}_if (
    input logic clk
);
    logic rst;
    // TODO: DUT 신호 추가

    clocking drv_cb @(posedge clk);
        default input #1step output #0;
        output rst;
        // TODO: output (TB → DUT)
        // TODO: input  (DUT → TB)
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst;
        // TODO: input (관측 신호)
    endclocking

    modport DRV(clocking drv_cb, input clk);
    modport MON(clocking mon_cb, input clk);
endinterface
EOF
    echo "  [NEW ] $IF_FILE"
else
    echo "  [SKIP] $IF_FILE (이미 존재)"
fi

# ── pkg.sv 생성 (include 순서 자동 구성) ─────────────────────
PKG_FILE="$TB_DIR/${PREFIX}_pkg.sv"
if [[ ! -f "$PKG_FILE" ]]; then
{
    echo "package ${PREFIX}_pkg;"
    echo "    import uvm_pkg::*;"
    echo "    \`include \"uvm_macros.svh\""
    echo ""
    for COMP in "${COMPONENTS[@]}"; do
        echo "    \`include \"${COMP}.sv\""
    done
    echo ""
    echo "endpackage"
} > "$PKG_FILE"
    echo "  [NEW ] $PKG_FILE"
else
    echo "  [SKIP] $PKG_FILE (이미 존재)"
fi

# ── tb_top 템플릿 생성 ────────────────────────────────────────
TOP_FILE="$TB_DIR/tb_top.sv"
if [[ ! -f "$TOP_FILE" ]]; then
cat > "$TOP_FILE" << EOF
import uvm_pkg::*;
import ${PREFIX}_pkg::*;

module tb_top ();
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;

    ${PREFIX}_if m_if (.clk(clk));

    // TODO: DUT 인스턴스
    // <dut_module> dut (
    //     .clk(m_if.clk),
    //     .rst(m_if.rst),
    //     ...
    // );

    initial begin
        uvm_config_db#(virtual ${PREFIX}_if)::set(null, "", "m_if", m_if);
        run_test("${PREFIX}_random_test");
    end

    initial begin
        \$fsdbDumpfile("${PREFIX}_tb_fsdb");
        \$fsdbDumpvars(0);
    end
endmodule
EOF
    echo "  [NEW ] $TOP_FILE"
else
    echo "  [SKIP] $TOP_FILE (이미 존재)"
fi

# ── Makefile 생성 ─────────────────────────────────────────────
MK_FILE="$TARGET/Makefile"
if [[ ! -f "$MK_FILE" ]]; then
cat > "$MK_FILE" << EOF
VCS_OPTS  = -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/10ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert
VCS_OUTPUT = -o simv
VCS_INCDIR = +incdir+tb +incdir+rtl
VCS_SRC_FILES = \\
                ./tb/${PREFIX}_if.sv \\
                ./tb/${PREFIX}_pkg.sv \\
                ./tb/tb_top.sv
# TODO: RTL 파일 추가

TEST       ?= ${PREFIX}_random_test
SEED       ?= 1
INFO_LEVEL ?= UVM_MEDIUM

SIMV_OPTS  = +UVM_TESTNAME=\$(TEST)
SIMV_OPTS += +UVM_VERBOSITY=\$(INFO_LEVEL)
SIMV_OPTS += +ntb_random_seed=\$(SEED)
SIMV_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIMV_OPTS += -cm_dir coverage.vdb
SIMV_OPTS += -cm_name sim1

.PHONY: all comp simv clean

all: simv

comp:
	vcs \$(VCS_OPTS) \$(VCS_INCDIR) \$(VCS_SRC_FILES) \$(VCS_OUTPUT)
	@echo "타겟 [\$@]"

simv: comp
	@./simv \$(SIMV_OPTS)
	@echo "의존 타겟 [\$<]"
	@echo "타겟 [\$@]"

clean:
	rm -rf simv* csrc *.log *.key *.h coverage.vdb *.fsdb
	@echo "결과물 정리 중 ..."
EOF
    echo "  [NEW ] $MK_FILE"
else
    echo "  [SKIP] $MK_FILE (이미 존재)"
fi

echo ""
echo "완료: ${PREFIX} UVM 환경이 $TARGET 에 생성됐습니다."
echo "생성된 파일:"
find "$TARGET" -name "*.sv" -o -name "Makefile" | sort | sed 's/^/  /'
