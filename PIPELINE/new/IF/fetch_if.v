`timescale 1ns/1ps

module mux #(parameter W=32)(
  input  wire [W-1:0] a_true,
  input  wire [W-1:0] b_false,
  input  wire         sel,
  output wire [W-1:0] y
);
  assign y = sel ? a_true : b_false;
endmodule

module pc(
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] pc_in,
  output reg  [31:0] pc_out
);
  always @(posedge clk or posedge rst) begin
    if (rst) pc_out <= 32'd0;
    else     pc_out <= pc_in;
  end
endmodule

//incrementer/adder
module incrementer(
    input  [31:0] pcin,
    output [31:0] pcout
);
assign pcout = pcin + 32'd4;
endmodule


//intruction memory
module instrMem #(
  parameter ADDR_INDEX_W = 10//2^10
)(
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] addr,
  output wire [31:0] data
);
  reg [31:0] mem [0:255];

initial begin
    $readmemh("instr.mem", mem);
end



  wire [ADDR_INDEX_W-1:0] word_index;
  assign word_index = addr[ADDR_INDEX_W+1:2];
  assign data = mem[word_index];
endmodule


//latch
module ifIdLatch(
  input  wire        clk,
  input  wire        rst,
  input  wire [31:0] pc_in,
  input  wire [31:0] instr_in,
  output reg  [31:0] pc_out,
  output reg  [31:0] instr_out
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      pc_out   <= 32'd0;
      instr_out<= 32'd0;
    end else begin
      pc_out   <= pc_in;
      instr_out<= instr_in;
    end
  end
endmodule

//fetch stage  
module fetch(
  input  wire        clk,
  input  wire        rst,
  input  wire        ex_mem_pc_src,
  input  wire [31:0] ex_mem_npc,
  output wire [31:0] if_id_instr,
  output wire [31:0] if_id_npc
);

  wire [31:0] pc_out;
  wire [31:0] next_pc;
  wire [31:0] pc_mux;
  wire [31:0] instr_data;

  incrementer u_inc(
    .pcin  (pc_out),
    .pcout (next_pc)
  );

  mux u_mux(
    .a_true   (ex_mem_npc),
    .b_false  (next_pc),
    .sel      (ex_mem_pc_src),
    .y        (pc_mux)
  );

  pc u_pc(
    .clk   (clk),
    .rst   (rst),
    .pc_in (pc_mux),
    .pc_out(pc_out)
  );

  instrMem #(.ADDR_INDEX_W(10)) u_imem(
    .clk  (clk),
    .rst  (rst),
    .addr (pc_out),
    .data (instr_data)
  );

  ifIdLatch u_ifid(
    .clk       (clk),
    .rst       (rst),
    .pc_in     (next_pc),
    .instr_in  (instr_data),
    .pc_out    (if_id_npc),
    .instr_out (if_id_instr)
  );
endmodule
