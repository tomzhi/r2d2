// class: uart_base_seq
// author: cursor-agent
// date: 2026-03-24
// description: Base sequence helper for UART stimulus.
class uart_base_seq extends uvm_sequence #(uart_seq_item);
  `uvm_object_utils(uart_base_seq)

  function new(string name = "uart_base_seq");
    super.new(name);
  endfunction

  virtual task send_byte(bit [7:0] i_data, int unsigned i_gap_cycles);
    uart_seq_item m_req;
    m_req = uart_seq_item::type_id::create("m_req");
    start_item(m_req);
    m_req.m_data       = i_data;
    m_req.m_gap_cycles = i_gap_cycles;
    m_req.m_dir        = UART_DIR_TX;
    finish_item(m_req);
  endtask
endclass
