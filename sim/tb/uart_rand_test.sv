// class: uart_rand_test
// author: cursor-agent
// date: 2026-03-24
// description: Randomized UART traffic test.
class uart_rand_test extends uart_base_test;
  `uvm_component_utils(uart_rand_test)

  function new(string name = "uart_rand_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uart_rand_seq m_seq;
    phase.raise_objection(this);
    m_seq = uart_rand_seq::type_id::create("m_seq");
    m_seq.start(m_env.m_agent.m_sequencer);
    repeat (200) @(posedge m_env.m_agent.m_driver.m_vif.i_clk);
    phase.drop_objection(this);
  endtask
endclass
