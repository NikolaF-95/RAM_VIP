
`ifndef __ram_same_addr_r_w_seq
`define __ram_same_addr_r_w_seq

class ram_same_addr_r_w_seq extends ram_base_seq#(`DATA_WIDTH, `ADDR_WIDTH);

    `uvm_object_param_utils(ram_same_addr_r_w_seq)
    

    extern function new(string name = "ram_same_addr_r_w_seq");
    extern task body();

endclass

function ram_same_addr_r_w_seq::new (string name="ram_same_addr_r_w_seq");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    super.new(name);
endfunction

task ram_same_addr_r_w_seq::body();

    ram_write_same_addr_seq wr_same_ad_seq = ram_write_same_addr_seq::type_id::create("wr_same_ad_seq");
    ram_read_same_addr_seq rd_same_ad_seq = ram_read_same_addr_seq::type_id::create("rd_same_ad_seq");

    // write 8 different data to addr = 5
    `uvm_do_with(wr_same_ad_seq, {
        address == 5;
        num_of_writes == 8;
    })

    // should be read last writen data
    `uvm_do_with(req, {
        transaction_type == 1;
        array_len == 1;
        addr_array[0] == 5;
    })

    `uvm_do_with(req, {
        transaction_type == 0;
        array_len == 1;
        addr_array[0] == 18;
    })

    `uvm_do_with(rd_same_ad_seq, {
        address == 18;
        num_of_reads == 4;
    })
    

endtask


`endif // __ram_same_addr_r_w_seq