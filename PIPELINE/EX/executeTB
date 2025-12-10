`timescale 1ns / 1ps
// executeTB.v
// Tests the EXECUTE stage (adder + bottom_mux + alu_control + alu + ex_mem)

module executeTB;
    reg [1:0]  wb_ctl_in;
    reg [2:0]  m_ctl_in;
    reg        regdst;
    reg        alusrc;
    reg [1:0]  alu_op;
    reg [31:0] npc;
    reg [31:0] rdata1;
    reg [31:0] rdata2;
    reg [31:0] s_extend;
    reg [4:0]  instr_2016;
    reg [4:0]  instr_1511;
    reg [5:0]  funct;

    // Outputs from EXECUTE / EX/MEM latch
    wire [1:0]  wb_ctlout;
    wire        branch;
    wire        memread;
    wire        memwrite;
    wire [31:0] EX_MEM_NPC;
    wire        zero;
    wire [31:0] alu_result;
    wire [31:0] rdata2out;
    wire [4:0]  five_bit_muxout;

    EXECUTE uut (
        .wb_ctl(wb_ctl_in),
        .m_ctl(m_ctl_in),
        .regdst(regdst),
        .alusrc(alusrc),
        .aluop(alu_op),
        .npcout(npc),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .s_extendout(s_extend),
        .instrout_2016(instr_2016),
        .instrout_1511(instr_1511),
        .funct(funct),

        .wb_ctlout(wb_ctlout),
        .branch(branch),
        .memread(memread),
        .memwrite(memwrite),
        .EX_MEM_NPC(EX_MEM_NPC),
        .zero(zero),
        .alu_result(alu_result),
        .rdata2out(rdata2out),
        .five_bit_muxout(five_bit_muxout)
    );

    initial begin
        wb_ctl_in   = 2'b10;
        m_ctl_in    = 3'b000;
        regdst      = 1;
        alusrc      = 0; 
        alu_op      = 2'b10;
        npc         = 32'd100;
        rdata1      = 32'd10;
        rdata2      = 32'd20;
        s_extend    = 32'd4;
        instr_2016  = 5'd5;
        instr_1511  = 5'd10;
        funct       = 6'b100000;

        #10;

        rdata1      = 32'd30;
        rdata2      = 32'd10;
        funct       = 6'b100010;
        #10;

        regdst      = 0;
        alusrc      = 0;
        alu_op      = 2'b01;
        rdata1      = 32'd15;
        rdata2      = 32'd15;
        s_extend    = 32'd8;
        #10;

        regdst      = 0;
        alusrc      = 1;
        alu_op      = 2'b00;
        rdata1      = 32'd100;
        s_extend    = 32'd16;
        #10;

        $stop;
    end
endmodule
