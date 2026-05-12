// class: uart_seq_item
// author: cursor-agent
// date: 2026-03-24
// description: Sequence item for UART host-side transactions.
class uart_seq_item extends uvm_sequence_item;
  rand bit [7:0]       m_data;
  rand int unsigned    m_gap_cycles;
  uart_dir_e           m_dir;

  constraint c_gap_cycles {
    m_gap_cycles inside {[0:32]};
  }

  `uvm_object_utils_begin(uart_seq_item)
    `uvm_field_int(m_data, UVM_DEFAULT)
    `uvm_field_int(m_gap_cycles, UVM_DEFAULT)
    `uvm_field_enum(uart_dir_e, m_dir, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "uart_seq_item");
    super.new(name);
    m_dir = UART_DIR_TX;
  endfunction
endclass
