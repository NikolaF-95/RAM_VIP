
`ifndef __ram_top
`define __ram_top

`include "uvm_macros.svh"
import uvm_pkg::*;
import ram_env_package::*;

`include "ram_if.sv"

`include "ram_sp_sr_sw.v"

module top#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH);

    bit clk=0;
    bit reset_n=1;
    wire[DATA_WIDTH-1:0] data_wire;

    always #10 clk=(~clk);
    
    ram_if#(DATA_WIDTH,ADDR_WIDTH) ram_if_obj(clk, reset_n);
    
    ram_sp_sr_sw #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) ram (
    .clk(clk) ,
    .address(ram_if_obj.address),
    .data(data_wire),
    .cs(ram_if_obj.cs),
    .we(ram_if_obj.we),
    .oe(ram_if_obj.oe)
    );

    
    assign data_wire = (ram_if_obj.oe && !ram_if_obj.we) ? {DATA_WIDTH{1'bz}} : ram_if_obj.data_out ;
    assign ram_if_obj.data_in = data_wire;


    initial begin
        $recordfile("waves.trn");   
        $recordvars;      
        uvm_config_db#(virtual ram_if#(DATA_WIDTH,ADDR_WIDTH))::set(uvm_root::get(), "*", "ram_if", ram_if_obj);       
        run_test();
    end

    initial begin
         #300 reset_n<=0;
         #100 reset_n<=1;
    end

endmodule

`endif