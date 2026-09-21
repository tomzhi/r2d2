`timescale 1ns/1ps

module uart_tb;
  localparam time CLK_PERIOD = 10ns;
  localparam logic [15:0] BAUD_DIVIDER = 16'd8;
  localparam int TIMEOUT_CYCLES = 200;

  logic       i_clk = 1'b0;
  logic       i_rstn = 1'b0;
  logic [7:0] i_tx_data = '0;
  logic       i_tx_valid = 1'b0;
  logic       o_tx_ready;
  logic       tx_serial;
  logic [7:0] o_rx_data;
  logic       o_rx_valid;
  logic       o_rx_framing_error;

  always #(CLK_PERIOD / 2) i_clk = ~i_clk;

  uart dut (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_baud_divider(BAUD_DIVIDER),
    .i_tx_data(i_tx_data),
    .i_tx_valid(i_tx_valid),
    .o_tx_ready(o_tx_ready),
    .o_tx_serial(tx_serial),
    .i_rx_serial(tx_serial),
    .o_rx_data(o_rx_data),
    .o_rx_valid(o_rx_valid),
    .o_rx_framing_error(o_rx_framing_error)
  );

  task automatic send_and_check(input logic [7:0] expected);
    int cycles;
    begin
      while (!o_tx_ready) @(posedge i_clk);

      // Start immediately after a baud tick so the start bit gets a full period.
      @(posedge dut.w_baud_tick);
      @(negedge i_clk);
      i_tx_data  = expected;
      i_tx_valid = 1'b1;
      @(negedge i_clk);
      i_tx_valid = 1'b0;

      cycles = 0;
      while (!o_rx_valid && cycles < TIMEOUT_CYCLES) begin
        @(posedge i_clk);
        cycles++;
      end

      if (!o_rx_valid)
        $fatal(1, "AUTOSMOKE FAIL: timeout receiving 0x%02x", expected);
      if (o_rx_data !== expected)
        $fatal(1, "AUTOSMOKE FAIL: expected 0x%02x, got 0x%02x",
               expected, o_rx_data);
      if (o_rx_framing_error)
        $fatal(1, "AUTOSMOKE FAIL: framing error for 0x%02x", expected);
    end
  endtask

  initial begin
    repeat (4) @(posedge i_clk);
    i_rstn = 1'b1;
    repeat (2) @(posedge i_clk);

    send_and_check(8'hA5);
    send_and_check(8'h3C);

    $display("AUTOSMOKE PASS: UART loopback received A5 and 3C");
    $finish;
  end

endmodule
