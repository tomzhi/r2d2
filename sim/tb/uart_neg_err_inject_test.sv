// class: uart_neg_err_inject_test
// author: cursor-agent
// date: 2026-03-24
// description: Negative test with deterministic expected error injection.
class uart_neg_err_inject_test extends uart_base_test;
  `uvm_component_utils(uart_neg_err_inject_test)

  uart_expected_error_catcher m_catcher;

  function new(
    string name = "uart_neg_err_inject_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(this, "m_env.m_scoreboard",
      "inject_expected_error", 1'b1);
  endfunction

  task run_phase(uvm_phase phase);
    uart_sanity_seq m_seq;
    phase.raise_objection(this);
    m_catcher = uart_expected_error_catcher::type_id::create("m_catcher");
    uvm_report_cb::add(null, m_catcher);
    m_seq = uart_sanity_seq::type_id::create("m_seq");
    m_seq.start(m_env.m_agent.m_sequencer);
    repeat (100) @(posedge m_env.m_agent.m_driver.m_vif.i_clk);
    uvm_report_cb::delete(null, m_catcher);
    phase.drop_objection(this);
  endtask
endclass
