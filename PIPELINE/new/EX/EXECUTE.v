`timescale 1ns / 1ps
/*
Execute Stage: Uses the outputs of the ID/EX latch and
instantiates: adder, bottom_mux (5-bit), alu_control, alu,
top_mux (32-bit), and ex_mem.
*/

module EXECUTE(
    input  wire        clk,          // <- clock for EX/MEM latch

    // control from ID/EX
    input  wire [1:0]  wb_ctl,       // WB control
    input  wire [2:0]  m_ctl,        // M control
    input  wire        regdst,
    input  wire        alusrc,
    input  wire [1:0]  aluop,        // ALUOp from control (2 bits)

    // datapath from ID/EX
    input  wire [31:0] npcout,
    input  wire [31:0] rdata1,
    input  wire [31:0] rdata2,
    input  wire [31:0] s_extendout,
    input  wire [4:0]  instrout_2016,  // rt
    input  wire [4:0]  instrout_1511,  // rd
    input  wire [5:0]  funct,          // Instr[5:0] from ID/EX latch

    // outputs to MEM stage
    output wire [1:0]  wb_ctlout,
    output wire        branch,
    output wire        memread,
    output wire        memwrite,
    output wire [31:0] EX_MEM_NPC,
    output wire        zero,
    output wire [31:0] alu_result,
    output wire [31:0] rdata2out,
    output wire [4:0]  five_bit_muxout
);

    // internal wires
    wire [31:0] adder_out;
    wire [31:0] b;           // ALU second operand
    wire [31:0] aluout;
    wire [4:0]  muxout;
    wire [2:0]  control;
    wire        aluzero;

    // 1) branch target address adder: NPC + sign-extended imm
    adder adder3(
        .add_in1(npcout),
        .add_in2(s_extendout),
        .add_out(adder_out)
    );

    // 2) bottom mux chooses write register (rt vs rd)
    bottom_mux bottom_mux3(
        .a(instrout_1511),   // rd
        .b(instrout_2016),   // rt
        .sel(regdst),
        .y(muxout)
    );

    // 3) ALU control: **funct comes from Instr[5:0], not from s_extendout**
    alu_control alu_control3(
        .funct(funct),
        .aluop(aluop),
        .select(control)
    );

    // 4) top mux: choose between register rt and immediate
    top_mux top_mux3(
        .a(rdata2),        // register value
        .b(s_extendout),   // immediate
        .alusrc(alusrc),
        .y(b)
    );

    // 5) ALU
    alu alu3(
        .a(rdata1),
        .b(b),
        .control(control),
        .result(aluout),
        .zero(aluzero)
    );

    // 6) EX/MEM latch
    ex_mem ex_mem3(
        .clk(clk),
        .ctlwb_out(wb_ctl),
        .ctlm_out(m_ctl),
        .adder_out(adder_out),
        .aluzero(aluzero),
        .aluout(aluout),
        .readdat2(rdata2),
        .muxout(muxout),
        .wb_ctlout(wb_ctlout),
        .branch(branch),
        .memread(memread),
        .memwrite(memwrite),
        .add_result(EX_MEM_NPC),
        .zero(zero),
        .alu_result(alu_result),
        .rdata2out(rdata2out),
        .five_bit_muxout(five_bit_muxout)
    );

endmodule
