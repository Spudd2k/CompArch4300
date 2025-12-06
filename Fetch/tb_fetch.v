`timescale 1ns/1ps

module tb_fetch;
  reg         clk;
  reg         rst;
  reg         ex_mem_pc_src;
  reg  [31:0] ex_mem_npc;
  wire [31:0] if_id_instr;
  wire [31:0] if_id_npc;

  fetch dut(
    .clk(clk),
    .rst(rst),
    .ex_mem_pc_src(ex_mem_pc_src),
    .ex_mem_npc(ex_mem_npc),
    .if_id_instr(if_id_instr),
    .if_id_npc(if_id_npc)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("fetch_if.vcd");
    $dumpvars(0, tb_fetch);

    ex_mem_pc_src = 1'b0;
    ex_mem_npc = 32'h00000000;

    rst = 1;
    repeat(2) @(posedge clk);
    rst = 0;
    repeat(6) @(posedge clk);
    
    ex_mem_npc = 32'h0000_0010;
    ex_mem_pc_src = 1'b1; 
    @(posedge clk);
    ex_mem_pc_src = 1'b0;

    repeat(10) @(posedge clk);   

    $display("Test finished.");
    $finish;
  end
    
  reg [31:0] cycle = 0;
  always @(posedge clk) begin
    if (!rst) cycle <= cycle + 1;
    $strobe("T=%0t ns  NPC=%08h  INSTR=%08h  PCSrc=%0b",
            $time, if_id_npc, if_id_instr, ex_mem_pc_src);
  end
endmodule
