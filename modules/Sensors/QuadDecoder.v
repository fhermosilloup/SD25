`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2025 01:28:41
// Design Name: 
// Module Name: QuadDecoder
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


module QuadDecoder #(parameter PPR = 334)(
	input wire clk,
	input wire rst,
	input wire qa,
	input wire qb,
	output reg dir,
	output reg [$clog2(4*PPR)-1:0] pos,
	output reg [31:0] cnt
);
	localparam QUAD_S0_STATE = 2'b00;
	localparam QUAD_S1_STATE = 2'b01;
	localparam QUAD_S2_STATE = 2'b10;
	localparam QUAD_S3_STATE = 2'b11;
	
	// Elimina metaestabilidad de señales asíncronas
	reg qa_prev = 0;
	reg qa_stable = 0;
	reg qb_prev = 0;
	reg qb_stable = 0;
	always@(posedge clk)
	begin
		if(!rst)
		begin
			qa_prev <= 0;
			qa_stable <= 0;
			qb_prev <= 0;
			qb_stable <= 0;
		end
		else
		begin
			// Filtrar Qa
			qa_prev <= qa;
			qa_stable <= qa_prev;
			// Filtrar Qb
			qb_prev <= qb;
			qb_stable <= qb_prev;
		end
	end
	
	
	// FSM
	reg [1:0] state = QUAD_S0_STATE;
	always@(posedge clk)
	begin
		if(!rst)
		begin
			state <= QUAD_S0_STATE;
			cnt <= 0;
			dir <= 0;
			pos <= 0;

		end
		else
		begin
			case(state)
				QUAD_S0_STATE:
				begin
					if({qb_stable,qa_stable}==2'b01)
					begin
						state <= QUAD_S1_STATE;
						dir <= 1; // Motor gira en sentido horario
						cnt <= cnt + 1;
						
						// Incrementamos el contador de posición
						if(pos == 4*PPR - 1)
							pos <= 0;
						else
							pos <= pos + 1;
					end
					else if({qb_stable,qa_stable}==2'b10)
					begin
						state <= QUAD_S3_STATE;
						dir <= 0; // Motor gira en sentido anti-horario
						cnt <= cnt - 1;
						
						// Decrementamos el contador de posición
						if(pos == 0)
							pos <= 4*PPR - 1;
						else
							pos <= pos - 1;
					end
					else
						state <= QUAD_S0_STATE;
				end
				
				QUAD_S1_STATE:
				begin
					if({qb_stable,qa_stable}==2'b11)
					begin
						state <= QUAD_S2_STATE;
						dir <= 1; // Motor gira en sentido horario
						cnt <= cnt + 1;
						
						// Incrementamos el contador de posición
						if(pos == 4*PPR - 1)
							pos <= 0;
						else
							pos <= pos + 1;
					end
					else if({qb_stable,qa_stable}==2'b00)
					begin
						state <= QUAD_S0_STATE;
						dir <= 0; // Motor gira en sentido anti-horario
						cnt <= cnt - 1;
						
						// Decrementamos el contador de posición
						if(pos == 0)
							pos <= 4*PPR - 1;
						else
							pos <= pos - 1;
					end
					else
						state <= QUAD_S1_STATE;
				end
				
				QUAD_S2_STATE:
				begin
					if({qb_stable,qa_stable}==2'b10)
					begin
						state <= QUAD_S3_STATE;
						dir <= 1; // Motor gira en sentido horario
						cnt <= cnt + 1;
						
						// Incrementamos el contador de posición
						if(pos == 4*PPR - 1)
							pos <= 0;
						else
							pos <= pos + 1;
					end
					else if({qb_stable,qa_stable}==2'b11)
					begin
						state <= QUAD_S1_STATE;
						dir <= 0; // Motor gira en sentido anti-horario
						cnt <= cnt - 1;
						
						// Decrementamos el contador de posición
						if(pos == 0)
							pos <= 4*PPR - 1;
						else
							pos <= pos - 1;
					end
					else
						state <= QUAD_S2_STATE;
				end
				
				QUAD_S3_STATE:
				begin
					if({qb_stable,qa_stable}==2'b00)
					begin
						state <= QUAD_S0_STATE;
						dir <= 1; // Motor gira en sentido horario
						cnt <= cnt + 1;
						
						// Incrementamos el contador de posición
						if(pos == 4*PPR - 1)
							pos <= 0;
						else
							pos <= pos + 1;
					end
					else if({qb_stable,qa_stable}==2'b11)
					begin
						state <= QUAD_S2_STATE;
						dir <= 0; // Motor gira en sentido anti-horario
						cnt <= cnt - 1;
						
						// Decrementamos el contador de posición
						if(pos == 0)
							pos <= 4*PPR - 1;
						else
							pos <= pos - 1;
					end
					else
						state <= QUAD_S3_STATE;
				end
			endcase
		end
	end
endmodule
