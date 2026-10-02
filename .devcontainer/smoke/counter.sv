// Tiny design shared by the Yosys/slang, SBY and OpenSTA smoke tests.
module counter (
    input  logic       clk,
    input  logic       rst,
    output logic [3:0] q
);
    always_ff @(posedge clk)
        if (rst) q <= '0;
        else     q <= (q == 4'd9) ? '0 : q + 4'd1;

`ifdef FORMAL
    // q is unknown until the first reset, so only check from the 2nd cycle on.
    logic past_valid = 1'b0;
    always_ff @(posedge clk) past_valid <= 1'b1;
    always_comb if (!past_valid) assume (rst);
    always_comb if (past_valid) assert (q <= 4'd9);
`endif
endmodule
