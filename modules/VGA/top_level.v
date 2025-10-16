`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 00:35:06
// Design Name: 
// Module Name: top_level
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


module top_level(
	input wire clk,
	input wire btnC,
	output wire Vsync,
	output wire Hsync,
	output wire [3:0] vgaRed,
	output wire [3:0] vgaGreen,
	output wire [3:0] vgaBlue
);
	wire nrst = ~btnC;
	wire Clk25MHz;
	
	// VGA clock divider
	ClockDiv #(.FREQ_OUT(25_000_000)) VgaClockDiv(
		.clk(clk),
		.rst(nrst),
		.clkout(Clk25MHz)
	);
	
	// VGA synchronizer
	wire [9:0] x, y;
	wire display_flag, end_of_frame;
	VGASynchronizer VgaSync(
		.pclk(Clk25MHz),
		.rst(nrst),
		.hcount(x),
		.vcount(y),
		.hsync(Hsync),
		.vsync(Vsync),
		.display(display_flag),
		.eof(end_of_frame)
	);
	
	// VGA Pixel controller
	VGAPixelControl VGAController(
		.x(x),
		.y(y),
		.display(display_flag),
		.vgaRed(vgaRed),
		.vgaGreen(vgaGreen),
		.vgaBlue(vgaBlue)
	);
endmodule
