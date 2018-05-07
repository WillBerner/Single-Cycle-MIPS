`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
//
// Will Berner
// 
//////////////////////////////////////////////////////////////////////////////////


module datapath #(
    parameter Nloc = 32,
    parameter Dbits = 32,
    parameter reg_init = "mem_data.mem"
)(

input wire clk,
input wire reset,
input wire enable,
output logic [31:0] pc = 'h0x0040_0000,
input wire [31:0] instr,
input wire [1:0] pcsel, wasel, 
input wire sext, bsel,
input wire [1:0] wdsel,
input wire [4:0] alufn,
input wire werf,
input wire [1:0] asel,
output wire Z,
output wire [31:0] mem_addr, 
output wire [Dbits - 1:0] mem_writedata,
input wire [Dbits - 1:0] mem_readdata
    );
    
    wire [Dbits-1:0] reg_writedata;
    wire [4:0] Rs, Rt, Rd, shamt;
    wire [25:0] J;
    wire [31:0] JT;   
    wire [31:0] BT; 
    wire [15:0] Imm;
    wire [31:0] signImm;    // after sign extension
    wire [31:0] aluA, aluB, alu_result, ReadData1, ReadData2;
    wire [4:0] reg_writeaddr;
    wire [Dbits-1:0] pcPlus4;
    wire [31:0] newPC;

    // Add 4 to PC
   assign pcPlus4 = pc + 4;
   
   // Assigning wires for R-Type Instructions
   assign Rs = instr[25:21];
   assign Rt = instr[20:16];
   assign Rd = instr[15:11];
   assign shamt = instr[10:6];
   
   // Assigning wires for other Instructions
   assign J = instr[25:0];
   assign JT = ReadData1;
   assign BT = pcPlus4 + (signImm << 2);
   assign Imm = instr[16:0];
   
    // Sign Extender SEXT
   assign signImm = (sext == 1'b0) ? {{16{1'b0}}, Imm} : {{16{Imm[15]}}, Imm} ;
  
   // A Select Multiplexer
   assign aluA = (asel == 2'b00) ? ReadData1
               : (asel == 2'b01) ? {27'b0, shamt} : {27'b0, 5'b10000};
  
    // B Select Multiplexer
   assign aluB = (bsel == 1'b0) ? ReadData2 : signImm;

   // PC Register
   always_ff @(posedge clk)
        if(enable)
             pc <= (~reset) ? newPC : 32'h0040_0000;
 
   // PC Select Multiplexer
   assign newPC = (pcsel == 2'b00) ? pcPlus4
                : (pcsel == 2'b01) ? BT
                : (pcsel == 2'b10) ? {pc[31:28], J ,2'b00}
                : (pcsel == 2'b11) ? JT
                : pcPlus4;
 
   // Write Address Multiplexer
   assign reg_writeaddr = (wasel == 2'b00) ? Rd
                       : (wasel == 2'b01) ? Rt
                       : (wasel == 2'b10) ? 5'b11111
                       : 5'b00000;        
   
   // Register Write Data Multiplexer
   assign reg_writedata = (wdsel == 2'b00) ? pcPlus4
                        : (wdsel == 2'b01) ? alu_result
                        : (wdsel == 2'b10) ? mem_readdata
                        : 32'bx;
                        
   // For Data Memory'd Address
   assign mem_addr = alu_result;
   
   // Fetching data to write to mem.
   assign mem_writedata = ReadData2;
   
    
   // Arithmetic Logic Unit
   ALU #(Dbits) alu(aluA, aluB, alu_result, alufn, Z);
  
   // Register File
   register_file #(Nloc, Dbits, reg_init) registerFile (clk, werf, Rs, Rt, reg_writeaddr, reg_writedata, ReadData1, ReadData2);
   
   
endmodule
