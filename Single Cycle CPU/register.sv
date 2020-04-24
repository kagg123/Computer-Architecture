`timescale 1ns/10ps
module register(dataOut, writeEnable, dataIn, clk, reset);
	
	input logic [63:0] dataIn;
	input logic writeEnable, clk, reset;
	output logic [63:0] dataOut;
	logic [63:0] d;
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : generate_block_identifier
			mux2_1 m0 (.out(d[i]), .in({dataIn[i], dataOut[i]}), .sel(writeEnable));
			D_FF bit0 (.q(dataOut[i]), .d(d[i]), .reset, .clk);
		end
	endgenerate
	
endmodule

module register_testbench();
	logic [63:0] dataIn, dataOut;
	logic writeEnable, clk, reset;

	register dut (.dataOut, .writeEnable, .dataIn, .clk, .reset);
 
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end      

	// Set up the inputs to the design.  Each line is a clock cycle.   
	initial begin                        
																@(posedge clk);    
		reset <= 1;            							@(posedge clk);    
		reset <= 0; writeEnable = 0; dataIn <= 0; @(posedge clk);                        
																@(posedge clk);                        
						dataIn <= 32;			  			@(posedge clk);                        
																@(posedge clk);                
						dataIn <= 405; 					@(posedge clk);                
																@(posedge clk);
		writeEnable = 1; dataIn <= 0; 				@(posedge clk);                        
																@(posedge clk);                        
						dataIn <= 32;			  			@(posedge clk);                        
																@(posedge clk);                
						dataIn <= 128; 					@(posedge clk);                
																@(posedge clk);
		writeEnable = 0; dataIn <= 0; 				@(posedge clk);                        
																@(posedge clk);                        
						dataIn <= 5627;			  		@(posedge clk);                        
																@(posedge clk);                
						dataIn <= 123818751; 			@(posedge clk);                
																@(posedge clk);
		$stop; // End the simulation.   
	end 

endmodule
