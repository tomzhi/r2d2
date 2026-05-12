// module: uart_pkg
// author: cursor-agent
// date: 2026-03-24
// description: UART UVM package with all TB classes.
package uart_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum logic [0:0] {
    UART_DIR_TX = 1'b0,
    UART_DIR_RX = 1'b1
  } uart_dir_e;

  `include "uart_seq_item.sv"
  `include "uart_sequencer.sv"
  `include "uart_driver.sv"
  `include "uart_monitor.sv"
  `include "uart_agent.sv"
  `include "uart_scoreboard.sv"
  `include "uart_env.sv"
  `include "uart_base_seq.sv"
  `include "uart_sanity_seq.sv"
  `include "uart_rand_seq.sv"
  `include "uart_expected_error_catcher.sv"
  `include "uart_base_test.sv"
  `include "uart_sanity_test.sv"
  `include "uart_rand_test.sv"
  `include "uart_neg_err_inject_test.sv"

endpackage
