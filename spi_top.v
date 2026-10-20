`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2023 18:25:10
// Design Name: 
// Module Name: spi_top
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


module spi_top #(parameter data=32,addr=32)(
    input wire PRESETn,
	input wire PCLK,
	input wire PENABLE,
	input wire PSEL,
	input wire PWRITE,
	
	input wire [addr-1:0] PADDR,
	input wire [data-1:0] PWDATA,
	input wire [7:0]baud_ip,
	//input wire miso,
	
	output wire SPIF,
    output wire SPTEF,
    output wire MODF,
    
	output wire [data-1:0] PRDATA,
	output wire ss,
	output wire sclk,
	output wire mosi
    );
    
    // input output wires
    wire clock_in,clock_out;
    wire [7:0]SPIBDR;
    wire [data-1:0] PWDATA_op,MWDATA,MRDATA,MRDATA_op,buffer;  
    wire [addr-1:0] PADDR_op,MADDR;
    wire [7:0]SPICR_1,SPICR_2,SPIDR,SPISR,SPISR_M;
    wire miso;
    
    clk_div CLK_DIVIDER(
    .clock_in(PCLK),                      
    .SPIBDR(baud_ip),               // 7-RESERVED 6-SPPR2, 5-SPPR1, 4-SPPR0, 3-RESERVED, 2-SPR2, 1-SPR1, 0-SPR0            
    .clock_out(clock_out)
    );
    
    spi_controller SPI_CONTROLLER(
    .PCLK(clock_out),
	.PRESETn(PRESETn),
	.PWRITE(PWRITE),
	.PADDR(PADDR),
	.PWDATA(PWDATA),
	.MRDATA(MRDATA_op),     
	.SPISR_M(SPISR),
	.SPIF(SPIF),
	.SPTEF(SPTEF),
    .MODF(MODF),
	.PADDR_op(PADDR_op),
	.PWDATA_op(PWDATA_op),                     
	.PRDATA(PRDATA) 
    );
    
    spi_master SPI_MASTER(
    .PRESETn(PRESETn),
    .PCLK(clock_out),
    .miso(buffer[31]),
    .MADDR(PADDR_op),
    .MWDATA(PWDATA_op),
    .SPICR_1(PADDR_op[7:0]),                    // 7-6 RESERVED 5-SPIF, 4-SPE, 3-MSTR, 2-CPOL, 1-CPHASE, 0-LSBFE
    .SPICR_2(PADDR_op[15:8]),                    // 7 to 1-RESERVED, 0-SPC0
    .SPISR(SPISR),                               // 7-3 RESERVED 2-TXCR 1-TXCW 0-SPTEF                
    .MRDATA_op(MRDATA_op),
    .buffer(buffer),
    .ss(ss),
    .sclk(sclk),
    .mosi(mosi)  
    );
    
endmodule
