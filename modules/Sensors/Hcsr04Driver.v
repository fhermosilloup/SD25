module Hcsr04Driver #(parameter SAMPLING_CYLES = 50000, TIMEOUT_CYLES = 25000)(
  input wire clk,
  input wire rst,
	input wire en,
  input wire echo,
  output reg trig,
  output reg data_ready,
	output reg timeout_err,
  output reg [$clog2(SAMPLING_CYLES)-1:0] tof
);
	
	/* Filtro Estabilidad ===========================================*/
	reg echo_dly_1 = 0;
	reg echo_dly_2 = 0;
	always @(posedge clk)
	begin
		if(!rst)
		begin
			echo_dly_1 <= 0;
			echo_dly_2 <= 0;
		end
		else
		begin
			echo_dly_1 <= echo;
			echo_dly_2 <= echo_dly_1;
		end
	end
	
	/* Registers ===========================================*/
	reg [$clog2(SAMPLING_CYLES)-1:0] count = 0;	// Contador (0-99999)
	reg [$clog2(SAMPLING_CYLES)-1:0] ccr1 = 0;	// Registro para almacenar el valor del contador cuando echo 0->1
	reg timeout_err_r = 0;
	
	/* FSM ===========================================*/
    localparam IDLE_STATE = 3'b000;
	localparam TRIG_STATE = 3'b001;
	localparam ECHO_PEDGE_STATE = 3'b010;
	localparam ECHO_NEDGE_STATE = 3'b011;
	localparam WAIT_STATE = 3'b100;
	
	reg [2:0] state = IDLE_STATE;
	
	// Register
	always @(posedge clk)
	begin
		if(!rst)
		begin
			state <= IDLE_STATE;
			trig <= 0;
			tof <= 0;
			data_ready <= 0;
			timeout_err <= 0;
			timeout_err_r <= 0;
		end
		else
		begin
			case(state)
				IDLE_STATE:
				begin
					data_ready <= 0;
					timeout_err <= 0;
					timeout_err_r <= 0;
					if(en)
					begin
						state <= TRIG_STATE;
						trig <= 1;
					end
					else
					begin
						state <= IDLE_STATE;
						trig <= 0;
					end
				end
				
				TRIG_STATE:
				begin
					count <= count + 1;
					if(count == 9)
					begin
						state <= ECHO_PEDGE_STATE;
						trig <= 0;
					end
					else
					begin
						state <= TRIG_STATE;
					end
				end
				
				ECHO_PEDGE_STATE:
				begin
					count <= count + 1;
					if(echo_dly_2)
					begin
						state <= ECHO_NEDGE_STATE;
						ccr1 <= count;
					end
					else
						state <= ECHO_PEDGE_STATE;
				end
				
				ECHO_NEDGE_STATE:
				begin
					count <= count + 1;
          if(count < TIMEOUT_CYLES)
						if(!echo_dly_2)
						begin
							state <= WAIT_STATE;
							tof <= count - ccr1; // Contador de ancho de Pulso
						end
						else
							state <= ECHO_NEDGE_STATE;
					else
					begin
						timeout_err_r <= 1;
						state <= WAIT_STATE;
					end
				end
				
				WAIT_STATE:
				begin
					count <= count + 1;
					if(count==SAMPLING_CYLES-1)
					begin
						state <= IDLE_STATE;
						timeout_err <= timeout_err_r;
						data_ready <= ~timeout_err_r;
					end
					else
						state <= WAIT_STATE;
				end
				
				default:
				begin
					state <= IDLE_STATE;
					count <= 0;
					data_ready <= 0;
					timeout_err <= 0;
					tof <= 0;
				end
			endcase
		end
	end
endmodule
