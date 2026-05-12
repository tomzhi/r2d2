// class: uart_driver
// author: cursor-agent
// date: 2026-03-24
// description: Drive host-side tx valid/data handshake into UART DUT.
class uart_driver extends uvm_driver #(uart_seq_item);
  `uvm_component_utils(uart_driver)

  virtual uart_if      m_vif;
  uart_seq_item        m_req;

  function new(string name = "uart_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", m_vif)) begin
      `uvm_fatal("uart_driver", "failed to get virtual interface from config_db")
    end
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    m_vif.i_tx_data  <= '0;
    m_vif.i_tx_valid <= 1'b0;
    // Avoid driving traffic while DUT is still in reset.
    wait (m_vif.i_rstn === 1'b1);
    @(posedge m_vif.i_clk);
    forever begin
      seq_item_port.get_next_item(m_req);
      repeat (m_req.m_gap_cycles) begin
        @(posedge m_vif.i_clk);
      end
      @(posedge m_vif.i_clk);
      while (!m_vif.o_tx_ready) begin
        @(posedge m_vif.i_clk);
      end
      m_vif.i_tx_data  <= m_req.m_data;
      m_vif.i_tx_valid <= 1'b1;
      @(posedge m_vif.i_clk);
      m_vif.i_tx_valid <= 1'b0;
      seq_item_port.item_done();
    end
  endtask
endclass
