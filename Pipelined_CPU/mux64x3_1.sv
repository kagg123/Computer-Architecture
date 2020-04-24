`timescale 1ns/10ps
module mux64x3_1 (muxOutput, muxInputs, sel);

	input logic [63:0] muxInputs[2:0] ;
	input logic [1:0] sel;
	output logic [63:0] muxOutput;
	

	logic [2:0] temp [63:0] ;
	
	integer i;
	integer j;
	always_comb begin
		for (i = 0; i < 3; i++) begin 
			for (j = 0; j < 64; j++) begin
				temp[j][i] =  muxInputs[i][j];
			end
		end
	end
	
	genvar k;
	generate
		for (k = 0; k < 64; k++) begin : generate_block_2
		  mux3_1 mx (.out(muxOutput[k]), .in(temp[k]), .sel(sel));
		end
	endgenerate

endmodule

module mux64x3_1_testbench ();
	logic [63:0] muxInputs [2:0];
	logic [1:0] sel;
	logic [63:0] muxOutput;
	
	mux64x3_1 dut (.muxOutput, .muxInputs, .sel);
      //integer i;                
		initial begin                        
			muxInputs[0] = 0;muxInputs[1] = 1; muxInputs[2] = 2; #1;
			sel = 2'b00; #10;
			sel = 2'b01; #10;
			sel = 2'b10; #10;


	end
 
endmodule