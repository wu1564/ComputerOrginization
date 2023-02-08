module Data_Memory
(
    clk_i,
    addr_i,
    data_wr_i,
    MemRead_i,
    MemWrite_i,
    data_rd_o
);
//*****************************************************************************
    // I/O Port Declaration
    input           clk_i;      // Clock input
    input  [32-1:0] addr_i;     // Memory address
    input  [32-1:0] data_wr_i;  // 32 bits memory write data
    input           MemRead_i;  // Memory write control signal
    input           MemWrite_i; // Memory write control signal
    output [32-1:0] data_rd_o;  // 32 bits memory read data

    // Global variables Declaration
    // System
    reg     [ 7:0] mem_block [0:127]; // Address: 0x00~0x80
    wire    [31:0] memory    [0: 31]; // For Testbench to debug
    integer idx;   // index
    genvar  block; // block num

    // System conection
    // Component Initializations
    generate
        for(block = 0; block < 32; block = block + 1'b1)
        begin : MEM_mapping
            assign  memory[block] = {mem_block[3 + 4*block], mem_block[2 + 4*block], mem_block[1 + 4*block], mem_block[0 + 4*block]};
        end
    endgenerate
    // Output
    assign data_rd_o = (MemRead_i) ? {mem_block[addr_i+3], mem_block[addr_i+2], mem_block[addr_i+1], mem_block[addr_i]} : 32'd0;
//*****************************************************************************
// Initial : For Testbench to debug
    initial begin
        for(idx = 0; idx < 128; idx = idx + 1'b1)
            mem_block[idx] = 8'd0;
    end
//*****************************************************************************
// Block : Memory Write
    always@(posedge clk_i) begin
        if(MemWrite_i) begin
            mem_block[addr_i + 3] <= data_wr_i[31:24];
            mem_block[addr_i + 2] <= data_wr_i[23:16];
            mem_block[addr_i + 1] <= data_wr_i[15: 8];
            mem_block[addr_i    ] <= data_wr_i[ 7: 0];
        end
    end
//*****************************************************************************
endmodule