module LAB6v1(Clk,D1,D2,CarNum);
	input Clk;
	input D1,D2;
	output [3:0] CarNum;
	
	reg [3:0] Cntr;
	reg [7:0] SS;
	
	
	parameter S0 = 8'b0, S1 = 8'b00000001, S2 = 8'b00000010, S3 = 8'b00000100, S4 = 8'b00001000;
	
	always @(posedge Clk)
		if(SS[7:0] == S4)
			Cntr[3:0] <= Cntr[3:0] + 1'b1;
		else
			Cntr[3:0] <= Cntr[3:0];
	always@(posedge Clk)
	begin
		case(SS)
	S0:		if(D1==1'b0 && D2==1'b0)
				SS[7:0] = SS[7:0];
			else if(D1==1'b1 && D2==1'b0)
				SS[7:0] = S1;
	
	S1: 	if(D1==1'b1 && D2==1'b0)
				SS[7:0] = SS[7:0];
			else if(D1==1'b0 && D2==1'b0)
				SS[7:0] = S0;
			else if(D1==1'b1 && D2==1'b1)
				SS[7:0] = S2;
		
	S2:		if(D1==1'b1 && D2==1'b1)
				SS[7:0] = SS[7:0];
			else if(D1==1'b1 && D2==1'b0)
				SS[7:0] = S1;
			else if(D1==1'b0 && D2==1'b1)
				SS[7:0] = S3;
	
	S3:		if(D1==1'b0 && D2==1'b1)
				SS[7:0] = SS[7:0];
			else if(D1==1'b1 && D2==1'b1)
				SS[7:0] = S2;
			else if(D1==1'b0 && D2==1'b0)
				SS[7:0] = S4;

	S4:			SS[7:0] = S0;
	
	default: 	SS[7:0] = S0;
	endcase
	end
	assign CarNum[3:0] = Cntr[3:0];
	
endmodule
