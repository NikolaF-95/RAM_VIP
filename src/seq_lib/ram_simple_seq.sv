
`ifndef __ram_simple_seq
`define __ram_simple_seq

class ram_simple_seq#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends ram_base_seq#(`DATA_WIDTH, `ADDR_WIDTH); /*uvm_sequence#(ram_item#(DATA_WIDTH, ADDR_WIDTH));*/
    
    `uvm_object_param_utils_begin(ram_simple_seq#(DATA_WIDTH, ADDR_WIDTH))
    `uvm_object_utils_end

    //`uvm_declare_p_sequencer(ram_sequencer#(DATA_WIDTH, ADDR_WIDTH))
    
    extern function new(string name = "ram_simple_seq");
    extern virtual task body();

endclass

function ram_simple_seq::new (string name="ram_simple_seq");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    super.new(name);
    //set_automatic_phase_objection(1);
endfunction

task ram_simple_seq::body();

        `uvm_do_with(req, {

        transaction_without_cs==1;
        full_memory== 1;
        transaction_type==0;
        array_len==8;
        delay_between_trans==0;
        delay_with_active_cs==0;
        active_oe_during_writing==1;

        })

    `uvm_do_with(req, { full_memory==0; transaction_type==0; array_len==2; delay_between_trans==0; delay_with_active_cs==1;})
    `uvm_do_with(req, {transaction_type==1; full_memory==0; array_len==8; delay_between_trans==1; delay_with_active_cs==0; })

    `uvm_do_with(req, {transaction_without_cs==1; transaction_type==0; full_memory== 0; array_len==3; delay_between_trans==1; delay_with_active_cs==0;})
    `uvm_do_with(req, {transaction_type==0; full_memory==0; array_len==2; delay_between_trans==1; delay_with_active_cs==1;})

    `uvm_do_with(req, {transaction_without_cs==1; transaction_type==1; full_memory==0; array_len==8; delay_between_trans==1; delay_with_active_cs==0; })
    `uvm_do_with(req, {transaction_type==1; full_memory==0; array_len==8; delay_between_trans==10; delay_with_active_cs==0; })

    `uvm_do_with(req, {transaction_type==0; full_memory==1; })
    `uvm_do_with(req, {transaction_type==1; full_memory==1; })
    

endtask

`endif
