module Simple_Single_CPU
(
    clk_i,
    rst_n
);
//*****************************************************************************
    ///////////////////////////////////////////////////////////////////////////
    // I/O Ports Declaration
    input         clk_i;         // System clock
    input         rst_n;         // All reset
    // Global variables Declaration
    // ProgramCounter
    wire [32-1:0] PC_next;       // PC address in
    wire [32-1:0] PC_pres;       // PC address out

    // Instr_Memory
    wire [32-1:0] instr;         // Instruction data

    // ImmGen
    wire [32-1:0] imm_out;       // Address with sign extend

    // Controller
    wire [   3:0] funct;         // Simplified function code
    wire [   6:0] opcode;        // Instruction opcode
    wire [ 2-1:0] ALUop;         // ALU opcode
    wire          RegWrite;      // Register Write
    wire          MemWrite;      // Memory Write
    wire [ 2-1:0] MemtoReg;      // Destination register write back data select
    wire          MemRead;       // Memory Read
    wire          ALUSrc;        // ALU source B select
    wire          Branch;        // Branch instruction
    wire          Jal;           // Jal instruction
    wire          Jalr;          // Jalr instruction

    // Reg_File
    wire [ 5-1:0] rs1_addr;      // Source register 1 index
    wire [ 5-1:0] rs2_addr;      // Source register 2 index
    wire [ 5-1:0] rd_addr;       // Destination register index
    wire [32-1:0] rs1_data;      // Source register 1 data
    wire [32-1:0] rs2_data;      // Source register 2 data
    wire [32-1:0] rd_data;       // Destination register data

    // ALU
    wire [32-1:0] ALUsrcA;       // ALU source A value
    wire [32-1:0] ALUsrcB;       // ALU source B value
    wire [32-1:0] ALUresult;     // ALU operation result
    wire [ 4-1:0] NZCV;          // NZCV flag, N: Negative, Z: Zero, C: Carry, V: Overflow

    // Adder
    wire [32-1:0] PC_plusfour;   // PC+4 value
    wire [32-1:0] PC_branch;     // Branch target address
    wire [32-1:0] PC_jump;       // Jump address

    // ALU_Ctrl
    wire [ 4-1:0] ALUctrl;       // 4 bits ALU control input

    // Data_Memory
    wire [32-1:0] mem_data_wr;   // Memory write data
    wire [32-1:0] mem_data_rd;   // Memory read data

    // MUX_2to1
    wire [32-1:0] PC_target;     // Target address with branch/jal
    wire          target_sel;    // Target address select
    ///////////////////////////////////////////////////////////////////////////
    // System conection
    // Program Counter
    ProgramCounter PC
    (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .load_i(PC_next),         // Next PC value
        .count_o(PC_pres)         // Present PC value
    );

    // Instruction Memory
    Instr_Memory IM
    (
        .PC_addr_i(PC_pres),      // Present PC value
        .instr_o(instr)         // Instruction data
    );

    // Immediate Generator
    Imm_Gen ImmGen
    (
        .instr_data_i(instr),   // Instruction data
        .imm_data_o(imm_out)      // Immediate value
    );

    // Controller
    assign opcode = instr[6:0];
    Controller Control
    (
        .instr_op_i(opcode),    // Instruction opcode
        .ALUop_o(ALUop),       // ALU opcode
        .RegWrite_o(RegWrite),    // Register write
        .MemWrite_o(MemWrite),    // Memory write
        .MemtoReg_o(MemtoReg),    // Write back data select
        .MemRead_o(MemRead),     // Memory read
        .ALUSrc_o(ALUSrc),      // ALU source B select
        .Branch_o(Branch),      // Branch instruction
        .Jal_o(Jal),         // Jal instruction
        .Jalr_o(Jalr)         // Jalr instruction
    );

    // Register File
    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11: 7];
    Reg_File RF
    (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .RegWrite_i(RegWrite),    // Register write control signal
        .rs1_addr_i(rs1_addr),    // Source register 1 index
        .rs2_addr_i(rs2_addr),    // Source register 2 index
        .rd_addr_i(rd_addr),     // Destination register index
        .rd_data_i(rd_data),     // Destination register data
        .rs1_data_o(rs1_data),    // Source register 1 data
        .rs2_data_o(rs2_data)     // Source register 2 data
    );

    // ALU source B select
    MUX_2to1 MUX_ALUSrc
    (
        .data0_i(rs2_data),       // Source register 2 data
        .data1_i(imm_out),       // Immediate value
        .select_i(ALUSrc),     // ALU source B select
        .data_o(ALUsrcB)         // ALU source B data
    );

    // Arithmetic Logic Unit
    assign ALUsrcA = rs1_data;
    ALU ALU
    (
        .srcA_i(ALUsrcA),        // ALU source A value
        .srcB_i(ALUsrcB),        // ALU source B value
        .ALUctrl_i(ALUctrl),     // ALU control signals
        .ALUresult_o(ALUresult),   // ALU operation result
        .NZCV_o(NZCV)         // NZCV flag, N: Negative, Z: Zero, C: Carry, V: Overflow
    );

    // ALU controller
    assign funct = {instr[30], instr[14:12]};
    ALU_Conrtoller ALU_Conrtoller
    (
        .funct_i(funct),      // function code
        .ALUop_i(ALUop),      // ALU opcode
        .ALUctrl_o(ALUctrl)     // ALU Control signals
    );

    // Adder for PC+4
    adder adder_PC_plusfour
    (
        .srcA_i(PC_pres),       // Present PC value
        .srcB_i(32'd4),
        .sum_o(PC_plusfour)         // PC+4 value
    );

    // Data Memory
    assign mem_data_wr = rs2_data;
    Data_Memory DM
    (
        .clk_i(clk_i),        // System clock
        .addr_i(ALUresult),       // Memory address value
        .data_wr_i(mem_data_wr),    // Memory write data
        .MemRead_i(MemRead),    // Memory read control signal
        .MemWrite_i(MemWrite),   // Memory write control signal
        .data_rd_o(mem_data_rd)     // Memory read data
    );

    // Adder for branch target address
    adder adder_branch_addr
    (
        .srcA_i(PC_pres),       // Current PC value
        .srcB_i(imm_out),       // Immediate value
        .sum_o(PC_branch)         // Branch target address
    );

    // Write back source select
    MUX_4to1 MUX_Mem_Reg
    (
        .data0_i(ALUresult),      // ALU operation result
        .data1_i(mem_data_rd),      // Memort read data
        .data2_i(PC_plusfour),      // PC+4 value
        .data3_i(32'd0), // None
        .select_i(MemtoReg),     // Write back data select
        .data_o(rd_data)        // Destination register write back data
    );

    // Target address with branch select
    assign target_sel = (Branch & NZCV[2]) | Jal;
    MUX_2to1 MUX_PC_Source
    (
        .data0_i(PC_plusfour),      // Current PC value
        .data1_i(PC_branch),      // Branch target address
        .select_i(target_sel),     // Branch condition
        .data_o(PC_target)        // Target address with branch/jal
    );

    // Adder for branch target address
    adder adder_jalr_addr
    (
        .srcA_i(rs1_data),       // Source register 1
        .srcB_i(imm_out),       // Immediate value
        .sum_o(PC_jump)         // Jump address
    );

    // Next PC source select
    MUX_2to1 MUX_PC_Branch
    (
        .data0_i(PC_target),      // Target address with branch
        .data1_i(PC_jump),      // Jump address
        .select_i(Jalr),     // Jalr instruction
        .data_o(PC_next)        // Next PC value
    );
//*****************************************************************************
endmodule