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
// This file contains the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
//////////////////////////////////////////////////////////////////////////////////


module UartTransmitter (
  input wire clk,         // Clock
  input wire rst,      	  // Reset
	input wire brclk,      // BaudRate clock
	input wire en,         // Habilitar transmisión
	input wire pen,        // Habilitador de paridad
	input wire peven,      // Paridad par
	input wire [7:0] din,  // Datos a transmitir
	output reg tx,         // Salida serial TX
  output reg busy        // Bandera de transmisión en curso 
);
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
					end
					else
					  state <= IDLE_STATE;
				end
				
				START_STATE:
				begin
					tx <= 0;
					if(brclk)
						state <= D0_STATE;
					else
						state <= START_STATE;
				end
				 
				
				D0_STATE:
				begin
					tx <= data_reg[0];
					if(brclk)
						state <= D1_STATE;
					else
						state <= D0_STATE;
				end
				
				D1_STATE :
				begin
					tx <= data_reg[1];
					if(brclk)
						state <= D2_STATE;
					else
						state <= D1_STATE;
				end
				
				D2_STATE :
				begin
					tx <= data_reg[2];
					if(brclk)
						state <= D3_STATE;
					else
						state <= D2_STATE;
				end
				
				D3_STATE :
				begin
					tx <= data_reg[3];
					if(brclk)
						state <= D4_STATE;
					else
						state <= D3_STATE;
				end
				
				D4_STATE :
				begin
					tx <= data_reg[4];
					if(brclk)
						state <= D5_STATE;
					else
						state <= D4_STATE;
				end
				
				D5_STATE :
				begin
					tx <= data_reg[5];
					if(brclk)
						state <= D6_STATE;
					else
						state <= D5_STATE;
				end
				
				D6_STATE :
				begin
					tx <= data_reg[6];
					if(brclk)
						state <= D7_STATE;
					else
						state <= D6_STATE;
				end
				
				D7_STATE :
				begin
					tx <= data_reg[7];
					if(brclk)
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
					
					if(brclk)
						state <= STOP_STATE;
					else
						state <= PARITY_STATE;
				end
				
				
				// Receive Stop bit state
				STOP_STATE:
				begin
					tx <= 1;
					if(brclk)
					begin
						state <= STOP_STATE;
						busy <= 0;
					end
					else
						state <= PARITY_STATE;
				end
				
				default : state <= IDLE_STATE;
			endcase
		end
    end   
endmodule
