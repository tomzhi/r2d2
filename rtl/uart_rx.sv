// module: uart_rx
// author: cursor-agent
// date: 2026-03-24
// description: UART receiver, 8 data bits, no parity, 1 stop bit.
module uart_rx (
  input  logic       i_clk,
  input  logic       i_rstn,
  input  logic [15:0] i_baud_divider,
  input  logic       i_rx_serial,
  output logic [7:0] o_rx_data,
  output logic       o_rx_valid,
  output logic       o_rx_framing_error
);

  typedef enum logic [1:0] {
    RX_STATE_IDLE  = 2'd0,
    RX_STATE_START = 2'd1,
    RX_STATE_DATA  = 2'd2,
    RX_STATE_STOP  = 2'd3
  } rx_state_e;

  rx_state_e  r_state;
  logic [7:0] r_rx_data;
  logic [2:0] r_bit_idx;
  logic [15:0] r_sample_cnt;
  logic [15:0] w_divider_safe;
  logic [15:0] w_half_divider;

  always_comb begin : comb_sample_divider
    w_divider_safe = (i_baud_divider < 16'd2) ? 16'd2 : i_baud_divider;
    w_half_divider = w_divider_safe >> 1;
    if (w_half_divider == 16'd0) begin
      w_half_divider = 16'd1;
    end
  end

  always_ff @(posedge i_clk or negedge i_rstn) begin : seq_rx_fsm
    if (!i_rstn) begin
      r_state            <= RX_STATE_IDLE;
      r_rx_data          <= '0;
      r_bit_idx          <= '0;
      r_sample_cnt       <= '0;
      o_rx_data          <= '0;
      o_rx_valid         <= 1'b0;
      o_rx_framing_error <= 1'b0;
    end else begin
      o_rx_valid <= 1'b0;
      case (r_state)
        RX_STATE_IDLE: begin
          r_sample_cnt <= '0;
          if (!i_rx_serial) begin
            o_rx_framing_error <= 1'b0;
            r_state            <= RX_STATE_START;
          end
        end
        RX_STATE_START: begin
          if (r_sample_cnt == (w_half_divider - 1'b1)) begin
            r_sample_cnt <= '0;
            if (!i_rx_serial) begin
              r_bit_idx <= 3'd0;
              r_state   <= RX_STATE_DATA;
            end else begin
              r_state <= RX_STATE_IDLE;
            end
          end else begin
            r_sample_cnt <= r_sample_cnt + 1'b1;
          end
        end
        RX_STATE_DATA: begin
          if (r_sample_cnt == (w_divider_safe - 1'b1)) begin
            r_sample_cnt <= '0;
            r_rx_data[r_bit_idx] <= i_rx_serial;
            if (r_bit_idx == 3'd7) begin
              r_state <= RX_STATE_STOP;
            end else begin
              r_bit_idx <= r_bit_idx + 1'b1;
            end
          end else begin
            r_sample_cnt <= r_sample_cnt + 1'b1;
          end
        end
        RX_STATE_STOP: begin
          if (r_sample_cnt == (w_divider_safe - 1'b1)) begin
            r_sample_cnt       <= '0;
            o_rx_data          <= r_rx_data;
            o_rx_valid         <= 1'b1;
            o_rx_framing_error <= ~i_rx_serial;
            r_state            <= RX_STATE_IDLE;
          end else begin
            r_sample_cnt <= r_sample_cnt + 1'b1;
          end
        end
        default: begin
          r_state      <= RX_STATE_IDLE;
          r_sample_cnt <= '0;
        end
      endcase
    end
  end

  property p_rx_valid_pulse;
    @(posedge i_clk) disable iff (!i_rstn)
      o_rx_valid |=> !o_rx_valid;
  endproperty

  assert property (p_rx_valid_pulse)
    else $error("uart_rx: o_rx_valid should be one-cycle pulse");

endmodule
