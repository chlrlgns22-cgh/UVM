VCS_OPTS = -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/10ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert
VCS_OUTPUT = -o simv
VCS_INCDIR = +incdir+tb +incdir+rtl
VCS_SRC_FILES = ./rtl/spi_master.sv ./rtl/spi_slave_top.sv ./rtl/spi_uvm.sv \
                ./tb/spi_if.sv ./tb/spi_pkg.sv ./tb/tb_top.sv

TEST ?= spi_random_test
SEED ?= 1
INFO_LEVEL ?= UVM_MEDIUM

SIMV_OPTS = +UVM_TESTNAME=$(TEST)
SIMV_OPTS += +UVM_VERBOSITY=$(INFO_LEVEL)
SIMV_OPTS += +ntb_random_seed=$(SEED)
SIMV_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIMV_OPTS += -cm_dir coverage.vdb
SIMV_OPTS += -cm_name sim1

.PHONY: all comp simv clean

all: simv

comp:
	vcs $(VCS_OPTS) $(VCS_INCDIR) $(VCS_SRC_FILES) $(VCS_OUTPUT)
	@echo "타겟 [$@]"

simv: comp
	@./simv $(SIMV_OPTS)
	@echo "의존 타겟 [$<]"
	@echo "타겟 [$@]"

clean:
	rm -rf simv* csrc *.log *.key *.h coverage.vdb
	@echo "결과물 정리 중 ..."
