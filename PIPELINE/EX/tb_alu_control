`timescale 1ns / 1ps
// alu_control_testbench.v
// Tests alu_control.v

module alu_control_testbench;
    // Wire ports
    wire [2:0] select;

    // Register declarations
    reg [1:0] alu_op;
    reg [5:0] funct;

    // DUT instantiation
    alu_control aluccontrol1 (
        .select(select),
        .aluop(alu_op),
        .funct(funct)
    );

    initial begin
        alu_op = 2'b00;          // lwsw
        funct  = 6'b100000;      // select = 010 (ALUadd)
        $monitor("ALUOp = %b\tfunct = %b\tselect = %b", alu_op, funct, select);

        #1
        alu_op = 2'b01;          // I-type (beq), select = 110 (ALUsub)
        funct  = 6'b100000;

        #1
        alu_op = 2'b10;          // R-type from here on
        funct  = 6'b100000;      // add -> select = 010

        #1  funct = 6'b100010;   // sub -> select = 110
        #1  funct = 6'b100100;   // and -> select = 000
        #1  funct = 6'b100101;   // or  -> select = 001
        #1  funct = 6'b101010;   // slt -> select = 111

        #1
        $finish;
    end
endmodule // alu_control_testbench
