module hello;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class hello_test extends uvm_test;
    `uvm_component_utils(hello_test)
    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("HELLO", "Hello from UVM 2020.3.2 on Verilator", UVM_LOW)
      #10;
      phase.drop_objection(this);
    endtask
    virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      $display("** UVM TEST PASSED **");
    endfunction
  endclass

  initial run_test("hello_test");
endmodule
