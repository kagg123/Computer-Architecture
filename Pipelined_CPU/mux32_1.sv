`timescale 1ns/10ps
module mux32_1(out, in, sel);
 output logic out;
 input logic [31:0] in;
 input logic [4:0] sel;

 logic v0, v1;
  
  mux16_1 m8(.out(v0), .in(in[15:0]), .sel(sel[3:0]));
  mux16_1 m7(.out(v1), .in(in[31:16]), .sel(sel[3:0]));
  mux2_1 m6 (.out, .in({v1, v0}), .sel(sel[4]));

endmodule

module mux32_1_testbench();
 logic [31:0] in;
 logic [4:0] sel;
 logic out;

 mux32_1 dut (.out, .in, .sel);
 
 integer i;
 initial begin
	 for (i = 0; i < 32; i++) begin
		sel = i;
		in[i] = 0; #10;
		in[i] = 1; #10;
	end

 end
endmodule
