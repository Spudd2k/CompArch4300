`timescale 1ns/1ps

module decode_tb;

    reg         clk, rst;
    reg         wb_reg_write;
    reg  [4:0]  wb_write_reg_location;
    reg  [31:0] mem_wb_write_data;
    reg  [31:0] if_id_instr;
    reg  [31:0] if_id_npc;

    wire [1:0]  id_ex_wb;
    wire [2:0]  id_ex_mem;
    wire [3:0]  id_ex_execute;
    wire [31:0] id_ex_npc;
    wire [31:0] id_ex_readdat1;
    wire [31:0] id_ex_readdat2;
    wire [4:0]  id_ex_instr_bits_20_16;
    wire [4:0]  id_ex_instr_bits_15_11;

    decode DUT(
        .clk(clk),
        .rst(rst),
        .wb_reg_write(wb_reg_write),
        .wb_write_reg_location(wb_write_reg_location),
        .mem_wb_write_data(mem_wb_write_data),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc),
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

    initial clk = 0;
    always #5 clk = ~clk;

    task apply_instr;
        input [31:0] instr;
        input [31:0] npc_val;
    begin
        @(negedge clk);
        if_id_instr = instr;
        if_id_npc   = npc_val;
    end
    endtask

    initial begin
        rst                   = 1;
        wb_reg_write          = 0;
        wb_write_reg_location = 0;
        mem_wb_write_data     = 0;
        if_id_instr           = 0;
        if_id_npc             = 0;

        #20;
        @(negedge clk);
        rst = 0;

        // ------------------------------------------------------------
        // 1) Simulate a couple of writes from MEM/WB into regfile
        //    so rs/rt will later read meaningful values.
        // ------------------------------------------------------------

        // Write 0x11111111 into $1
        @(negedge clk);
        wb_reg_write          = 1;
        wb_write_reg_location = 5'd1;
        mem_wb_write_data     = 32'h11121951;
        @(posedge clk);   // write at this clock edge
        @(negedge clk);
        wb_reg_write = 0;

        // Write 0x22222222 into $2
        @(negedge clk);
        wb_reg_write          = 1;
        wb_write_reg_location = 5'd2;
        mem_wb_write_data     = 32'h23938222;
        @(posedge clk);
        @(negedge clk);
        wb_reg_write = 0;
        
        @(negedge clk);
        wb_reg_write          = 1;
        wb_write_reg_location = 5'd3;
        mem_wb_write_data     = 32'h19396328;
        @(posedge clk);
        @(negedge clk);
        wb_reg_write = 0;
        
        @(negedge clk);
        wb_reg_write          = 4;
        wb_write_reg_location = 5'd4;
        mem_wb_write_data     = 32'h28418204;
        @(posedge clk);
        @(negedge clk);
        wb_reg_write = 0;

        // ------------------------------------------------------------
        // 2) R-format: add $3, $1, $2
        // opcode=000000, rs=1, rt=2, rd=3, shamt=0, funct=100000
        // ------------------------------------------------------------
        apply_instr(32'b000000_00001_00010_00011_00000_100000,
                    32'h00000004);
        @(posedge clk);   // ID/EX latch captures control + operands
        @(posedge clk);   // give an extra cycle for waveform clarity

        // ------------------------------------------------------------
        // 3) LW $4, 8($1)
        // opcode=100011, rs=1, rt=4, imm=8
        // ------------------------------------------------------------
        apply_instr(32'b100001_00001_00100_0000000000001000,
                    32'h00000008);
        @(posedge clk);
        @(posedge clk);

        // ------------------------------------------------------------
        // 4) SW $4, 12($1)
        // opcode=101011, rs=1, rt=4, imm=12
        // ------------------------------------------------------------
        apply_instr(32'b101011_00001_00100_0000000000001100,
                    32'h0000000C);
        @(posedge clk);
        @(posedge clk);

        // ------------------------------------------------------------
        // 5) BEQ $1, $2, -1
        // opcode=000100, rs=1, rt=2, imm = -1 (0xFFFF)
        // ------------------------------------------------------------
        apply_instr(32'b000100_00001_00010_1111111111111111,
                    32'h00000010);
        @(posedge clk);
        @(posedge clk);

        // Done
        #50;
        $finish;
    end

endmodule
