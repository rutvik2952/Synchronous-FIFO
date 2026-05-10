//----------------------------------------------------------------------
// Project       : Synchronous_FiFo
// File          : synchronous_fifo_common.sv
//----------------------------------------------------------------------
// Created by    : RUTVIK  MAKWANA
// Creation Date : 2026-05-10
//----------------------------------------------------------------------
// Description   : This File is contained the common variable 
//                 (Enum ,parameter) which is used the across TB.   
//----------------------------------------------------------------------
`ifndef SYNCHRONOUS_FIFO_COMMON_SV
`define SYNCHRONOUS_FIFO_COMMON_SV

typedef enum bit[2:0] { RESET, 
                        WRITE , 
                        READ , 
                        WRITE_READ ,
                        WRITE_RESET_READ,
                        WRITE_RANDOM_RESET ,
                        READ_RANDOM_RESET, 
                        RADNOM_WRITE_READ} fifo_operation_t; // Use for FiFo Operation

parameter DATA_WIDTH = 8;  // Write and Read data Width
parameter DEPTH      = 16; // FiFo Memory Depth
parameter FILL_WIDTH = 5;  // Width for Valid Data Entry in FiFo


`endif // SYNCHRONOUS_FIFO_COMMON_SV 
