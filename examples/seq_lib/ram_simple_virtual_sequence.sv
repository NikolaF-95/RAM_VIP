
`ifndef __ram_simple_virtual_sequence
`define __ram_simple_virtual_sequence

class ram_simple_virtual_sequence#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_sequence#(uvm_sequence_item);

    ram_simple_seq#(DATA_WIDTH, ADDR_WIDTH) master_seq;
    ram_cfg master_cfg;
    virtual ram_if#(DATA_WIDTH, ADDR_WIDTH) ram_if_obj;


    `uvm_object_utils(ram_simple_virtual_sequence)
    `uvm_declare_p_sequencer(ram_virtual_sequencer)
    
    function new(string name = "ram_simple_virtual_sequence");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction: new

    extern function void pre_randomize();
    extern virtual task body();
    extern virtual task reset_handler();
    
endclass

function void ram_simple_virtual_sequence::pre_randomize();

    if(!uvm_config_db#(ram_cfg)::get(this.p_sequencer, "", "cfg", master_cfg))
        `uvm_fatal(get_name(), "cfg is not set");
    
    if(!uvm_config_db#(virtual ram_if#(DATA_WIDTH,ADDR_WIDTH))::get(this.p_sequencer, "", "ram_if", ram_if_obj))
    `uvm_fatal(get_name(), "master if not set")
    
endfunction

task ram_simple_virtual_sequence::body();
    fork
        reset_handler();
        begin
            `uvm_do_on(master_seq, p_sequencer.master_sequencer)
        end
    join_any
    disable fork;
endtask

task ram_simple_virtual_sequence::reset_handler();
    begin
        @(negedge ram_if_obj.reset_n);
        forever begin
            @(negedge ram_if_obj.reset_n);
             `uvm_info(get_name(), "Reset - stop sequences", UVM_LOW)
        end
    end
endtask
`endif
