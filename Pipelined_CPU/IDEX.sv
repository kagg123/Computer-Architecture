`timescale 1ns/10ps
module IDEX(input logic clk, reset,
			input logic [2:0] aluOp,
			input logic [1:0] memToReg,
			input logic memWrite, regWrite, flagEn,
			input logic [4:0] Rd,
			output logic [4:0] RdOut,
			output logic [2:0] aluOpOut,
			output logic [1:0] memToRegOut,
			output logic memWriteOut, regWriteOut, flagEnOut);
	//#(parameter WIDTH = 9) (d, q, reset, clk);
	paramDFF #(.WIDTH(3)) pD2 (aluOp, aluOpOut, reset, clk);
	paramDFF #(.WIDTH(2)) pD3 (memToReg, memToRegOut, reset, clk);

	paramDFF #(.WIDTH(5)) pD6 (Rd, RdOut, reset, clk);

	//D_FF (q, d, reset, clk);
	D_FF pD4 (.q(memWriteOut), .d(memWrite), .reset, .clk);
	D_FF pD5 (.q(regWriteOut), .d(regWrite), .reset, .clk);
	D_FF pD7 (.q(flagEnOut), .d(flagEn), .reset, .clk);
	 
endmodule


module IDEX_testbench();
	logic clk, reset;
	logic [1:0] aluSrc;
	logic [2:0] aluOp;
	logic [1:0] memToReg;
	logic memWrite, regWrite, flagEn;
	logic [1:0] aluSrcOut;
	logic [2:0] aluOpOut;
	logic [1:0] memToRegOut;
	logic memWriteOut, regWriteOut, flagEnOut;

	// Set up the clock.   
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 

	IDEX dut (.clk, .reset, .aluSrc, .aluOp,
			  .memToReg, .memWrite, .regWrite, .flagEn,
			  .aluSrcOut, .aluOpOut, .memToRegOut, .memWriteOut, 
			  .regWriteOut, .flagEnOut);

	initial begin
							     @( posedge clk );    
		reset <= 1;              @( posedge clk );    
		reset <= 0; aluSrc <= 2'b01; aluOp <= 3'b001;   
		            memToReg <= 2'b10; memWrite <= 1'b1;
					regWrite <= 1'b1; flagEn <= 1'b1; @( posedge clk );                        
								 @( posedge clk );                        
								 @( posedge clk );                        
								 @( posedge clk );                
					aluSrc <= 2'b10; @( posedge clk );                
					             @( posedge clk );                
				    aluOp <= 3'b010; @( posedge clk );                        
							 	 @( posedge clk );                        
					memToReg <= 2'b11; @( posedge clk );                        
								 @( posedge clk );               
				    memWrite <= 1'b0; @( posedge clk );                        
							     @( posedge clk ); 
					regWrite <= 1'b0; @( posedge clk ); 
							     @( posedge clk ); 
					flagEn <= 1'b0; @( posedge clk );                        
								 @( posedge clk );
								 @( posedge clk );                        
								 @( posedge clk ); 
		$stop; // End the simulation.  
	end

endmodule