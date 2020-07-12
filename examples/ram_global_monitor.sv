
`ifndef __ram_global_monitor
`define __ram_global_monitor

class ram_global_monitor#(parameter DATA_WIDTH=`DATA_WIDTH, parameter ADDR_WIDTH=`ADDR_WIDTH) extends uvm_scoreboard;

        ram_cfg cfg;
        virtual ram_if#(DATA_WIDTH, ADDR_WIDTH) ram_if_obj; //for run phase
        int sequencer_items_cnt=0;
        int monitor_items_cnt=0;

        covergroup ram_gm_cg with function sample(ram_item#(DATA_WIDTH, ADDR_WIDTH)::transaction_type_enum tr_typ, bit full_memory, int array_len);

                option.name = "gm_cg";
                option.per_instance = 1;

                transaction_type_cp: coverpoint tr_typ { 
                        bins read = {ram_item#(DATA_WIDTH, ADDR_WIDTH)::READ};
                        bins write = {ram_item#(DATA_WIDTH, ADDR_WIDTH)::WRITE};
                }
  
                full_memory_cp: coverpoint full_memory iff(array_len==2**ADDR_WIDTH) {
                    bins happen = {1};
                }
                
                cross_tr_type_full_mem: cross transaction_type_cp, full_memory_cp;
        
           endgroup

        `uvm_component_param_utils(ram_global_monitor#(DATA_WIDTH, ADDR_WIDTH))

        `uvm_analysis_imp_decl(_monitor)
        uvm_analysis_imp_monitor#(ram_item#(DATA_WIDTH, ADDR_WIDTH), ram_global_monitor#(DATA_WIDTH, ADDR_WIDTH)) analysis_port_monitor;

        `uvm_analysis_imp_decl(_sequencer)
        uvm_analysis_imp_sequencer#(ram_item#(DATA_WIDTH, ADDR_WIDTH), ram_global_monitor#(DATA_WIDTH, ADDR_WIDTH)) analysis_port_sequencer;

        uvm_in_order_class_comparator#(ram_item#(DATA_WIDTH, ADDR_WIDTH)) cmp;
        uvm_analysis_port#(ram_item#(DATA_WIDTH, ADDR_WIDTH)) add_item_port;
        uvm_analysis_port#(ram_item#(DATA_WIDTH, ADDR_WIDTH)) check_item_port;

        // new - constructor
        extern function new (string name, uvm_component parent);
 
        extern function void build_phase(uvm_phase phase);

        // write
        extern function void write_monitor(ram_item#(DATA_WIDTH, ADDR_WIDTH) trans);
        extern function void write_sequencer(ram_item#(DATA_WIDTH, ADDR_WIDTH) trans);

        extern function void connect_phase(uvm_phase phase);
        extern function void check_phase(uvm_phase phase);

        task run_phase (uvm_phase phase);
		super.run_phase(phase);
		@ (negedge ram_if_obj.reset_n);
		forever
		begin				
			@ (negedge ram_if_obj.reset_n);
                        monitor_items_cnt=0;
                        sequencer_items_cnt=0;
                        // $display("M_matches before flush=%0d", cmp.m_matches);
                        // $display("M_mismatches before flush=%0d", cmp.m_mismatches);
                        cmp.flush();
                        // $display("M_matches after flush=%0d", cmp.m_matches);
                        // $display("M_mismatches after flush=%0d", cmp.m_mismatches);
			@ (posedge ram_if_obj.reset_n);
		end
	  endtask : run_phase
 
endclass 

//`protect //begin protected region
function ram_global_monitor::new (string name, uvm_component parent);
        super.new(name, parent);
        ram_gm_cg = new();
endfunction

function void ram_global_monitor::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(ram_cfg)::get(this,"","cfg",cfg)) `uvm_fatal(get_name(),"cfg not set in config_db");

        if(!uvm_config_db#(virtual ram_if#(DATA_WIDTH, ADDR_WIDTH))::get(this, "", "ram_if", ram_if_obj)) 
        `uvm_fatal(get_name(), "Interface is not set in ram_interface")

        this.analysis_port_monitor = new("analysis_port_monitor",this);
        this.analysis_port_sequencer = new("analysis_port_sequencer",this);

        if(cfg.has_checks) begin
                this.cmp = uvm_in_order_class_comparator#(ram_item#(DATA_WIDTH, ADDR_WIDTH))::type_id::create("cmp",this);
                this.add_item_port   = new("add_item_port",this);
                this.check_item_port = new("check_item_port",this);
        end

        uvm_top.set_report_severity_id_override(UVM_INFO,"MISCMP",UVM_ERROR); //By default it's INFO!
endfunction

function void ram_global_monitor::write_monitor(ram_item#(DATA_WIDTH, ADDR_WIDTH) trans);
        ram_item#(DATA_WIDTH, ADDR_WIDTH) tclone;
        `uvm_info("write_monitor",$sformatf("new trans for global monitor from monitor :\n%s",trans.sprint()),UVM_MEDIUM);
        if(cfg.has_checks) begin
                $cast(tclone,trans.clone());
                check_item_port.write(tclone);
                monitor_items_cnt++;
        end
endfunction

function void ram_global_monitor::write_sequencer(ram_item#(DATA_WIDTH, ADDR_WIDTH) trans);
        ram_item#(DATA_WIDTH, ADDR_WIDTH) tclone;
        `uvm_info("write_monitor",$sformatf("new trans for global monitor from sequencer :\n%s",trans.sprint()),UVM_MEDIUM);
        if(cfg.has_checks) begin
                $cast(tclone,trans.clone());
                if(cfg.has_coverage) ram_gm_cg.sample(tclone.transaction_type, tclone.full_memory,tclone.array_len);
                add_item_port.write(tclone);
                sequencer_items_cnt++;
        end
endfunction

function void ram_global_monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.has_checks) begin
                add_item_port.connect(cmp.before_export);
                check_item_port.connect(cmp.after_export);
        end
endfunction // connect_phase

function void ram_global_monitor::check_phase(uvm_phase phase);
        if(cfg.has_checks) begin
                if(sequencer_items_cnt != monitor_items_cnt)
                `uvm_error(get_name(),  $sformatf("Mismatch numbers of driven ( %0d ) and collected ( %0d ) items !",sequencer_items_cnt,monitor_items_cnt))
                else `uvm_info(get_name(), "Numbers of transactions matched", UVM_LOW)
        end
endfunction
//`endprotect

`endif

