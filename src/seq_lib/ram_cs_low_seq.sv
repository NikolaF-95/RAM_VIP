
`ifndef __ram_cs_low_seq
`define __ram_cs_low_seq

class ram_cs_low_seq extends ram_base_seq#(`DATA_WIDTH, `ADDR_WIDTH);

    `uvm_object_param_utils(ram_cs_low_seq)
    
    extern function new(string name = "ram_cs_low_seq");
    extern task body();

endclass

function ram_cs_low_seq::new (string name="ram_cs_low_seq");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    super.new(name);
endfunction

task ram_cs_low_seq::body();

    bit[DATA_WIDTH-1:0] addr[$];

    `uvm_info(get_name(), "ram_cs_low_seq is starting! ", UVM_LOW);
    
    for (int i = 0; i < 5; i++)
        addr.push_back(i);

    // 5 writes with cs on inactiv value
    `uvm_do_with(req, {
        transaction_without_cs==1;
        transaction_type==0;        //write
        array_len==5;
        //delay_with_active_cs==0;
        foreach (addr[ii]) addr_array[ii] == addr[ii];
    })

    // 5 reads with cs on active value
    `uvm_do_with(req, {
        transaction_type==1;        //read
        array_len==5;
        //delay_with_active_cs==0;
        foreach (addr[ii]) addr_array[ii] == addr[ii];
    })

    `uvm_do_with(req, {
        transaction_type==0;        //write
        array_len==5;
        //delay_with_active_cs==0;
        foreach (addr[ii]) addr_array[ii] == addr[ii];
    })

    `uvm_do_with(req, {
        transaction_without_cs==1;
        transaction_type==1;        //read
        array_len==5;
        //delay_with_active_cs==0;
        foreach (addr[ii]) addr_array[ii] == addr[ii];
    })

    
    
    `uvm_info(get_name(), "ram_cs_low_seq ends! ", UVM_LOW);

endtask


`endif // __ram_cs_low_seq