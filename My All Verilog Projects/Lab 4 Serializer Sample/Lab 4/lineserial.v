module lineserial(Clk,Send,PDin,SCout,SDout,PDout,PDready);
	input Clk;
	input Send;
	input [7:0] PDin;
	
	output SCout;
	output SDout;
	output [7:0] PDout;
	output PDready;
	
	SerialTransmitter ST(.Clk(Clk),.Send(Send),.PDin(PDin),.SCout(SCout),.SDout(SDout));
	SerialReceiver SR(.SCin(SCout),.SDin(SDout),.PDout(PDout),.PDready(PDready));
	
endmodule



module SerialTransmitter(PDin, Clk, Send, SCout, SDout);
input Clk,Send; input [7:0] PDin;
output SCout,SDout;
reg [8:0] SRreg;
 reg [4:0] Cnt;
 reg SRshift;
assign SCout=Clk;

always @(posedge Clk)
	if(Send==1'b1 && Cnt[4:0]==4'b0)
		begin
			SRreg[8]<=1'b1;
			SRreg[7:0]<=PDin[7:0];
		end
	else
		if(SRshift==1'b1)
			begin
			SRreg[8:1]<=SRreg[7:0];
			SRreg[0]<=1'b0;
			end
		else
		SRreg[8:0]<=SRreg[8:0];

always @(posedge Clk)
	if(SRshift==1'b0)
	Cnt[4:0]<=4'b0;
	else
	Cnt[4:0]<=Cnt[4:0]+4'b1;

always @(posedge Clk)
	if(Send==1'b1)
		SRshift<=1'b1;
	else
		if(Cnt==4'd8)
			SRshift<=1'b0;
		else
			SRshift<=SRshift;

assign SDout=SRreg[8];
endmodule







module SerialReceiver(SCin,SDin,PDout,PDready);
	input SCin;  			//Clock input,  SDin  is valid at the rising clock edge. 
	input SDin;  			//Serial data input, set to 0 when it is idle. 
	output reg[7:0] PDout;		//8-bit parallel data output,  PDout[7]  is the first bit received. 
	output PDready;  		//One-clock-cycle output pulse generated after the last serial data bit is received. 

	reg [2:0] Cntr;
	reg SRshift_R;			//is counter active or not active?
	reg SRshift_gg;			//one clock cycle delayed SRshift_R


// Describe the counter
always @(posedge SCin)  // a simple counter enabled by SRshift
begin    
	if (SRshift_R == 1'b0)      
		Cntr[2:0] <= 3'd0; // reset the counter    
	else 
		Cntr[2:0] <= Cntr[2:0] + 3'd1;  // increment the counter  
end



always @(posedge SCin)
begin
	if (Cntr[2:0] == 3'd7)
		SRshift_R <= 1'b0;  // reset when counter reaches 7
	else
		if(SDin == 1'b1)	//starting bit of SDout is 1 and first bit for receiver
			SRshift_R <= 1'b1;
		else
			SRshift_R <= SRshift_R;  // keep the last value
end

always @(posedge SCin)
begin
	if(SRshift_R == 1'b1)
		begin
			PDout[7:1] <= PDout[6:0];
			PDout[0] <= SDin;
		end
	else
		PDout[7:0] <= PDout[7:0];
end	
		
always @(posedge SCin)
	SRshift_gg <= SRshift_R;		//decision of PDready is 1/0.

	assign PDready = ((SRshift_R == 1'b0) && (SRshift_gg == 1'b1))? 1'b1 : 1'b0;

endmodule

