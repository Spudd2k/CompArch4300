`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2025 03:44:22 PM
// Design Name: 
// Module Name: D_MEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module D_MEM(
input wire clk,
input wire MemRead,
input wire MemWrite,
input wire [31:0] Address,
input wire [31:0] Write_data,
output wire [31:0] Read_data
    );

//256 32 bit words
reg [31:0] memory [0:255];
//load memory
initial begin
    $readmemh("data.mem", memory);
end


//address
wire[7:0] Word_address = Address[9:2];

//write 
always @(posedge clk) begin
    if (MemWrite)
    memory[Word_address] <= Write_data;
end

assign Read_data = (MemRead == 1'b1) ? memory[Word_address] : 32'b0;

endmodule
