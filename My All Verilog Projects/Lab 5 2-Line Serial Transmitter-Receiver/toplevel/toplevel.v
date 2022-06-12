module toplevel(Clk,Send,PDin,PDout,PDready,ParErr);

input Clk;
input Send;
input [7:0] PDin;

output PDready;
output [7:0] PDout;
output ParErr; 

wire SDout;
wire SCout;


serialtransmitter X(Clk,Send,PDin,SCout,SDout);
serialreceiver Y(SCout, SDout, PDout, PDready,ParErr);

endmodule 

 

module serialtransmitter(Clk,Send,PDin,SCout,SDout);
input Clk;
input Send;
input [7:0] PDin; 

output SCout; 
output reg SDout;

reg [9:0] SR; 
assign SCout = Clk; 
wire A; 
wire Send2; 
reg Send1;
assign A = ^PDin[7:0]; 


always@(posedge Clk)
begin
	Send1 <= Send;
end
assign Send2 = Send & ~Send1; 

always @(posedge Clk)
begin
	if (Send2 == 1'b1)  
	begin
		if(SR[9:0] == 10'b0 ) 
		begin
			SR[9] <= 1'b1; 
			SR[8:1] <= PDin[7:0]; 
			SR[0] <= A; 
			SDout <=1'b0; 
		end
		else  
		begin
			SDout <= SR[9];  
			SR[9:1] <= SR[8:0]; 
			SR[0] <= 1'b0; 
		end
	end
	else 
	begin 
		if(SR[9:0] == 10'b0 )  
		begin
			SDout <= 1'b0;  
		end
		else 
		begin
			SDout <= SR[9]; 
			SR[9:1] <= SR[8:0]; 
			SR[0] <= 1'b0;
		end
	end
end
endmodule 

//SERIAL RECEÝVER

module serialreceiver(SCin, SDin, PDout, PDready,ParErr);
input SCin;
input SDin;

output reg PDready;
output reg [7:0] PDout;
output reg ParErr;

reg [3:0] counter = 4'b0; 

always@(posedge SCin)
begin

	PDout[0] <= SDin;  
	PDout[7:1] <= PDout[6:0];
	
	
	if(SDin == 1'b1) 
	begin
		if(counter[3:0] == 4'b0000) 
		begin
			PDout <= 1'b0; 
			PDready <= 0; 
			counter[3:0] <= counter[3:0] + 1'b1; 
		end
		else if(counter[3:0] == 4'b1010) 
		begin
			PDready <= 0; 
			PDout[7:0] <= 8'b0;
			counter[3:0] <= 4'b0000; 
		end
		else
		begin
			counter[3:0] <= counter[3:0] + 1'b1; 
			PDready <= 0;
			if(counter[3:0] == 4'b1001) 
			begin
				PDready <= 1'b1; 
				PDout[7:0] <= PDout[7:0];
				ParErr <= SDin^(^PDout[7:0]); 
			end                               
		                                      
		end
	end
	
	else
	begin
		if(counter[3:0] == 4'b0)  
		begin
			PDout<=1'b0;
			PDout[7:0] <= 0;
			PDready <= 0;
		end
		else if(counter[3:0] == 4'b1010) 
		begin
			PDready <= 0;
			counter[3:0] <= 4'b0000;
			PDout[7:0] <= 8'b0;
		end
		else
		begin
			counter[3:0] <= counter[3:0] + 1'b1; 
			PDready <= 0;
			if(counter[3:0] == 4'b1001) 
			begin
				PDready <= 1;
				PDout[7:0] <= PDout[7:0];
				ParErr <= SDin^(^PDout[7:0]); 

			end
		end
	end
		
end
endmodule 