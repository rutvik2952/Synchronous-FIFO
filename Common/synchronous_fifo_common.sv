`ifndef SYNCHRONOUS_FIFO_COMMON_SV
`define SYNCHRONOUS_FIFO_COMMON_SV

typedef enum bit[2:0] { RESET, 
                        WRITE , 
                        READ , 
                        WRITE_READ ,
                        WRITE_RESET_READ,
                        WRITE_RANDOM_RESET ,
                        READ_RANDOM_RESET, 
                        RADNOM_WRITE_READ} fifo_operation_t;

parameter DATA_WIDTH = 8;
parameter DEFTH      = 16;
parameter FILL_WIDTH = 5;


`endif // SYNCHRONOUS_FIFO_COMMON_SV 
