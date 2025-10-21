`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.08.2025 11:45:44
// Design Name: 
// Module Name: CounterModN
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

module Counter #(parameter NUM_BITS = 1)(
    input wire clk,
    input wire rst,
  	input wire en,
    output reg [$clog2(NUM_BITS)-1:0] q,
	output reg rco
);
    always @(posedge clk or negedge rst)
    begin
        if(!rst)
		begin
            q <= 0;
			rco <= 0;
		end
        else
		begin
			if(en)
			begin
				q <= q + 1;
			end
		end
    end
	
	assign rco <= q == 2**NUM_BITS-1;
endmodule
