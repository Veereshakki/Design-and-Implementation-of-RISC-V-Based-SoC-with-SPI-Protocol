`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.07.2023 11:49:50
// Design Name: 
// Module Name: spi_master
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

module spi_master #(parameter data=32,addr=32)(
input PRESETn,
input PCLK,

input miso,

input [addr-1:0]MADDR,
input [data-1:0]MWDATA,
                                       
input [7:0]SPICR_1,                 // 7-RESERVED 6-SPE, 5-SPTIE, 4-MSTR, 3-CPOL, 2-CPHASE, 1-SSOE, 0-LSBFE
input [7:0]SPICR_2,                 // 7 to 1-RESERVED, 0-SPC0
          
output reg [7:0]SPISR=8'ha0,              // 7-SPIF, 6-RESERVED, 5-SPTEF, 4-MODF, 3 to 0-RESERVED     
output reg [data-1:0]MRDATA_op,
output reg [data-1:0]buffer,
output reg ss=1,
output reg sclk=0,
output reg mosi=0  
    );
    
reg [3:0] count1=4'b0,count2=4'b0; 
reg [2:0]scount=3'b0;
reg clken;
reg [7:0]SPIDR_W[0:3];
reg [7:0]SPIDR_R[0:3];

localparam idle=2'b00, setup = 2'b01, write = 2'b10, read = 2'b11;

reg [1:0]current_state,next_state;

always@(posedge PCLK,negedge PCLK)
begin
	if(clken)
	   sclk=~sclk;
	else if(SPICR_1[3]==1'b0 && SPICR_1[2]==1'b0)           //   00  cpol, cphase
		sclk=1'b0;
	else if(SPICR_1[3]==1'b0 && SPICR_1[2]==1'b1)           //   01
		sclk=1'b1;
	else if(SPICR_1[3]==1'b1 && SPICR_1[2]==1'b0)           //   10
        sclk=1'b0;
    else if(SPICR_1[3]==1'b1 && SPICR_1[2]==1'b1)           //   11
        sclk=1'b1;
	else
	    sclk=1'b0;
end

always@(posedge PCLK,negedge PRESETn)
begin
    if(!PRESETn)
    begin
        current_state <= idle;
    end
    else
    begin
        current_state <= next_state;
    end
end

	always@(posedge PCLK)
	begin
		case(current_state)
			idle:
			begin
                if(SPICR_1[6]==1)
                begin
                    SPIDR_W[0][7:0]<=0;
                    SPIDR_W[1][7:0]<=0;
                    SPIDR_W[2][7:0]<=0;
                    SPIDR_W[3][7:0]<=0;
                    
                    SPIDR_R[0][7:0]<=0;
                    SPIDR_R[1][7:0]<=0;
                    SPIDR_R[2][7:0]<=0;
                    SPIDR_R[3][7:0]<=0;  
                    
                    next_state <= setup;
                end
                else
                begin
                    next_state <= idle;
                end
            end
            
			setup:
			begin
			     buffer <= MWDATA;
			     if(SPICR_1[1]==1'b1)
			     begin
			        ss<=1'b0;                              // slave select active low
			     end
			    
                 if(SPICR_1[4]==1'b1 && SPICR_2[0]==1'b1 && SPISR[5]==1'b1)
                 begin
                    SPISR[7]=1;
                    if(SPICR_1[0]==1)                      // lsb first
                    begin
                        SPIDR_W[0][7:0]<= MWDATA[7:0];
                        SPIDR_W[1][7:0]<= MWDATA[15:8];
                        SPIDR_W[2][7:0]<= MWDATA[23:16];
                        SPIDR_W[3][7:0]<= MWDATA[31:24];
                    end
                    
                    else if(SPICR_1[0]==0)                 //msb first
                    begin
                        SPIDR_W[3][7:0]<= MWDATA[7:0];
                        SPIDR_W[2][7:0]<= MWDATA[15:8];
                        SPIDR_W[1][7:0]<= MWDATA[23:16];
                        SPIDR_W[0][7:0]<= MWDATA[31:24];
                    end
                
                    next_state <= write;
                 end
                
                 else if(SPICR_1[4] == 1'b0 && SPICR_2[0]==1'b0)
		         begin
			         next_state <= read;
		         end
		          
		         else if(SPICR_1[6]==0)
		         begin
	                 next_state <= idle;
		         end
			end
			
			write:
			begin
				if(SPISR[7]==1)                                  //SPIF
				begin
				    if(scount<3'd4)
				    begin
					   if(count1<4'd8)                             // 8bit BIT
					   begin
					       clken=1'b1;
					       SPISR[5]<=1'b0;                       //SPTEF=0;
						   mosi<=SPIDR_W[scount][4'h7-count1];
						   count1=count1+1'b1;
					   end
					
					   if(count1==4'd8)                      // 32 BIT
					   begin						
						  count1=0;
						  scount=scount+1;
						  next_state<=write;
					   end
				   end
				   
				   else if(scount==3'd4)
				   begin
				       clken=1'b0;
				       scount=3'b0;
				       SPISR[7]<=1'b0;        //SPIF=0
				       SPISR[5]<=1'b1;        //SPTEF=1
				       next_state<=idle;
				   end
				end
				
				else if(SPICR_1[6]==1'b0)
				begin
			        next_state<=idle;
				end
		    end
			
			read:
			begin
			    if(scount<3'd4)
			    begin
				    if(count2<4'd8)                            //32 BIT
				    begin
					   clken=1'b1;
					   SPISR[5]=1'b0;                       //SPTEF=0
					   SPIDR_R[scount][4'h7-count2]<=miso;
					   count2=count2+1'b1;
					   buffer={buffer[30:0],1'b0};
				    end
				
				    if(count2==4'd8)
				    begin   
					   count2<=0;
					   scount<=scount+1;					
					   next_state<=read;
				    end
			     end
			
			if(scount==3'd4)
			begin
			     scount=3'b0;
			     clken=1'b0;
			     SPISR[5]=1'b1;                        //SPTEF=1	
			     MRDATA_op[7:0]=SPIDR_R[3][7:0];
			     MRDATA_op[15:8]=SPIDR_R[2][7:0];
			     MRDATA_op[23:16]=SPIDR_R[1][7:0];
			     MRDATA_op[31:24]=SPIDR_R[0][7:0];
			     next_state<=idle;
			end
		
		else if(SPICR_1[6]==1'b0)
			begin
		        next_state<=idle;
			end
		end
					
    		default:
			begin
				next_state<=idle;
			end
		endcase
	end
endmodule
