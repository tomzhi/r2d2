// class: uart_agent
// author: cursor-agent
// date: 2026-03-24
// description: UART UVM agent with sequencer, driver and monitor.
class uart_agent extends uvm_component;
  `uvm_component_utils(uart_agent)

  uart_sequencer        m_sequencer;
  uart_driver           m_driver;
  uart_monitor          m_monitor;

  function new(string name = "uart_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_sequencer = uart_sequencer::type_id::create("m_sequencer", this);
    m_driver    = uart_driver::type_id::create("m_driver", this);
    m_monitor   = uart_monitor::type_id::create("m_monitor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass
