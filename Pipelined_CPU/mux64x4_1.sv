`timescale 1ns/10ps
module mux64x4_1 (muxOutput, muxInputs, sel);

	input logic [63:0] muxInputs[3:0] ;
	input logic [1:0] sel;
	output logic [63:0] muxOutput;
	

	logic [3:0] temp [63:0] ;
	
	integer i;
	integer j;
	always_comb begin
		for (i = 0; i < 4; i++) begin 
			for (j = 0; j < 64; j++) begin
				temp[j][i] =  muxInputs[i][j];
			end
		end
	end
	
	genvar k;
	generate
		for (k = 0; k < 64; k++) begin : generate_block_2
		  mux4_1 mx (.out(muxOutput[k]), .in(temp[k]), .sel(sel));
		end
	endgenerate

endmodule


