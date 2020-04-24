`timescale 1ns/10ps
module MEMWR(
	input logic clk, reset,
	input logic regWrite, 
	input logic [4:0] Rd,
	// input logic [1:0] memToReg;
	// output logic [1:0] memToRegOut;

	output logic [4:0] RdOut,
	output logic regWriteOut);
	
	//D_FF (q, d, reset, clk);	
	D_FF pD5 (.q(regWriteOut), .d(regWrite), .reset, .clk);
	paramDFF #(.WIDTH(5)) pD6 (Rd, RdOut, reset, clk);
	//paramDFF #(.WIDTH(2)) pD6 (memToReg, memToRegOut, reset, clk);
	 
endmodule

module MEMWR_testbench();
	logic clk, reset;
	logic regWrite;

	logic regWriteOut;

	// Set up the clock.   
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 

	MEMWR dut(.clk, .reset, .regWrite, .regWriteOut);

	initial begin
							     @( posedge clk );    
		reset <= 1;              @( posedge clk );    
		reset <= 0; 
					regWrite <= 1'b1; @( posedge clk );                        
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
					regWrite <= 1'b0; @( posedge clk ); 
							     @( posedge clk ); 
					 @( posedge clk );                        
								 @( posedge clk );
								 @( posedge clk );                        
								 @( posedge clk ); 
		$stop; // End the simulation.  
	end

endmodule