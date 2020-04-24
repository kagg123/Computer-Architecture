`timescale 1ns/10ps
module mux4_1(out, in, sel);
 output logic out;
 input logic [3:0] in;
 input logic [1:0] sel;

 logic v0, v1;

 mux2_1 m0 (.out(v0), .in(in[1:0]), .sel(sel[0]));
 mux2_1 m1 (.out(v1), .in(in[3:2]),  .sel(sel[0]));
 mux2_1 m  (.out, .in({v1, v0}), .sel(sel[1]));
endmodule

module mux4_1_testbench();
 logic [3:0] in;
 logic [1:0] sel;
 logic out;

 mux4_1 dut (.out, .in, .sel);
 
 integer i;
 initial begin
	 for (i = 0; i < 4; i++) begin
		sel = i;
		in[i] = 0; #10;
		in[i] = 1; #10;
	end

 end
endmodule
