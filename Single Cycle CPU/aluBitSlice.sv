`timescale 1ns/10ps

module aluBitSlice (a, b, Cin, Cout, cntrl, result);
	
	input logic a, b, Cin;
	input logic [2:0] cntrl;
	output logic result, Cout;
	
	logic [7:0] operations;
	logic notB, adderB;
	
	//000 = b
	assign operations[0] = b;
	
	//010 = a+b, 011 = a-b
	not #0.05 c (notB, b);
	mux2_1 d (.out(adderB), .in({notB, b}), .sel(cntrl[0]));
	fullAdder e (.a, .b(adderB), .Cin, .sum(operations[2]), .Cout); 
	assign operations[3] = operations[2];
	
	//100 = a&b
	and #0.05 f (operations[4], a, b);
	
	//101 = a or b
	or #0.05 g (operations[5], a, b);
	
	//110 = a xor b
	xor #0.05 h (operations[6], a, b);
	
	mux8_1 i (.out(result), .in(operations), .sel(cntrl));
	

endmodule


module aluBitSlice_testbench();

	logic a, b, Cin, result, Cout;
	logic [2:0] cntrl;
	
	aluBitSlice dut (.a, .b, .Cin, .Cout, .cntrl, .result);
	
	integer i;
	initial begin
		for (i = 0; i < 64; i++) begin
			{a, b, Cin, cntrl} = i; #10;
		end
	end
	
endmodule


