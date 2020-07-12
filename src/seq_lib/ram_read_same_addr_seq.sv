
`ifndef __ram_seq_read
`define __ram_seq_read

class ram_read_same_addr_seq extends ram_base_seq#(`DATA_WIDTH, `ADDR_WIDTH);

    rand int num_of_reads;
    rand int address;

    `uvm_object_param_utils(ram_read_same_addr_seq)
    

    extern function new(string name = "ram_read_same_addr_seq");
    extern task body();

    constraint c{
        num_of_reads inside {[2:32]};
        address inside {[0:2**`ADDR_WIDTH - 1]};
    }

endclass

function ram_read_same_addr_seq::new (string name="ram_read_same_addr_seq");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    super.new(name);
endfunction

task ram_read_same_addr_seq::body();

    bit[DATA_WIDTH-1:0] addr[$];
    for (int i = 0; i < num_of_reads; i++)
        addr.push_back(address);
    
    `uvm_do_with(req, {
        array_len == num_of_reads;
        transaction_type == 1;
        delay_between_trans == 0;
        foreach (addr[ii]) addr_array[ii] == addr[ii];
    })

endtask

`endif // __ram_seq_read