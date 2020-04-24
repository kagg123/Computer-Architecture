`timescale 1ns/10ps
module controlPath(
	input logic [31:0] instruction,
	input logic        zeroFlag, negFlag, overflowFlag,
	output logic [1:0] brTaken, aluSrc,
	output logic [2:0] aluOp,
	output logic [1:0] memToReg,
	output logic reg2Loc, memWrite, regWrite, unCondBr, flagEn
	);
	
	logic xorOverflowNegative;
	
	xor #0.05 x1 (xorOverflowNegative, negFlag, overflowFlag);
	
	always_comb begin
		casex (instruction[31:21])
			11'b1001000100x: // ADDI - 0x244
			begin
				reg2Loc = 1'b0; //edited
				regWrite = 1'b1;
				aluSrc = 2'b10;
				aluOp = 3'b010;
				memWrite = 1'b0;
				memToReg = 2'b00;
				unCondBr = 1'bx;
				brTaken = 2'b00;
				flagEn = 1'b0;
			end
				
			11'b10101011000: // ADDS - 0x558
			begin
				reg2Loc = 1'b1;
				regWrite = 1'b1;
				aluSrc = 2'b00;
				aluOp = 3'b010;
				memWrite = 1'b0;
				memToReg = 2'b00;
				unCondBr = 1'bx;
				brTaken = 2'b00;
				flagEn = 1'b1;
			end
			
			11'b000101xxxxx: // BIMM26 - 0x05
			begin
				reg2Loc = 1'b0; //edited
				regWrite = 1'b0;
				aluSrc = 2'bxx;
				aluOp = 3'bxxx;
				memWrite = 1'b0;
				memToReg = 2'bxx;
				unCondBr = 1'b1;
				brTaken = 2'b01;
				flagEn = 1'b0;
			end
			
			11'b01010100xxx: // BLT - 0x54B
			begin
				reg2Loc = 1'b0; //edited
				regWrite = 1'b0;
				aluSrc = 2'bxx;
				aluOp = 3'bxxx;
				memWrite = 1'b0;
				memToReg = 2'bxx;
				unCondBr = 1'b0;
				brTaken = {1'b0, xorOverflowNegative};
				flagEn = 1'b0;
			end
				
			11'b100101xxxxx: // BL - 0x25
			begin
				reg2Loc = 1'b0; //edited
				regWrite = 1'b0;
				aluSrc = 2'bxx;
				aluOp = 3'bxxx;
				memWrite = 1'b0;
				memToReg = 2'b10;
				unCondBr = 1'b1;
				brTaken = 2'b01;
				flagEn = 1'b0;
			end
			
			11'b11010110000: // BR - 0x6B0
			begin
				reg2Loc = 1'b0;
				regWrite = 1'b0;
				aluSrc = 2'bxx;
				aluOp = 3'bxxx;
				memWrite = 1'b0;
				memToReg = 2'bxx;
				unCondBr = 1'b0;
				brTaken = 2'b10;
				flagEn = 1'b0;
			end
				
			11'b11101011000: // SUBS - 0x758
			begin
				reg2Loc = 1'b1;
				regWrite = 1'b1;
				aluSrc = 2'b00;
				aluOp = 3'b011;
				memWrite = 1'b0;
				memToReg = 2'b00;
				unCondBr = 1'bx; 
				brTaken = 2'b00;
				flagEn = 1'b1;
			end
			
			11'b10110100xxx: // CBZ - 0xB4
			begin
				reg2Loc = 1'b0;
				regWrite = 1'b0;
				aluSrc = 2'b00;
				aluOp = 3'b000;
				memWrite = 1'b0;
				memToReg = 2'bxx;
				unCondBr = 1'b0;
				brTaken = {1'b0, zeroFlag};
				flagEn = 1'b1;
			end
			
			11'b11111000010: // LDUR - 0x7C2
			begin
				reg2Loc = 1'b0; //edited
				regWrite = 1'b1;
				aluSrc = 2'b01;
				aluOp = 3'b010;
				memWrite = 1'b0;
				memToReg = 2'b01;
				unCondBr = 1'bx;
				brTaken = 1'b0;
				flagEn = 1'b0;
			end
			
			11'b11111000000: // STUR - 0x7C0
			begin
				reg2Loc = 1'b0;
				regWrite = 1'b0;
				aluSrc = 2'b01;
				aluOp = 3'b010;
				memWrite = 1'b1;
				memToReg = 2'bxx;
				unCondBr = 1'bx;
				brTaken = 1'b0;
				flagEn = 1'b0;
			end
			
			default:
			begin
				reg2Loc = 1'b0; //edited
				regWrite = 1'b0;
				aluSrc = 2'bxx;
				aluOp = 3'bxxx;
				memWrite = 1'b0;
				memToReg = 2'bxx;
				unCondBr = 1'bx;
				brTaken = 2'bxX;
				flagEn = 1'b0;
			end

		endcase
	end
	
endmodule


`timescale 1ns/10ps

module controlPath_testbench();
	
	logic [31:0] instruction;
   logic        zeroFlag, negFlag, overflowFlag;
	logic [1:0]  brTaken, aluSrc;
   logic [2:0]  aluOp;
	logic [1:0]  memToReg;
   logic reg2Loc, memWrite, regWrite, unCondBr, flagEn;
	
	controlPath dut (.instruction, .zeroFlag, .brTaken, .aluSrc, .aluOp, .memToReg,
	                 .reg2Loc, .memWrite, .regWrite, .unCondBr, .flagEn);
						  
	initial begin
		instruction[31:21] <= 11'b10010001000; #10;// ADDI - 0x244
		instruction[31:21] <= 11'b10010001001; #10;          // ADDI - 0x244 	
		instruction[31:21] <= 11'b10101011000; #10; // ADDS - 0x558
		instruction[31:21] <= 11'b00010100000; #10; // BIMM26 - 0x05
		instruction[31:21] <= 11'b01010100111; #10; // BLT - 0x54B
		instruction[31:21] <= 11'b10010100000; #10; // BL - 0x25
		instruction[31:21] <= 11'b11011010000; #10; // BR - 0x6B0
		instruction[31:21] <= 11'b11101011000; #10; // SUBS - 0x758
		instruction[31:21] <= 11'b10110100xxx;  zeroFlag <= 0; #10; // CBZ - 0xB4
		instruction[31:21] <= 11'b10110100xxx;  zeroFlag <= 1; #10; // CBZ - 0xB4
		instruction[31:21] <= 11'b11111000010; #10; // LDUR - 0x7C2
		instruction[31:21] <= 11'b11111000000; #10; // STUR - 0x7C0
	end	
	
endmodule

