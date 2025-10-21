module Bin2BCD #(parameter DATA_WIDTH=8, parameter NUM_DIGS=3)(
	input wire clk,         			// Clock
	input wire rst,      	  			// Reset
	input wire en,         				// Habilitar la conversion
	input wire [DATA_WIDTH-1:0] din,	// Datos a transmitir
	output reg [4*NUM_DIGS-1:0] digs,   // Digitos concatenados
	output reg done        				// Bandera de finalizacion de conversion
);
	localparam IDLE_STATE = 1'b0;
	localparam CONVERT_STATE = 1'b1;
	
	// Bin2BCD FSM
	reg state = IDLE_STATE;
	reg [DATA_WIDTH-1:0] data_reg = 0;    // Registro de datos
	
	reg [$clog2(4*NUM_DIGS)-1:0] dig_index = 0; 	// Contador de digitos 1
	
    always @(posedge clk)
    begin
		if(!rst)
		begin
			done <= 0;
			state <= IDLE_STATE;
			data_reg <= 0;
			digs <= 0;
			dig_index <= 0;
		end
		else
		begin
			case (state)
				IDLE_STATE :
				begin
					done <= 0;
					if (en)
					begin
					  state <= CONVERT_STATE;
					  data_reg <= din;
					  dig_index <= 0;
					end
					else
					begin
					  state <= IDLE_STATE;
					end
				end
				
				CONVERT_STATE:
				begin
				  digs[(dig_index*4) +: 4] <= data_reg % 10;
                    data_reg <= data_reg / 10;

                    if (dig_index == NUM_DIGS-1) begin
                        done <= 1;
                        state <= IDLE_STATE;
                    end else begin
                        dig_index <= dig_index + 1;
                    end
				end
			endcase
		end
    end   
endmodule
