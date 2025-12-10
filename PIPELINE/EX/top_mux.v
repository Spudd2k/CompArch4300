`timescale 1ns / 1ps
/*
Implements a multiplexer that selects from two 32-bit inputs based on the alusrc input.
Its inputs are rdata2 and s_extendout from ID/EX latch, and alusrc.
The output is a 32-bit value which is sent to the ALU.
*/
module top_mux(
    output wire [31:0] y,        // Output of Multiplexer
    input  wire [31:0] a,        // Input 0 of Multiplexer (rdata2)
    input  wire [31:0] b,        // Input 1 of Multiplexer (s_extendout)
    input  wire        alusrc    // Select Input
);

    assign y = alusrc ? b : a;

endmodule
