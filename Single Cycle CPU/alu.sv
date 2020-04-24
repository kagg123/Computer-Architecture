`timescale 1ns/10ps
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
	
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	
	logic [63:0] Cout;
	
	aluBitSlice bit0 (.a(A[0]), .b(B[0]), .Cin(cntrl[0]), .Cout(Cout[0]), .cntrl, .result(result[0]));
	
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin : generate_block_identifier
			aluBitSlice bitx  (.a(A[i]), .b(B[i]), .Cin(Cout[i-1]), .Cout(Cout[i]), .cntrl, .result(result[i]));
		end
	endgenerate
	
	assign negative = result[63];
	xor #0.05 overfloW (overflow, Cout[63], Cout[62]);
	assign carry_out = Cout[63];
	
	
	//create 64 to 1 nor gate to assign zero flag
	logic [15:0] temp;
	logic [3:0] temp2;
	logic notzero;
	genvar j, k;
	
	generate
		for (j = 0; j < 16; j++) begin : generate_block_identifier1
			or #0.05 zerO (temp[j], result[j * 4], result[j * 4 + 1], result[j * 4 + 2], result[j * 4 + 3] );
		end
	endgenerate
	
	generate
		for (k = 0; k < 4; k++) begin : generate_block_identifier2
			or #0.05 zeRO (temp2[k], temp[k * 4], temp[k * 4 + 1], temp[k * 4 + 2], temp[k * 4 + 3] );
		end
	endgenerate
	
	or #0.05 zERO (notzero, temp2[0], temp2[1], temp2[2], temp2[3] );
	not #0.05 ZERO (zero, notzero);
	

endmodule


// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_A operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		
		$display("%t testing ALU_ADD operations", $time);
		cntrl = ALU_ADD;
		// A and B are both positive and A + B > 0; Result is valid
			A = 64'h0000000000000001; B = 64'h0000000000000001;
			#(delay);
			assert(result == 64'h0000_0000_0000_0002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
			for (i=0; i<10; i++) begin
				A = i; B = i + 1;
				#(delay);
				assert(result == 2 * i + 1);
				assert(carry_out == 0);
				assert(overflow == 0);
				assert(negative == 0);
				assert(zero == 0);
			end
		// A and B are both positive but A + B < 0; Result is not valid; Should trigger overflow flag
			A = 64'h7FFFFFFFFFFFFFFF; B = 1; //max positive + 1
			#(delay);
			assert(result == 64'h8000000000000000 && overflow == 1 && negative == 1 && zero == 0);
			A = 64'h7FFFFFFFFFFFFFFF; B = 2; //max positive + 2
			#(delay);
			assert(result == 64'h8000000000000001 && overflow == 1 && negative == 1 && zero == 0);
		// A is negative B is positive and A + B > 0; Result is valid; should trigger carry_out flag
			A = 64'hFFFFFFFFFFFFFFFF; B = 2; //-1 + 2
			#(delay);
			assert(result == 1 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		// A is negative B is positive and A + B = 0; Result is valid; should trigger carry_out flag and zero flag
			A = 64'hFFFFFFFFFFFFFFFF; B = 1; //-1 + 1
			#(delay);
			assert(result == 0 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		// A is negative B is 0, result is valid; should trigger negative flag 
			A = 64'h8000000000000000; B = 0; //max negative + 0
			#(delay);
			assert(result == 64'h8000000000000000 && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);	
		// A and B are both negative and A + B < 0; result is valid; should trigger negative flag
			A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF; //-1 + -1
			#(delay);
			assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);	

		// A and B are both negative but A + B > 0; result is not valid; should trigger overflow flag
			A = 64'hFFFFFFFFFFFFFFFF; B = 64'h8000000000000000; // max negative + -1
			#(delay);
			assert(result == 64'h7FFFFFFFFFFFFFFF  && overflow == 1 && negative == 0 );
			
		
		$display("%t testing ALU_SUBTRACT operations", $time);
		cntrl = ALU_SUBTRACT;
		// A > B; A and B are both positive and A - B > 0; Result is valid
			A = 4; B = 2;
			#(delay);
			assert(result == 2 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		// A > B; A is positive B is negative and A - B > 0; Result is valid
			A = 4; B = 64'hFFFFFFFFFFFFFFFE; // 4 - -2
			#(delay);
			assert(result == 6 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		// A > B; A is positive B is negative and A - B < 0; Result is not valid
			A = 64'h7FFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFE; // max positive - -2
			#(delay);
			assert(result == 64'h8000000000000001 && overflow == 1);
		// A > B; A is negative B is positive and A - B < 0; Result is valid
			A = 64'hFFFFFFFFFFFFFFFE; B = 1; // -2 - 1
			#(delay);
			assert(result == 64'hFFFFFFFFFFFFFFFD && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		// A > B; A is negative B is positive and A - B > 0; Result is not valid
			A = 64'h8000000000000000; B = 1; // max negative - 1
			#(delay);
			assert(result == 64'h7FFFFFFFFFFFFFFF && overflow == 1);
		// A > B; A is negative B is negative and A - B < 0; Result is  valid
			A = 64'hFFFFFFFFFFFFFFFE; B = 64'hFFFFFFFFFFFFFFFF; //-2 - -1
			#(delay);
			assert(result == 64'hFFFFFFFFFFFFFFFF && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);
			
		// A < B; A and B are both positive and A - B < 0; Result is valid
			A = 2; B = 4; //2-4
			#(delay);
			assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);
		// A < B; A is positive B is negative and A - B > 0; Result is valid
			A = 1; B = 64'hFFFFFFFFFFFFFFFE; // 1 - -2
			#(delay);
			assert(result == 3 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		// A < B; A is negative B is positive and A - B < 0; Result is valid
			A = 64'hFFFFFFFFFFFFFFFF; B = 2; // -1 - 2
			#(delay);
			assert(result == 64'hFFFFFFFFFFFFFFFD && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		
		
		$display("%t testing ALU_AND operations", $time);
		cntrl = ALU_AND;
			A = 3; B = 31;
			#(delay);
			assert(result == 3 && zero == 0);
			A = 31; B = 3;
			#(delay);
			assert(result == 3 && zero == 0);
			A = 4; B = 3;
			#(delay);
			assert(result == 0 && zero == 1);
		
		$display("%t testing ALU_OR operations", $time);
		cntrl = ALU_OR;
			A = 3; B = 31;
			#(delay);
			assert(result == 31 && zero == 0);
			A = 4; B = 3;
			#(delay);
			assert(result == 7 && zero == 0);
			A = 0; B = 0;
			#(delay);
			assert(result == 0 && zero == 1);
		
		$display("%t testing ALU_XOR operations", $time);
		cntrl = ALU_XOR;
			A = 3; B = 5;
			#(delay);
			assert(result == 6 && zero == 0);
			// case where both numbers are true - output should be zero
			A = 12; B = 12;
			#(delay);
			assert(result == 0 && zero == 1);
			// any number xor zero should be same number
			A = 7; B = 0;
			#(delay);
			assert(result == 7 && zero == 0);
			
		
		
	end
endmodule
