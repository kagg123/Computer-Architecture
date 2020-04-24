`timescale 1ns/10ps
module mux3_1(out, in, sel);
 output logic out;
 input logic [2:0] in;
 input logic [1:0] sel;

 logic v0;

 mux2_1 m0 (.out(v0), .in(in[1:0]), .sel(sel[0]));
 mux2_1 m  (.out, .in({in[2], v0}), .sel(sel[1]));
endmodule

module mux3_1_testbench();
 logic [2:0] in;
 logic [1:0] sel;
 logic out;

 mux3_1 dut (.out, .in, .sel);

 integer i;
 initial begin
		in[0] = 0; in[1] = 1; in[2] = 0;
	 for (i = 0; i < 3; i++) begin
		sel = i; #10;
		
	end

 end
endmodule
