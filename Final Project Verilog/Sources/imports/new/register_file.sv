//////////////////////////////////////////////////////////////////////////////////
//
// Will Berner
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module register_file #(
   parameter Nloc = 32,                      // Number of memory locations
   parameter Dbits = 32,                     // Number of bits in data
   parameter reg_init = "mem_data.mem"       // Name of file with intial memory values
)(

   input wire clock,
   input wire werf,
   input wire [4:0] Rs, Rt, regWriteAddr,
   input wire [31:0] regWriteData,
   
   output wire [31:0] readData1, readData2
   );

   logic [Dbits-1 : 0] rf [Nloc-1 : 0];
   initial $readmemh(reg_init, rf, 0, Nloc-1);

   always_ff @(posedge clock)              
      if(werf)
         rf[regWriteAddr] <= regWriteData;

   
   assign readData1 = (Rs == 0) ? 0 : rf[Rs]; 
   assign readData2 = (Rt == 0) ? 0 : rf[Rt];
   
endmodule