`timescale 1ns/10ps
module IFID(
	input logic [31:0] instruction,
	input logic  zeroFlag, negFlag, overflowFlag, clk, reset,
	// input logic [1:0] forwardCtrlOneNext, forwardCtrlTwoNext,
	output logic [4:0] Rd, Rm, Rn,
	output logic [11:0] Imm12,
	output logic [8:0] Imm9,
	output logic [18:0] condAddr19,
	output logic [25:0] condAddr26,
	//output logic [1:0] forwardCtrlOne, forwardCtrlTwo,
	output logic [1:0] brTaken, aluSrc, memToReg,
	output logic [2:0] aluOp,
	output logic reg2Loc, memWrite, regWrite, unCondBr, flagEn, isCbz, isBlt);
	
	//logic xorOverflowNegative;

	//xor #0.05 x1 (xorOverflowNegative, negFlag, overflowFlag);
	
	logic [8:0] Imm9Next;
	logic [11:0] Imm12Next;
	logic [18:0] condAddr19Next;
	logic [25:0] condAddr26Next;

	logic [1:0] brTakenNext, aluSrcNext, memToRegNext;
	logic [2:0] aluOpNext;
	logic reg2LocNext, memWriteNext, regWriteNext, unCondBrNext, flagEnNext, isCbzNext, isBltNext;
	logic [4:0] RdNext, RmNext, RnNext;

	assign Imm12Next = instruction[21:10];
	assign Imm9Next = instruction[20:12];
	assign condAddr19Next = instruction[23:5];
	assign condAddr26Next = instruction[25:0];

	always_comb begin
		casex (instruction[31:21])
			11'b11111111111:
			begin
				reg2LocNext = 1'b0; //edited
				regWriteNext = 1'b0;
				aluSrcNext = 2'b00;
				aluOpNext = 3'b000;
				memWriteNext = 1'b0;
				memToRegNext = 2'b00;
				unCondBrNext = 1'b0;
				brTakenNext = 2'b11;
				flagEnNext = 1'b0;
				RdNext = 5'b11111;
				RmNext = 5'b11111;
	 			RnNext = 5'b11111;
				isCbzNext = 1'b0;
				isBltNext = 1'b0;
				//isRtype= 0;
			end

			11'b1001000100x: // ADDI - 0x244
			begin
				reg2LocNext = 1'b0; //edited
				regWriteNext = 1'b1;
				aluSrcNext = 2'b10;
				aluOpNext = 3'b010;
				memWriteNext = 1'b0;
				memToRegNext = 2'b00;
				unCondBrNext = 1'bx;
				brTakenNext = 2'b00;
				flagEnNext = 1'b0;
				RdNext = instruction[4:0];
				RmNext = 5'b11111;
	 			RnNext = instruction[9:5];
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
				
				
			end
				
			11'b10101011000: // ADDS - 0x558
			begin
				reg2LocNext = 1'b0;
				regWriteNext = 1'b1;
				aluSrcNext = 2'b00;
				aluOpNext = 3'b010;
				memWriteNext = 1'b0;
				memToRegNext = 2'b00;
				unCondBrNext = 1'bx;
				brTakenNext = 2'b00;
				flagEnNext = 1'b1;
				RdNext = instruction[4:0];
				RmNext = instruction[20:16];
	 			RnNext = instruction[9:5];
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end

			11'b000101xxxxx: // BIMM26 - 0x05
			begin
				reg2LocNext = 1'b0; //edited
				regWriteNext = 1'b0;
				aluSrcNext = 2'bxx;
				aluOpNext = 3'bxxx;
				memWriteNext = 1'b0;
				memToRegNext = 2'bxx;
				unCondBrNext = 1'b1;
				brTakenNext = 2'b01;
				flagEnNext = 1'b0;
				RdNext = 5'b11111;
				RmNext = 5'b11111;
	 			RnNext = 5'b11111;
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end
			
			11'b01010100xxx: // BLT - 0x54B
			begin
				reg2LocNext = 1'b0; //edited
				regWriteNext = 1'b0;
				aluSrcNext = 2'bxx;
				aluOpNext = 3'bxxx;
				memWriteNext = 1'b0;
				memToRegNext = 2'bxx;
				unCondBrNext = 1'b0;
				brTakenNext = 2'b00;
				flagEnNext = 1'b0;
				RdNext = 5'b11111;
				RmNext = 5'b11111;
	 			RnNext = 5'b11111;
				 isCbzNext = 1'b0;
				 isBltNext = 1'b1;
			end
				
			11'b100101xxxxx: // BL - 0x25
			begin
				reg2LocNext = 1'b0; //edited
				regWriteNext = 1'b1;
				aluSrcNext = 2'bxx;
				aluOpNext = 3'bxxx;
				memWriteNext = 1'b0;
				memToRegNext = 2'b10;
				unCondBrNext = 1'b1;
				brTakenNext = 2'b01;
				flagEnNext = 1'b0;
				RdNext = 5'b11110; //move this to Rn?
				RmNext = 5'b11111;
	 			RnNext = 5'b11111;
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end
			
			11'b11010110000: // BR Rd- 0x6B0
			begin
				reg2LocNext = 1'b0;
				regWriteNext = 1'b0;
				aluSrcNext = 2'b00;
				aluOpNext = 3'bxxx;
				memWriteNext = 1'b0;
				memToRegNext = 2'bxx;
				unCondBrNext = 1'b0;
				brTakenNext = 2'b10;
				flagEnNext = 1'b0;
				RdNext = 5'b11111;
				RmNext = 5'b11111;
	 			RnNext = instruction[4:0];
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end
				
			11'b11101011000: // SUBS - 0x758
			begin
				reg2LocNext = 1'b0;
				regWriteNext = 1'b1;
				aluSrcNext = 2'b00;
				aluOpNext = 3'b011;
				memWriteNext = 1'b0;
				memToRegNext = 2'b00;
				unCondBrNext = 1'bx; 
				brTakenNext = 2'b00;
				flagEnNext = 1'b1;
				RdNext = instruction[4:0];
				RmNext = instruction[20:16];
	 			RnNext = instruction[9:5];
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end
			
			11'b10110100xxx: // CBZ - 0xB4
			begin
				reg2LocNext = 1'b0;
				regWriteNext = 1'b0;
				aluSrcNext = 2'b00;
				aluOpNext = 3'b000;
				memWriteNext = 1'b0;
				memToRegNext = 2'bxx;
				unCondBrNext = 1'b0;
				brTakenNext = 2'b00;
				flagEnNext = 1'b1;
				RdNext = 5'b11111;
				RmNext = 5'b11111;
	 			RnNext = instruction[4:0];
				 isCbzNext = 1'b1;
				 isBltNext = 1'b0;
			end
			
			11'b11111000010: // LDUR - 0x7C2
			begin
				reg2LocNext = 1'b0; //edited
				regWriteNext = 1'b1;
				aluSrcNext = 2'b01;
				aluOpNext = 3'b010;
				memWriteNext = 1'b0;
				memToRegNext = 2'b01;
				unCondBrNext = 1'bx;
				brTakenNext = 1'b0;
				flagEnNext = 1'b0;
				RdNext = instruction[4:0];
				RmNext = 5'b11111;
	 			RnNext = instruction[9:5];
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end
			
			11'b11111000000: // STUR - 0x7C0
			begin
				reg2LocNext = 1'b0;
				regWriteNext = 1'b0;
				aluSrcNext = 2'b01;
				aluOpNext = 3'b010;
				memWriteNext = 1'b1;
				memToRegNext = 2'b10;
				unCondBrNext = 1'bx;
				brTakenNext = 1'b0;
				flagEnNext = 1'b0;
				RdNext = 5'b11111;
				RmNext = instruction[4:0];
	 			RnNext = instruction[9:5];
				 isCbzNext = 1'b0;
				 isBltNext = 1'b0;
			end

		endcase
	end
	
	

	always_ff @(posedge clk) begin
		if (reset) begin
			reg2Loc <= 1'b0;
			regWrite <= 1'b0;
			aluSrc <= 2'b00;
			aluOp <= 3'b000;
			memWrite <= 1'b0;
			memToReg <= 2'b00;
			unCondBr <= 1'b0;
			brTaken <= 2'b11;
			flagEn <= 1'b0;
			//forwardCtrlOne <= 2'b00;
			//forwardCtrlTwo <= 2'b00;
			Rd <= 5'b11111;
			Rm <= 5'b11111;
	 		Rn <= 5'b11111;
			Imm12 <= 0;
	 		Imm9 <= 0;
			condAddr19 <= 0;
	 		condAddr26 <= 0;
			 isCbz <= 0;
			 isBlt <= 0;
 		end else begin
			reg2Loc <= reg2LocNext;
			regWrite <= regWriteNext;
			aluSrc <= aluSrcNext;
			aluOp <= aluOpNext;
			memWrite <= memWriteNext;
			memToReg <= memToRegNext;
			unCondBr <= unCondBrNext;
			brTaken <= brTakenNext;
			flagEn <= flagEnNext;
			// forwardCtrlOne <= forwardCtrlOneNext;
			// forwardCtrlTwo <= forwardCtrlTwoNext;
			Rd <= RdNext;
			Rm <= RmNext;
	 		Rn <= RnNext;
			Imm12 <= Imm12Next;
	 		Imm9 <= Imm9Next;
			condAddr19 <= condAddr19Next;
	 		condAddr26 <= condAddr26Next;
			 isCbz <= isCbzNext;
			 isBlt <= isBltNext;
		end
	end
endmodule


`timescale 1ns/10ps
module IFID_testbench();
	
	logic [31:0] instruction;
	logic [2:0] aluOp;
	logic [1:0] brTaken, aluSrc, memToReg;
    logic zeroFlag, negFlag, overflowFlag,
	      reg2Loc, memWrite, regWrite, unCondBr, flagEn, isBlt, isCbz, reset, clk;

	// Set up the clock.   
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end  

	IFID dut (.instruction, .zeroFlag, .negFlag, .overflowFlag, .clk, .reset,
	                 .brTaken, .aluSrc, .memToReg, .aluOp, .reg2Loc, .memWrite, .regWrite, .unCondBr, .flagEn, .isCbz, .isBlt);
						  
	initial begin
											   @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		reset <= 1'b1;						   @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		reset <= 1'b0;						   @(posedge clk);@(posedge clk);@(posedge clk);@(posedge clk);
		instruction[31:21] <= 11'b10010001000; @(posedge clk);// ADDI - 0x244
		instruction[31:21] <= 11'b10010001001; @(posedge clk);          // ADDI - 0x244 	
		instruction[31:21] <= 11'b10101011000; @(posedge clk); // ADDS - 0x558
		instruction[31:21] <= 11'b00010100000; @(posedge clk); // BIMM26 - 0x05
		instruction[31:21] <= 11'b01010100111; @(posedge clk); // BLT - 0x54B
		instruction[31:21] <= 11'b10010100000; @(posedge clk); // BL - 0x25
		instruction[31:21] <= 11'b11011010000; @(posedge clk); // BR - 0x6B0
		instruction[31:21] <= 11'b11101011000; @(posedge clk); // SUBS - 0x758
		instruction[31:21] <= 11'b10110100xxx; zeroFlag <= 0; @(posedge clk); // CBZ - 0xB4
		instruction[31:21] <= 11'b10110100xxx; zeroFlag <= 1; @(posedge clk); // CBZ - 0xB4
		instruction[31:21] <= 11'b11111000010; @(posedge clk); // LDUR - 0x7C2
		instruction[31:21] <= 11'b11111000000; @(posedge clk); // STUR - 0x7C0
		$stop; // End the simulation.
	end	
	
endmodule

