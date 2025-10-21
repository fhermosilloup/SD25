`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Universidad Panamericana
// Engineer: 
// 
// Create Date: 15.09.2025 12:56:40
// Design Name: 
// Module Name: UartReceiver
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
// This file contains the UART Receiver.  
// * This receiver is able to receive 8 bits of serial data, one start bit, one stop bit, and may be parity bit.
// * When receive is complete data_ready will be driven high for one clock cycle.
// * When parity is enabled, if a package error is detected, "perr" signal will be driven high until the uart reception is completed.
// 
//////////////////////////////////////////////////////////////////////////////////


module UartReceiver #(parameter CLK_FREQ_HZ=100000000, parameter BAUDRATE=9600)(
	input wire clk,      	 // Uart Clock
	input wire rst,      	 // Uart Reset
	input wire rx,       	 // RX Serial input
	input wire pen,          // Parity Enabled flag
	input wire peven,        // Even Parity flag
	output reg busy,         // Receiver busy flag
	output reg data_ready,	 // Data ready flag
	output reg perr,	     // Parity error flag
  	output reg [7:0] dout 	 // Data Output Register
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
  
	reg rx_prev = 1'b1;
	reg rx_stable = 1'b1;
	reg [7:0] data_reg     = 0;
	reg [3:0] state = IDLE_STATE;
	wire parity = data_reg[0] ^ data_reg[1] ^ data_reg[2] ^ data_reg[3] ^ data_reg[4] ^ data_reg[5] ^ data_reg[6] ^ data_reg[7];
	
    // Purpose: Double-register the incoming data.
    // This allows it to be used in the UART RX Clock Domain.
    // (It removes problems caused by metastability)
    always @(posedge clk)
    begin
		if(!rst)
		begin
			rx_prev <= 1;
			rx_stable <= 1;
		end
		else
		begin
			rx_prev <= rx;
			rx_stable   <= rx_prev;
		end
    end 
	
	// Baudrate tick generator
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
			  brtick <= 0;
			end
		  else
			begin
			  brcnt <= brcnt + 1;
			  if(brcnt == BRCLOCK_CYCLES/2 - 1)
				brtick <= 1;
			  else
				brtick <= 0;
			end
		end
	end
    // Purpose: Control RX state machine
    always @(posedge clk)
    begin
		if(!rst)
		begin
			busy <= 0;
			data_ready <= 0;
			perr <= 0;
			state <= IDLE_STATE;
			data_reg <= 0;
		  	dout <= 0;
		  	brcnt_rst <= 0;
		end
		else
		begin
			case (state)
				IDLE_STATE :
				begin
					data_ready <= 0;
					perr <= 0;
					if (!rx_stable)          // Start bit detected
					begin
					  state <= START_STATE;
					  busy <= 1;
					  brcnt_rst <= 1;
					end
					else
					begin
					  state <= IDLE_STATE;
					  busy <= 0;
					  brcnt_rst <= 0;
					end
				end
				 
				// Check middle of start bit to make sure it's still low
				START_STATE :
				begin
					if (brtick)
					begin
						if (rx_stable == 1'b0)
						begin
							state <= D0_STATE;
						end
						else
						  state <= IDLE_STATE;
					  end
					else
					begin
						state <= START_STATE;
					end
				end
				 
				 
				// Wait CYCLES_PER_BIT-1 clock cycles to sample serial data at the middle
				D0_STATE :
				begin
					if (brtick)
					begin
						data_reg[0] <= rx_stable;
						state <= D1_STATE;
					end
					else
						state <= D0_STATE;
				end
				
				D1_STATE :
				begin
					if (brtick)
					begin
						data_reg[1] <= rx_stable;
						state <= D2_STATE;
					end
					else
						state <= D1_STATE;
				end
				
				D2_STATE :
				begin
					if (brtick)
					begin
						data_reg[2] <= rx_stable;
						state <= D3_STATE;
					end
					else
						state <= D2_STATE;
				end
				
				D3_STATE :
				begin
					if (brtick)
					begin
						data_reg[3] <= rx_stable;
						state <= D4_STATE;
					end
					else
						state <= D3_STATE;
				end
				
				D4_STATE :
				begin
					if (brtick)
					begin
						data_reg[4] <= rx_stable;
						state <= D5_STATE;
					end
					else
						state <= D4_STATE;
				end
				
				D5_STATE :
				begin
					if (brtick)
					begin
						data_reg[5] <= rx_stable;
						state <= D6_STATE;
					end
					else
						state <= D5_STATE;
				end
				
				D6_STATE :
				begin
					if (brtick)
					begin
						data_reg[6] <= rx_stable;
						state <= D7_STATE;
					end
					else
						state <= D6_STATE;
				end
				
				D7_STATE :
				begin
					if (brtick)
					begin
						data_reg[7] <= rx_stable;
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
					if (brtick)
					begin
						// Check parity
						if(peven)
							if(parity)
								perr <= 0;
							else
								perr <= 1;
						else
							if(parity)
								perr <= 1;
							else
								perr <= 0;
					end
					else
						state <= PARITY_STATE;
				end
				
				
				// Receive Stop bit state
				STOP_STATE:
				begin
					if (brtick)
					begin
						dout <= data_reg;
						data_ready <= 1;
						brcnt_rst <= 0;
						busy <= 0;
						state <= IDLE_STATE;
					end
					else
						state <= STOP_STATE;
				end
				
				default : state <= IDLE_STATE;
			endcase
		end
    end   
endmodule
