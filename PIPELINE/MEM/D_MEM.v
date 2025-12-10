
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
integer i;
initial begin
    $readmemb("data.mem", memory);
    for (i=0; i<6; i = i+1)
    $display(memory[i]);
end


//address
//wire[7:0] Word_address = Address[9:2];
wire [7:0] Word_address = Address[7:0];


//write 
always @(posedge clk) begin
    if (MemWrite)
    memory[Word_address] <= Write_data;
end

assign Read_data = MemRead ? memory[Word_address] : 32'b0;

endmodule
