`timescale 1ns/10ps
module mux64x2_1 (muxOutput, muxInputs, select);

	input logic [63:0] muxInputs [1:0];
	input logic select;
	output logic [63:0] muxOutput;
	

	logic [1:0] temp [63:0];
	
	integer i;
	integer j;
	always_comb begin
		for (i = 0; i < 2; i++) begin 
			for (j = 0; j < 64; j++) begin
				temp[j][i] =  muxInputs[i][j];
			end
		end
	end
	
	genvar k;
	generate
		for (k = 0; k < 64; k++) begin : generate_block_2
		  mux2_1 mx (.out(muxOutput[k]), .in(temp[k]), .sel(select));
		end
	endgenerate

endmodule

module mux64x2_1_testbench();
	
	logic [63:0] muxInputs [1:0];
	logic select;
	logic [63:0] muxOutput;
	
	mux64x2_1 dut (.muxOutput, .muxInputs, .select);               
	
	initial begin                        
		muxInputs[0] = 0; muxInputs[1] = 31; #1;
		select = 0; #30;
		select = 1; #30;
	end
 
endmodule
