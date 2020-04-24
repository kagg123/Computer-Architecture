`timescale 1ns/10ps
module EXMEM(
	input logic clk, reset,
	input logic [1:0] memToReg,
	input logic memWrite, regWrite, 
	input logic [4:0] Rd,
	output logic [4:0] RdOut,
	output logic [1:0] memToRegOut,
	output logic memWriteOut, regWriteOut);
	//#(parameter WIDTH = 9) (d, q, reset, clk);
	 paramDFF #(.WIDTH(2)) pD3 (.d(memToReg), .q(memToRegOut), .reset, .clk);
	 paramDFF #(.WIDTH(5)) pD6 (Rd, RdOut, reset, clk);
	 //D_FF (q, d, reset, clk);
	 D_FF pD4 (.q(memWriteOut), .d(memWrite), .reset, .clk);
	 D_FF pD5 (.q(regWriteOut), .d(regWrite), .reset, .clk);
	 
endmodule

module EXMEM_testbench();
	 logic clk, reset;
	 logic [1:0] memToReg;
	 logic memWrite, regWrite;
	

	 logic [1:0] memToRegOut;
	 logic memWriteOut, regWriteOut;

	// Set up the clock.   
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 

	EXMEM dut(.clk, .reset, .memToReg, .memWrite, .regWrite, .memToRegOut, .memWriteOut, .regWriteOut);

	initial begin
							     @( posedge clk );    
		reset <= 1;              @( posedge clk );    
		reset <= 0; memToReg <= 2'b10; memWrite <= 1'b1;
					regWrite <= 1'b1; @( posedge clk );                        
								 @( posedge clk );                        
								 @( posedge clk );                        
								 @( posedge clk );                
					 @( posedge clk );                
					             @( posedge clk );                
				     @( posedge clk );                        
							 	 @( posedge clk );                        
					memToReg <= 2'b11; @( posedge clk );                        
								 @( posedge clk );               
				    memWrite <= 1'b0; @( posedge clk );                        
							     @( posedge clk ); 
					regWrite <= 1'b0; @( posedge clk ); 
							     @( posedge clk ); 
					 @( posedge clk );                        
								 @( posedge clk );
								 @( posedge clk );                        
								 @( posedge clk ); 
		$stop; // End the simulation.  
	end

endmodule