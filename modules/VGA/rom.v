`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 14:36:26
// Design Name: 
// Module Name: rom
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


module rom (
	input wire [16:0] addr,
	output reg [11:0] dout
);
	// Declaro mi region de memoria
	reg [11:0] mem [76800-1:0];
	
	// 
	initial
	begin
		$readmemh("img.mem", mem);
	end
	
	always @(*)
	begin
	   if(addr < 76800)
	       dout = mem[addr];
	   else
	       dout = 12'h000;
	end
endmodule
