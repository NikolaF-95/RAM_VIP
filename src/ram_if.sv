`ifndef __ram_if
`define __ram_if

interface ram_if#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8)(input logic clk, input logic reset_n);

    reg[DATA_WIDTH-1:0] data_in;
    reg[DATA_WIDTH-1:0] data_out;
    reg[ADDR_WIDTH-1:0] address;
    logic cs;
    logic we;
    logic oe;
 
    clocking driver_cb@(posedge clk);
        //inout data;
        output data_out;
        output address;
        output cs;
        output we;
        output oe;
    endclocking
    
    clocking monitor_cb@(posedge clk);
        input  data_in;
        input  address;
        input  cs;
        input  we;
        input  oe;
    endclocking

    // No X/Z assertions:

    property no_x_z_cs;
        @(posedge clk) disable iff (!reset_n)
            $isunknown(cs) == 0; 
    endproperty
    assert_no_x_z_cs: assert property (no_x_z_cs) else `uvm_error("ram_if", "cs is x or z value!")

    property no_x_z_we;
        @(posedge clk) disable iff (!reset_n)
            $isunknown(we) == 0; 
    endproperty

    assert_no_x_z_we: assert property (no_x_z_we) else `uvm_error("ram_if", "we is x or z value!")

    property no_x_z_oe;
        @(posedge clk) disable iff (!reset_n)
            $isunknown(oe) == 0; 
    endproperty

    assert_no_x_z_oe: assert property (no_x_z_oe) else `uvm_error("ram_if", "oe is x or z value!")    

endinterface

`endif
