`timescale 1ns/10ps

module fullAdder (a, b, Cin, sum, Cout);

	input logic a, b, Cin;
	output logic sum, Cout;
	
	logic ab, bCin, aCin;
	
   xor #0.05 c (sum, a, b, Cin);
	
	and #0.05 d (ab, a, b);
	and #0.05 e (bCin, b, Cin);
	and #0.05 f (aCin, a, Cin);
	
	or #0.05 g (Cout, ab, bCin, aCin);
   
endmodule


module fullAdder_testbench();

	logic a, b, Cin, sum, Cout;
	
	fullAdder dut (.a, .b, .Cin, .sum, .Cout);
	
	integer i;
	initial begin
		for (i = 0; i < 8; i++) begin
			{a, b, Cin} = i; #10;
		end
	end

endmodule

