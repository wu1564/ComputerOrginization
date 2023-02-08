module Controller
(
    instr_op_i,
    ALUop_o,
    RegWrite_o,
    MemWrite_o,
    MemtoReg_o,
    MemRead_o,
    ALUSrc_o,
    Branch_o,
    Jal_o,
    Jalr_o
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
    localparam OPC_LUI    = 5'b01101; // LUI
    localparam OPC_AUIPC  = 5'b00101; // AUIPC

    // Function codes
    // Arithmetic operation
    localparam F3_ADDSUB = 3'b000; // Addition / Subtration
    localparam F3_SLT    = 3'b010; // Set less than (signed)
    localparam F3_SLTU   = 3'b011; // Set less than (unsigned)
    localparam F3_XOR    = 3'b100; // Exclusive OR
    localparam F3_OR     = 3'b110; // OR logic
    localparam F3_AND    = 3'b111; // AND logic
    localparam F3_SLL    = 3'b001; // Logic shift left
    localparam F3_SR     = 3'b101; // Shift right (Logic / Arithmetic)
    
    // I/O port declaration
    input  wire [7-1:0] instr_op_i; // Instruction opcode
    output  reg [2-1:0] ALUop_o;    // ALU opcode
    output  reg         RegWrite_o; // Register write signal
    output  reg         MemWrite_o; // Memory write signal
    output  reg [2-1:0] MemtoReg_o; // RD_data select
    output  reg         MemRead_o;  // Memory read signal
    output  reg         ALUSrc_o;   // ALU src2 select
    output  reg         Branch_o;   // Branch address select
    output  reg         Jal_o;      // Jump address select (Jal)
    output  reg         Jalr_o;     // Jump address select (Jalr)
//*****************************************************************************
// Block: Control Singal Decoder
    always @(*)
    begin
        case (instr_op_i[6:2]) // Acturally use 5 bits
        ///////////////////////////////////////////////////////////////////////////// HARDER VERSION
        // Solve the truth table
        ///////////////////////////////////////////////////////////////////////////
        // opcode  | RegWrite | ALUSrc | MemWrite | MemtoReg | MemRead | Branch | Jal | Jalr | ALUop |
        // --------+----------+--------+----------+----------+---------+--------+-----+------+-------+------------------
        // 0000011 |    1     |   1    |    0     |    01    |    1    |    0   |  0  |   0  |   00  | LW
        // 0100011 |    0     |   1    |    1     |    00    |    0    |    0   |  0  |   0  |   00  | SW
        // 1100011 |    0     |   0    |    0     |    00    |    0    |    1   |  0  |   0  |   01  | BEQ
        // 0110011 |    1     |   0    |    0     |    00    |    0    |    0   |  0  |   0  |   10  | R-type
        // 0010011 |    1     |   1    |    0     |    00    |    0    |    0   |  0  |   0  |   10  | R-type immediate 
        // 1101111 |    1     |   0    |    0     |    10    |    0    |    0   |  1  |   0  |   00  | JAL
        // 1100111 |    1     |   0    |    0     |    10    |    0    |    0   |  0  |   1  |   00  | JALR
        ///////////////////////////////////////////////////////////////////////////
            OPC_LOAD: // LW
                begin
                    RegWrite_o = 1'b1;
                    ALUSrc_o   = 1'b1;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b01;
                    MemRead_o  = 1'b1;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b00;
                end
            OPC_STORE: // SW
                begin
                    RegWrite_o = 1'b0;
                    ALUSrc_o   = 1'b1;
                    MemWrite_o = 1'b1;
                    MemtoReg_o = 2'b00;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b00;
                end
            OPC_BRANCH: // BEQ
                begin
                    RegWrite_o = 1'b0;
                    ALUSrc_o   = 1'b0;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b00;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b1;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b01;
                end
            OPC_OP: // R-type Arithmetic
                begin
                    RegWrite_o = 1'b1;
                    ALUSrc_o   = 1'b0;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b00;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b10;
                end
            OPC_OP_IMM: // Arithmetic immediate
                begin
                    RegWrite_o = 1'b1;
                    ALUSrc_o   = 1'b1;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b00;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b10;
                end
            OPC_JAL: // Jal
                begin
                    RegWrite_o = 1'b1;
                    ALUSrc_o   = 1'b0;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b10;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b1;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b00;
                end
            OPC_JALR: // Jalr
                begin
                    RegWrite_o = 1'b1;
                    ALUSrc_o   = 1'b0;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b10;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b1;
                    ALUop_o    = 2'b00;
                end
            default: // None
                begin
                    RegWrite_o = 1'b0;
                    ALUSrc_o   = 1'b0;
                    MemWrite_o = 1'b0;
                    MemtoReg_o = 2'b00;
                    MemRead_o  = 1'b0;
                    Branch_o   = 1'b0;
                    Jal_o      = 1'b0;
                    Jalr_o     = 1'b0;
                    ALUop_o    = 2'b00;
                end
        endcase
    end
//*****************************************************************************
endmodule