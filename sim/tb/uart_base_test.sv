// class: uart_base_test
// author: cursor-agent
// date: 2026-03-24
// description: Base UART test constructing the full environment.
class uart_base_test extends uvm_test;
  `uvm_component_utils(uart_base_test)

  uart_env m_env;

  function new(string name = "uart_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = uart_env::type_id::create("m_env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("uart_base_test",
      $sformatf("test=%s verbosity default=UVM_MEDIUM",
      get_type_name()), UVM_LOW)
  endfunction
endclass
