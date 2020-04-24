`timescale 1ns/10ps

module isZero (zero, result);
    input logic [63:0] result;
    output logic zero;
    logic [15:0] temp;
	logic [3:0] temp2;
	logic notzero;
	genvar j, k;
	
	generate
		for (j = 0; j < 16; j++) begin : generate_block_identifier1
			or #0.05 zerO (temp[j], result[j * 4], result[j * 4 + 1], result[j * 4 + 2], result[j * 4 + 3] );
		end
	endgenerate
	
	generate
		for (k = 0; k < 4; k++) begin : generate_block_identifier2
			or #0.05 zeRO (temp2[k], temp[k * 4], temp[k * 4 + 1], temp[k * 4 + 2], temp[k * 4 + 3] );
		end
	endgenerate
	
	or #0.05 zERO (notzero, temp2[0], temp2[1], temp2[2], temp2[3] );
	not #0.05 ZERO (zero, notzero);
endmodule

module isZero_testbench();
 logic [63:0] result;
 logic zero;

isZero DUT (.result, .zero);
 initial begin
     result = 0; #10;
     result = 1; #10;
     result = 64; #10;
     result = 0; #10;
 end
 endmodule
