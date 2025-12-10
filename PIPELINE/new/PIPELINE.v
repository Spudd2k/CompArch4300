`timescale 1ns / 1ps

// ================================================================
//                    MIPS 5-STAGE PIPELINE
//
// IFETCH -> IF/ID -> DECODE -> ID/EX -> EXECUTE -> EX/MEM -> MEMORY
// -> MEM/WB -> WRITEBACK -> back to DECODE (register file)
//
// This file wires ALL stages together using YOUR module ports.
// ================================================================

module PIPELINE(
    input wire clk,
    input wire rst
);

    // ============================================================
    // IF/ID wires
    // ============================================================
    wire [31:0] if_id_instr;
    wire [31:0] if_id_npc;

    // ============================================================
    // ID/EX wires
    // ============================================================
    wire [1:0]  id_ex_wb;
    wire [2:0]  id_ex_mem;
    wire [3:0]  id_ex_execute;

    wire [31:0] id_ex_npc;
    wire [31:0] id_ex_readdat1;
    wire [31:0] id_ex_readdat2;
    wire [31:0] id_ex_sign_ext;

    wire [4:0]  id_ex_instr_bits_20_16;
    wire [4:0]  id_ex_instr_bits_15_11;

    // ============================================================
    // EXECUTE (EX/MEM outputs)
    // ============================================================
    wire [1:0]  ex_mem_wb_ctl;
    wire        ex_mem_branch;
    wire        ex_mem_memread;
    wire        ex_mem_memwrite;

    wire [31:0] ex_mem_npc;
    wire        ex_mem_zero;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rdata2out;
    wire [4:0]  ex_mem_five_bit_muxout;

    // ============================================================
    // MEMORY (MEM/WB outputs)
    // ============================================================
    wire        PCSrc;
    wire [31:0] branch_addr;

    wire [1:0]  mem_control_wb;     // {RegWrite, MemtoReg}
    wire [31:0] mem_Read_data;
    wire [31:0] mem_ALU_result;
    wire [4:0]  mem_Write_reg;

    // ============================================================
    // WRITEBACK (WB outputs)
    // ============================================================
    wire [31:0] wb_data;
    wire        wb_reg_write;
    wire [4:0]  wb_write_reg;

    // ============================================================
    // IFETCH STAGE
    // ============================================================
    fetch u_fetch(
        .clk(clk),
        .rst(rst),
        .ex_mem_pc_src(PCSrc),
        .ex_mem_npc(branch_addr),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc)
    );

    // ============================================================
    // DECODE STAGE
    // ============================================================
    decode u_decode(
        .clk(clk),
        .rst(rst),

        // FROM WRITEBACK
        .wb_reg_write(wb_reg_write),
        .wb_write_reg_location(wb_write_reg),
        .mem_wb_write_data(wb_data),

        // FROM IF/ID
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc),

        // TO ID/EX
        .id_ex_wb(id_ex_wb),
        .id_ex_mem(id_ex_mem),
        .id_ex_execute(id_ex_execute),
        .id_ex_npc(id_ex_npc),
        .id_ex_readdat1(id_ex_readdat1),
        .id_ex_readdat2(id_ex_readdat2),
        .id_ex_sign_ext(id_ex_sign_ext),
        .id_ex_instr_bits_20_16(id_ex_instr_bits_20_16),
        .id_ex_instr_bits_15_11(id_ex_instr_bits_15_11)
    );

    // ============================================================
    // EXECUTE STAGE
    // ============================================================

    // Decode EX control bundle
    wire ex_regdst = id_ex_execute[3];
    wire ex_alusrc = id_ex_execute[0];
    wire [1:0] ex_aluop = id_ex_execute[2:1];

    EXECUTE u_execute(
        .clk(clk),

        // CONTROL
        .wb_ctl(id_ex_wb),
        .m_ctl(id_ex_mem),
        .regdst(ex_regdst),
        .alusrc(ex_alusrc),
        .aluop(ex_aluop),

        // DATAPATH
        .npcout(id_ex_npc),
        .rdata1(id_ex_readdat1),
        .rdata2(id_ex_readdat2),
        .s_extendout(id_ex_sign_ext),
        .instrout_2016(id_ex_instr_bits_20_16),
        .instrout_1511(id_ex_instr_bits_15_11),

        // IMPORTANT: decode does NOT currently output funct.
        // Set to 0 for now unless you add that port.
        .funct(6'b000000),

        // OUTPUTS TO MEM
        .wb_ctlout(ex_mem_wb_ctl),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .EX_MEM_NPC(ex_mem_npc),
        .zero(ex_mem_zero),
        .alu_result(ex_mem_alu_result),
        .rdata2out(ex_mem_rdata2out),
        .five_bit_muxout(ex_mem_five_bit_muxout)
    );

    // ============================================================
    // MEMORY STAGE
    // ============================================================
    MEMORY u_memory(
        .clk(clk),

        // FROM EXECUTE
        .wb_ctlout(ex_mem_wb_ctl),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .EX_MEM_NPC(ex_mem_npc),
        .zero(ex_mem_zero),
        .alu_result(ex_mem_alu_result),
        .rdata2out(ex_mem_rdata2out),
        .five_bit_muxout(ex_mem_five_bit_muxout),

        // BRANCH OUTPUTS
        .PCSrc(PCSrc),
        .branch_addr(branch_addr),

        // TO WB
        .mem_control_wb(mem_control_wb),
        .mem_Read_data(mem_Read_data),
        .mem_ALU_result(mem_ALU_result),
        .mem_Write_reg(mem_Write_reg)
    );

    // ============================================================
    // WRITEBACK STAGE
    // ============================================================
    WRITEBACK u_wb(
        .MemtoReg(mem_control_wb[0]),
        .RegWrite_in(mem_control_wb[1]),
        .mem_Read_data(mem_Read_data),
        .mem_ALU_result(mem_ALU_result),
        .mem_Write_reg(mem_Write_reg),

        .wb_data(wb_data),
        .RegWrite(wb_reg_write),
        .WriteReg(wb_write_reg)
    );

endmodule
