module mux2x3_1 (muxOutput, muxInputs, select);

	input logic [1:0] muxInputs [2:0];
	input logic [1:0] select;
	output logic [1:0] muxOutput;
	

	logic [2:0] temp [1:0];
	
	integer i;
	integer j;
	always_comb begin
		for (i = 0; i < 3; i++) begin 
			for (j = 0; j < 2; j++) begin
				temp[j][i] =  muxInputs[i][j];
			end
		end
	end
	
	genvar k;
	generate
		for (k = 0; k < 2; k++) begin : generate_block_2
		  mux3_1 mx (.out(muxOutput[k]), .in(temp[k]), .sel(select));
		end
	endgenerate

endmodule
