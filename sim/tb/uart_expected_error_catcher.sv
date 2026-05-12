// class: uart_expected_error_catcher
// author: cursor-agent
// date: 2026-03-24
// description: Demote expected injected error for negative test.
class uart_expected_error_catcher extends uvm_report_catcher;
  `uvm_object_utils(uart_expected_error_catcher)

  function new(string name = "uart_expected_error_catcher");
    super.new(name);
  endfunction

  virtual function action_e catch();
    if ((get_severity() == UVM_ERROR) && (get_id() == "EXP_ERR_INJECT")) begin
      set_severity(UVM_INFO);
      set_message({"expected error suppressed: ", get_message()});
      return THROW;
    end
    return THROW;
  endfunction
endclass
