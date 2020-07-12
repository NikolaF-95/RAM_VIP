
`ifndef __ram_agent
`define __ram_agent

class ram_agent#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_agent;

    ram_cfg cfg;
    ram_driver#(DATA_WIDTH, ADDR_WIDTH)      driver;
    ram_sequencer#(DATA_WIDTH, ADDR_WIDTH)   sequencer;
    ram_monitor#(DATA_WIDTH, ADDR_WIDTH)     monitor;
    //virtual ram_if#(DATA_WIDTH, ADDR_WIDTH)  ram_if_obj;
    
    `uvm_component_param_utils_begin(ram_agent#(DATA_WIDTH))
        `uvm_field_object(cfg,UVM_ALL_ON)
        `uvm_field_object(driver,UVM_ALL_ON)
        `uvm_field_object(sequencer,UVM_ALL_ON)
        `uvm_field_object(monitor,UVM_ALL_ON)
    `uvm_component_utils_end
    
    extern function new(string name = "ram_agent", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    
endclass
//-------------------------------------------------------------------------------------------------------
function ram_agent::new(string name = "ram_agent", uvm_component parent);
    super.new(name, parent);
endfunction
//-------------------------------------------------------------------------------------------------------
function void ram_agent::build_phase(uvm_phase phase);

    super.build_phase(phase);
    
    if(!uvm_config_db#(ram_cfg)::get(this,"","cfg",cfg)) `uvm_fatal(get_name(),"cfg not set in config_db");
    uvm_config_db#(ram_cfg)::set(this,"*","cfg",cfg);
 
    monitor=ram_monitor#(DATA_WIDTH)::type_id::create($sformatf("%s_monitor",get_name()), this);

    if(cfg.is_active==UVM_ACTIVE) begin 
        driver=ram_driver#(DATA_WIDTH,ADDR_WIDTH)::type_id::create($sformatf("%s_driver",get_name()), this);
        sequencer=ram_sequencer#(DATA_WIDTH, ADDR_WIDTH)::type_id::create($sformatf("%s_sequencer",get_name()), this);
    end

endfunction
//-------------------------------------------------------------------------------------------------------
function void ram_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(cfg.is_active==UVM_ACTIVE) begin       
        driver.seq_item_port.connect(sequencer.seq_item_export); 
    end         
endfunction
//-------------------------------------------------------------------------------------------------------
`endif
