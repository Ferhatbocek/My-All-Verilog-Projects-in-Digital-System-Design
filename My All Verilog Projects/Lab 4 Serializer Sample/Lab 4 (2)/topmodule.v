module topmodule(Clk,Send,PDin,PDout,PDready);

input Clk;
input Send;
input [7:0] PDin;

output PDready;
output [7:0] PDout;

wire SDout;
wire SCout;

serialtransmitter X(Clk,Send,PDin,SCout,SDout);
serialreceiver Y(SCout, SDout, PDout, PDready);

endmodule 



module serialtransmitter(Clk,Send,PDin,SCout,SDout);
input Clk;
input Send;
input [7:0] PDin;

output SCout;
output reg SDout;

reg [8:0] SR;
assign SCout = Clk; 

always @(posedge Clk)
begin

	if (Send == 1'b1)
		begin
		SR[7:0] <= PDin[7:0];
		SR[8] <= 1'b1;
		end
	else
		begin 
		SDout <= SR[8]; 
		SR[8:1] <= SR[7:0]; 
		SR[0] <= 1'b0;
			if(SR[8:0] == 9'b0)
			SDout <= 0;
		end
end
endmodule


module serialreceiver(SCin, SDin, PDout, PDready);
input SCin;
input SDin;

output reg PDready;
output reg [7:0] PDout;

reg [3:0] counter = 4'b0; 


always@(posedge SCin)
begin
PDout[0] <= SDin;   //SDin transmitter çýkýþý
PDout[7:1] <= PDout[6:0];
	if(SDin == 1'b1)
		begin
		if(counter[3:0] == 4'b0)
			begin
			PDready <= 0;
			counter[3:0] <= counter[3:0] + 1;
			end
		else if(counter[3:0] == 4'b1001)
			begin
			PDout[7:0] <= PDout[7:0];
			PDready <= 0;
			counter[3:0] <= 4'b1001;
			end
		else
			begin
			counter[3:0] <= counter[3:0] + 1; 
			PDready <= 0;
				if(counter[3:0] == 4'b1000)
					begin
					PDready <= 1;
					end
			end
		end
	
	else
		begin
			if(counter[3:0] == 4'b0)
				begin
				PDout[7:0] <= 0;
				PDready <= 0;
				end
			else if(counter[3:0] == 4'b1001)
				begin
				PDout[7:0] <= PDout[7:0];
				PDready <= 0;
				counter[3:0] <= 4'b1001;
				end
			else
				begin
				counter[3:0] <= counter[3:0] + 1; 
				PDready <= 0;
					if(counter[3:0] == 4'b1000)
					begin
					PDready <= 1;
					end
				end
		end

end

endmodule 

