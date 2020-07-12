
`ifndef __ram_env
`define __ram_env

class ram_env#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_env;
    
    //RAM most often behaves like a slave in systems. That's why our agent will act like a master
    ram_agent#(DATA_WIDTH, ADDR_WIDTH) master_agent;

    //configuration
    ram_cfg master_cfg;
    
    //Scoreboard - when we use it for VIP testing it is often called global monitor
    ram_global_monitor ram_sb;

    //Virtual sequencer - not neccessary for one VIP testing(because we have only one real sequencer); only for usage demonstrating
    ram_virtual_sequencer#(DATA_WIDTH, ADDR_WIDTH) virtual_sequencer;
    
    `uvm_component_utils_begin(ram_env);
        `uvm_field_object(master_agent,UVM_ALL_ON);
        `uvm_field_object(master_cfg,UVM_ALL_ON);
    `uvm_component_utils_end
    
    extern function new(string name = "ram_env", uvm_component parent);
    
    extern function void build_phase(uvm_phase phase);
    
    extern function void connect_phase(uvm_phase phase);
    
endclass
//-------------------------------------------------------------------------------------------------------
function ram_env::new(string name = "ram_env", uvm_component parent);
    super.new(name, parent);
endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_env::build_phase(uvm_phase phase);

    super.build_phase(phase);  
    
    //create agent
    master_agent=ram_agent#(DATA_WIDTH, ADDR_WIDTH)::type_id::create("master_agent", this);
    
    //create global monitor (scoreboard)
    ram_sb=ram_global_monitor#(DATA_WIDTH, ADDR_WIDTH)::type_id::create("global_monitor", this);
    
    //get configuration from test
    if((!uvm_config_db#(ram_cfg)::get(this, "", "master_cfg", master_cfg))||(master_cfg==null)) 
        `uvm_fatal(get_name(), "master agent cfg is not set")

    //set configuration for agent
    uvm_config_db#(ram_cfg)::set(this, "master_agent", "cfg", master_cfg);

    //set configuration for global monitor
    uvm_config_db#(ram_cfg)::set(this, "global_monitor", "cfg", master_cfg);

    //craete virtual sequencer and set configuration for it
    if(master_cfg.is_active==UVM_ACTIVE) begin 
        this.virtual_sequencer=ram_virtual_sequencer#(DATA_WIDTH, ADDR_WIDTH)::type_id::create("virtual_sequencer", this); 
        uvm_config_db#(ram_cfg)::set(this, "virtual_sequencer*", "cfg", master_cfg);
    end
     
endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_env::connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    if(master_cfg.is_active==UVM_ACTIVE) virtual_sequencer.master_sequencer=master_agent.sequencer;

    if(master_agent.monitor==null) `uvm_fatal(get_name(), "No monitor!");
    master_agent.monitor.analysis_port.connect(ram_sb.analysis_port_monitor);

    if(master_agent.driver==null) `uvm_info(get_name(), "No driver!", UVM_LOW)
    else master_agent.driver.analysis_port.connect(ram_sb.analysis_port_sequencer);

endfunction

//-------------------------------------------------------------------------------------------------------
`endif
