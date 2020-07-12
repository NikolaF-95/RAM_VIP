`ifndef __ram_env_package
`define __ram_env_package


package ram_env_package;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import ram_package::*;

    `include "ram_virtual_sequencer.sv"
    `include "ram_global_monitor.sv"
    
    `include "ram_env.sv"
    `include  "ram_base_test.sv"   
    `include  "ram_simple_test.sv"
    `include  "ram_simple_vsq_test.sv"
    `include  "ram_cs_low_test.sv"
    `include  "ram_same_addr_r_w_test.sv"

    `include "ram_simple_virtual_sequence.sv"

    `include "ram_virtual_sequencer.sv" 

endpackage



`endif
