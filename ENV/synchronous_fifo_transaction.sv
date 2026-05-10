//----------------------------------------------------------------------
// Project       : Synchronous_FiFo
// File          : synchronous_fifo_transaction.sv
//----------------------------------------------------------------------
// Created by    : RUTVIK  MAKWANA
// Creation Date : 2026-05-10
//----------------------------------------------------------------------
// Description   : This file is contained the variable and method for 
//                 generate the different data for assign to dut.
//----------------------------------------------------------------------
`ifndef SYNCHRONOUS_FIFO_TRANSACTION_SV
`define SYNCHRONOUS_FIFO_TRANSACTION_SV


//---------------------------------------------------------------------
// class : synchronous_fifo_transaction
//---------------------------------------------------------------------
class synchronous_fifo_transaction;

  // Generate random 8bit write data for fifo
  randc bit[DATA_WIDTH-1:0] write_data;    

  // Use for FiFo operation
  rand  fifo_operation_t operation;              

  // variable is use to collect fifo operation status from design
  // write_read_status[0] : Write Status  ( 1: Write asserted , 0: Writ de-asserted)
  // write_read_status[1] : Read Status   ( 1: Read  asserted , 0: Read de-asserted)
  bit[1:0] write_read_status;               

  // Variable is use to collect read data from FiFo design
  bit[DATA_WIDTH-1:0] read_data;

  // Variable is use to collect valid write_read entry from design
  bit[FILL_WIDTH-1:0] valid_entry;

  // variable is use to collect empty and almost-empty status from design
  // empty_status[0] :   Empty Status          ( 1: Empty asserted , 0: Empty de-asserted)
  // empty_status[1] :   Almost Empty Status   ( 1: Almost Empty asserted , 0: Almost Empty de-asserted)
  bit[1:0] empty_status;     
  
  // variable is use to collect full and almost-full status from design
  // full_status[0] :   full Status          ( 1: Full asserted , 0: Full de-asserted)
  // full_status[1] :   Almost full Status   ( 1: Almost full asserted , 0: Almost full de-asserted)
  bit[1:0] full_status;    

  // variable is use to collect overflow and underflow status from design
  // over_under_flow_status[0] :   Overflow Status    ( 1: Overflow asserted ,  0: Overflow de-asserted)
  // over_under_flow_status[1] :   Underflow Status   ( 1: Underflow asserted , 0: Overflow de-asserted)
  bit[1:0] over_under_flow_status; 

 // This array is store write data during write operation and read operation
 // this array is use for generate unique write data to ensure when write operation
 // is disable and write data not impact on read data.
  bit[DATA_WIDTH-1:0] buffer[$]; 

 // This is control the handshaking between generator and driver block
 static semaphore key;

 // Constraint for generate write data during read operation
 constraint wr_rd_buff_data{ if(operation == READ) { !(write_data inside {buffer});}}

 // Constraint for generate different write data during write operation
 constraint wr_data  { if(operation inside {WRITE_READ,WRITE,WRITE_RESET_READ,WRITE_RANDOM_RESETRADNOM_WRITE_READ})
                       { write dist {1:=50,[2:254]:=50,255:=50};}}

 //----------------------------------------------------------------------------
 // Function : new
 // Argument : NA
 // Description : This method is construct the semaphore and put the default key.
 //----------------------------------------------------------------------------
 function new();
   key = new();
 endfunction

 //----------------------------------------------------------------------------
 // Function : post_randomize
 // Argument : NA
 // Description : This method is store write data in to queue array during write
 //               operation and delete the queue during reset operation.
 //----------------------------------------------------------------------------
 function void post_randomize();
   if(operation == WRITE) buffer.push_back(write_data);
   if(operation == RESET) buffer.delete(); 
 endfunction
 
endclass

`endif //SYNCHRONOUS_FIFO_TRANSACTION_SV
