module lab3 
(
	input wire Clk,SwOut,
	output wire SwOutDB1, SwOutDB2
);

	debouncer1 db1(SwOut,Clk,SwOutDB1);
	debouncer2 db2(SwOut,Clk,SwOutDB2);

endmodule




module debouncer1   //clock 1 ms and total 4 ms delay
(
	input wire SwOut, Clk1ms,
	output reg SwOutDB1
);
reg [3:0] flip;

// 4ms delay and 1ms clock

always @(posedge Clk1ms) //shift register
begin
	flip[3:0] <= {flip[2:0], SwOut};
end

always @(posedge Clk1ms) //debouncer 1 
begin
	if(&flip[3:0])
		SwOutDB1 <= 1'b1;
	else 
	begin
		if (~(|flip[3:0]))
			SwOutDB1 <= 1'b0;
		else
			SwOutDB1 <= SwOutDB1;
	end	
end


endmodule



// 3ms bir deðer görsün ki kullanýcýnýn verdiði deðerinin deðiþtiðini anlasýn
module debouncer2
(
	input wire SwOut, Clk1ms,
	output reg SwOutDB2 
);
reg [2:0] flip;


always @(posedge Clk1ms) //shift register
begin
	flip[2:0] <= {flip[1:0], SwOut};
end

always @(posedge Clk1ms) //debouncer 2 
begin
	
	if((&flip[2:0]) & (SwOut == 1'b0))    // 0111 
		SwOutDB2 <= 1'b0;
	else 
	begin
		if ((~(|flip[2:0])) & (SwOut == 1'b1)) // 1000
			SwOutDB2 <= 1'b1;
		else
			SwOutDB2 <= SwOutDB2;
	end	
	
end

endmodule



