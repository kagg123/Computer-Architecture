`timescale 1ns/10ps
module dataPath (
	input logic reg2Loc, regWrite, clk, memWrite, flagEn, reset,
	input logic	[1:0] aluSrc, memToReg,
	input logic	[2:0] aluOp,
	input logic [4:0] Rd, Rm, Rn,
	input logic [8:0] Imm9,
	input logic [11:0] Imm12,
	input logic [63:0] zerothSum,
	output logic negFlag, zeroFlag, overflowFlag, carry_outFlag,
	output logic [63:0] Db 
	
);	
	logic [4:0] Aw, Ab;
	logic [63:0] Da, Dw, ALUOutput, Imm9_64, Imm12_64, aluSrcOutput;
	
	logic [4:0] muxInputArray[1:0] ;
	assign muxInputArray[1] = Rm;
	assign muxInputArray[0] = Rd;
	
	mux5x2_1 m0 (.muxOutput(Ab), .muxInputs(muxInputArray), .sel(reg2Loc));
	regfile RegFile(.ReadData1(Da), .ReadData2(Db), .WriteData(Dw), .ReadRegister1(Rn), .ReadRegister2(Ab), .WriteRegister(Rd), .RegWrite(regWrite), .clk, .reset);
	
	signExtend #( .WIDTH(9)) s1(.extend(Imm9), .extended(Imm9_64));
	signExtend #( .WIDTH(12)) s2(.extend(Imm12), .extended(Imm12_64));
	
	logic [63:0] muxInputArray2[2:0] ;
	logic negALU, zeroALU, overflowALU, carry_outALU;
	assign muxInputArray2[2] = Imm12_64;
	assign muxInputArray2[1] = Imm9_64;
	assign muxInputArray2[0] = Db;
	
	mux64x3_1 m1 (.muxOutput(aluSrcOutput), .muxInputs(muxInputArray2), .sel(aluSrc));
	alu datapathALU(.A(Da), .B(aluSrcOutput), .cntrl(aluOp), .result(ALUOutput), .negative(negALU), .zero(zeroALU), .overflow(overflowALU), .carry_out(carry_outALU));
	
	setFlag sF (.negALU, .zeroALU, .overflowALU, .carry_outALU, .flagEn, .reset, .clk, .negFlag, .zeroFlag, .overflowFlag, .carry_outFlag);
	
	logic [63:0] muxInputArray3[2:0] ;
	logic [63:0] Dout;
	
	assign muxInputArray3[2] = zerothSum;
	assign muxInputArray3[1] = Dout;
	assign muxInputArray3[0] = ALUOutput;
	
	datamem dM (.address(ALUOutput), .write_enable(memWrite), .read_enable(memToReg[0]), .write_data(Db), .clk, .xfer_size(4'b1000), .read_data (Dout));
	mux64x3_1 m2 (.muxOutput(Dw), .muxInputs(muxInputArray3), .sel(memToReg));

endmodule

`timescale 1ns/10ps
module dataPath_testbench ();
	logic reg2Loc, regWrite, clk, memWrite, flagEn, reset;
	logic	[1:0] aluSrc, memToReg;
	logic	[2:0] aluOp;
	logic [4:0] Rd, Rm, Rn;
	logic [8:0] Imm9;
	logic [11:0] Imm12;
	logic [63:0] zerothSum;
	logic negFlag, zeroFlag, overflowFlag, carry_outFlag;
	logic [63:0] Db;
	
	dataPath DUT (.reg2Loc, .regWrite, .clk, .memWrite, .flagEn, .reset, .aluSrc, .memToReg, .aluOp, .Rd, .Rm, .Rn, .Imm9, .Imm12, .zerothSum, .negFlag, .zeroFlag, .overflowFlag, .carry_outFlag, .Db);
	
		parameter CLOCK_PERIOD = 100000;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end      

	// Set up the inputs to the design.  Each line is a clock cycle.   
	initial begin
       
		 @( posedge clk );	
		reset <= 1;Rd = 0; Rm <= 0; Rn <=0; Imm9 <=0; Imm12 <=0; zerothSum <=0; @( posedge clk ); 
																		@( posedge clk );
																		@( posedge clk );
																		@( posedge clk );
																		@( posedge clk );
																		@( posedge clk );
		//ADDI X1, X31, 2 X1=2
		Rd <= 1; Rn <=31; Imm12 <=2;
		reset <= 0;
		reg2Loc = 1'bx;
		regWrite = 1'b1;
		aluSrc = 2'b10;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b0;
		@( posedge clk );@( posedge clk );
		
		//ADDI X2, X31, 3 X2=3
		Rd <= 2; Rn <=31; Imm12 <=3;
		reg2Loc = 1'bx;
		regWrite = 1'b1;
		aluSrc = 2'b10;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b0;
		@( posedge clk );@( posedge clk );
		
		//ADDS X3, X2, X1 X3 = 2 + 3 = 5
		Rd <= 3; Rn <=2; Rm <= 1;
		reg2Loc = 1'b1;
		regWrite = 1'b1;
		aluSrc = 2'b00;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b1; @( posedge clk );@( posedge clk );
		
		//SUBS X3, X1, X2 X3 = X1(2) - X2(3) = -1
		Rd <= 3; Rn <=1; Rm <= 2;
		reg2Loc = 1'b1;
		regWrite = 1'b1;
		aluSrc = 2'b00;
		aluOp = 3'b011;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b1; @( posedge clk );@( posedge clk );
		
		//ADDI X3, X3, 1 X3 = X3 + 1 = 0 + 1 = 1
		Rd <= 3; Rn <=3; Imm12 <=1;
		reg2Loc = 1'bx;
		regWrite = 1'b1;
		aluSrc = 2'b10;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b0; @( posedge clk );@( posedge clk );
		
		//ADDS X3, X2, X1 X3 = 2 + 3 = 5
		Rd <= 31; Rn <=31; Rm <= 31;
		reg2Loc = 1'b1;
		regWrite = 1'b1;
		aluSrc = 2'b00;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b1; @( posedge clk );@( posedge clk );
		
		
		//STUR X2, X1, #6 Mem[8] = 3;
		Rd <= 2; Rn <= 1; Imm9 <= 6;
		reg2Loc = 1'b0;
				regWrite = 1'b0;
				aluSrc = 2'b01;
				aluOp = 3'b010;
				memWrite = 1'b1;
				memToReg = 2'bxx;
				flagEn = 1'b0; @( posedge clk );@( posedge clk );
		
		//LDUR X5, X1, #6 X5 = Mem[8] = 3;
		Rd <= 5; Rn <= 1; Imm9 <= 6;
		reg2Loc = 1'bx;
				regWrite = 1'b1;
				aluSrc = 2'b01;
				aluOp = 3'b010;
				memWrite = 1'b0;
				memToReg = 2'b01;
				flagEn = 1'b0; @( posedge clk );@( posedge clk );
		
		//ADDI X5, X5, #0
		Rd <= 5; Rn <=5; Imm12 <=0;
		reg2Loc = 1'bx;
		regWrite = 1'b1;
		aluSrc = 2'b10;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		flagEn = 1'b0; @( posedge clk );@( posedge clk );
		

							  
		$stop; // End the simulation.   
	end  

endmodule

