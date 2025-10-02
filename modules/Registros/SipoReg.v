module SipoReg #(parameter N=1)(
	input wire clk,
	input wire rst,
	input wire load,
	input wire sdi,
	output reg [N-1:0] q,
);
	always @(posedge clk)
	begin
		if(!rst)
			q <= 0;
		else
			if(load)
				q <= {q[N-2:0],sdi};
	end
endmodule
