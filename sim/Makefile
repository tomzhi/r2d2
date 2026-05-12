.RECIPEPREFIX := >

VCS ?= vcs
SIMV ?= ./simv
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

.PHONY: help build compile sim regress sanity-ci clean

help:
>@echo "Targets:"
>@echo "  make build            # compile/elaboration gate"
>@echo "  make sim TEST=<name>  # run single test"
>@echo "  make regress          # run test list and summary"
>@echo "  make sanity-ci        # minimal sanity gate with env check"
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

clean:
>@rm -rf simv simv.daidir csrc ucli.key novas* DVEfiles verdiLog
>@rm -f *.vpd
>@rm -rf *.vdb
>@rm -f logs/*.log
