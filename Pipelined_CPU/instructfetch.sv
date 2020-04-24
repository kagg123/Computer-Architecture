`timescale 1ns/10ps
module instructfetch(input logic reset, clk, uncondBr,
							input logic [1:0] brTaken,
							input logic [18:0] condAddr19,
							input logic [25:0] condAddr26,
							input logic [63:0] forwardCtrlOneOutput,
							output logic [31:0] instruction,
							output logic [63:0] pc_output);
							
	logic [63:0] condAddr19_Extended;
	logic [63:0] condAddr26_Extended;


	signExtend #(.WIDTH(19)) extend1 (.extend(condAddr19), .extended(condAddr19_Extended));
	signExtend #(.WIDTH(26)) extend2 (.extend(condAddr26), .extended(condAddr26_Extended));
	
	logic [63:0] chooseAddress;
	
	logic [63:0] muxInput [1:0];
	assign muxInput[0] = condAddr19_Extended;
	assign muxInput[1] = condAddr26_Extended;
	
	mux64x2_1 bigMux (.muxOutput(chooseAddress), .muxInputs(muxInput), .select(uncondBr));
	
	logic [63:0] chooseAddress_shifted;
	
	shifter shift (.value(chooseAddress), .direction(1'b0), .distance(6'b000010), .result(chooseAddress_shifted));

	//logic [63:0] pc_output;
	logic [63:0] pc_output_clocked;
	logic [63:0] firstSum;
	logic [63:0] zerothSum;
	
	paramDFF #(.WIDTH(64)) pDff200 (.d(pc_output), .q(pc_output_clocked), .reset, .clk);

	addAddresses adder (.a(chooseAddress_shifted), .b(pc_output_clocked), .sum(firstSum));
	addAddresses adderTwo (.a(pc_output), .b(64'h0000000000000004), .sum(zerothSum));
	
	logic [63:0] finalAddress;
	
	logic [63:0] muxInputTwo [3:0];
	assign muxInputTwo[0] = zerothSum;
	assign muxInputTwo[1] = firstSum;
	assign muxInputTwo[2] = forwardCtrlOneOutput;
	assign muxInputTwo[3] = 0;
	mux64x4_1 secondBigMux (.muxOutput(finalAddress), .muxInputs(muxInputTwo), .sel(brTaken));
	
	pc pcCounter (.reset, .clk, .d(finalAddress), .q(pc_output));
	
	instructmem instruct (.address(pc_output), .instruction, .clk); // Memory is combinational, but used for error-checking
	
endmodule

module instructfetch_testbench();
							
	logic reset, clk, uncondBr;
	logic [1:0] brTaken;
   logic [18:0] condAddr19;
	logic [25:0] condAddr26;
   logic [63:0] forwardCtrlOneOutput, pc_output;
	logic [31:0] instruction;
	
	instructfetch dut (.reset, .clk, .uncondBr, .brTaken, .condAddr19, .condAddr26,
                      .forwardCtrlOneOutput, .instruction, .pc_output);
							 
	// Set up the clock.   
	parameter CLOCK_PERIOD = 100000;   
	initial begin    
		clk <= 0;    
		forever #( CLOCK_PERIOD / 2 ) clk <= ~clk;   
	end 
	
	initial begin     
									                            @( posedge clk );    
		reset <= 1; uncondBr <= 1'b0; brTaken <= 2'b00;  @( posedge clk );  
                                          @( posedge clk );    
		                                    @( posedge clk );
											         @( posedge clk );
														@( posedge clk );    				
		reset <= 0; condAddr19 <= 2; condAddr26 <= 2; forwardCtrlOneOutput <= 4; @( posedge clk );   
		                                    @( posedge clk );    
		                                    @( posedge clk );
													   @( posedge clk );	
														@( posedge clk ); 
								brTaken <= 2'b01;	@( posedge clk );
		                                    @( posedge clk );    
		                                    @( posedge clk ); 
														@( posedge clk );
														@( posedge clk );
		                  brTaken <= 2'b10; @( posedge clk );
														@( posedge clk );    
		                                    @( posedge clk ); 
														@( posedge clk );
														@( posedge clk );
		uncondBr <= 1'b1; brTaken <= 2'b00;	@( posedge clk );
														@( posedge clk );    
		                                    @( posedge clk ); 
														@( posedge clk );
													   @( posedge clk );	
		                brTaken <= 2'b01;	@( posedge clk );
		                                    @( posedge clk );    
		                                    @( posedge clk ); 
														@( posedge clk );
														@( posedge clk );
		                brTaken <= 2'b11;	@( posedge clk );
														@( posedge clk );												
														@( posedge clk );
														@( posedge clk );
									reset <= 0;		@( posedge clk );												
														@( posedge clk );
														@( posedge clk );
	   $stop; // End the simulation. 
	end
							
endmodule



