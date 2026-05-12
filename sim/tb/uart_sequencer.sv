// class: uart_sequencer
// author: cursor-agent
// date: 2026-03-24
// description: Sequencer for UART sequence items.
class uart_sequencer extends uvm_sequencer #(uart_seq_item);
  `uvm_component_utils(uart_sequencer)

  function new(string name = "uart_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
