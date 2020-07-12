
`ifndef __ram_write_same_addr_seq
`define __ram_write_same_addr_seq

class ram_write_same_addr_seq extends ram_base_seq#(`DATA_WIDTH, `ADDR_WIDTH);

    rand int num_of_writes;
    rand int address;

    `uvm_object_param_utils(ram_write_same_addr_seq)
    

    extern function new(string name = "ram_write_same_addr_seq");
    extern task body();

    constraint c{
        num_of_writes inside {[2:32]};
        address inside {[0:2**`ADDR_WIDTH - 1]};
    }

endclass

function ram_write_same_addr_seq::new (string name="ram_write_same_addr_seq");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    super.new(name);
endfunction

task ram_write_same_addr_seq::body();

    bit[DATA_WIDTH-1:0] addr[$];
    for (int i = 0; i < num_of_writes; i++)
        addr.push_back(address);
    
    `uvm_do_with(req, {
        array_len == num_of_writes;
        transaction_type == 0;
        delay_between_trans == 0;
        foreach (addr[ii]) addr_array[ii] == addr[ii];
    })

endtask


`endif // __ram_write_same_addr_seq