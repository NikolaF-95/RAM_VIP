
`ifndef __ram_cfg
`define __ram_cfg

    class ram_cfg extends uvm_object;

        
        rand uvm_active_passive_enum is_active;

        rand bit has_checks;
       
        rand bit has_coverage;

        `uvm_object_utils_begin(ram_cfg);
            `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
            `uvm_field_int(has_checks, UVM_ALL_ON)
            `uvm_field_int(has_coverage, UVM_ALL_ON)
        `uvm_object_utils_end
        
        constraint con{    

            soft has_checks==0;
            soft has_coverage==0;
            soft is_active == UVM_PASSIVE;

        }

        extern function new(string name = "ram_cfg");     

    endclass
    //-------------------------------------------------------------------------------------------------------
    function ram_cfg::new(string name = "ram_cfg");
        super.new(name);
    endfunction
    //-------------------------------------------------------------------------------------------------------
	
`endif
