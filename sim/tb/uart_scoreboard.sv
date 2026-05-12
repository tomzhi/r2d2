// class: uart_scoreboard
// author: cursor-agent
// date: 2026-03-24
// description: Compare tx-sent bytes against rx-received bytes.
`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)

class uart_scoreboard extends uvm_component;
  `uvm_component_utils(uart_scoreboard)

  uvm_analysis_imp_tx #(uart_seq_item, uart_scoreboard) m_tx_imp;
  uvm_analysis_imp_rx #(uart_seq_item, uart_scoreboard) m_rx_imp;

  bit                     m_inject_expected_error;
  bit                     m_expected_error_seen;
  byte unsigned           m_expected_q[$];
  int unsigned            m_pass_count;
  int unsigned            m_fail_count;

  function new(string name = "uart_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_tx_imp = new("m_tx_imp", this);
    m_rx_imp = new("m_rx_imp", this);
    if (!uvm_config_db#(bit)::get(this, "", "inject_expected_error",
      m_inject_expected_error)) begin
      m_inject_expected_error = 1'b0;
    end
  endfunction

  function void write_tx(uart_seq_item t);
    m_expected_q.push_back(t.m_data);
  endfunction

  function void write_rx(uart_seq_item t);
    byte unsigned w_expected_data;
    if (m_expected_q.size() == 0) begin
      m_fail_count++;
      `uvm_error("SCB_UNDERFLOW",
        $sformatf("RX has 0x%02h but expected queue is empty", t.m_data))
      return;
    end

    w_expected_data = m_expected_q.pop_front();
    if (m_inject_expected_error && !m_expected_error_seen) begin
      w_expected_data       = w_expected_data ^ 8'h01;
      m_expected_error_seen = 1'b1;
    end

    if (t.m_data !== w_expected_data) begin
      m_fail_count++;
      if (m_inject_expected_error && m_expected_error_seen) begin
        `uvm_error("EXP_ERR_INJECT",
          $sformatf("expected error injection hit: exp=0x%02h act=0x%02h",
          w_expected_data, t.m_data))
      end else begin
        `uvm_error("SCB_MISMATCH",
          $sformatf("data mismatch: exp=0x%02h act=0x%02h",
          w_expected_data, t.m_data))
      end
    end else begin
      m_pass_count++;
      `uvm_info("uart_scoreboard",
        $sformatf("compare pass: data=0x%02h", t.m_data), UVM_MEDIUM)
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (m_expected_q.size() != 0) begin
      `uvm_error("SCB_PENDING",
        $sformatf("expected queue not empty, remain=%0d", m_expected_q.size()))
    end
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("uart_scoreboard",
      $sformatf("scoreboard summary: pass=%0d fail=%0d",
      m_pass_count, m_fail_count), UVM_LOW)
  endfunction
endclass
