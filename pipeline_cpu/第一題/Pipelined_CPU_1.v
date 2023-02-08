module Pipelined_CPU
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
    // ProgramCounter IF
    wire [32-1:0] PC_next_IF;       // PC address in
    wire [32-1:0] PC_pres_IF;       // PC address out

    // ProgramCounter ID
    wire [32-1:0] PC_pres_ID;       // PC address out

    // ProgramCounter EX
    wire [32-1:0] PC_pres_EX;       // PC address out

    // Instr_Memory IF
    wire [32-1:0] instr_IF;         // Instruction data

    // Instr_Memory ID
    wire [32-1:0] instr_ID;         // Instruction data


    // ImmGen ID
    wire [32-1:0] imm_out_ID;       // Address with sign extend

    // ImmGen EX
    wire [32-1:0] imm_out_EX;       // Address with sign extend

    // Controller ID
    wire [   3:0] funct_ID;
    wire [   6:0] opcode_ID;        // Instruction opcode
    wire [ 2-1:0] ALUop_ID;         // ALU opcode
    wire          RegWrite_ID;      // Register Write
    wire          MemWrite_ID;      // Memory Write
    wire [ 2-1:0] MemtoReg_ID;      // Destination register write back data select
    wire          MemRead_ID;       // Memory Read
    wire          ALUSrc_ID;        // ALU source B select
    wire          Branch_ID;        // Branch instruction

    // Controller EX
    wire [   3:0] funct_EX;
    wire [ 2-1:0] ALUop_EX;         // ALU opcode
    wire          RegWrite_EX;      // Register Write
    wire          MemWrite_EX;      // Memory Write
    wire [ 2-1:0] MemtoReg_EX;      // Destination register write back data select
    wire          MemRead_EX;       // Memory Read
    wire          ALUSrc_EX;        // ALU source B select
    wire          Branch_EX;        // Branch instruction

    // Controller MEM
    wire          RegWrite_MEM;      // Register Write
    wire          MemWrite_MEM;      // Memory Write
    wire [ 2-1:0] MemtoReg_MEM;      // Destination register write back data select
    wire          MemRead_MEM;       // Memory Read
    wire          Branch_MEM;        // Branch instruction

    // Controller WB
    wire          RegWrite_WB;      // Register Write
    wire [ 2-1:0] MemtoReg_WB;      // Destination register write back data select

    // Reg_File ID
    wire [ 5-1:0] rs1_addr_ID;      // Source register 1 index
    wire [ 5-1:0] rs2_addr_ID;      // Source register 2 index
    wire [ 5-1:0] rd_addr_ID;       // Destination register index
    wire [32-1:0] rs1_data_ID;      // Source register 1 data
    wire [32-1:0] rs2_data_ID;      // Source register 2 data

    // Reg_File EX
    wire [ 5-1:0] rd_addr_EX;       // Destination register index
    wire [32-1:0] rs1_data_EX;      // Source register 1 data
    wire [32-1:0] rs2_data_EX;      // Source register 2 data

    // Reg_File MEM
    wire [ 5-1:0] rd_addr_MEM;       // Destination register index
    wire [32-1:0] rs1_data_MEM;      // Source register 1 data
    wire [32-1:0] rs2_data_MEM;      // Source register 2 data

    // Reg_File WB
    wire [32-1:0] rd_data_WB;       // Destination register data
    wire [ 5-1:0] rd_addr_WB;       // Destination register index

    
    // ALU EX
    wire [32-1:0] ALUsrcA_EX;       // ALU source A value
    wire [32-1:0] ALUsrcB_EX;       // ALU source B value
    wire [32-1:0] ALUresult_EX;     // ALU control signals
    wire [ 4-1:0] NZCV_EX;          // NZCV flag, N: Negative, Z: Zero, C: Carry, V: Overflow

    // ALU MEM
    wire [32-1:0] ALUresult_MEM;     // ALU control signals
    wire [ 4-1:0] NZCV_MEM;          // NZCV flag, N: Negative, Z: Zero, C: Carry, V: Overflow

    // ALU WB
    wire [32-1:0] ALUresult_WB;     // ALU control signals
    // Adder IF
    wire [32-1:0] PC_plusfour_IF;   // PC+4 value

    // Adder EX
    wire [32-1:0] PC_branch_EX;     // Branch target address
    
    // Adder MEM
    wire [32-1:0] PC_branch_MEM;     // Branch target address

    // ALU_Ctrl EX
    wire [ 4-1:0] ALUctrl_EX;       // 4 bits ALU control input

    // Data_Memory MEM
    wire [32-1:0] mem_data_wr_MEM;   // Memory write data
    wire [32-1:0] mem_data_rd_MEM;   // Memory read data

    // Data_Memory WB
    wire [32-1:0] mem_data_rd_WB;   // Memory read data

    // MUX_2to1 MEM
    wire          target_sel_MEM;    // Target address select

    // swai_adder MEM
    wire [32-1:0] swai_result_MEM;    // swai result 

    // swai_adder WB
    wire [32-1:0] swai_result_WB;    // swai result 
    ///////////////////////////////////////////////////////////////////////////
    // System conection

    ///////////////////////IF_ID////////////////////////////

    // Program Counter
    ProgramCounter PC
    (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .load_i(PC_next_IF),        // Next PC value
        .count_o(PC_pres_IF)        // Present PC value
    );

    // Instruction Memory
    Instr_Memory IM
    (
        .PC_addr_i(PC_pres_IF),     // Present PC value
        .instr_o(instr_IF)          // Instruction data
    );

    // Adder for PC+4
    adder adder_PC_plusfour
    (
        .srcA_i(PC_pres_IF),        // Present PC value
        .srcB_i(32'd4),
        .sum_o(PC_plusfour_IF)      // PC+4 value
    );

        // Target address with branch select
    assign target_sel_MEM = (Branch_MEM & NZCV_MEM[2]);
    MUX_2to1 MUX_PC_Source
    (
        .data0_i(PC_plusfour_IF),   // Current PC value
        .data1_i(PC_branch_MEM),     // Branch target address
        .select_i(target_sel_MEM),   // Branch condition
        .data_o(PC_next_IF)       // Target address with branch/jal
    );
    ///////////////////////ID_EX////////////////////////////

    // Immediate Generator
    Imm_Gen ImmGen
    (
        .instr_data_i(instr_ID),    // Instruction data
        .imm_data_o(imm_out_ID)     // Immediate value
    );

    // Controller
    assign opcode_ID = instr_ID[6:0];
    Controller Control
    (
        .instr_op_i(opcode_ID),     // Instruction opcode
        .ALUop_o(ALUop_ID),         // ALU opcode
        .RegWrite_o(RegWrite_ID),   // Register write
        .MemWrite_o(MemWrite_ID),   // Memory write
        .MemtoReg_o(MemtoReg_ID),   // Write back data select
        .MemRead_o(MemRead_ID),     // Memory read
        .ALUSrc_o(ALUSrc_ID),       // ALU source B select
        .Branch_o(Branch_ID)       // Branch instruction
    );

    // Register File
    assign rs1_addr_ID = instr_ID[19:15];
    assign rs2_addr_ID = instr_ID[24:20];
    assign rd_addr_ID = instr_ID[11:7];

    Reg_File RF
    (
        .clk_i(clk_i),
        .rst_n(rst_n),
        .RegWrite_i(RegWrite_WB),   // Register write control signal
        .rs1_addr_i(rs1_addr_ID),   // Source register 1 index
        .rs2_addr_i(rs2_addr_ID),   // Source register 2 index
        .rd_addr_i(rd_addr_WB),    // Destination register index
        .rd_data_i(rd_data_WB),     // Destination register data
        .rs1_data_o(rs1_data_ID),   // Source register 1 data
        .rs2_data_o(rs2_data_ID)    // Source register 2 data
    );

    ///////////////////////EX_MEM////////////////////////////

    // ALU source B select
    MUX_2to1 MUX_ALUSrc
    (
        .data0_i(rs2_data_EX),      // Source register 2 data
        .data1_i(imm_out_EX),       // Immediate value
        .select_i(ALUSrc_EX),       // ALU source B select
        .data_o(ALUsrcB_EX)         // ALU source B data
    );

    // Arithmetic Logic Unit
    assign ALUsrcA_EX = rs1_data_EX;
    ALU ALU
    (
        .srcA_i(ALUsrcA_EX),        // ALU source A value
        .srcB_i(ALUsrcB_EX),        // ALU source B value
        .ALUctrl_i(ALUctrl_EX),     // ALU control signals
        .ALUresult_o(ALUresult_EX), // ALU operation result
        .NZCV_o(NZCV_EX)            // NZCV flag, N: Negative, Z: Zero, C: Carry, V: Overflow
    );

    // ALU controller
    assign funct_ID = {instr_ID[30], instr_ID[14:12]};
    ALU_Conrtoller ALU_Conrtoller
    (	
        .funct_i(funct_EX),         // function code
        .ALUop_i(ALUop_EX),         // ALU opcode
        .ALUctrl_o(ALUctrl_EX)      // ALU Control signals
    );

    // Adder for branch target address
    adder adder_branch_addr
    (
        .srcA_i(PC_pres_EX),        // Current PC value
        .srcB_i(imm_out_EX),        // Immediate value
        .sum_o(PC_branch_EX)        // Branch target address
    );
    ///////////////////////MEM_WB////////////////////////////

    // Data Memory
    assign mem_data_wr_MEM = rs2_data_MEM;
    Data_Memory DM
    (
        .clk_i(clk_i),           // System clock
        .addr_i(ALUresult_MEM),      // Memory address value
        .data_wr_i(mem_data_wr_MEM), // Memory write data
        .MemRead_i(MemRead_MEM),     // Memory read control signal
        .MemWrite_i(MemWrite_MEM),   // Memory write control signal
        .data_rd_o(mem_data_rd_MEM)  // Memory read data
    );

    ///////////////////////WB_stage////////////////////////////

    MUX_4to1 MUX_Mem_Reg
    (
        .data0_i(ALUresult_WB),     // ALU operation result
        .data1_i(mem_data_rd_WB),   // Memort read data
        .data2_i(swai_result_WB),   
        .data3_i(32'd0),            // None
        .select_i(MemtoReg_WB),     // Write back data select
        .data_o(rd_data_WB)         // Destination register write back data
    );
    
    ///////////////////////"Add your new hardware here////////////////////////////
/*
    
        rd_select rd_select
        (
            .instr_i(instr_IF),   // Instruction data
            .rd_addr_o(rd_addr_ID)       // Destination register index
        );
        
        logic logic(
            .data_i(rs1_data_EX),
            .data_o(swai_result_WB)
        );*/
    

        
//****************************Pipe_Reg*********************************
    // IF_ID

    Pipe_Reg       #(.size(32))  IFID1(.rst_i(rst_n),.clk_i(clk_i),.data_i(instr_IF),.data_o(instr_ID));
    Pipe_Reg	   #(.size(32))  IFID2(.rst_i(rst_n),.clk_i(clk_i),.data_i(PC_pres_IF),.data_o(PC_pres_ID));	  

    // ID_EX

    Pipe_Reg       #(.size(32)) IDEX1(.rst_i(rst_n),.clk_i(clk_i),.data_i(PC_pres_ID),.data_o(PC_pres_EX));
    Pipe_Reg       #(.size(1)) IDEX2(.rst_i(rst_n),.clk_i(clk_i),.data_i(RegWrite_ID),.data_o(RegWrite_EX));
    Pipe_Reg       #(.size(1)) IDEX3(.rst_i(rst_n),.clk_i(clk_i),.data_i(Branch_ID),.data_o(Branch_EX));
    Pipe_Reg       #(.size(2)) IDEX4(.rst_i(rst_n),.clk_i(clk_i),.data_i(ALUop_ID),.data_o(ALUop_EX));
    Pipe_Reg       #(.size(1)) IDEX5(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemRead_ID),.data_o(MemRead_EX));
    Pipe_Reg       #(.size(2)) IDEX6(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemtoReg_ID),.data_o(MemtoReg_EX));
    Pipe_Reg       #(.size(1)) IDEX7(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemWrite_ID),.data_o(MemWrite_EX));    
    Pipe_Reg       #(.size(1)) IDEX8(.rst_i(rst_n),.clk_i(clk_i),.data_i(ALUSrc_ID),.data_o(ALUSrc_EX));    
    Pipe_Reg       #(.size(32)) IDEX9(.rst_i(rst_n),.clk_i(clk_i),.data_i(rs1_data_ID),.data_o(rs1_data_EX));    
    Pipe_Reg       #(.size(32)) IDEX10(.rst_i(rst_n),.clk_i(clk_i),.data_i(rs2_data_ID),.data_o(rs2_data_EX));    
    Pipe_Reg       #(.size(32)) IDEX11(.rst_i(rst_n),.clk_i(clk_i),.data_i(imm_out_ID),.data_o(imm_out_EX));    
    Pipe_Reg       #(.size(4)) IDEX12(.rst_i(rst_n),.clk_i(clk_i),.data_i(funct_ID),.data_o(funct_EX));    
    Pipe_Reg       #(.size(5)) IDEX13(.rst_i(rst_n),.clk_i(clk_i),.data_i(rd_addr_ID),.data_o(rd_addr_EX));    

    // EX_MEM
    
    Pipe_Reg       #(.size(32)) EX_MEX1(.rst_i(rst_n),.clk_i(clk_i),.data_i(PC_branch_EX),.data_o(PC_branch_MEM));    
    Pipe_Reg       #(.size(1)) EX_MEX2(.rst_i(rst_n),.clk_i(clk_i),.data_i(RegWrite_EX),.data_o(RegWrite_MEM));            
    Pipe_Reg       #(.size(1)) EX_MEX3(.rst_i(rst_n),.clk_i(clk_i),.data_i(Branch_EX),.data_o(Branch_MEM));    
    Pipe_Reg       #(.size(1)) EX_MEX4(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemRead_EX),.data_o(MemRead_MEM));    
    Pipe_Reg       #(.size(2)) EX_MEX5(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemtoReg_EX),.data_o(MemtoReg_MEM));    
    Pipe_Reg       #(.size(1)) EX_MEX6(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemWrite_EX),.data_o(MemWrite_MEM));    
    Pipe_Reg       #(.size(4)) EX_MEX7(.rst_i(rst_n),.clk_i(clk_i),.data_i(NZCV_EX),.data_o(NZCV_MEM));    
    Pipe_Reg       #(.size(32)) EX_MEX8(.rst_i(rst_n),.clk_i(clk_i),.data_i(ALUresult_EX),.data_o(ALUresult_MEM));    
    Pipe_Reg       #(.size(32)) EX_MEX9(.rst_i(rst_n),.clk_i(clk_i),.data_i(rs2_data_EX),.data_o(rs2_data_MEM));    
    Pipe_Reg       #(.size(5)) EX_MEX10(.rst_i(rst_n),.clk_i(clk_i),.data_i(rd_addr_EX),.data_o(rd_addr_MEM));    

    // MEM_WB
    
    Pipe_Reg       #(.size(1)) MEM_WB1(.rst_i(rst_n),.clk_i(clk_i),.data_i(RegWrite_MEM),.data_o(RegWrite_WB));    
    Pipe_Reg       #(.size(2)) MEM_WB2(.rst_i(rst_n),.clk_i(clk_i),.data_i(MemtoReg_MEM),.data_o(MemtoReg_WB));    
    Pipe_Reg       #(.size(32)) MEM_WB3(.rst_i(rst_n),.clk_i(clk_i),.data_i(mem_data_rd_MEM),.data_o(mem_data_rd_WB));    
    Pipe_Reg       #(.size(32)) MEM_WB4(.rst_i(rst_n),.clk_i(clk_i),.data_i(ALUresult_MEM),.data_o(ALUresult_WB));    
    Pipe_Reg       #(.size(5)) MEM_WB5(.rst_i(rst_n),.clk_i(clk_i),.data_i(rd_addr_MEM),.data_o(rd_addr_WB));                
    
    
endmodule
