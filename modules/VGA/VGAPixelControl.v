`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 00:35:06
// Design Name: 
// Module Name: VGAPixelControl
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


module VGAPixelControl(
	input wire [9:0] x,
	input wire [9:0] y,
	input wire display,
	output reg [3:0] vgaRed,
	output reg [3:0] vgaGreen,
	output reg [3:0] vgaBlue
);
	
	always @(*)
	begin
		if(!display)
		begin
			vgaRed = 0;
			vgaGreen = 0;
			vgaBlue = 0;
		end
		else
		begin
			// Red screen
			vgaRed = 15;
			vgaGreen = 0;
			vgaBlue = 0;
		end
	end
endmodule
