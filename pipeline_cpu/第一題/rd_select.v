module rd_select(
    instr_i,  // Instruction data
    rd_addr_o // Destination register index
);

input [32-1:0] instr_i;
output [5-1:0] rd_addr_o;
wire [5-1:0]rs1_addr; // Source register 1 index
wire [5-1:0]rd_addr; // Destination register index
wire [6:2]opcode; // Instruction opcode

assign opcode = instr_i[6:2];
assign rs1_addr = instr_i[19:15];
assign rd_addr = instr_i[11:7];

assign rd_addr_o = (opcode == 5'b01010) ? rs1_addr : rd_addr; //select output signal


endmodule