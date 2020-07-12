
`ifndef __ram_item
`define __ram_item

class ram_item#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8) extends uvm_sequence_item;

	typedef enum {WRITE, READ} transaction_type_enum; //WRITE = 0, READ = 1
	
	rand transaction_type_enum transaction_type;

	//the length of the address/data array
	rand longint array_len;

	//queue with data
	rand bit[DATA_WIDTH-1:0] data_array[$];
	
	//queue with addresses
	rand bit[ADDR_WIDTH-1:0] addr_array[$]; 

	//the time interval between two transactions expressed in the number of clocks
	rand int delay_between_trans;

	//the period between two transactions (when neither OE nor WE are active) can have active or inactive CS
	rand bit delay_with_active_cs;
	
	//output enable signal is ignored during write operation - it can be active or inactive
	rand bit active_oe_during_writing; 
	
	// fill/read all locations memory - good for first write transaction to avoid many "x" values on data lines
	rand bit full_memory;
	
	//drive oe/we with inactive cs - for testing RAM's cs
	rand bit transaction_without_cs; 
	
	/*The utils macros define the infrastructure needed to enable the object/component for correct factory operation*/
	`uvm_object_param_utils_begin(ram_item#(DATA_WIDTH, ADDR_WIDTH))
		`uvm_field_int(array_len,UVM_ALL_ON)
	    `uvm_field_int(delay_with_active_cs,UVM_ALL_ON + UVM_NOCOMPARE)
		`uvm_field_int(delay_between_trans,UVM_ALL_ON + UVM_NOCOMPARE)
		`uvm_field_int(active_oe_during_writing,UVM_ALL_ON)
		`uvm_field_int(full_memory,UVM_ALL_ON+ UVM_NOCOMPARE)
	    `uvm_field_int(transaction_without_cs,UVM_ALL_ON)
	    `uvm_field_queue_int(data_array, UVM_ALL_ON)
	    `uvm_field_queue_int(addr_array, UVM_ALL_ON)
	    `uvm_field_enum(transaction_type_enum, transaction_type, UVM_ALL_ON)
	`uvm_object_utils_end
	
	 extern function new(string name = "ram_item");
	 
	constraint c{

		soft full_memory== 0;

		if(!full_memory) {soft array_len inside {[1:32]}; }
	    else { soft array_len == 2**ADDR_WIDTH; }
		
		addr_array.size()==array_len;

		if (full_memory) {
			 if(ADDR_WIDTH<10) { unique {addr_array} ; }
			 else {
				foreach(addr_array[ii]) {
					addr_array[ii]== ii; 
				}
			 }
		}
        
		if(transaction_type) {
			data_array.size()==0;
			active_oe_during_writing==0;
		}
		else {
			data_array.size()==array_len;
			soft active_oe_during_writing == 0;
		}

		soft delay_between_trans inside {[0:30]};

		soft transaction_without_cs==0;
	}

endclass

//-------------------------------------------------------------------------------------------------------
	function ram_item::new(string name = "ram_item");
		super.new(name);
	endfunction

//-------------------------------------------------------------------------------------------------------

`endif
