`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2018 04:24:16 PM
// Design Name: 
// Module Name: bitmapMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bitmapMemory #(
    parameter Nloc = 2048,
    parameter Dbits = 12,
    parameter initfile = "Pong_bmem.mem"
    )(
    input wire [$clog2(Nloc)-1:0] bitmapAddr,
    
    output logic [Dbits-1:0] ColorValue
    );
    
    logic [Dbits-1:0] mem [1023:0];
    initial $readmemh(initfile, mem, 0, Nloc-1);
    
    assign ColorValue = mem[bitmapAddr];
    
endmodule
