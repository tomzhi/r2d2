.PHONY: autosmoke clean

VERILATOR ?= verilator
AUTOSMOKE_DIR := obj_dir/autosmoke
RTL_SOURCES := uart.sv uart_baud_gen.sv uart_tx.sv uart_rx.sv

autosmoke:
	$(VERILATOR) --binary --timing --assert --Wall -Wno-fatal \
		--top-module uart_tb --Mdir $(AUTOSMOKE_DIR) \
		uart_tb.sv $(RTL_SOURCES)
	./$(AUTOSMOKE_DIR)/Vuart_tb

clean:
	rm -rf obj_dir
