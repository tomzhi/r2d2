// module: uart_tx
// author: cursor-agent
// date: 2026-03-24
// description: UART transmitter, 8 data bits, no parity, 1 stop bit.
module uart_tx (
  input  logic       i_clk,
  input  logic       i_rstn,
  input  logic       i_baud_tick,
  input  logic [7:0] i_tx_data,
  input  logic       i_tx_valid,
  output logic       o_tx_ready,
  output logic       o_tx_serial
);

  typedef enum logic [1:0] {
    TX_STATE_IDLE  = 2'd0,
    TX_STATE_START = 2'd1,
    TX_STATE_DATA  = 2'd2,
    TX_STATE_STOP  = 2'd3
  } tx_state_e;

  tx_state_e  r_state;
  logic [7:0] r_tx_data;
  logic [2:0] r_bit_idx;

  always_ff @(posedge i_clk or negedge i_rstn) begin : seq_tx_fsm
    if (!i_rstn) begin
      r_state   <= TX_STATE_IDLE;
      r_tx_data <= '0;
      r_bit_idx <= '0;
    end else begin
      case (r_state)
        TX_STATE_IDLE: begin
          if (i_tx_valid && o_tx_ready) begin
            r_tx_data <= i_tx_data;
            r_bit_idx <= 3'd0;
            r_state   <= TX_STATE_START;
          end
        end
        TX_STATE_START: begin
          if (i_baud_tick) begin
            r_state <= TX_STATE_DATA;
          end
        end
        TX_STATE_DATA: begin
          if (i_baud_tick) begin
            if (r_bit_idx == 3'd7) begin
              r_state <= TX_STATE_STOP;
            end else begin
              r_bit_idx <= r_bit_idx + 1'b1;
            end
          end
        end
        TX_STATE_STOP: begin
          if (i_baud_tick) begin
            r_state <= TX_STATE_IDLE;
          end
        end
        default: begin
          r_state <= TX_STATE_IDLE;
        end
      endcase
    end
  end

  always_comb begin : comb_tx_outputs
    o_tx_ready = (r_state == TX_STATE_IDLE);
    case (r_state)
      TX_STATE_IDLE:  o_tx_serial = 1'b1;
      TX_STATE_START: o_tx_serial = 1'b0;
      TX_STATE_DATA:  o_tx_serial = r_tx_data[r_bit_idx];
      TX_STATE_STOP:  o_tx_serial = 1'b1;
      default:        o_tx_serial = 1'b1;
    endcase
  end

  property p_idle_line_high;
    @(posedge i_clk) disable iff (!i_rstn)
      (r_state == TX_STATE_IDLE) |-> (o_tx_serial == 1'b1);
  endproperty

  assert property (p_idle_line_high)
    else $error("uart_tx: tx line must stay high in IDLE");

endmodule
