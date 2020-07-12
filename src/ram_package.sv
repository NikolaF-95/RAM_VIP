`ifndef __ram_package
`define __ram_package

package ram_package;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `ifndef DATA_WIDTH
        `define DATA_WIDTH 8
    `endif

    `ifndef ADDR_WIDTH
        `define ADDR_WIDTH 8
    `endif

    `include "ram_cfg.sv"
    `include "ram_item.sv"
    `include "ram_sequencer.sv"

    `include "ram_base_seq.sv"
    `include "ram_simple_seq.sv"
    `include "ram_cs_low_seq.sv"
    `include "ram_write_same_addr_seq.sv"
    `include "ram_read_same_addr_seq.sv"
    `include "ram_same_addr_r_w_seq.sv"

    `include "ram_driver.sv"
    `include "ram_monitor.sv"
    `include "ram_agent.sv"

endpackage

`endif