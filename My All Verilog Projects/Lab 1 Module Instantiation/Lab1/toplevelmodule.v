module toplevelmodule(Clk, nReset, select, fout);

input Clk, nReset, select;
output fout;


wire [2:0]lines;


Counter3bit Cl(lines, Clk, nReset);
andexfunc Sl(lines[0], lines[2], select, fout);

endmodule


module Counter3bit(CountOut, Clk, nReset);
output reg [2:0] CountOut;  // counter output
input Clk;              // clock input
input nReset;           // asynchronous reset


always @(posedge Clk or negedge nReset)
begin
if(nReset == 1'b0)
CountOut[2:0] <= 3'b0; // reset the counter
else
CountOut[2:0] <= CountOut[2:0] + 3'b1; // increment
end
endmodule 



module andexfunc(op1, op2, select, fout);
input op1, op2, select;
output fout;
   
assign fout = (select == 1'b0) ? (op1 & op2) : (op1 ^ op2);     

endmodule 