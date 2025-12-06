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

    // Preload the register file like instruction memory
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;

        // Give some registers meaningful values
        regs[0] = 32'b0;           // $zero
        regs[1] = 32'h11121951;
        regs[2] = 32'h23938222;    // RT will read this
        regs[3] = 32'h19396328;
        regs[4] = 32'h28418204;
        // add more if you want
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // optional: either clear here OR leave contents as initialized
            // for a "ROM-like" regfile, you might *not* clear on reset:
            // do nothing on reset
        end else if (regwrite && rd != 0) begin
            regs[rd] <= writedata;
        end
    end

    assign A_readdat1 = regs[rs];
    assign B_readdat2 = regs[rt];

endmodule
