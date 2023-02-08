//*****************************************************************************
// Module Declaration
module ALU_Conrtoller
(
    funct_i,
    ALUop_i,
    ALUctrl_o
);
//*****************************************************************************
    // I/O Port
    input  [3:0] funct_i;   // 4 bits simplified function code
    input  [1:0] ALUop_i;   // 2 bits ALU opcode
    output [3:0] ALUctrl_o; // 4 bits ALU control code
    // Global variables Declaration
    // System
    reg    [2:0] ALUopcode; // ALU operation code
    // System conection
    // Output
    assign ALUctrl_o = {1'b0 , ALUopcode}; // Acturally used 3 bits
//*****************************************************************************
// Block : ALU control decode
    always @(*)
    begin
        case(ALUop_i) // ALU opcode decode
        ///////////////////////////////////////////////////////////////////////
        // Solve the truth table
        ///////////////////////////////////////////////////////////////////////
        // ALUop | funct | ALUCtrl
        // ------+-------+--------
        //  0 0  |x | xxx| 0 0 1 0  LW   -> ADD
        //  0 0  |x | xxx| 0 0 1 0  SW   -> ADD
        //  0 1  |x | xxx| 0 1 1 0  BEQ  -> SUB
        //  1 0  |0 | 111| 0 0 0 0  AND
        //  1 0  |0 | 110| 0 0 0 1  OR
        //  1 0  |0 | 000| 0 0 1 0  ADD
        //  1 0  |1 | 000| 0 1 1 0  SUB
        //  1 0  |0 | 010| 0 1 1 1  SLT
        //  1 0  |x | xxx| 0 0 0 1  ORI  -> OR
        //  1 0  |x | xxx| 0 0 1 0  ADDI -> ADD
        //  x x  |x | xxx| x x x x  JAL  -> None (set 0)
        //  x x  |x | xxx| x x x x  JALR -> None (set 0)
        //  x x  |x | xxx| x x x x  None (set 0)
        ///////////////////////////////////////////////////////////////////////
        // Table
        ///////////////////////////////////////////////////////////////////////
            2'b00  : ALUopcode = 3'b010; // LW / SW
            2'b01  : ALUopcode = 3'b110; // BEQ
            2'b10  : // R-type
                begin
                    case(funct_i[2:0])
                        3'b000:  ALUopcode = (funct_i[3]) ? 3'b110 : 3'b010; // ADD
                        3'b010:  ALUopcode = 3'b111; // SLT
                        3'b110:  ALUopcode = 3'b001; // OR
                        3'b111:  ALUopcode = 3'b000; // AND
                        default: ALUopcode = 3'b000; // None
                    endcase
                end
            2'b11  : ALUopcode = 4'b000; // None
            default: ALUopcode = 4'b000; // None
        endcase
    end
//*****************************************************************************
endmodule