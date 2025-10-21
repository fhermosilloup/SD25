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

module CounterModN #(parameter N = 1)(
    input wire clk,
    input wire rst,
    output reg [$clog2(N)-1:0] q,
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
			if(q == N-1)
			begin
				q <= 0;
				rco <= 1;
			end
			else
			begin
				q <= q + 1;
				rco <= 0;
			end
    end
endmodule
