`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2025 16:29:57
// Design Name: 
// Module Name: Rectangle
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


module Rectangle(
	input wire [9:0] x,
	input wire [9:0] y,
	input wire display,
	input wire [9:0] x0, // 0-799
	input wire [9:0] y0, // 0-524
	input wire [9:0] w,
	input wire [9:0] h,
	input wire [11:0] color,
	output reg [11:0] rgb,
	output reg inRange
);
	always @(*)
	begin
		if(display)
		begin
			if(x >= x0 && x < x0+w && y >= y0 && y < y0+h)
			begin
				rgb = color;
				inRange = 1;
			end
			else
			begin
				rgb = 12'h000;
				inRange = 0;
			end
		end
	end
endmodule
