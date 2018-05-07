`timescale 1ns / 1ps
`default_nettype none
`include "display640x480.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2018 01:15:27 PM
// Design Name: 
// Module Name: vgadisplaydriver
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


module vgadisplaydriver #(
parameter Nloc = 1024,
parameter Dbits = 12,
parameter initfile = "Pong_bmem.mem"
)(
input wire clock,
input wire [3:0] charCode,
output wire [10:0] ScreenAddr,
output wire [11:0] RGB,
output wire hsync, vsync
    );
    
    wire [11:0] bmem_color;
    wire [10:0] bmem_addr;
    wire [3:0] XOffset, YOffset;
    wire [5:0] row, column; 
    wire [`xbits-1:0] x;
    wire [`ybits-1:0] y;
    wire activevideo;
    
    vgatimer myvgatimer(clock, hsync, vsync, activevideo, x, y);
    bitmapMemory #(.Nloc(1024), .Dbits(12), .initfile(initfile)) BitMapMem(bmem_addr, bmem_color);
    
    // xy values to ScreenAddr encoding
    assign row = y[9:4];                                    // each sprite is 16 pixels
    assign column = x[9:4];                                 // so skip the lowest 4 bits
    assign ScreenAddr = (row << 5) + (row << 3) + column;   // encode the screen address
    
    // Bitmap encoding
    assign XOffset = x[3:0];                                // where in the exact
    assign YOffset = y[3:0];                                // sprite the pixel is
    assign bmem_addr = {charCode, YOffset, XOffset};       // encode the bitmap address
    
    // output the correct color based on the bitmap Mem.
    assign RGB = (activevideo) ? bmem_color : 'b000000000000;
    
endmodule
