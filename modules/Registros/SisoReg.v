module SisoReg #(parameter N=1)(
	input wire clk,
	input wire rst,
	input wire load,
	input wire sdi,
	output wire sdo
);
	reg [N-1:0] q = 0;
	always @(posedge clk)
	begin
		if(!rst)
			q <= 0;
		else
			if(load)
				q <= {q[N-2:0],sdi};
	end
	
	assign sdo = q[N-1];
endmodule
