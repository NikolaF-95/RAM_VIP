
`ifndef __ram_cs_low_test
`define __ram_cs_low_test


class ram_cs_low_test extends ram_base_test#(`DATA_WIDTH,`ADDR_WIDTH);

    `uvm_component_utils(ram_cs_low_test)
   
    extern function new(string name = "ram_cs_low_test", uvm_component parent);

    extern virtual function void build_phase(uvm_phase phase);

    extern virtual function void connect_phase(uvm_phase phase);

    extern virtual function void start_of_simulation_phase(uvm_phase phase);

    extern task run_phase(uvm_phase phase);

 endclass

//-------------------------------------------------------------------------------------------------------
function ram_cs_low_test::new(string name = "ram_cs_low_test", uvm_component parent);

    super.new(name, parent);

endfunction
//-------------------------------------------------------------------------------------------------------
function void ram_cs_low_test::build_phase(uvm_phase phase);

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
function void ram_cs_low_test::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_cs_low_test::start_of_simulation_phase (uvm_phase phase);

    super.start_of_simulation_phase (phase);

    // [Optional] Assign a default sequence to be executed by the sequencer or look at the run_phase ...

 endfunction

//-------------------------------------------------------------------------------------------------------
task ram_cs_low_test::run_phase(uvm_phase phase);

    ram_cs_low_seq simple_seq = ram_cs_low_seq::type_id::create("simple_seq");

    super.run_phase(phase);

    phase.raise_objection(this);
    if(!simple_seq.randomize())`uvm_fatal(get_name(), "randomization failed"); 
    if(master_cfg.is_active==UVM_ACTIVE) simple_seq.start(env.master_agent.sequencer);
    phase.drop_objection(this);  
    
endtask

//------------------------------------------------------------------------------------------------------
`endif
