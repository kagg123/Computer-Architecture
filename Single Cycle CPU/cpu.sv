`timescale 1ns/10ps
module cpu(input logic clk, reset);
	
	logic [31:0] instruction;
	logic        zeroFlag, reg2Loc, memWrite, regWrite, unCondBr, flagEn,
	             negFlag, overflowFlag, carry_outFlag;
	logic [1:0]  brTaken, aluSrc, memToReg;
	logic [2:0]  aluOp;
	logic [4:0] Rd, Rm, Rn;
	logic [8:0] Imm9;
	logic [11:0] Imm12;
	logic [18:0] condAddr19;
	logic [25:0] condAddr26;
	logic [63:0] Db, zerothSum;
	
	// instantiate the dataPath module

	controlPath control (.instruction, .zeroFlag, .negFlag, .overflowFlag, .brTaken, .aluSrc, .aluOp, .memToReg,
								.reg2Loc, .memWrite, .regWrite, .unCondBr, .flagEn);
	
	instructfetch fetch (.reset, .clk, .uncondBr(unCondBr), .brTaken, .condAddr19, 
	                     .condAddr26, .Db, .instruction, .zerothSum);
								
	assign Rd = instruction[4:0];
	assign Rm = instruction[20:16];
	assign Rn = instruction[9:5];
	assign Imm12 = instruction[21:10];
	assign Imm9 = instruction[20:12];
	assign condAddr19 = instruction[23:5];
	assign condAddr26 = instruction[25:0];
	
	dataPath path (.reg2Loc, .regWrite, .clk, .memWrite, .flagEn, .reset,
                  .aluSrc, .memToReg, .aluOp, .Rd, .Rm, .Rn, .Imm9, .Imm12,
				      .zerothSum, .negFlag, .zeroFlag, .overflowFlag, .carry_outFlag, .Db);
						
endmodule


module cpu_testbench();

	logic clk, reset;
	
	cpu dut (.clk, .reset);
	
	// Set up the clock.   
	parameter CLOCK_PERIOD = 100000;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 
	
	
	initial begin
										@( posedge clk );    
		 reset <= 1'b1;         @( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
		 reset <= 1'b0;			@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
		 reset <= 1'b0;			@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk ); // 3422710450
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										@( posedge clk );
										
		 $stop; // End the simulation.
		 
	end
	
	
endmodule




