
`ifndef __ram_base_seq
`define __ram_base_seq

class ram_base_seq#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_sequence#(ram_item#(DATA_WIDTH, ADDR_WIDTH));
    
    `uvm_object_param_utils_begin(ram_base_seq#(DATA_WIDTH, ADDR_WIDTH))
    `uvm_object_utils_end

    `uvm_declare_p_sequencer(ram_sequencer#(DATA_WIDTH, ADDR_WIDTH))
    
    extern function new(string name = "ram_base_seq");

endclass

function ram_base_seq::new (string name="ram_base_seq");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    super.new(name);
    set_automatic_phase_objection(1);
endfunction

`endif
