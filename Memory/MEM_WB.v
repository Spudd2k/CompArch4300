module MEM_WB
(
    input  wire        clk,
    input  wire [1:0]  control_wb_in,
    input  wire [31:0] Read_data_in,
    input  wire [31:0] ALU_result_in,
    input  wire [4:0]  Write_reg_in,

    output reg  [1:0]  mem_control_wb,
    output reg  [31:0] Read_data,
    output reg  [31:0] mem_ALU_result,
    output reg  [4:0]  mem_Write_reg
); 

always @(posedge clk) 
begin
    mem_control_wb <= control_wb_in;
    Read_data <= Read_data_in;
    mem_ALU_result <= ALU_result_in;
    mem_Write_reg <= Write_reg_in;
end
endmodule
