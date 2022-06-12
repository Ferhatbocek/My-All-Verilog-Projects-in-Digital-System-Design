module Lab2(
	input nReset,
	input Clock,
	input Enable,
	output [3:0] Co1,
	output [3:0] Co10,
	output [3:0] Co100
);
	wire [1:0] next;
	BCD_Counter Module1(.Clk(Clock), .nRst(nReset), .Cout(Co1), .CntEn(Enable), .NextEn(next[0]));
    BCD_Counter Module2(.Clk(Clock), .nRst(nReset), .Cout(Co10), .CntEn(next[0]), .NextEn(next[1]));
	BCD_Counter Module3(.Clk(Clock), .nRst(nReset), .Cout(Co100), .CntEn(next[1]), .NextEn( ));

endmodule

module BCD_Counter(
	input nRst,
	input Clk,
	input CntEn,
	output [3:0] Cout,
	output NextEn
);

	reg [3:0] counter;
	
	always @ (posedge Clk or negedge nRst)
	begin
		if(nRst == 1'b0)
			counter[3:0] <= 4'b0;
		else
			if(CntEn == 1'b1)
				if(counter == 4'd9)
				    counter[3:0] <= 4'b0;
				else
					counter[3:0] <= counter[3:0] + 4'b1;	
						
	end
	
	assign Cout[3:0] = counter[3:0];
	assign NextEn = (counter[3:0] == 4'd9) ? CntEn : 1'b0;
	
endmodule	