
`ifndef __ram_monitor
`define __ram_monitor

class ram_monitor#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_monitor;
        
        //Variable: cfg
        //Configuration file
        ram_cfg cfg;

        `uvm_component_param_utils_begin(ram_monitor#(DATA_WIDTH, ADDR_WIDTH))
                `uvm_field_object(cfg,UVM_ALL_ON)
        `uvm_component_utils_end

        // //Variable: ram_if
        virtual ram_if#(DATA_WIDTH, ADDR_WIDTH) ram_if_obj;

        bit[DATA_WIDTH-1:0] memory_model[int];
        event start_read;
        event start_write;
        int num_of_read_data=0;
        int num_of_checked_read_data=0;

        // //Variable: tr
        ram_item#(DATA_WIDTH, ADDR_WIDTH) tr;

        //Variable: analysis_port
        //TLM port used to connect to the scoreboard
        uvm_analysis_port #(ram_item#(DATA_WIDTH, ADDR_WIDTH)) analysis_port;
    
        //Monitor coverage
        covergroup ram_cg; 
                   	
                //When true, coverage information for this covergroup instance is tracked as well.                                                      
                option.per_instance = 1;

                transaction_type: coverpoint tr.transaction_type { 
                        bins read = {ram_item#(DATA_WIDTH, ADDR_WIDTH)::READ};
                        bins write = {ram_item#(DATA_WIDTH, ADDR_WIDTH)::WRITE};
                }

                array_len: coverpoint tr.array_len { 
                        bins array_len_1 = {1};            
                        bins array_len_2_32 = {[2:32]};
                        bins array_len_33_inf = {[33:$]};
                }

                active_oe_during_writing: coverpoint tr.active_oe_during_writing iff (tr.transaction_type==ram_item#(DATA_WIDTH, ADDR_WIDTH)::WRITE)  {
                        bins inactive = {0};
                        bins active   = {1};
                }             

                transaction_without_cs: coverpoint  tr.transaction_without_cs {
                        bins did_not_appear = {0};
                        bins appeared = {1};
                }

                //coverage group can specify cross coverage between two or more coverage points or variables.
                cross_trans_type_array_len:   cross   transaction_type, array_len ;
                cross_trans_type_without_cs:  cross   transaction_type, transaction_without_cs;
                
        endgroup

        extern function new(string name,uvm_component parent);

        extern function void build_phase (uvm_phase phase); 
        extern task run_phase (uvm_phase phase);
        extern function void check_phase(uvm_phase phase);
        
        extern task collect_item();

        extern task data_checker();
        extern function void initial_checker();
        extern task cs_inactive_checker();

        extern task checkers();

endclass

//-------------------------------------------------------------------------------------------------------------------------------------------------------- 
function ram_monitor::new (string name, uvm_component parent);
        super.new(name, parent);
        ram_cg=new();
endfunction
//-------------------------------------------------------------------------------------------------------------------------------------------------------- 
function void ram_monitor::build_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual ram_if#(DATA_WIDTH,ADDR_WIDTH))::get(this, "", "ram_if", ram_if_obj)) 
                `uvm_fatal(get_name(), "Interface is not set in ram_interface")
        if (!uvm_config_db#(ram_cfg)::get(this, "", "cfg", cfg) || (cfg == null))
                `uvm_fatal("CFG ERROR","no ram_cfg cfg in db")

        analysis_port = new("analysis_port",this);
        tr = ram_item#(DATA_WIDTH, ADDR_WIDTH)::type_id::create("tr", this);
   
endfunction
//-------------------------------------------------------------------------------------------------------------------------------------------------------        
task ram_monitor::run_phase(uvm_phase phase);
        bit reset_happened;
        super.run_phase(phase);
        @ (posedge ram_if_obj.reset_n);
        initial_checker();
        forever begin
                 fork    
                        begin
                                fork
                                        collect_item();
                                        begin
                                                if(cfg.has_checks) checkers();
                                        end
                                join
                        end
                        begin
                                 @ (negedge ram_if_obj.reset_n);
                                 reset_happened=1;
                         end
                 join_any
                 disable fork;

                 if(reset_happened==1) begin
                         @ (posedge ram_if_obj.reset_n);
                         initial_checker();
                 end 
                 reset_happened=0;
         end
endtask
//--------------------------------------------------------------------------------------------------------------------------------------------------------
task ram_monitor::collect_item();
        bit active_oe;
        fork
                forever begin
                        @ (posedge ram_if_obj.monitor_cb.we  ) begin -> start_write; end 
                end
                forever begin
                        @ (posedge ram_if_obj.monitor_cb.oe  ) begin -> start_read; end 
                end

                forever begin
                        @ start_write ;
                        //wait(start_write.triggered);
                        tr.transaction_type=ram_item#(DATA_WIDTH, ADDR_WIDTH)::WRITE;
                        if(ram_if_obj.monitor_cb.oe) tr.active_oe_during_writing=1;
                        else tr.active_oe_during_writing=0;
                        while (ram_if_obj.monitor_cb.we) begin
                                tr.addr_array.push_back(ram_if_obj.monitor_cb.address);
                                tr.data_array.push_back(ram_if_obj.monitor_cb.data_in);
                                if(ram_if_obj.monitor_cb.cs) begin
                                        memory_model[ram_if_obj.monitor_cb.address] = ram_if_obj.monitor_cb.data_in;
                                        tr.transaction_without_cs=0;
                                end
                                else tr.transaction_without_cs=1;
                                @ram_if_obj.monitor_cb;
                        end
                        tr.array_len=tr.addr_array.size();
                        active_oe=tr.active_oe_during_writing;
                        if(cfg.has_coverage) ram_cg.sample();
                        analysis_port.write(tr);
                        tr.addr_array = {};
                        tr.data_array = {};
                        if(ram_if_obj.monitor_cb.oe && active_oe) -> start_read;
                end
                forever begin
                        @ start_read ;
                        if(ram_if_obj.monitor_cb.we) continue;
                        tr.transaction_type=ram_item#(DATA_WIDTH, ADDR_WIDTH)::READ;
                        while (ram_if_obj.monitor_cb.oe) begin
                                tr.addr_array.push_back(ram_if_obj.monitor_cb.address);
                                if(ram_if_obj.monitor_cb.cs) tr.transaction_without_cs=0;
                                else tr.transaction_without_cs=1;
                                @ ram_if_obj.monitor_cb;
                                if(ram_if_obj.monitor_cb.we && ram_if_obj.monitor_cb.oe ) break;        
                        end
                        tr.addr_array.pop_back();
                        tr.array_len=tr.addr_array.size();
                        num_of_read_data += tr.array_len;
                        tr.active_oe_during_writing=0;
                        if(cfg.has_coverage) ram_cg.sample();
                        analysis_port.write(tr);
                        tr.addr_array = {};
                end
        join

endtask

//--------------------------------------------------------------------------------------------------------------------------------------------------------
function void ram_monitor::initial_checker();
        if(ram_if_obj.oe)
                `uvm_error(get_name(), "oe signal must be zero in initial state!")
        if(ram_if_obj.we)
                `uvm_error(get_name(), " we must be zero in initial state!")
        if(ram_if_obj.cs)
                `uvm_error(get_name(), "cs signal must be zero in initial state!")
        if(ram_if_obj.data_in !== {DATA_WIDTH{1'bz}}) 
                `uvm_error(get_name(), "data signal must be z in initial state!")
endfunction

//--------------------------------------------------------------------------------------------------------------------------------------------------------
task ram_monitor::data_checker();
        bit[ADDR_WIDTH-1:0] addr_array[$];
        logic[DATA_WIDTH-1:0] data_array[$];
        bit fake_read=0;
        forever begin
                @ start_read;
                if(ram_if_obj.monitor_cb.we) continue;
                if(!ram_if_obj.monitor_cb.cs) fake_read=1;
                else fake_read=0;
                while (ram_if_obj.monitor_cb.oe && !ram_if_obj.monitor_cb.we) begin
                        if(!fake_read) begin
                                addr_array.push_back(ram_if_obj.monitor_cb.address);
                                data_array.push_back(ram_if_obj.monitor_cb.data_in);
                        end
                        else begin
                                num_of_checked_read_data++;
                                if(ram_if_obj.monitor_cb.data_in !== {DATA_WIDTH{1'bz}}) 
                                        `uvm_error(get_name(),  $sformatf("Data appeared during fake read on address %0h!",ram_if_obj.monitor_cb.address))
                        end
                        @ ram_if_obj.monitor_cb;        
                end
                if(fake_read) num_of_checked_read_data--; 
                else begin
                        addr_array.pop_back();
                        for(int jj=1;jj<=addr_array.size(); jj++) begin
                                if(memory_model.exists(addr_array[jj-1])) begin
                                        `uvm_info(get_name(),  $sformatf("Data in memory model= %0d, data in DUT = %0d",memory_model[addr_array[jj-1]],data_array[jj] ), UVM_LOW)
                                        if(memory_model[addr_array[jj-1]]!==data_array[jj]) begin
                                                `uvm_error(get_name(),  $sformatf("Wrong data in RAM on address %0h!",addr_array[jj-1] ))
                                        end
                                end
                                else begin
                                        if(data_array[jj]!=={DATA_WIDTH{1'bx}})
                                        `uvm_error(get_name(),  $sformatf("Wrong data in RAM on address %0h!",addr_array[jj-1] ))
                                end 
                                num_of_checked_read_data++;
                        end
                end
                addr_array={};
                data_array={};
        end
endtask
//--------------------------------------------------------------------------------------------------------------------------------------------------------
task ram_monitor::cs_inactive_checker();
        forever begin
                //@ (negedge ram_if_obj.monitor_cb.cs)
                @ ram_if_obj.monitor_cb;
                while(ram_if_obj.monitor_cb.cs === 0) begin
                        if((ram_if_obj.monitor_cb.data_in !== {DATA_WIDTH{1'bz}})&&(ram_if_obj.monitor_cb.oe && !ram_if_obj.monitor_cb.we)) 
                        `uvm_error(get_name(), "data signal must be z while cs is inactive!")
                        @ ram_if_obj.monitor_cb;
                end    
        end
endtask
//--------------------------------------------------------------------------------------------------------------------------------------------------------
task ram_monitor::checkers();
        fork
                data_checker();
                cs_inactive_checker();
        join
endtask
//--------------------------------------------------------------------------------------------------------------------------------------------------------
function void ram_monitor::check_phase(uvm_phase phase);
        if(cfg.has_checks) begin
                if(num_of_read_data != num_of_checked_read_data) begin
                        `uvm_error(get_name(),  $sformatf("Mismatch numbers of read ( %0d ) and read+checked ( %0d ) data !",num_of_read_data,num_of_checked_read_data))
                end
                else `uvm_info(get_name(), "Numbers of read/checked data matched", UVM_LOW)
        end
endfunction
//--------------------------------------------------------------------------------------------------------------------------------------------------------
`endif
