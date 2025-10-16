`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 00:35:06
// Design Name: 
// Module Name: VGASynchronizer
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


module VGASynchronizer(
    input pclk,
    input rst,
    output reg [9:0] hcount,
    output reg [9:0] vcount,
    output wire hsync,
    output wire vsync,
    output wire display,
    output wire eof    // EndOfFrame
);
	// VGA Constants (see vga timing table)
	// - XMAX=800 (10bits)
	// - YMAX=525 (10bits)
	localparam SCREEN_HEIGHT = 480;    // 9bits
    localparam SCREEN_WIDTH = 640;     // 10bits 
	localparam VGA_H_FRONT_PORCH = 16;
	localparam VGA_H_SYNC_PULSE = 96;
	localparam VGA_H_BACK_PORCH = 48;
	localparam VGA_V_FRONT_PORCH = 10;
	localparam VGA_V_SYNC_PULSE = 2;
	localparam VGA_V_BACK_PORCH = 33;
	localparam VGA_HSYNC_POL = 0;
	localparam VGA_VSYNC_POL = 0;
	localparam VGA_H_COUNT_MAX = SCREEN_WIDTH + VGA_H_FRONT_PORCH +VGA_H_SYNC_PULSE + VGA_H_BACK_PORCH;
	localparam VGA_V_COUNT_MAX = SCREEN_HEIGHT + VGA_V_FRONT_PORCH +VGA_V_SYNC_PULSE + VGA_V_BACK_PORCH;
	// HSYNC and VSYNC pulse generator: number of start and end clock cycles
    localparam VGA_HSYNC_START = SCREEN_WIDTH + VGA_H_FRONT_PORCH;
	localparam VGA_HSYNC_END = SCREEN_WIDTH + VGA_H_FRONT_PORCH + VGA_H_SYNC_PULSE;
	localparam VGA_VSYNC_START = SCREEN_HEIGHT + VGA_V_FRONT_PORCH;
	localparam VGA_VSYNC_END = SCREEN_HEIGHT + VGA_V_FRONT_PORCH + VGA_V_SYNC_PULSE;
    

   
    always @(posedge pclk or negedge rst)
	begin
        if (!rst)
		begin
            hcount <= 0;
            vcount <= 0;
        end
        else begin
            if (hcount == VGA_H_COUNT_MAX-1) begin
                hcount <= 0;
                if (vcount == VGA_V_COUNT_MAX-1)
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
            end
            else
                hcount <= hcount + 1;
        end
    end
 
    assign hsync = (hcount > VGA_HSYNC_START-1 && hcount < VGA_HSYNC_END) ? VGA_HSYNC_POL : ~VGA_HSYNC_POL;
    assign vsync = (vcount > VGA_VSYNC_START-1 && vcount < VGA_VSYNC_END) ? VGA_VSYNC_POL : ~VGA_VSYNC_POL;
    assign display = (hcount < SCREEN_WIDTH && vcount < SCREEN_HEIGHT) & rst;
    assign eof = (hcount == SCREEN_WIDTH  && vcount == SCREEN_HEIGHT);
endmodule
