`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2023 22:47:16
// Design Name: 
// Module Name: spi_controller
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

module spi_controller #(parameter data=32,addr=32)(
    input PCLK,
	input PRESETn,
	input PWRITE,
	
	input [addr-1:0] PADDR,
	input [data-1:0] PWDATA,
	input [data-1:0] MRDATA,     // to read the data
	
	input [7:0]SPISR_M,
	
	output SPIF,
	output SPTEF,
    output MODF,

	output reg [addr-1:0]PADDR_op=0,
	output reg [data-1:0]PWDATA_op=0,                     
	output reg [data-1:0]PRDATA = 0
    );
	 
	assign SPIF=SPISR_M[7];
    assign SPTEF=SPISR_M[5];
    assign MODF=SPISR_M[4];	
	
	reg [1:0] current_state,next_state;
	
	always@(posedge PCLK) 
	begin
        if(PADDR[7:0] == 8'h00) 
        begin 
			if(PWRITE == 1) 
			begin                                             
                PADDR_op[7:0] <= PWDATA[7:0];          // REGISTER CONFIGURATION   SPICR-1
                PADDR_op[15:8] <= PWDATA[15:8];        // REGISTER CONFIGURATION   SPICR-2
		    end
					
		    else 
		    begin                                           
            //  PRDATA[7:0] <= SPICR_C;
                PRDATA[7:0] <= SPISR_M;
			end			
		end
				
		else if(PADDR[7:0] == 8'h02 && PWRITE == 1) 
		begin                                               
			 PWDATA_op[31:0] <= PWDATA[31:0];
		end
					
		else if(PADDR[7:0] == 8'h04 && PWRITE == 0)
        begin                                            
            PRDATA <= MRDATA;
        end
        
		else 
		begin
		     PADDR_op[31:16]=PADDR[31:16];
	    end
    end
endmodule





