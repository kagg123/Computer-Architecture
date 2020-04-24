`timescale 1ns/10ps
module mux16_1(out, in, sel);
 output logic out;
 input logic [15:0] in;
 input logic [3:0] sel;

 logic v0, v1;
  
  mux8_1 m5 (.out(v0), .in(in[7:0]), .sel(sel[2:0]));
  mux8_1 m4(.out(v1), .in(in[15:8]), .sel(sel[2:0]));
  mux2_1 m (.out, .in({v1, v0}), .sel(sel[3]));

endmodule

module mux16_1_testbench();
 logic out;
 logic [15:0] in;
 logic [3:0] sel;

 mux16_1 dut (.out, .in, .sel);
 
 integer i;
 initial begin
	 for (i = 0; i < 16; i++) begin
		sel = i;
		in[i] = 0; #10;
		in[i] = 1; #10;
	end
	
 end
endmodule
