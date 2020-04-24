module signExtend #(parameter WIDTH = 9) (extend, extended);
	input logic [WIDTH-1:0] extend; 
	output logic [63:0] extended;
	assign extended = { {(64-WIDTH){extend[WIDTH-1]}}, extend[WIDTH-1:0] };
endmodule

module signExtend_testbench();
	logic [8:0] extend9; 
	logic [11:0] extend12;
	logic [18:0] extend19; 
	logic [25:0] extend26; 
	logic [63:0] extendedOutput9, extendedOutput12, extendedOutput19, extendedOutput26;
	
	signExtend #(.WIDTH(9)) extend1 (.extend(extend9), .extended(extendedOutput9));
	signExtend #(.WIDTH(12)) extend2 (.extend(extend12), .extended(extendedOutput12));
	signExtend #(.WIDTH(19)) extend3 (.extend(extend19), .extended(extendedOutput19));
	signExtend #(.WIDTH(26)) extend4 (.extend(extend26), .extended(extendedOutput26));
	
   initial begin
	
		extend9 <= 9'b010110001; extend12 <= 12'b010110001001; extend19 <= 19'b0101100010101100011; extend26 <= 26'b01011000101011000101011000; #10;
		extend9 <= 9'b110110001; extend12 <= 12'b110110001001; extend19 <= 19'b1101100010101100011; extend26 <= 26'b11011000101011000101011000; #10;
		
	end


endmodule
