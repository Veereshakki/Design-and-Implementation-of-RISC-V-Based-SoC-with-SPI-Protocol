`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.07.2023 09:33:33
// Design Name: 
// Module Name: clk_div
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


module clk_div(clock_in,SPIBDR,clock_out);
input clock_in;                           
input [7:0]SPIBDR;                         // 7-RESERVED 6-SPPR2, 5-SPPR1, 4-SPPR0, 3-RESERVED, 2-SPR2, 1-SPR1, 0-SPR0            
output wire clock_out;                     // output clock after dividing the input clock by divisor
reg clock_2;                               
reg [3:0] counter = 4'd0;
reg [3:0] DIVISOR = 4'd0;

assign clock_out = (DIVISOR==4'd1)?clock_in:clock_2;

always @(posedge clock_in)
begin
if(SPIBDR[6:4]==3'b000 && SPIBDR[2:0]==3'b000)
    DIVISOR <= 4'd1;
else if(SPIBDR[6:4]==3'b000 && SPIBDR[2:0]==3'b001)
    DIVISOR <= 4'd2;
else if(SPIBDR[6:4]==3'b000 && SPIBDR[2:0]==3'b010)
    DIVISOR <= 4'd4;
else if(SPIBDR[6:4]==3'b000 && SPIBDR[2:0]==3'b011)
    DIVISOR <= 4'd8;
else
    DIVISOR <= 4'd1;
  
 if(DIVISOR>4'd1)
  begin
    counter <= counter + 4'd1;
    if(counter>=(DIVISOR-1))
    counter <= 4'd0;
    clock_2 <= (counter<DIVISOR/2)?1'b1:1'b0;
  end
end
endmodule
