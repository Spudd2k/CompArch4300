module WRITEBACK(
    input  wire MemtoReg,
    input  wire RegWrite_in,     
    input  wire [31:0] mem_Read_data,
    input  wire [31:0] mem_ALU_result,
    input  wire [4:0] mem_Write_reg,

    output wire [31:0] wb_data,
    output wire RegWrite,
    output wire [4:0]  WriteReg
);

    assign wb_data  = MemtoReg ? mem_Read_data : mem_ALU_result;

    assign WriteReg = mem_Write_reg;
    
    assign RegWrite = RegWrite_in;

endmodule