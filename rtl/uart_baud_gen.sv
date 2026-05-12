// module: uart_baud_gen
// author: cursor-agent
// date: 2026-03-24
// description: Generate baud and half-baud tick pulses from divider.
module uart_baud_gen #(
  parameter int DIV_WIDTH = 16
) (
  input  logic                 i_clk,
  input  logic                 i_rstn,
  input  logic                 i_enable,
  input  logic [DIV_WIDTH-1:0] i_divider,
  output logic                 o_baud_tick,
  output logic                 o_half_baud_tick
);

  logic [DIV_WIDTH-1:0] r_cnt;
  logic [DIV_WIDTH-1:0] w_divider_safe;
  logic [DIV_WIDTH-1:0] w_half_divider;

  always_comb begin : comb_divider_safe
    w_divider_safe = (i_divider < 2) ? 2 : i_divider;
    w_half_divider = w_divider_safe >> 1;
    if (w_half_divider == 0) begin
      w_half_divider = 1;
    end
  end

  always_ff @(posedge i_clk or negedge i_rstn) begin : seq_tick_gen
    if (!i_rstn) begin
      r_cnt            <= '0;
      o_baud_tick      <= 1'b0;
      o_half_baud_tick <= 1'b0;
    end else if (!i_enable) begin
      r_cnt            <= '0;
      o_baud_tick      <= 1'b0;
      o_half_baud_tick <= 1'b0;
    end else begin
      o_baud_tick      <= 1'b0;
      o_half_baud_tick <= 1'b0;
      if (r_cnt == (w_divider_safe - 1'b1)) begin
        r_cnt       <= '0;
        o_baud_tick <= 1'b1;
      end else begin
        r_cnt <= r_cnt + 1'b1;
        if (r_cnt == (w_half_divider - 1'b1)) begin
          o_half_baud_tick <= 1'b1;
        end
      end
    end
  end

endmodule
