-timescale 1ns/1ns
-disable_sem2009 
-warn_multiple_driver 
-access +rwc 
-uvm 
-uvmhome CDNS-1.2 

//-define ADDR_WIDTH=18 //simulator's limit for full_memory randomization
//-define DATA_WIDTH=32

+incdir+/project/users/$USER/ram_sv_verification/src
+incdir+/project/users/$USER/ram_sv_verification/src/seq_lib
+incdir+/project/users/$USER/ram_sv_verification/examples

+incdir+/project/users/$USER/ram_sv_verification/examples/tests

+incdir+/project/users/$USER/ram_sv_verification/examples/seq_lib

/project/users/$USER/ram_sv_verification/src/ram_package.sv
/project/users/$USER/ram_sv_verification/examples/ram_env_package.sv

/project/users/$USER/ram_sv_verification/examples/ram_top.sv
