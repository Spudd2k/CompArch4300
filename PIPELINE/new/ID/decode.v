module decode(
    input wire          clk,
                        rst,
                        wb_reg_write,              // RegWrite from MEM/WB stage
    input wire [4:0]    wb_write_reg_location,     // Write register number from MEM/WB
    input wire  [31:0]  mem_wb_write_data,         // Write data from MEM/WB
                        if_id_instr,               // Instruction from IF/ID latch
                        if_id_npc,                 // NPC from IF/ID latch
    output wire [1:0]   id_ex_wb,                  // WB control to ID/EX
    output wire [2:0]   id_ex_mem,                 // MEM control to ID/EX
    output wire [3:0]   id_ex_execute,             // EX control to ID/EX
    output wire [31:0]  id_ex_npc,
                        id_ex_readdat1,
                        id_ex_readdat2,
                        id_ex_sign_ext,
    output wire [4:0]   id_ex_instr_bits_20_16,
                        id_ex_instr_bits_15_11
);

    // internal
    wire [31:0] sign_ext_internal;
    wire [31:0] readdat1_internal;
    wire [31:0] readdat2_internal;
    wire [1:0]  wb_internal;
    wire [2:0]  mem_internal;
    wire [3:0]  ex_internal;

    // Sign extend immediate [15:0] -> 32 bits
    signExt sE0(
        .immediate(if_id_instr[15:0]),
        .extended(sign_ext_internal)
    );

    // Register file
    regfile rf0(
        .clk(clk),
        .rst(rst),
        .regwrite(wb_reg_write),               // from MEM/WB stage
        .rs(if_id_instr[25:21]),               // Read Reg1
        .rt(if_id_instr[20:16]),               // Read Reg2
        .rd(wb_write_reg_location),            // Write Reg
        .writedata(mem_wb_write_data),         // Write Data
        .A_readdat1(readdat1_internal),
        .B_readdat2(readdat2_internal)
    );

    // Main control unit (uses opcode [31:26])
    control c0(
        .clk(clk),
        .rst(rst),
        .opcode(if_id_instr[31:26]),
        .wb(wb_internal),
        .mem(mem_internal),
        .ex(ex_internal)
    ); 

    // ID/EX pipeline latch
    idExLatch iEL0(
        // inputs
        .clk(clk),
        .rst(rst),
        .ctl_wb(wb_internal),
        .ctl_mem(mem_internal),
        .ctl_ex(ex_internal),
        .npc(if_id_npc),
        .readdat1(readdat1_internal),
        .readdat2(readdat2_internal),
        .sign_ext(sign_ext_internal),
        .instr_bits_20_16(if_id_instr[20:16]),
        .instr_bits_15_11(if_id_instr[15:11]),
        // outputs
        .wb_out(id_ex_wb),
        .mem_out(id_ex_mem),
        .ctl_out(id_ex_execute),
        .npc_out(id_ex_npc),
        .readdat1_out(id_ex_readdat1),
        .readdat2_out(id_ex_readdat2),
        .sign_ext_out(id_ex_sign_ext),
        .instr_bits_20_16_out(id_ex_instr_bits_20_16),
        .instr_bits_15_11_out(id_ex_instr_bits_15_11)
    );

endmodule
