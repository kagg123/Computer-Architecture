`timescale 1ns/10ps
module mux8_1(out, in, sel);
 output logic out;
 input logic [7:0] in;
 input logic [2:0] sel;

 logic v0, v1;
  
  mux4_1 m4 (.out(v0), .in(in[3:0]), .sel(sel[1:0]));
  mux4_1 m3(.out(v1), .in(in[7:4]), .sel(sel[1:0]));
  mux2_1 m2 (.out, .in({v1, v0}), .sel(sel[2]));

endmodule

module mux8_1_testbench();
 logic [7:0] in;
 logic [2:0] sel;
 logic out;

 mux8_1 dut (.out, .in, .sel);
 
 integer i;
 initial begin
	 for (i = 0; i < 8; i++) begin
		sel = i;
		in[i] = 0; #10;
		in[i] = 1; #10;
	end
	

 end
endmodule
