// class: uart_sanity_seq
// author: cursor-agent
// date: 2026-03-24
// description: Deterministic sanity sequence with fixed patterns.
class uart_sanity_seq extends uart_base_seq;
  `uvm_object_utils(uart_sanity_seq)

  function new(string name = "uart_sanity_seq");
    super.new(name);
  endfunction

  task body();
    bit [7:0] m_pattern_q[$];
    m_pattern_q.push_back(8'h55);
    m_pattern_q.push_back(8'hAA);
    m_pattern_q.push_back(8'h00);
    m_pattern_q.push_back(8'hff);
    m_pattern_q.push_back(8'h3c);
    m_pattern_q.push_back(8'hc3);

    foreach (m_pattern_q[m_idx]) begin
      send_byte(m_pattern_q[m_idx], m_idx);
    end
  endtask
endclass
