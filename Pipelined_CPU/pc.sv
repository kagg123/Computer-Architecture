module pc(input logic reset, clk, 
          input logic [63:0] d,
          output logic [63:0] q);

		genvar i;
		generate
			for (i = 0; i < 64; i++) begin : generate_block_identifier	
				D_FF curr_dff (.q(q[i]), .d(d[i]), .reset, .clk);
			end
		endgenerate

endmodule


module pc_testbench();
 
	logic reset, clk;
   logic [63:0] d;
   logic [63:0] q;
	
	pc dut (.reset, .clk, .d, .q);
	
	// Set up the clock.   
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 
	
	initial begin                        
									  @( posedge clk );    
		reset <= 1;            @( posedge clk );    
		reset <= 0; d <= 5; @( posedge clk );                        
									  @( posedge clk );                        
									  @( posedge clk );                        
									  @( posedge clk );                
						d <= 4; @( posedge clk );    
                          @( posedge clk ); 						
		reset <= 1;			   @( posedge clk );
		                    @( posedge clk );
								  @( posedge clk );
					  
		$stop; // End the simulation.   
	end  
	

endmodule
