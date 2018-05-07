`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2018 03:33:23 PM
// Design Name: 
// Module Name: screenmem
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


module screenmem #(
    parameter Nloc = 1200,
    parameter Abits = 11,
    parameter Dbits = 4,
    parameter smem_init = "smem_screentest.mem"
)(
    // CLOCK
    input wire clk,
    
    // TO MEM MAPPER
    input wire smem_wr,
    input wire [$clog2(Nloc)-1:0] ScreenAddr,
    input wire [Dbits-1:0] smem_writedata,
    output wire [3:0] smem_readdata,
    
    // TO VGA DISPLAY DRIVER
    input wire [$clog2(Nloc)-1:0] vga_addr,
    output wire [Dbits-1:0] vga_readdata
 
    );
    
    logic [Dbits-1:0] mem [Nloc-1:0];
    initial $readmemh(smem_init, mem, 0, Nloc-1);
   
   // WRITE TO SCREEN MEM @ CLOCK TICK
    always_ff @(posedge clk)
        if (smem_wr)
            mem[ScreenAddr] = smem_writedata;
    
    // CONSTANT READ TO VGA 
    assign vga_readdata = mem[vga_addr];
    
    // CONSTANT READ TO MEM MAP
    assign smem_readdata = mem[ScreenAddr];
    
endmodule
