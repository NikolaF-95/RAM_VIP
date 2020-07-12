
`ifndef __ram_sequencer
`define __ram_sequencer

class ram_sequencer#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_sequencer#(ram_item#(DATA_WIDTH, ADDR_WIDTH));

	ram_cfg cfg;
	virtual ram_if#(DATA_WIDTH, ADDR_WIDTH) ram_if_obj; //for run phase

	`uvm_component_param_utils_begin(ram_sequencer#(DATA_WIDTH))
		`uvm_field_object(cfg,UVM_ALL_ON)
	`uvm_component_utils_end
	
	extern function new(string name,uvm_component parent);
	extern function void build_phase (uvm_phase phase);
	
	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		@ (negedge ram_if_obj.reset_n);
		forever
		begin				
			@ (negedge ram_if_obj.reset_n);
			stop_sequences();
			@ (posedge ram_if_obj.reset_n);
		end
	  endtask : run_phase
      
endclass

function ram_sequencer::new (string name, uvm_component parent);
	super.new(name, parent);
endfunction 

function void ram_sequencer::build_phase(uvm_phase phase);
	if(!uvm_config_db#(ram_cfg)::get(this, "", "cfg", cfg)) 
		`uvm_fatal(get_name(), "cfg is not set")
	if(!uvm_config_db#(virtual ram_if#(DATA_WIDTH, ADDR_WIDTH))::get(this, "", "ram_if", ram_if_obj)) 
		`uvm_fatal(get_name(), "Interface is not set in ram_interface")
endfunction

 `endif
