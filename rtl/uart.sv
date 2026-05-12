// module: uart
// author: cursor-agent
// date: 2026-03-24
// description: UART top module with baud generator, tx and rx.
module uart (
  input  logic        i_clk,
  input  logic        i_rstn,
  input  logic [15:0] i_baud_divider,
  input  logic [7:0]  i_tx_data,
  input  logic        i_tx_valid,
  output logic        o_tx_ready,
  output logic        o_tx_serial,
  input  logic        i_rx_serial,
  output logic [7:0]  o_rx_data,
  output logic        o_rx_valid,
  output logic        o_rx_framing_error
);

  logic w_baud_tick;
  logic w_half_baud_tick;

  uart_baud_gen #(
    .DIV_WIDTH(16)
  ) u_uart_baud_gen (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_enable(1'b1),
    .i_divider(i_baud_divider),
    .o_baud_tick(w_baud_tick),
    .o_half_baud_tick(w_half_baud_tick)
  );

  uart_tx u_uart_tx (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_baud_tick(w_baud_tick),
    .i_tx_data(i_tx_data),
    .i_tx_valid(i_tx_valid),
    .o_tx_ready(o_tx_ready),
    .o_tx_serial(o_tx_serial)
  );

  uart_rx u_uart_rx (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_baud_divider(i_baud_divider),
    .i_rx_serial(i_rx_serial),
    .o_rx_data(o_rx_data),
    .o_rx_valid(o_rx_valid),
    .o_rx_framing_error(o_rx_framing_error)
  );

endmodule
