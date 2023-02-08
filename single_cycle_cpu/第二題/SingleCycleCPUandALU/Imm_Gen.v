module Imm_Gen
(
    instr_data_i,
    imm_data_o
);
//*****************************************************************************
    // Parameters declaration
    // Operation codes
    localparam OPC_OP     = 5'b01100; // Operation
    localparam OPC_OP_IMM = 5'b00100; // Operation immediate
    localparam OPC_LOAD   = 5'b00000; // Load
    localparam OPC_STORE  = 5'b01000; // Store
    localparam OPC_BRANCH = 5'b11000; // Branch
    localparam OPC_JAL    = 5'b11011; // Jal
    localparam OPC_JALR   = 5'b11001; // Jalr

    // I/O port declaration
    input  wire [32-1:0] instr_data_i; // Instruction data input
    output reg  [32-1:0] imm_data_o;   // Immediate generator data output

    // Global variable declaration
    // System
    wire [19:0] sign_ext_20; // 20 bits sign-extension
    wire [11:0] sign_ext_12; // 12 bits sign-extension
    // System conection
    assign sign_ext_20 = {20{instr_data_i[31]}};
    assign sign_ext_12 = {12{instr_data_i[31]}};
//*****************************************************************************
// Block : Immediate generator
    always @(*)
    begin
        case (instr_data_i[6:2])
            OPC_OP :
                // R-type
                imm_data_o = 32'd0;
            OPC_OP_IMM, OPC_LOAD, OPC_JALR:
                // I-type
                imm_data_o = {sign_ext_20, instr_data_i[31:20]};
            OPC_STORE:
                // S-type
                imm_data_o = {sign_ext_20, instr_data_i[31:25], instr_data_i[11:7]};
            OPC_BRANCH:
                // B-type
                imm_data_o = {{19{instr_data_i[31]}}, instr_data_i[31], instr_data_i[7], instr_data_i[30:25], instr_data_i[11:8], 1'b0};
            OPC_JAL:
                // J-type
                imm_data_o = {{11{instr_data_i[31]}}, instr_data_i[31], instr_data_i[19:12], instr_data_i[20], instr_data_i[30:21], 1'b0};
            default: imm_data_o = 32'd0;// Not implemented
        endcase
    end
//*****************************************************************************
endmodule