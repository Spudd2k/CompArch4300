`timescale 1ns / 1ps

module MEMORY(
    input  wire        clk, rst,

    input  wire [1:0]  wb_ctlout,        // WB control from EX/MEM
    input  wire        branch,           // Branch bit (M control)
    input  wire        memread,          // MemRead
    input  wire        memwrite,         // MemWrite
    input  wire [31:0] EX_MEM_NPC,       // branch target address
    input  wire        zero,             // ALU zero flag
    input  wire [31:0] alu_result,       // address for D_MEM
    input  wire [31:0] rdata2out,        // write data for stores
    input  wire [4:0]  five_bit_muxout,  // destination register

    output wire        PCSrc,            // Branch taken signal
    output wire [31:0] branch_addr,      // branch target (to PC mux)

    output wire [1:0]  mem_control_wb,   // WB control out of MEM/WB
    output wire [31:0] mem_Read_data,    // loaded data
    output wire [31:0] mem_ALU_result,   // forwarded ALU result
    output wire [4:0]  mem_Write_reg     // destination register
);

    wire [31:0] dm_read_data;

    assign PCSrc      = branch & zero;   // Branch & Zero
    assign branch_addr = EX_MEM_NPC;     // forward branch target

    D_MEM data_memory(
        .clk       (clk),
        .MemRead   (memread),
        .MemWrite  (memwrite),
        .Address   (alu_result),
        .Write_data(rdata2out),
        .Read_data (dm_read_data)
    );

    MEM_WB mem_wb_reg(
        .clk           (clk),
        .rst (rst),
        .control_wb_in (wb_ctlout),
        .Read_data_in  (dm_read_data),
        .ALU_result_in (alu_result),
        .Write_reg_in  (five_bit_muxout),

        .mem_control_wb(mem_control_wb),
        .Read_data     (mem_Read_data),
        .mem_ALU_result(mem_ALU_result),
        .mem_Write_reg (mem_Write_reg)
    );

endmodule
