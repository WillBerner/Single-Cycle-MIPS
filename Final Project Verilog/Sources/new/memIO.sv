`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Will Berner
//
//////////////////////////////////////////////////////////////////////////////////


module memIO #(
    parameter Nloc = 1200,
    parameter Dbits = 32,
    parameter dmem_init = "Pong_dmem_bouncy.mem",     // correct filename inherited by parent
    parameter smem_init = "smem_screentest.mem"
    )(
    
// MIPS IO
input wire clk, cpu_wr,
input wire [31:0] cpu_addr,
output wire [31:0] cpu_readdata,
input wire [31:0] cpu_writedata,

// VGA IO
output wire [3:0] vga_readdata,
input wire [10:0] vga_addr,

// KEYBOARD IN
input wire [31:0] keyb_char,

// ACCELEROMETER IN
input wire [31:0] accel_val,

// SOUND OUT
output logic unsigned [31:0] period,

// LIGHTS OUT
output logic [15:0] lights
    );
    
    wire [31:0] dmem_readdata, dmem_writedata, dmem_writeaddr, smem_writeaddr;
    wire sound_wr, lights_wr, smem_wr, dmem_wr;
    wire [3:0] smem_readdata;
    
    // ASSIGNING SCREEN MEM AND DATA MEM ADDRESSES
    assign dmem_writeaddr = cpu_addr [31:2];
    assign smem_writeaddr = cpu_addr [31:2];
    
    // MEMORY MAPPER MODULE
    mem_mapper mem_mapper(cpu_wr, cpu_addr, cpu_readdata, dmem_readdata, dmem_wr, smem_readdata, smem_wr, keyb_char, accel_val, sound_wr, lights_wr);
    
    
    // DATA MEMORY MODULE
    dmem #(.Nloc(64), .Dbits(32), .dmem_init(dmem_init)) 
    dmem(clk, dmem_wr, dmem_writeaddr, cpu_writedata, dmem_readdata);
    
    // SCREEN MEMORY MODULE
    screenmem #(.Nloc(Nloc), .Dbits(4), .smem_init(smem_init))
    screenmem(clk, smem_wr, smem_writeaddr, cpu_writedata, smem_readdata, vga_addr, vga_readdata);
    
    // LED REGISTER
    always_ff @(posedge clk)
        if (lights_wr)
            lights <= cpu_writedata;
    
    // SOUND REGISTER
    always_ff @(posedge clk)
        if (sound_wr)
            period <= cpu_writedata;
    
    
    
endmodule
