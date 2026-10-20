`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2023 18:59:11
// Design Name: 
// Module Name: spi_top_tb
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


module spi_top_tb;
  
  parameter data=32,addr=32;
  
    reg PRESETn;
	reg PCLK;
	reg PENABLE;
	reg PSEL;
	reg PWRITE;
	
	reg [addr-1:0] PADDR;
	reg [data-1:0] PWDATA;
	reg [7:0]baud_ip;
	
	wire SPIF;
    wire SPTEF;
    wire MODF;
    
	wire [data-1:0] PRDATA;
	wire ss;
	wire sclk;
    wire mosi;
    
    spi_top uut(
    .PRESETn(PRESETn),
	.PCLK(PCLK),
	.PENABLE(PENABLE),
	.PSEL(PSEL),
	.PWRITE(PWRITE),
	
	.PADDR(PADDR),
	.PWDATA(PWDATA),
	.baud_ip(baud_ip),
	//input wire miso,
	
	.SPIF(SPIF),
	.SPTEF(SPTEF),
    .MODF(MODF),
    
	.PRDATA(PRDATA),
	.ss(ss),
	.sclk(sclk),
	.mosi(mosi)
    );

    initial
    begin
        PCLK=0;
        forever #1 PCLK=~PCLK;
    end
    
    initial 
    begin
        PRESETn=0;
        PADDR = 0;
        PWDATA =0;
        PSEL=0;
        PENABLE = 0;
        PWRITE = 0; 
        #1
        
        PRESETn=1;
	    PCLK=1;
	    PENABLE=1;
	    PSEL=1;
	    baud_ip=8'h00;
	    #2
	    
        PADDR=8'h00;
        PWRITE=0;
        #1
        
        PWRITE=1;
        #1
        
        PADDR=8'h00;                                     // REGISTERS CONFIG  write
        PWRITE=1; 
        PWDATA=32'b00000000000000000000000101110010;    //7-0 SPICR_1, 15-8 SPICR_2
        #2
        
        PADDR=8'h02;
        PWDATA=32'h501acf1a;
        #72
        
        PADDR=8'h00;   
        PWDATA=32'b00000000000000000000000001100010;           //read
        #76

        PADDR=8'h04;
        PWRITE=1'b0;
        #4
        
        PADDR=8'h00;
        PWRITE=0;
        #1
        
        PWRITE=1;
        #1
        
        PADDR=8'h00;                                     // REGISTERS CONFIG  write
        PWRITE=1; 
        PWDATA=32'b00000000000000000000000101110010;    //7-0 SPICR_1, 15-8 SPICR_2
        #2
        
        PADDR=8'h02;
        PWDATA=32'habcdef7a;
        #72
        
        PADDR=8'h00;   
        PWDATA=32'b00000000000000000000000001100010;           //read
        #76;
       
        end
endmodule
