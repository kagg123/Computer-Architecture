`timescale 1ns/10ps
module mux5x2_1 (muxOutput, muxInputs, sel);

	input logic [4:0] muxInputs[1:0] ;
	input logic sel;
	output logic [4:0] muxOutput;
	

	logic [1:0] temp [4:0] ;
	
	integer i;
	integer j;
	always_comb begin
		for (i = 0; i < 2; i++) begin 
			for (j = 0; j < 5; j++) begin
				temp[j][i] =  muxInputs[i][j];
			end
		end
	end
	
	genvar k;
	generate
		for (k = 0; k < 5; k++) begin : generate_block_2
		  mux2_1 mx (.out(muxOutput[k]), .in(temp[k]), .sel(sel));
		end
	endgenerate

endmodule

module mux5x2_1_testbench ();
	logic [4:0] muxInputs [1:0];
	logic  sel;
	logic [4:0] muxOutput;
	
	mux5x2_1 dut (.muxOutput, .muxInputs, .sel);
		
	initial begin                        
		muxInputs[0] = 0; muxInputs[1] = 31; #1;
		sel = 0; #30;
		sel = 1; #30;
	end
 
endmodule
