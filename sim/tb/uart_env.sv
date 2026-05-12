// class: uart_env
// author: cursor-agent
// date: 2026-03-24
// description: UART environment holding agent and scoreboard.
class uart_env extends uvm_env;
  `uvm_component_utils(uart_env)

  uart_agent       m_agent;
  uart_scoreboard  m_scoreboard;

  function new(string name = "uart_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent      = uart_agent::type_id::create("m_agent", this);
    m_scoreboard = uart_scoreboard::type_id::create("m_scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agent.m_monitor.m_tx_ap.connect(m_scoreboard.m_tx_imp);
    m_agent.m_monitor.m_rx_ap.connect(m_scoreboard.m_rx_imp);
  endfunction
endclass
