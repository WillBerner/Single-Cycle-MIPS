# MIPS Single Cycle CPU

A Single-Cycle MIPS Processor with a limited instruction set created throughout UNC's Digital Logic course. Designed on a NEXYS 4 FPGA, it can handle most standard MIPS instructions with some exceptions such as jal, jr, lui, etc. 

It comes with reset but no error handling capabilities. All written in SystemVerilog with functionality demonstrated via an ASM program written to mimic Pong. The Pong program, a soccer version featuring Chelsea and Manchester United, was compiled from ASM into hex memory .mem files as instructions for the CPU to read in and execute.



A low detail top-level graphic of the architecture:

<img width="1414" alt="Low Level Top Display" src="https://user-images.githubusercontent.com/25047954/123528859-18e6ba00-d6b9-11eb-8751-be1333fc40d7.png">

A high detail top-level graphic of the architecture:

<img width="1426" alt="High Level Top Display" src="https://user-images.githubusercontent.com/25047954/123528824-e76dee80-d6b8-11eb-93fd-7678b90a9d57.png">
