
//wir
`timescale 1ns/10ps
module decoder(RegWrite, WriteRegister, decodeOut);

	input logic RegWrite;
	input logic [4:0] WriteRegister;
	
	output logic [31:0] decodeOut;
	
	logic [3:0] enable;
	
	//only initiate one of 4 3:8 decoders if RegWrite is true
	/*assign enable[0] = RegWrite & (~WriteRegister[4] & ~WriteRegister[3]);
	assign enable[1] = RegWrite & (~WriteRegister[4] & WriteRegister[3]);
	assign enable[2] = RegWrite & (WriteRegister[4] & ~WriteRegister[3]);
	assign enable[3] = RegWrite & (WriteRegister[4] & WriteRegister[3]);*/
	
	logic notWriteReg0, notWriteReg1, notWriteReg2, notWriteReg3, notWriteReg4,
	      zero_zero, zero_one, one_zero, one_one;
	
	not #0.05 a (notWriteReg0, WriteRegister[0]);
	not #0.05 b (notWriteReg1, WriteRegister[1]);
	not #0.05 c (notWriteReg2, WriteRegister[2]);
	not #0.05 d (notWriteReg4, WriteRegister[4]);
	not #0.05 e (notWriteReg3, WriteRegister[3]);
	
	and #0.05 f (enable[0], notWriteReg4, notWriteReg3, RegWrite);
	and #0.05 g (enable[1], notWriteReg4, WriteRegister[3], RegWrite);
	and #0.05 h (enable[2], WriteRegister[4], notWriteReg3, RegWrite);
	and #0.05 r (enable[3], WriteRegister[4], WriteRegister[3], RegWrite);
	
	/*and g (enable[0], RegWrite, zero_zero);
	and h (enable[1], RegWrite, zero_one);
	and i (enable[2], RegWrite, one_zero);
	and j (enable[3], RegWrite, one_one);*/
	
	//if 0th 3:8 decoder is enabled
	genvar i;
	generate
		for (i = 0; i < 4; i++) begin : generate_block_identifier
		   and #0.05 j (decodeOut[i * 8], enable[i], notWriteReg2, notWriteReg1, notWriteReg0);
			and #0.05 k (decodeOut[i * 8 + 1], enable[i], notWriteReg2, notWriteReg1, WriteRegister[0]);
			and #0.05 l (decodeOut[i * 8 + 2], enable[i], notWriteReg2, WriteRegister[1], notWriteReg0);
			and #0.05 m (decodeOut[i * 8 + 3], enable[i], notWriteReg2, WriteRegister[1], WriteRegister[0]);
			and #0.05 n (decodeOut[i * 8 + 4], enable[i],  WriteRegister[2], notWriteReg1, notWriteReg0);
			and #0.05 o (decodeOut[i * 8 + 5], enable[i],  WriteRegister[2], notWriteReg1, WriteRegister[0]);
			and #0.05 p (decodeOut[i * 8 + 6], enable[i],  WriteRegister[2], WriteRegister[1], notWriteReg0);
			and #0.05 q (decodeOut[i * 8 + 7], enable[i],  WriteRegister[2], WriteRegister[1], WriteRegister[0]);
			
			/*assign decodeOut[i*8] = enable[i] & (~WriteRegister[2] & ~WriteRegister[1] & ~WriteRegister[0]);
			assign decodeOut[i*8 + 1] = enable[i] & (~WriteRegister[2] & ~WriteRegister[1] & WriteRegister[0]);
			assign decodeOut[i*8 + 2] = enable[i] & (~WriteRegister[2] & WriteRegister[1] & ~WriteRegister[0]);
			assign decodeOut[i*8 + 3] = enable[i] & (~WriteRegister[2] & WriteRegister[1] & WriteRegister[0]);
			assign decodeOut[i*8 + 4] = enable[i] & (WriteRegister[2] & ~WriteRegister[1] & ~WriteRegister[0]);
			assign decodeOut[i*8 + 5] = enable[i] & (WriteRegister[2] & ~WriteRegister[1] & WriteRegister[0]);
			assign decodeOut[i*8 + 6] = enable[i] & (WriteRegister[2] & WriteRegister[1] & ~WriteRegister[0]);
			assign decodeOut[i*8 + 7] = enable[i] & (WriteRegister[2] & WriteRegister[1] & WriteRegister[0]);*/
			
		end
	endgenerate
	
	
	
endmodule

module decoder_testbench();

	logic RegWrite;
	logic [4:0] WriteRegister;
	
	logic [31:0] decodeOut;
	integer i;
	decoder dut (.RegWrite, .WriteRegister, .decodeOut);
	

	initial begin 
		RegWrite = 0;
		for (i = 0; i <= 32; i ++) begin
			WriteRegister = i; #10;
		end
		RegWrite = 1;
		for (i = 0; i <= 32; i ++) begin
			WriteRegister = i; #10; 
		end
		
		$stop;
	end
	
endmodule
