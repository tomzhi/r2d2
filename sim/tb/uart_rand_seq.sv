// class: uart_rand_seq
// author: cursor-agent
// date: 2026-03-24
// description: Random UART traffic sequence.
class uart_rand_seq extends uart_base_seq;
  `uvm_object_utils(uart_rand_seq)

  int unsigned m_item_count;

  function new(string name = "uart_rand_seq");
    super.new(name);
    m_item_count = 64;
  endfunction

  task body();
    uart_seq_item m_req;
    repeat (m_item_count) begin
      m_req = uart_seq_item::type_id::create("m_req");
      start_item(m_req);
      if (!m_req.randomize() with { m_gap_cycles inside {[0:12]}; }) begin
        `uvm_fatal("uart_rand_seq", "item randomize failed")
      end
      m_req.m_dir = UART_DIR_TX;
      finish_item(m_req);
    end
  endtask
endclass
