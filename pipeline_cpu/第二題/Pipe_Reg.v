module Pipe_Reg
	#(parameter size = 5)
	(
	 // Input  Declaration
	 input  rst_i,
	 input  clk_i,
	 input  [size-1:0]data_i,
	 // Output Declaration
	 output [size-1:0]data_o
	);
//*****************************************************************************
	// Global variables Declaration
	// System
	reg [size-1:0]data;
	// System conection
	// Output
	assign data_o = data;
//*****************************************************************************
	always @(posedge clk_i or negedge rst_i) begin
		if(!rst_i) data <= 0;
		else data <= data_i;
	end
//*****************************************************************************
endmodule
