// class: uart_monitor
// author: cursor-agent
// date: 2026-03-24
// description: Monitor tx handshakes and rx outputs to analysis ports.
class uart_monitor extends uvm_component;
  `uvm_component_utils(uart_monitor)

  virtual uart_if                              m_vif;
  uvm_analysis_port #(uart_seq_item)           m_tx_ap;
  uvm_analysis_port #(uart_seq_item)           m_rx_ap;
  bit [7:0]                                    m_cov_tx_data;
  bit [7:0]                                    m_cov_rx_data;

  covergroup m_uart_cg;
    option.per_instance = 1;
    cp_tx_data: coverpoint m_cov_tx_data;
    cp_rx_data: coverpoint m_cov_rx_data;
  endgroup

  function new(string name = "uart_monitor", uvm_component parent = null);
    super.new(name, parent);
    m_uart_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", m_vif)) begin
      `uvm_fatal("uart_monitor", "failed to get virtual interface from config_db")
    end
    m_tx_ap = new("m_tx_ap", this);
    m_rx_ap = new("m_rx_ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    uart_seq_item m_tx_item;
    uart_seq_item m_rx_item;
    super.run_phase(phase);
    forever begin
      @(posedge m_vif.i_clk);
      if (m_vif.i_tx_valid && m_vif.o_tx_ready) begin
        m_tx_item = uart_seq_item::type_id::create("m_tx_item");
        m_tx_item.m_data = m_vif.i_tx_data;
        m_tx_item.m_dir  = UART_DIR_TX;
        m_tx_ap.write(m_tx_item);
        m_cov_tx_data = m_vif.i_tx_data;
        m_uart_cg.sample();
      end
      if (m_vif.o_rx_valid) begin
        m_rx_item = uart_seq_item::type_id::create("m_rx_item");
        m_rx_item.m_data = m_vif.o_rx_data;
        m_rx_item.m_dir  = UART_DIR_RX;
        m_rx_ap.write(m_rx_item);
        m_cov_rx_data = m_vif.o_rx_data;
        m_uart_cg.sample();
      end
    end
  endtask
endclass
