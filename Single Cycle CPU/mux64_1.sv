`timescale 1ns/10ps
module mux64_1 (readData, dataFromReg, readRegister);

	input logic [63:0] dataFromReg[31:0] ;
	input logic [4:0] readRegister;
	output logic [63:0] readData;
	

	logic [31:0] temp [63:0] ;
	
	integer i;
	integer j;
	always_comb begin
		for (i = 0; i < 32; i++) begin 
			for (j = 0; j < 64; j++) begin
				temp[j][i] =  dataFromReg[i][j];
			end
		end
	end
	
	genvar k;
	generate
		for (k = 0; k < 64; k++) begin : generate_block_2
		  mux32_1 mx (.out(readData[k]), .in(temp[k]), .sel(readRegister));
		end
	endgenerate

endmodule

module mux64_1_testbench ();
	logic [63:0] dataFromReg [31:0];
	logic [4:0] readRegister;
	logic [63:0] readData;
	
	mux64_1 dut (.readData, .dataFromReg, .readRegister);
	integer i;
	initial begin                        
		for (i = 0; i < 64; i++) begin
			dataFromReg[i] = i; #1;
		end 
		for (i = 0; i < 32; i++) begin
			readRegister = i; #30;
		end 
	end 

endmodule
