
`ifndef __ram_base_test
`define __ram_base_test


class ram_base_test#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_test;

    ram_env env;
    ram_cfg master_cfg;

    `uvm_component_utils_begin(ram_base_test)
        `uvm_field_object(env,UVM_ALL_ON);
    `uvm_component_utils_end

    extern function new(string name = "ram_base_test", uvm_component parent);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern function void check_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass

//-------------------------------------------------------------------------------------------------------
function ram_base_test::new(string name = "ram_base_test", uvm_component parent);
    super.new(name, parent);
endfunction

//-------------------------------------------------------------------------------------------------------
 function void ram_base_test::build_phase(uvm_phase phase);

    super.build_phase(phase);

    env=ram_env#(DATA_WIDTH, ADDR_WIDTH)::type_id::create("env", this);

    if(!this.randomize())
    `uvm_fatal(get_name(), "randomization failed")

    //If you want to run this test, uncomment lines below:
    
    // master_cfg=ram_cfg::type_id::create();
    // if(!master_cfg.randomize()) `uvm_fatal(get_name(), "randomization failed") //Uses constraints from configuration class

    // uvm_config_db#(ram_cfg)::set(this, "env", "master_cfg", master_cfg);

 endfunction

 //-------------------------------------------------------------------------------------------------------
function void ram_base_test::connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    
endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_base_test::end_of_elaboration_phase(uvm_phase phase);

    uvm_top.print_topology();
    uvm_top.set_timeout (20000000ns);   // timeout to prevent tests from running forever

endfunction

// -------------------------------------------------------------------------------------------------------
task ram_base_test::run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 1000);

endtask

// -------------------------------------------------------------------------------------------------------
function void ram_base_test::check_phase(uvm_phase phase);

    check_config_usage();

endfunction

//-------------------------------------------------------------------------------------------------------
function void ram_base_test::report_phase(uvm_phase phase);
    uvm_report_server svr;
    int fatal_c;
    int error_c;
    int warning_c;
    bit passed=1;

    super.report_phase(phase);

    svr = uvm_report_server::get_server();

    fatal_c=svr.get_severity_count(UVM_FATAL);
    error_c=svr.get_severity_count(UVM_ERROR);
    warning_c=svr.get_severity_count(UVM_WARNING);

    if((fatal_c+error_c+warning_c)!=0) passed=0;

    if(passed==1) 
    begin
        $display("%c[32m",27);
        `uvm_info(get_name(), "\nTEST PASSED (0 UVM_FATAL, 0 UVM_ERROR, 0 UVM_WARNING)", UVM_NONE)
        $display("%c[0m",27);

    end
    else if (passed==0) 
    begin
        $display("%c[31m",27);        
        `uvm_info(get_name(), $sformatf("\nTEST FAILED (%0d UVM_FATAL, %0d UVM_ERROR, %0d UVM_WARNING)", fatal_c, error_c, warning_c), UVM_NONE)
        $display("%c[0m",27);
    end   
endfunction

//-------------------------------------------------------------------------------------------------------

`endif

