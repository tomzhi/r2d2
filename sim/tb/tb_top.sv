// module: tb_top
// author: cursor-agent
// date: 2026-03-24
// description: Top-level UVM TB, clock/reset generation and DUT hookup.
module tb_top;
  import uvm_pkg::*;
  import uart_pkg::*;

  logic i_clk;
  uart_if u_uart_if (
    .i_clk(i_clk)
  );

  uart u_dut (
    .i_clk(i_clk),
    .i_rstn(u_uart_if.i_rstn),
    .i_baud_divider(u_uart_if.i_baud_divider),
    .i_tx_data(u_uart_if.i_tx_data),
    .i_tx_valid(u_uart_if.i_tx_valid),
    .o_tx_ready(u_uart_if.o_tx_ready),
    .o_tx_serial(u_uart_if.o_tx_serial),
    .i_rx_serial(u_uart_if.i_rx_serial),
    .o_rx_data(u_uart_if.o_rx_data),
    .o_rx_valid(u_uart_if.o_rx_valid),
    .o_rx_framing_error(u_uart_if.o_rx_framing_error)
  );

  assign u_uart_if.i_rx_serial = u_uart_if.o_tx_serial;

  always begin : clk_gen
    #5 i_clk = ~i_clk;
  end

  initial begin : init_signals
    i_clk                    = 1'b0;
    u_uart_if.i_rstn         = 1'b0;
    u_uart_if.i_baud_divider = 16'd16;
    u_uart_if.i_tx_data      = '0;
    u_uart_if.i_tx_valid     = 1'b0;
    repeat (8) @(posedge i_clk);
    u_uart_if.i_rstn         = 1'b1;
  end

  initial begin : start_uvm
    uvm_config_db#(virtual uart_if)::set(null, "*", "vif", u_uart_if);
    run_test();
  end

endmodule
