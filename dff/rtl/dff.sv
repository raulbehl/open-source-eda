module dff #(
    parameter type T = logic
)(
    input       logic           clk,
    input       logic           reset_n,
    input       T               d_i,
    output      T               q_o
);

    always_ff @(posedge clk or negedge reset_n)
        if (~reset_n)
            q_o <= T'(1'b0);
        else
            q_o <= d_i;

endmodule
