module regfile(
    input  wire        clk,
    input  wire        rst,
    input  wire        regwrite,
    input  wire [4:0]  rs, rt, rd,
    input  wire [31:0] writedata,
    output wire [31:0] A_readdat1,
    output wire [31:0] B_readdat2
);

    reg [31:0] regs [31:0];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    // CHANGE: write on posedge clk (standard)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
           // for (i = 0; i < 32; i = i + 1)
           //     regs[i] <= 32'b0;
        end
        else if (regwrite && rd != 0) begin
            regs[rd] <= writedata;
        end
    end

    assign A_readdat1 = regs[rs];
    assign B_readdat2 = regs[rt];

endmodule