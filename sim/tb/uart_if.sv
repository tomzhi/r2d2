// module: uart_if
// author: cursor-agent
// date: 2026-03-24
// description: UART DUT interface for UVM driver/monitor.
interface uart_if (
  input logic i_clk
);

  logic        i_rstn;
  logic [15:0] i_baud_divider;

  logic [7:0]  i_tx_data;
  logic        i_tx_valid;
  logic        o_tx_ready;
  logic        o_tx_serial;

  logic        i_rx_serial;
  logic [7:0]  o_rx_data;
  logic        o_rx_valid;
  logic        o_rx_framing_error;

endinterface
