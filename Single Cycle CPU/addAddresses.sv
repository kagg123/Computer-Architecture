`timescale 1ns/10ps
module addAddresses (input logic [63:0] a, b,
                     output logic [63:0] sum);

	logic [63:0] carryIns;
	
	fullAdder zeroth_Bit_Adder (.a(a[0]), .b(b[0]), .Cin(1'b0), .sum(sum[0]), .Cout(carryIns[0]));
	
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin : generate_block
			fullAdder zeroth_Bit_Adder (.a(a[i]), .b(b[i]), .Cin(carryIns[i - 1]), .sum(sum[i]), .Cout(carryIns[i]));
		end
	endgenerate

endmodule


module addAddresses_testbench();

	logic [63:0] a, b, sum;
	
	addAddresses dut (.a, .b, .sum);
	
	integer i;
	
	parameter delay = 100000;
	
	initial begin
		$display("%t testing ALU_ADD operations", $time);
		// A and B are both positive and A + B > 0; Result is valid
		a = 64'h0000000000000000; b = 64'h0x04;
		#(delay);
		assert(sum == 64'h0x04);
		for (i = 0; i < 10; i++) begin
			a = i; b = i + 1;
			#(delay);
			assert(sum == 2 * i + 1);
		end
		
		a = 64'h0000000000000001; b = 64'h0000000000000001;
		#(delay);
		assert(sum == 64'h0000_0000_0000_0002);
		for (i = 0; i < 10; i++) begin
			a = i; b = i + 1;
			#(delay);
			assert(sum == 2 * i + 1);
		end
		
		// A and B are both positive but A + B < 0; Result is not valid; Should trigger overflow flag
		a = 64'h7FFFFFFFFFFFFFFF; b = 1; //max positive + 1
		#(delay);
		assert(sum == 64'h8000000000000000);
		
		a = 64'h7FFFFFFFFFFFFFFF; b = 2; //max positive + 2
		#(delay);
		assert(sum == 64'h8000000000000001);
		
		// A is negative B is positive and A + B > 0; Result is valid; should trigger carry_out flag
		a = 64'hFFFFFFFFFFFFFFFF; b = 2; //-1 + 2
		#(delay);
		assert(sum == 1);
		
		// A is negative B is positive and A + B = 0; Result is valid; should trigger carry_out flag and zero flag
		a = 64'hFFFFFFFFFFFFFFFF; b = 1; //-1 + 1
		#(delay);
		assert(sum == 0);
		
		// A is negative B is 0, result is valid; should trigger negative flag 
		a = 64'h8000000000000000; b = 0; //max negative + 0
		#(delay);
		assert(sum == 64'h8000000000000000);	
		
		// A and B are both negative and A + B < 0; result is valid; should trigger negative flag
		a = 64'hFFFFFFFFFFFFFFFF; b = 64'hFFFFFFFFFFFFFFFF; //-1 + -1
		#(delay);
		assert(sum == 64'hFFFFFFFFFFFFFFFE);	

		// A and B are both negative but A + B > 0; result is not valid; should trigger overflow flag
		a = 64'hFFFFFFFFFFFFFFFF; b = 64'h8000000000000000; // max negative + -1
		#(delay);
		assert(sum == 64'h7FFFFFFFFFFFFFFF);
			
	end

endmodule

