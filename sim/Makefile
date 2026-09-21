.RECIPEPREFIX := >

VCS ?= vcs
SIMV ?= ./simv
VERILATOR ?= verilator
TEST ?= uart_sanity_test
VERBOSITY ?= UVM_MEDIUM
TESTS ?=
UVM_HOME ?=

VCS_OPTS := -full64 -sverilog -timescale=1ns/1ps -lca
VCS_OPTS += -debug_access+all -kdb
UVM_OPTS := -ntb_opts uvm-1.2

ifneq ($(strip $(UVM_HOME)),)
UVM_INC := +incdir+$(UVM_HOME)/src
else
UVM_INC :=
endif

BUILD_LOG := logs/build.log
SIM_LOG := logs/$(TEST).log
VERILATOR_DIR := obj_dir/verilator
VERILATOR_TOP := uart_tb
VERILATOR_RTL := ../rtl/uart.sv ../rtl/uart_baud_gen.sv \
  ../rtl/uart_tx.sv ../rtl/uart_rx.sv

.PHONY: help build compile sim regress sanity-ci verilator-lint verilator-smoke clean

help:
>@echo "Targets:"
>@echo "  make build            # compile/elaboration gate"
>@echo "  make sim TEST=<name>  # run single test"
>@echo "  make regress          # run test list and summary"
>@echo "  make sanity-ci        # minimal sanity gate with env check"
>@echo "  make verilator-lint   # lint RTL with Verilator"
>@echo "  make verilator-smoke  # build and run lightweight loopback test"
>@echo "  make clean            # clean simulation outputs"
>@echo ""
>@echo "Variables:"
>@echo "  TEST=uart_sanity_test (default)"
>@echo "  TESTS='a b c'         (for regress)"
>@echo "  VERBOSITY=UVM_MEDIUM  (default)"
>@echo "  UVM_HOME=<path>       (optional)"

build:
>@mkdir -p logs
>$(VCS) $(VCS_OPTS) $(UVM_OPTS) $(UVM_INC) -f filelist.f -top tb_top -o simv \
>  -l $(BUILD_LOG)

compile: build

sim: build
>$(SIMV) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) -l $(SIM_LOG)
>@if awk '/^UVM_(ERROR|FATAL)[[:space:]]+[^:]/ || /^Error:/{found=1} END{exit(found?0:1)}' "$(SIM_LOG)"; then \
>  echo "[sim] FAIL: found error signatures in $(SIM_LOG)"; \
>  exit 1; \
>fi

regress: build
>TESTS="$(TESTS)" VERBOSITY="$(VERBOSITY)" ./regress.sh

sanity-ci:
>./sanity_ci.sh

verilator-lint:
>$(VERILATOR) --lint-only --timing --assert --Wall -Wno-fatal $(VERILATOR_RTL)

verilator-smoke:
>$(VERILATOR) --binary --timing --assert --Wall -Wno-fatal \
>  --top-module $(VERILATOR_TOP) --Mdir $(VERILATOR_DIR) \
>  verilator/uart_tb.sv $(VERILATOR_RTL)
>$(VERILATOR_DIR)/V$(VERILATOR_TOP)

clean:
>@rm -rf simv simv.daidir csrc ucli.key novas* DVEfiles verdiLog
>@rm -rf obj_dir
>@rm -f *.vpd
>@rm -rf *.vdb
>@rm -f logs/*.log
