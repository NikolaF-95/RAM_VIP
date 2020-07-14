/*-----------------------------------------------------------------

// ram_virtual_sequencer.sv

// description: It is usually used for multi-agent environments. Only use is demonstrated here.

-----------------------------------------------------------------*/

`ifndef __ram_virtual_sequencer
`define __ram_virtual_sequencer

class ram_virtual_sequencer#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_sequencer#(uvm_sequence_item);

    ram_sequencer master_sequencer;
    //ram_sequencer slave_sequencer;

    //The configuration and interface can be get in a virtual sequence most easily via virtual sequencer 
    ram_cfg cfg;
    virtual ram_if#(DATA_WIDTH, ADDR_WIDTH) ram_if_obj; //

    `uvm_component_utils_begin(ram_virtual_sequencer)
    `uvm_field_object(master_sequencer, UVM_ALL_ON)
    `uvm_field_object(cfg,UVM_ALL_ON)
     //`uvm_field_object(slave_sequencer, UVM_ALL_ON)
    `uvm_component_utils_end

    extern function new(string name="ram_virtual_sequencer",uvm_component parent);

    extern function void build_phase(uvm_phase phase);
    
endclass
//-------------------------------------------------------------------------------------------------------
function ram_virtual_sequencer::new (string name="ram_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_virtual_sequencer::build_phase(uvm_phase phase);

    super.build_phase(phase);

   if(!uvm_config_db#(ram_cfg)::get(this, "", "cfg", cfg)) 
   `uvm_fatal(get_name(), "cfg is not set")

    if(!uvm_config_db#(virtual ram_if#(DATA_WIDTH, ADDR_WIDTH))::get(this, "", "ram_if", ram_if_obj))
        `uvm_fatal(get_name(), "Interface is not set")

endfunction
//-----------------------------------------------------
`endif
