module PipoReg #(parameter N=1)(
	input wire clk,
	input wire rst,
	input wire load,
	input wire [N-1:0] di,
	output reg [N-1:0] q
);
	
	always @(posedge clk)
	begin
		if(!rst)
			q <= 0;
		else
			if(load)
				q <= di;
			else
				q <= q;
	end
endmodule
