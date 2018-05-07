`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
//
// Will Berner
// 
//////////////////////////////////////////////////////////////////////////////////


module imem #(
    parameter Nloc = 512,
    parameter Dbits = 32,
    parameter initfile = "imem.mem"        // correct filename inherited by parent
)(
    input wire [$clog2(Nloc)-1:0] pc,                // pc counter
    
    output logic [Dbits-1:0] instr                   // instruction at pc address
    );
    
    logic [Dbits-1:0] mem [Nloc-1:0];
    initial $readmemh(initfile, mem, 0, Nloc-1);
    
    assign instr = mem[pc];                         // always read instruction
    
endmodule
