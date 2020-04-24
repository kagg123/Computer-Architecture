`timescale 1ns/10ps
module paramDFF #(parameter WIDTH = 9) (d, q, reset, clk);
    input logic [WIDTH - 1 : 0] d;
    input logic clk, reset;
    output logic [WIDTH - 1 : 0] q;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : generate_block_identifier	
            D_FF curr_dff (.q(q[i]), .d(d[i]), .reset, .clk);
        end
    endgenerate
endmodule

module paramDFF_testbench();
    logic [2:0] d;
    logic clk, reset;
    logic [2:0] q;

    paramDFF #(.WIDTH(3)) dut (.d, .q, .reset, .clk);

    // Set up the clock.   
	parameter CLOCK_PERIOD = 100;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 

    initial begin
        					          @( posedge clk );    
		reset <= 1;                   @( posedge clk );    
		reset <= 0; d <= 3'b000;      @( posedge clk );                        
									  @( posedge clk );                        
					d <= 3'b001;      @( posedge clk );                        
									  @( posedge clk );                
					d <= 3'b010;      @( posedge clk );                
						              @( posedge clk );                
					d <= 3'b011;      @( posedge clk );                        
									  @( posedge clk );                        
					d <= 3'b100;	  @( posedge clk );                        
									  @( posedge clk );               
				    d <= 3'b101;      @( posedge clk );                        
									  @( posedge clk ); 
					d <= 3'b110;	  @( posedge clk ); 
									  @( posedge clk ); 
                    d <= 3'b110;      @( posedge clk ); 	
                                      @( posedge clk );
                    d <= 3'b111;      @( posedge clk );
        reset <= 1;                   @( posedge clk );					  
		$stop; // End the simulation.   
    end
endmodule
