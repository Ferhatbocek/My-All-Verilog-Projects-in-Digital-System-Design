module LAB6v2(Clk,D1,D2,CarNum);
	input Clk;
	input D1,D2;
	output [3:0] CarNum;
	
	reg [3:0] Cntr;
	reg [2:0] SS;
	reg [2:0] SS2;
	
	parameter S0 = 3'b000, S1 = 3'b010, S2 = 3'b011, S3 = 3'b001, S4 = 3'b100;
	
	always @(posedge Clk)
	begin
		if(SS[2:0] == S4)
			Cntr[3:0] <= Cntr[3:0] + 1'b1;
		else if(SS2[2:0] == S4)
			Cntr[3:0] <= Cntr[3:0] - 1'b1;
		else
			Cntr[3:0] <= Cntr[3:0];
	end
	
	
	always@(posedge Clk)
	begin
		case(SS)
	S0:		if(D1==1'b0 && D2==1'b0)
				SS[2:0] = SS[2:0];
			else if(D1==1'b1 && D2==1'b0)
				SS[2:0] = S1;
	
	S1: 	if(D1==1'b1 && D2==1'b0)
				SS[2:0] = SS[2:0];
			else if(D1==1'b0 && D2==1'b0)
				SS[2:0] = S0;
			else if(D1==1'b1 && D2==1'b1)
				SS[2:0] = S2;
		
	S2:		if(D1==1'b1 && D2==1'b1)
				SS[2:0] = SS[2:0];
			else if(D1==1'b1 && D2==1'b0)
				SS[2:0] = S1;
			else if(D1==1'b0 && D2==1'b1)
				SS[2:0] = S3;
	
	S3:		if(D1==1'b0 && D2==1'b1)
				SS[2:0] = SS[2:0];
			else if(D1==1'b1 && D2==1'b1)
				SS[2:0] = S2;
			else if(D1==1'b0 && D2==1'b0)
				SS[2:0] = S4;

	S4:			SS[2:0] = S0;
	
	default: 	SS[2:0] = S0;
	endcase
	end
	
	always @(posedge Clk)
	begin
		case(SS2)
	S0:		if(D1==1'b0 && D2==1'b0)
				SS2[2:0] = SS2[2:0];
			else if(D1==1'b0 && D2==1'b1)
				SS2[2:0] = S3;
	
	S1:		if(D1==1'b1 && D2==1'b0)
				SS2[2:0] = SS2[2:0];
			else if(D1==1'b0 && D2==1'b0)
				SS2[2:0] = S4;
			else if(D1==1'b1 && D2==1'b1)
				SS2[2:0] = S2;

	S2:		if(D1==1'b1 && D2==1'b1)
				SS2[2:0] = SS2[2:0];
			else if(D1==1'b0 && D2==1'b1)
				SS2[2:0] = S3;
			else if(D1==1'b1 && D2==1'b0)
				SS2[2:0] = S1;
	
	S3:		if(D1==1'b0 && D2==1'b1)
				SS2[2:0] = SS2[2:0];
			else if(D1==1'b1 && D2==1'b1)
				SS2[2:0] = S2;
			else if(D1==1'b0 && D2==1'b0)
				SS2[2:0] = S0;
	
	S4:			SS2[2:0] = S0;
	
	default:	SS2[2:0] = S0;
	endcase
	end
	
	assign CarNum[3:0] = Cntr[3:0];
	
endmodule
