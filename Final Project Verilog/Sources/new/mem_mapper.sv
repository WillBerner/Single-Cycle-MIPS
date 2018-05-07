`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2018 01:44:35 PM
// Design Name: 
// Module Name: mem_mapper
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


module mem_mapper(
// CPU INPUTS
input wire cpu_wr,
input wire [31:0] cpu_addr,
output wire [31:0] cpu_readdata,

// DATA MEMORY READ/WRITE
input wire [31:0] dmem_readdata,
output wire dmem_wr,

// SCREEN MEMORY READ/WRITE
input wire [3:0] smem_readdata,
output wire smem_wr,

// IO INPUT
input wire [31:0] keyb_char,
input wire [31:0] accel_val,

// IO OUTPUT
output wire sound_wr,
output wire lights_wr
    );
    
    // SETTING LIGHTS WRITE
    assign lights_wr = (cpu_addr[17:16] == 2'b11 &&  cpu_addr[3:2] == 2'b11 && cpu_wr) ? 1 : 0;
    
    // SETTING SOUND WRITE
    assign sound_wr = (cpu_addr[17:16] == 2'b11 && cpu_addr[3:2] == 2'b10 && cpu_wr) ? 1 : 0;
    
    // SETTING SCREEN MEM WRITE
    assign smem_wr = (cpu_addr[17:16] == 2'b10 && cpu_wr) ? 1 : 0;
    
    // SETTING DATA MEM WRITE
    assign dmem_wr = (cpu_addr[17:16] == 2'b01 && cpu_wr) ? 1 : 0;
    
    // MAPPING TO CPU READ DATA BASED OFF OF CPU ADDR
    assign cpu_readdata = ((cpu_addr[17:16] == 2'b11) && (cpu_addr[3:2] == 2'b01)) ? accel_val
                        : ((cpu_addr[17:16] == 2'b11) && (cpu_addr[3:2] == 2'b00)) ? keyb_char
                        : (cpu_addr[17:16] == 2'b10) ? {28'b0, smem_readdata}
                        : (cpu_addr[17:16] == 2'b01) ? dmem_readdata
                        : 32'b0;
    
   
    
    
endmodule
