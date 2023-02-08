//*****************************************************************************
// Module Declaration
module ALU
(
    srcA_i,
    srcB_i,
    ALUctrl_i,
    ALUresult_o,
    NZCV_o
);
//*****************************************************************************
    // I/O Port Declaration
    input  [32-1:0] srcA_i;      // 32 bits source A
    input  [32-1:0] srcB_i;      // 32 bits source B
    input  [ 4-1:0] ALUctrl_i;   // 4 bits ALU control signals
    output [32-1:0] ALUresult_o; // 32 bits ALU operation result
    output [ 4-1:0] NZCV_o;      // N: Negative, Z: Zero, C: Carry, V: Overflow

    // Global variables Declaration
    // System
    reg    [33-1:0] result; // ALU operation result (include carry out bit)

    // System conection
    // Output
    assign ALUresult_o = result[31:0];
    assign NZCV_o[3]   = result[31];       // Sign bit
    assign NZCV_o[2]   = ~(|result[31:0]); // NOR all bits
    assign NZCV_o[1]   = result[32];       // Carry out bit (only for addition/subtract)
    assign NZCV_o[0]   = (srcA_i[31] ^ result[31]) & (srcB_i[31] ^ result[31]); // Positive/Negative overflow
//*****************************************************************************
// Block : ALU operation with behavioral description
    always @(*)
    begin
        case(ALUctrl_i) 
            4'b0000: result = {1'b0, srcA_i & srcB_i};                             // AND
            4'b0001: result = {1'b0, srcA_i | srcB_i};                             // OR 
            4'b0010: result = {1'b0, srcA_i} + {1'b0, srcB_i};                     // Addition (signed)
            4'b0110: result = {1'b0, srcA_i} + {1'b0, (~srcB_i + 1'b1)};           // Subtract (signed)
            4'b0111: result = ($signed(srcA_i) < $signed(srcB_i)) ? 33'd1 : 33'd0; // Set less than (signed)
            4'b1100: result = {1'b0, ~(srcA_i | srcB_i)};                          // NOR
            4'b1101: result = {1'b0, ~(srcA_i & srcB_i)};                          // NAND
            default: result = 33'd0;                                               // Default: 0
        endcase
    end
//*****************************************************************************
endmodule