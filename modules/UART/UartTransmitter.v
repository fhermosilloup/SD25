`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2025 12:56:40
// Design Name: 
// Module Name: UartTransmitter
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
//////////////////////////////////////////////////////////////////////////////////


module UartTransmitter #(parameter CLK_FREQ_HZ=100000000, parameter BAUDRATE=9600)(
	input wire clk,        // Clock
	input wire rst,        // Reset
	input wire en,         // Habilitar transmisión
	input wire pen,        // Habilitador de paridad
	input wire peven,      // Paridad par
	input wire [7:0] din,  // Datos a transmitir
	output reg tx,         // Salida serial TX
	output reg busy        // Bandera de transmisión en curso 
);
    localparam integer BRCLOCK_CYCLES = (CLK_FREQ_HZ/BAUDRATE + 0.5);
    
    // fsm state definition
	localparam IDLE_STATE = 4'b0000;
	localparam START_STATE = 4'b0001;
	localparam D0_STATE = 4'b0010;
	localparam D1_STATE = 4'b0011;
	localparam D2_STATE = 4'b0100;
	localparam D3_STATE = 4'b0101;
	localparam D4_STATE = 4'b0110;
	localparam D5_STATE = 4'b0111;
	localparam D6_STATE = 4'b1000;
	localparam D7_STATE = 4'b1001;
	localparam PARITY_STATE = 4'b1010;
	localparam STOP_STATE  = 4'b1011;
	
	// BaudRate clock generator
	reg [$clog2(BRCLOCK_CYCLES)-1:0] brcnt = 0;
	reg brtick = 0;
	reg brcnt_rst = 0;
	always @(posedge clk)
	begin
		if(!rst | !brcnt_rst)
		begin
			brcnt <= 0;
			brtick <= 0;
		end
		else
		begin
			if(brcnt == BRCLOCK_CYCLES-1)
			begin
				brcnt <= 0;
				brtick <= 1;
			end
			else
			begin
				brcnt <= brcnt + 1;
				brtick <= 0;
			end
		end
	end
	
	// UartTransmitter FSM
	reg [7:0] data_reg = 0;    // Registro de datos
	reg [3:0] state = IDLE_STATE;
   
    // Purpose: Control TX state machine
    always @(posedge clk)
    begin
		if(!rst)
		begin
			busy <= 0;
			state <= IDLE_STATE;
			data_reg <= 0;
		  	tx <= 1;
			brcnt_rst <= 0;
		end
		else
		begin
			case (state)
				IDLE_STATE :
				begin
					busy <= 0;
					if (en)
					begin
					  state <= START_STATE;
					  busy <= 1;
					  data_reg <= din;
					  brcnt_rst <= 1;
					end
					else
					begin
					  state <= IDLE_STATE;
					  brcnt_rst <= 0;
					end
				end
				
				START_STATE:
				begin
					tx <= 0;
					if(brtick)
						state <= D0_STATE;
					else
						state <= START_STATE;
				end
				 
				
				D0_STATE:
				begin
					tx <= data_reg[0];
					if(brtick)
						state <= D1_STATE;
					else
						state <= D0_STATE;
				end
				
				D1_STATE :
				begin
					tx <= data_reg[1];
					if(brtick)
						state <= D2_STATE;
					else
						state <= D1_STATE;
				end
				
				D2_STATE :
				begin
					tx <= data_reg[2];
					if(brtick)
						state <= D3_STATE;
					else
						state <= D2_STATE;
				end
				
				D3_STATE :
				begin
					tx <= data_reg[3];
					if(brtick)
						state <= D4_STATE;
					else
						state <= D3_STATE;
				end
				
				D4_STATE :
				begin
					tx <= data_reg[4];
					if(brtick)
						state <= D5_STATE;
					else
						state <= D4_STATE;
				end
				
				D5_STATE :
				begin
					tx <= data_reg[5];
					if(brtick)
						state <= D6_STATE;
					else
						state <= D5_STATE;
				end
				
				D6_STATE :
				begin
					tx <= data_reg[6];
					if(brtick)
						state <= D7_STATE;
					else
						state <= D6_STATE;
				end
				
				D7_STATE :
				begin
					tx <= data_reg[7];
					if(brtick)
					begin
						if(pen)
							state <= PARITY_STATE;
						else
							state <= STOP_STATE;
					end
					else
						state <= D7_STATE;
				end
				 
				// Stay here 1 clock
				PARITY_STATE:
				begin
				    if(peven)
					   tx <= data_reg[0] ^ data_reg[1] ^ data_reg[2] ^ data_reg[3] ^ data_reg[4] ^ data_reg[5] ^ data_reg[6] ^ data_reg[7];
					else
					   tx <= ~(data_reg[0] ^ data_reg[1] ^ data_reg[2] ^ data_reg[3] ^ data_reg[4] ^ data_reg[5] ^ data_reg[6] ^ data_reg[7]);
					
					if(brtick)
						state <= STOP_STATE;
					else
						state <= PARITY_STATE;
				end
				
				
				// Receive Stop bit state
				STOP_STATE:
				begin
					tx <= 1;
					if(brtick)
					begin
						state <= IDLE_STATE;
						busy <= 0;
						brcnt_rst <= 0;
					end
					else
						state <= STOP_STATE;
				end
				
				default : state <= IDLE_STATE;
			endcase
		end
    end   
endmodule
