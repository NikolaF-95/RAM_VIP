
`ifndef __ram_simple_vsq_test
`define __ram_simple_vsq_test


class ram_simple_vsq_test extends ram_base_test#(`DATA_WIDTH,`ADDR_WIDTH);

    `uvm_component_utils(ram_simple_vsq_test)
   
    extern function new(string name = "ram_simple_vsq_test", uvm_component parent);

    extern virtual function void build_phase(uvm_phase phase);

    extern virtual function void connect_phase(uvm_phase phase);

    extern virtual function void start_of_simulation_phase(uvm_phase phase);

    extern task run_phase(uvm_phase phase);

 endclass

//-------------------------------------------------------------------------------------------------------
function ram_simple_vsq_test::new(string name = "ram_simple_vsq_test", uvm_component parent);

    super.new(name, parent);

endfunction
//-------------------------------------------------------------------------------------------------------
function void ram_simple_vsq_test::build_phase(uvm_phase phase);

    super.build_phase(phase);

    master_cfg=ram_cfg::type_id::create();

    if(!master_cfg.randomize() with {
          is_active==UVM_ACTIVE;
          has_checks==1;
          has_coverage==1;
   }) `uvm_fatal(get_name(), "randomization failed")
   //if(!master_cfg.randomize()) `uvm_fatal(get_name(), "randomization failed") //Uses constraints from configuration class
      
    uvm_config_db#(ram_cfg)::set(this, "env", "master_cfg", master_cfg);

endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_simple_vsq_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_simple_vsq_test::start_of_simulation_phase (uvm_phase phase);

    super.start_of_simulation_phase (phase);

    //Assign a default sequence to be executed by the sequencer 
    if(master_cfg.is_active==UVM_ACTIVE) uvm_config_db#(uvm_object_wrapper)::set(this, "env.virtual_sequencer.run_phase", "default_sequence", ram_simple_virtual_sequence#(DATA_WIDTH,ADDR_WIDTH)::type_id::get()); //::get_type();

 endfunction

//-------------------------------------------------------------------------------------------------------
task ram_simple_vsq_test::run_phase(uvm_phase phase);

    super.run_phase(phase);
    
endtask

//------------------------------------------------------------------------------------------------------
`endif