module control(
    input  wire       clk,
    input  wire       rst,
    input  wire [5:0] opcode,
    output reg  [1:0] wb,
    output reg  [2:0] mem,
    output reg  [3:0] ex
);

localparam OP_R   = 6'b000000;
localparam OP_LW  = 6'b100011;
localparam OP_SW  = 6'b101011;
localparam OP_BEQ = 6'b000100;

always @(*) begin
    // default
    wb  = 2'b00;
    mem = 3'b000;
    ex  = 4'b0000;

    case (opcode)
        OP_R: begin
            // RegDst=1, ALUOp=10, ALUSrc=0  --> 1100
            ex  = 4'b1100;
            mem = 3'b000;
            wb  = 2'b10;      // RegWrite=1, MemToReg=0
        end

        OP_LW: begin
            // RegDst=0, ALUOp=00, ALUSrc=1  --> 0001
            ex  = 4'b0001;
            mem = 3'b010;     // MemRead=1
            wb  = 2'b11;      // RegWrite=1, MemToReg=1
        end

        OP_SW: begin
            // RegDst=X, ALUOp=00, ALUSrc=1  --> 0001 (RegDst unused)
            ex  = 4'b0001;
            mem = 3'b001;     // MemWrite=1
            wb  = 2'b00;      // no writeback
        end

        OP_BEQ: begin
            // RegDst=X, ALUOp=01, ALUSrc=0  --> 0010
            ex  = 4'b0010;
            mem = 3'b100;     // Branch=1
            wb  = 2'b00;      // no writeback
        end
    endcase
end

endmodule
