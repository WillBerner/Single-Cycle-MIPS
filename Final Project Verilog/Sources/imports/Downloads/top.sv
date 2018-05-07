//////////////////////////////////////////////////////////////////////////////////
//
// Will Berner
// COMP 541 FINAL PROJECT 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`default_nettype none

module top #(
    parameter imem_init="Pong_imem.mem",
    parameter dmem_init="Pong_dmem.mem",
    parameter smem_init="Pong_smem.mem",
    parameter bmem_init="Pong_bmem.mem",
    parameter reg_init="mem_data.mem"
)(
    input wire clk, reset,
    
    // KEYBOARD IN
    input wire ps2_clk, ps2_data,
    
    // ACCELEROMETER IN/OUT
    output wire aclSCK, aclMOSI, aclSS,
    input wire aclMISO,
    
    // DISPLAY OUT
    output wire [3:0] red, green, blue,
    output wire hsync, vsync,
    
    // LED LIGHTS OUT
    output wire [7:0] segments, digitselect,
    output wire [15:0] LED,
    
    // SOUND OUT
    output logic audPWM
    
);
    // CPU WIRES 
   wire [31:0] pc, instr, mem_readdata, mem_writedata, mem_addr;
   wire mem_wr;
   
   // CLOCK WIRES
   wire clk100, clk50, clk25, clk12;
   
   // ACCELEROMETER WIRE
   wire [31:0] accel_val;
   wire [8:0] accelX, accelY;
   wire [11:0] accelTmp;                // not used
   
   // VGA WIRES
   wire [10:0] smem_addr;
   wire [3:0] charcode;
   wire [11:0] RGB;
   
   assign red = RGB[11:8];
   assign green = RGB[7:4];
   assign blue = RGB[3:0];
   
   // KEYBOARD WIRES
   wire [31:0] keyb_char;
 
   // DEBUG WIRE
   wire enable = 1'b1;			// for debugging
   
   // SOUND WIRE
   wire unsigned [31:0] period;

   
   clockdivider_Nexys4 clkdv(clk, clk100, clk50, clk25, clk12);   //for synthesis/board deployment
   // assign clk100=clk; assign clk50=clk; assign clk25=clk; assign clk12=clk;  // for simulation/testing
   
   
   assign accel_val = {7'b0, accelX, 7'b0, accelY};     // I don't actually use the FPGA's Accelerometer at all
   

   mips #(.Nloc(32), .Dbits(32), .reg_init(reg_init))
   mips(clk12, reset, enable, pc, instr, mem_wr, mem_addr, mem_writedata, mem_readdata);
  
   imem #(.Nloc(512), .Dbits(32), .initfile(imem_init)) imem(pc[31:2], instr);
  
   memIO #(.Nloc(1200), .Dbits(32), .dmem_init(dmem_init), .smem_init(smem_init)) 
   memIO(clk12, mem_wr, mem_addr, mem_readdata, mem_writedata, charcode, smem_addr, keyb_char, accel_val, period, LED);

   // I/O devices
   //
   // Note: All I/O devices were developed assuming a 100 MHz clock.
 
   vgadisplaydriver #(.Nloc(2048), .Dbits(12), .initfile(bmem_init)) 
   display(clk100, charcode, smem_addr, RGB, hsync, vsync);

  
  keyboard keyb(clk100, ps2_clk, ps2_data, keyb_char);
  display8digit disp(keyb_char, clk100, segments, digitselect);
  accelerometer accel(clk100, aclSCK, aclMOSI, aclMISO, aclSS, accelX, accelY, accelTmp);
  montek_sound_Nexys4 sound(clk100, period, audPWM);    // Given sound module, I don't actually use at all though



endmodule
