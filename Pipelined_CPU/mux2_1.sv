`timescale 1ns/10ps
module mux2_1(out, in, sel);
 output logic out;
 input logic [1:0] in;
 input logic sel;
 
 logic or_one, or_two, notSelect;
 
 // (in[1] & sel) | (in[0] & ~sel);
 and #0.05 input1 (or_one, sel, in[1]);
 not #0.05 invert (notSelect, sel);
 and #0.05 input2 (or_two, notSelect, in[0]);
 or #0.05 result (out, or_one, or_two);
 
 // assign out = (in[1] & sel) | (in[0] & ~sel);
endmodule

module mux2_1_testbench();
 logic [1:0] in;
 logic sel, out;

 mux2_1 dut (.out, .in, .sel);

 integer i;
 initial begin
	for (i = 0; i < 2; i++) begin
		sel = i;
		in[i] = 0; #10;
		in[i] = 1; #10;
	end

 end
endmodule
