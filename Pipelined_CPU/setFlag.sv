`timescale 1ns/10ps
module setFlag (
	input logic negALU, zeroALU, overflowALU, carry_outALU, flagEn, reset, clk,
	output logic negFlag, zeroFlag, overflowFlag, carry_outFlag
	);
	
	logic [3:0] previous;
	
	D_FF d1 (.q(previous[0]), .d(negFlag), .reset, .clk);
	D_FF d2 (.q(previous[1]), .d(zeroFlag), .reset, .clk);
	D_FF d3 (.q(previous[2]), .d(overflowFlag), .reset, .clk);
	D_FF d4 (.q(previous[3]), .d(carry_outFlag), .reset, .clk);
	
	mux2_1 m1 (.out(negFlag), .in({negALU, previous[0]}), .sel(flagEn));
	mux2_1 m2 (.out(zeroFlag), .in({zeroALU, previous[1]}), .sel(flagEn));
	mux2_1 m3 (.out(overflowFlag), .in({overflowALU, previous[2]}), .sel(flagEn));
	mux2_1 m4 (.out(carry_outFlag), .in({carry_outALU, previous[3]}), .sel(flagEn));

endmodule

