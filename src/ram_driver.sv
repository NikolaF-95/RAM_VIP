
`ifndef __ram_driver
`define __ram_driver

class ram_driver#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_driver#(ram_item#(DATA_WIDTH,ADDR_WIDTH));

    ram_cfg cfg;

    ram_item#(DATA_WIDTH, ADDR_WIDTH) tr;

    uvm_analysis_port #(ram_item#(DATA_WIDTH, ADDR_WIDTH)) analysis_port;

    bit type_of_previous_item; 
    bit type_of_current_item;
    int had_previous_delay=1; //to avoid one clk delay before first item
 
    virtual ram_if#(DATA_WIDTH, ADDR_WIDTH) ram_if_obj;

    `uvm_component_param_utils(ram_driver#(DATA_WIDTH, ADDR_WIDTH))
    
    extern function new(string name = "ram_driver", uvm_component parent);

    //uvm phases
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

    //task for driving all interface signals to initial values
    extern task drive_init();

    extern task drive_item();
    extern task drive_write();
    extern task drive_read();
    extern task drive_delay();

endclass
//-------------------------------------------------------------------------------------------------------
function ram_driver::new(string name = "ram_driver", uvm_component parent);
    super.new(name, parent); 
endfunction
//-------------------------------------------------------------------------------------------------------
function void ram_driver::build_phase(uvm_phase phase);
    super.build_phase(phase); 
    if(!uvm_config_db#(virtual ram_if#(DATA_WIDTH, ADDR_WIDTH))::get(this, "", "ram_if", ram_if_obj)) 
        `uvm_fatal(get_name(), "Interface is not set in ram_driver")
    if(!uvm_config_db#(ram_cfg)::get(this, "", "cfg", cfg)) 
        `uvm_fatal(get_name(), "Cfg is not set in ram_driver")
    analysis_port = new("analysis_port",this);
    tr = ram_item#(DATA_WIDTH, ADDR_WIDTH)::type_id::create("tr", this);
endfunction
//-------------------------------------------------------------------------------------------------------
task ram_driver::run_phase(uvm_phase phase);  
    super.run_phase(phase);
    drive_init();
    @(posedge ram_if_obj.reset_n) $display("DESIO SE RESET");
    @ ram_if_obj.driver_cb; //to sync with cb
     forever begin
         fork
             forever begin
                 `uvm_info(get_name(), "before get_next_item", UVM_DEBUG)
                 wait(ram_if_obj.reset_n===1);
                 seq_item_port.get_next_item(req); 
                 `uvm_info(get_name(),$sformatf("item is\n %s", req.sprint()), UVM_LOW)
                 $cast(tr,req.clone());
                 analysis_port.write(tr); //Send clone to the scoreboard
                 
                 //if we have two consecutive transactions of the same type without delay, insert one clock between:
                 if(req.transaction_type)  type_of_current_item = 1;
                 else type_of_current_item = 0;
                 if((type_of_current_item==type_of_previous_item) && !had_previous_delay ) begin
                     if(!ram_if_obj.driver_cb.cs) ram_if_obj.driver_cb.data_out<={DATA_WIDTH{1'bz}}; //after fake operation
                     @ ram_if_obj.driver_cb;
                 end
                 //drive_something///
                 drive_item();
                 ///////////////////
                 wait(ram_if_obj.reset_n===1);

                 type_of_previous_item=type_of_current_item;
                 had_previous_delay=req.delay_between_trans;

                 seq_item_port.item_done(); 
                 `uvm_info(get_name(), "item done", UVM_DEBUG)
             end
            begin
                @(negedge ram_if_obj.reset_n);
                `uvm_info(get_name(), "reset detected", UVM_DEBUG)
            end
         join_any
         disable fork;
         drive_init();
    end
endtask

//-------------------------------------------------------------------------------------------------------
task ram_driver::drive_init();
    ram_if_obj.cs<=0;
    ram_if_obj.oe<=0;
    ram_if_obj.we<=0;
    ram_if_obj.address<={ADDR_WIDTH{1'bz}};
    ram_if_obj.data_out<={DATA_WIDTH{1'bz}};
    
    ram_if_obj.driver_cb.cs<=0;
    ram_if_obj.driver_cb.oe<=0;
    ram_if_obj.driver_cb.we<=0;
    ram_if_obj.driver_cb.address<={ADDR_WIDTH{1'bz}};
    ram_if_obj.driver_cb.data_out<={DATA_WIDTH{1'bz}};
    
endtask

//------------------------------------------------------------------------------------------------------- 
task ram_driver::drive_item();
    if(req.transaction_type) begin
         drive_read();
    end
    else begin
        drive_write();
   end
   drive_delay();
endtask

//-------------------------------------------------------------------------------------------------------
task ram_driver::drive_read();
    if(req.transaction_without_cs)ram_if_obj.driver_cb.cs<=0;
    else ram_if_obj.driver_cb.cs<=1;
    ram_if_obj.driver_cb.we<=0;
    ram_if_obj.driver_cb.oe<=1;
    foreach(req.addr_array[ii]) begin
       ram_if_obj.driver_cb.address<=req.addr_array[ii];
       @ram_if_obj.driver_cb;
    end
    @ram_if_obj.driver_cb;
    ram_if_obj.driver_cb.oe<=0;   
endtask

//-------------------------------------------------------------------------------------------------------
task ram_driver::drive_write();
    if(req.transaction_without_cs)ram_if_obj.driver_cb.cs<=0;
    else ram_if_obj.driver_cb.cs<=1;
    if (req.active_oe_during_writing)ram_if_obj.driver_cb.oe<=1;
    else ram_if_obj.driver_cb.oe<=0;
    ram_if_obj.driver_cb.we<=1;
    for (int ii=0; ii<req.array_len; ii++) begin
    //foreach(req.addr_array[ii]) begin
       ram_if_obj.driver_cb.address<=req.addr_array[ii];
       ram_if_obj.driver_cb.data_out<=req.data_array[ii];
       @ram_if_obj.driver_cb;
    end
    ram_if_obj.driver_cb.we<=0;
    if (req.active_oe_during_writing)ram_if_obj.driver_cb.oe<=0;
endtask

//-------------------------------------------------------------------------------------------------------
task ram_driver::drive_delay();
    if(req.delay_between_trans && !req.delay_with_active_cs) ram_if_obj.driver_cb.cs<=0;
    if(req.delay_between_trans) ram_if_obj.driver_cb.data_out<={DATA_WIDTH{1'bz}};
    repeat(req.delay_between_trans) @ram_if_obj.driver_cb;
endtask

//-------------------------------------------------------------------------------------------------------
`endif
