`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2018 06:13:26 PM
// Design Name: 
// Module Name: imem
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


module dmem #(
    parameter Nloc = 64,
    parameter Dbits = 32,
    parameter dmem_init = "Pong_dmem_bouncy.mem"       // will inherit correct file name from parent
)(
    input wire clk,
    input wire mem_wr,
    input wire [$clog2(Nloc)-1:0] dmem_addr,         // memory address
    
    input wire [Dbits-1:0] mem_writedata,    // incoming data for if writing
    
    output wire [Dbits-1:0] mem_readdata           // data at the address given
    );
    
    logic [Dbits-1:0] mem [Nloc-1:0];
    initial $readmemh(dmem_init, mem, 0, Nloc-1);    // Inialization data
    
    always_ff @(posedge clk) begin
        if (mem_wr)                                 // if mem_write is enabled
            mem[dmem_addr] <= mem_writedata;         // we're writing to memory
    end
    
    assign mem_readdata = mem[dmem_addr];            // for reading from mem
    
endmodule
