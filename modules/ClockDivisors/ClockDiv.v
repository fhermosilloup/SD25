`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2025 00:35:06
// Design Name: 
// Module Name: ClockDiv
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


module ClockDiv #(parameter FREQ_IN = 100000000, parameter FREQ_OUT = 1)(
    input wire clk,
    input wire rst,
    output reg clkout
);
    localparam QMAX = (FREQ_IN/FREQ_OUT)/2; 
    reg [$clog2(QMAX)-1:0] q = 0;
    
    always @(posedge clk)
    begin
        if(!rst)
        begin
            q <= 0;
            clkout <= 0;
        end
        else
            if(q == QMAX-1)
            begin
                q <= 0;
                clkout <= ~clkout;
            end
            else
                q <= q + 1;
    end
endmodule
