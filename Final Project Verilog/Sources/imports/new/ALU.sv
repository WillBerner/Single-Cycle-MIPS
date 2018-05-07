`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
//
// Will Berner
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU #(parameter N=32) (
input wire [N-1:0] A, B,
output wire [N-1:0] R,
input wire [4:0] ALUfn,
output wire FlagZ
    );
    wire subtract, bool1, bool0, shft, math, comparison, FlagN, FlagC, FlagV;
    assign {subtract, bool1, bool0, shft, math} = ALUfn [4:0];
    
    wire [N-1:0] addsubResult, shiftResult, logicalResult;
    
    addsub #(N) AS(A, B, subtract, addsubResult, FlagN, FlagC, FlagV);
    shifter #(N) S(B, A[$clog2(N)-1:0], ~bool1, ~bool0, shiftResult);
    Logical #(N) L(A, B, {bool1, bool0}, logicalResult);
    comparator C(FlagN, FlagV, FlagC, bool0, comparison);
    
    assign R = (~shft & math)? addsubResult:
               (shft & ~math)? shiftResult:
               (~shft & ~math)? logicalResult: {{(N-1){1'b0}}, comparison};
               
    assign FlagZ = ~|R;
    
endmodule
