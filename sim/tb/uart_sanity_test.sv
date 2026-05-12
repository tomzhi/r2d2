// class: uart_sanity_test
// author: cursor-agent
// date: 2026-03-24
// description: Basic UART loopback sanity test.
class uart_sanity_test extends uart_base_test;
  `uvm_component_utils(uart_sanity_test)

  function new(string name = "uart_sanity_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uart_sanity_seq m_seq;
    phase.raise_objection(this);
    m_seq = uart_sanity_seq::type_id::create("m_seq");
    m_seq.start(m_env.m_agent.m_sequencer);
    // Leave enough drain time for the final serialized bytes to exit RX.
    repeat (300) @(posedge m_env.m_agent.m_driver.m_vif.i_clk);
    phase.drop_objection(this);
  endtask
endclass
