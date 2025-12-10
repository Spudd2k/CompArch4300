module memoryTB();
    reg clk;
    reg [31:0] ALUResult, WriteData;
    reg [4:0]  WriteReg;
    reg [1:0]  WBControl;
    reg        MemWrite, MemRead, Branch, Zero;

    wire [31:0] ReadData;
    wire [31:0] ALUResult_out;
    wire [4:0]  WriteReg_out;
    wire [1:0]  WBControl_out;
    wire        PCSrc;
    wire [31:0] branch_addr;  // not checked by this TB

    // Instantiate your MEMORY stage directly
    MEMORY uut (
        .clk           (clk),
        .wb_ctlout     (WBControl),
        .branch        (Branch),
        .memread       (MemRead),
        .memwrite      (MemWrite),
        .EX_MEM_NPC    (32'd0),       // we don't care about branch target here
        .zero          (Zero),
        .alu_result    (ALUResult),
        .rdata2out     (WriteData),
        .five_bit_muxout(WriteReg),

        .PCSrc         (PCSrc),
        .branch_addr   (branch_addr),

        .mem_control_wb(WBControl_out),
        .mem_Read_data (ReadData),
        .mem_ALU_result(ALUResult_out),
        .mem_Write_reg (WriteReg_out)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
     // Mem Read
    ALUResult = 32'h00000004;
    WriteData = 32'h12345678;
    WriteReg = 5'h02;
    WBControl = 2'b01;
    MemWrite = 0;
    MemRead = 1;
    Branch = 0;
    Zero = 0;

    #10; 

    // Mem Write
    MemWrite = 1;
    MemRead = 0;
    #10; // Allow write to occur
    MemWrite = 0;
    MemRead = 1;
    #10; // Verify write by reading back

    // Branch
    Branch = 1;
    Zero = 1;
    #10; // Check PCSrc

    $finish;
end
endmodule