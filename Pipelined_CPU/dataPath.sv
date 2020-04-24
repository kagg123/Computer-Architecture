`timescale 1ns/10ps
module dataPath (
	input logic reg2Loc, regWrite, clk, memWrite, flagEn, reset, 
	input logic	[1:0] aluSrc, memToReg,
	input logic	[2:0] aluOp,
	input logic [1:0] forwardCtrlOne,
	input logic [1:0] forwardCtrlTwo,
	input logic [4:0] Rd, Rm, Rn,
	input logic [8:0] Imm9,
	input logic [11:0] Imm12,
	input logic [63:0] pc_output,
	output logic negFlag, zeroFlag, zero_cbzcheck, overflowFlag, carry_outFlag,
	output logic [63:0] forwardCtrlOneOutput);	

	logic [4:0] Aw;
	logic [63:0] Da, Db, Dw, DwClocked, ALUOutput, Imm9_64, Imm12_64, aluSrcOutput;
	
	paramDFF #(.WIDTH(64)) pdff120 (.d(Dw), .q(DwClocked), .reset, .clk);
	
	//STAGE 2 - REGISTER DECODE
	assign Aw = Rd;

	regfile RegFile(.ReadData1(Da), .ReadData2(Db), .WriteData(DwClocked), .ReadRegister1(Rn), .ReadRegister2(Rm), .WriteRegister(Aw), .RegWrite(regWrite), .clk(~clk), .reset);
	
	signExtend #(.WIDTH(9)) s1(.extend(Imm9), .extended(Imm9_64));
	signExtend #(.WIDTH(12)) s2(.extend(Imm12), .extended(Imm12_64));

    // 3 inputs to the first mux of the forwarding unit
	logic [63:0]  forwardCtrlTwoOutput;
	logic [63:0] forwardCtrlOneInput [2:0];
	assign forwardCtrlOneInput[0] = Da;
	assign forwardCtrlOneInput[1] = ALUOutput;
	assign forwardCtrlOneInput[2] = Dw;

    // 3 inputs to the second mux of the forwarding unit
	logic [63:0] forwardCtrlTwoInput [2:0];
	assign forwardCtrlTwoInput[0] = Db;
	assign forwardCtrlTwoInput[1] = ALUOutput;
	assign forwardCtrlTwoInput[2] = Dw;

	// two muxes for datapath of forwarding unit
	mux64x3_1 firstForward (.muxOutput(forwardCtrlOneOutput), .muxInputs(forwardCtrlOneInput), .sel(forwardCtrlOne));
	mux64x3_1 secondForward (.muxOutput(forwardCtrlTwoOutput), .muxInputs(forwardCtrlTwoInput), .sel(forwardCtrlTwo));

	logic [63:0] aluSrcMux[2:0] ;
	assign aluSrcMux[2] = Imm12_64;
	assign aluSrcMux[1] = Imm9_64;
	assign aluSrcMux[0] = forwardCtrlTwoOutput;
	
	mux64x3_1 m1 (.muxOutput(aluSrcOutput), .muxInputs(aluSrcMux), .sel(aluSrc));
	
	isZero zeroChek (.zero(zero_cbzcheck), .result(forwardCtrlOneOutput));
	logic [63:0] aluInputA, aluInputB;
	
	//DATAPATH IDEX REGISTER
	paramDFF #(.WIDTH(64)) pdffAluOut (.d(forwardCtrlOneOutput), .q(aluInputA), .reset, .clk);
	paramDFF #(.WIDTH(64)) pdffAluOut2 (.d(aluSrcOutput), .q(aluInputB), .reset, .clk);
	
	//STAGE 3- EXECUTE
	logic negALU, zeroALU, overflowALU, carry_outALU;
	alu datapathALU(.A(aluInputA), .B(aluInputB), .cntrl(aluOp), .result(ALUOutput), .negative(negALU), .zero(zeroALU), .overflow(overflowALU), .carry_out(carry_outALU));
	setFlag sF (.negALU, .zeroALU, .overflowALU, .carry_outALU, .flagEn, .reset, .clk, .negFlag, .zeroFlag, .overflowFlag, .carry_outFlag);
	
	//DATAPATH EXMEM REGISTER
	logic [63:0] forwardCtrlTwoOutput1, forwardCtrlTwoOutput2, ALUOutputClocked;
		
	paramDFF #(.WIDTH(64)) pdff110 (.d(forwardCtrlTwoOutput), .q(forwardCtrlTwoOutput1), .reset, .clk);
	paramDFF #(.WIDTH(64)) pdff111 (.d(forwardCtrlTwoOutput1), .q(forwardCtrlTwoOutput2), .reset, .clk);
	paramDFF #(.WIDTH(64)) pdff112 (.d(ALUOutput), .q(ALUOutputClocked), .reset, .clk);

	//Data Memory (Stage 4)
	logic [63:0] Dout;
	datamem dM (.address(ALUOutputClocked), .write_enable(memWrite), .read_enable(memToReg[0]), .write_data(forwardCtrlTwoOutput2), .clk, .xfer_size(4'b1000), .read_data (Dout));
	
	//MEMWR Register
	logic [63:0] DoutClocked, pc_outputClocked, pc_outputClocked2;
	
	//paramDFF #(parameter WIDTH = 64) pdff100 (.d(Dout), .q(DoutClocked)), .reset, .clk);
	//paramDFF #(parameter WIDTH = 64) pdff101 (.d(ALUOutputClocked), .q(ALUOutputClocked2)), .reset, .clk);
	paramDFF #(.WIDTH(64)) pdff102 (.d(pc_output), .q(pc_outputClocked), .reset, .clk);
	paramDFF #(.WIDTH(64)) pdff103 (.d(pc_outputClocked), .q(pc_outputClocked2), .reset, .clk);
	
	//Write Back Stage (Stage 4)
	logic [63:0] memToRegMux[2:0];
	
	assign memToRegMux[2] = pc_outputClocked2; //zerothSumClocked2;
	assign memToRegMux[1] = Dout; //DoutClocked
	assign memToRegMux[0] = ALUOutputClocked; //ALUOutputClocked2;

	mux64x3_1 m2 (.muxOutput(Dw), .muxInputs(memToRegMux), .sel(memToReg));

endmodule

`timescale 1ns/10ps
module dataPath_testbench ();
	logic reg2Loc, regWrite, clk, memWrite, flagEn, reset;
	logic [1:0] aluSrc, memToReg;
	logic [2:0] aluOp, forwardCtrlOne, forwardCtrlTwo;
	logic [4:0] Rd, Rm, Rn;
	logic [8:0] Imm9;
	logic [11:0] Imm12;
	logic [63:0] pc_output;
	logic negFlag, zeroFlag, overflowFlag, carry_outFlag;
	logic [63:0] forwardCtrlOneOutput;
	
	dataPath DUT (.reg2Loc, .regWrite, .clk, .memWrite, .flagEn, .reset, 
	              .aluSrc, .memToReg, .aluOp, .forwardCtrlOne, .forwardCtrlTwo, .Rd, .Rm, .Rn, .Imm9, .Imm12, 
				  .pc_output, .negFlag, .zeroFlag, .overflowFlag, .carry_outFlag, .forwardCtrlOneOutput);
	
	parameter CLOCK_PERIOD = 100000;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end      

	// Set up the inputs to the design.  Each line is a clock cycle.   
	initial begin
       
		 @( posedge clk );	
		reset <= 1;Rd = 0; Rm <= 0; Rn <=0; Imm9 <=0; Imm12 <=0; pc_output <=0; @( posedge clk ); 
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
		forwardCtrlOne <= 2'b00;
		forwardCtrlTwo <= 2'b00;
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
		forwardCtrlOne <= 2'b00;
		forwardCtrlTwo <= 2'b01;
		@( posedge clk );@( posedge clk );
		
		//ADDS X3, X2, X1 X3 = 2 + 3 = 5
		Rd <= 3; Rn <=2; Rm <= 1;
		reg2Loc = 1'b1;
		regWrite = 1'b1;
		aluSrc = 2'b00;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		forwardCtrlOne <= 2'b00;
		forwardCtrlTwo <= 2'b10;
		flagEn = 1'b1; @( posedge clk );@( posedge clk );
		
		//SUBS X3, X1, X2 X3 = X1(2) - X2(3) = -1
		Rd <= 3; Rn <=1; Rm <= 2;
		reg2Loc = 1'b1;
		regWrite = 1'b1;
		aluSrc = 2'b00;
		aluOp = 3'b011;
		memWrite = 1'b0;
		memToReg = 2'b00;
		forwardCtrlOne <= 2'b01;
		forwardCtrlTwo <= 2'b00;
		flagEn = 1'b1; @( posedge clk );@( posedge clk );
		
		//ADDI X3, X3, 1 X3 = X3 + 1 = 0 + 1 = 1
		Rd <= 3; Rn <=3; Imm12 <=1;
		reg2Loc = 1'bx;
		regWrite = 1'b1;
		aluSrc = 2'b10;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		forwardCtrlOne <= 2'b01;
		forwardCtrlTwo <= 2'b01;
		flagEn = 1'b0; @( posedge clk );@( posedge clk );
		
		//ADDS X3, X2, X1 X3 = 2 + 3 = 5
		Rd <= 31; Rn <=31; Rm <= 31;
		reg2Loc = 1'b1;
		regWrite = 1'b1;
		aluSrc = 2'b00;
		aluOp = 3'b010;
		memWrite = 1'b0;
		memToReg = 2'b00;
		forwardCtrlOne <= 2'b10;
		forwardCtrlTwo <= 2'b00;
		flagEn = 1'b1; @( posedge clk );@( posedge clk );
		
		
		//STUR X2, X1, #6 Mem[8] = 3;
		Rd <= 2; Rn <= 1; Imm9 <= 6;
		reg2Loc = 1'b0;
				regWrite = 1'b0;
				aluSrc = 2'b01;
				aluOp = 3'b010;
				memWrite = 1'b1;
				memToReg = 2'bxx;
				forwardCtrlOne <= 2'b10;
				forwardCtrlTwo <= 2'b01;
				flagEn = 1'b0; @( posedge clk );@( posedge clk );
		
		//LDUR X5, X1, #6 X5 = Mem[8] = 3;
		Rd <= 5; Rn <= 1; Imm9 <= 6;
		reg2Loc = 1'bx;
				regWrite = 1'b1;
				aluSrc = 2'b01;
				aluOp = 3'b010;
				memWrite = 1'b0;
				memToReg = 2'b01;
				forwardCtrlOne <= 2'b10;
				forwardCtrlTwo <= 2'b10;
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

