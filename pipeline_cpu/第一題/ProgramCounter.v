module ProgramCounter
(
    clk_i, // System Clock
    rst_n, // All Reset
    load_i, // Next PC Address
    count_o // PC Address for Now
);
//*****************************************************************************
    // I/O Port Declaration
    input  wire          clk_i;    // System Clock
    input  wire          rst_n;    // All Reset
    input  wire [32-1:0] load_i;  // Next PC Address
    output reg  [32-1:0] count_o; // PC Address for Now
//*****************************************************************************
// Block : PC data out
    always @(posedge clk_i or negedge rst_n) 
    begin
        if(~rst_n)
            count_o <= 0;
        else
            count_o <= load_i;
    end
//*****************************************************************************
endmodule
