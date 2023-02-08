//*****************************************************************************
// Module declaration
module adder
(
    srcA_i, // 32 bits source 1
    srcB_i, // 32 bits source 2
    sum_o   // 32 bits result
);
//*****************************************************************************
    // I/O port declaration
    input  [32-1:0] srcA_i;
    input  [32-1:0] srcB_i;
    output [32-1:0] sum_o;

    // System conection
    // Output
    assign sum_o = srcA_i + srcB_i;
//*****************************************************************************
endmodule