// Self-checking testbench for `dff` (async active-low reset D flip-flop, parameterised type).
// Build and run with `make` (uses --binary --timing, so needs Verilator 5).
//
// The same checker runs against several types of T (1-bit, narrow, 32-bit, 64-bit,
// packed struct) so the `parameter type` plumbing and T'(1'b0) reset value are exercised.
//
// Timing convention inside a checker (P = a rising clock edge, period 10 ns):
//   P+1  check q_o after the edge        P+2  d_i glitch (high phase)
//   P+3  q_o must not have moved         P+4  optional async reset assert/release
//   P+6  drive the real d_i for next edge P+7  q_o must still hold, optional release
// All stimulus changes are placed away from clock edges, so there are no races.

module dff_tb_unit
    import dff_tb_pkg::*;
#(
    parameter type   T        = logic,
    parameter string NAME     = "T",
    parameter int    NUM_RAND = 3000
)(
    input  logic        clk,
    output logic        done,
    output int unsigned errors
);
    localparam int W  = $bits(T);
    localparam int NW = (W + 31) / 32;

    logic reset_n;
    T     d_i;
    T     q_o;
    T     exp_q;

    dff #(.T(T)) dut (
        .clk     (clk),
        .reset_n (reset_n),
        .d_i     (d_i),
        .q_o     (q_o)
    );

    // ------------------------------------------------------------------ helpers
    function automatic T rand_t();
        /* verilator lint_off UNUSEDSIGNAL */  // upper bits unused when W < 32
        logic [NW*32-1:0] r;
        /* verilator lint_on UNUSEDSIGNAL */
        for (int i = 0; i < NW; i++) r[i*32 +: 32] = $urandom;
        return T'(r[W-1:0]);
    endfunction

    task automatic check(input string what);
        logic [W-1:0] got, want;
        got  = q_o;
        want = exp_q;
        if (got !== want) begin
            errors++;
            $display("[%s] ERROR @%0t: %s: q_o=0x%0h expected=0x%0h", NAME, $time, what, got, want);
        end
    endtask

    // One clock cycle of checking + stimulus, see timing convention above.
    // rst_chance: 0 = never touch reset_n, else ~1/rst_chance per cycle to toggle it.
    task automatic run_cycle(input T d_next, input int unsigned rst_chance);
        @(posedge clk);
        #1;                                    // P+1
        exp_q = reset_n ? d_i : '0;            // what the flop must have captured
        check("after clock edge");
        #1;                                    // P+2
        d_i = rand_t();                        // glitch: q_o must ignore it
        #1;                                    // P+3
        check("d_i change in high phase");
        if (rst_chance != 0) begin             // P+3 -> P+4
            if (reset_n && ($urandom_range(rst_chance - 1) == 0)) begin
                reset_n = 1'b0;
                exp_q   = '0;
                #1;
                check("async reset assert (no clock edge)");
            end else if (!reset_n && ($urandom_range(1) == 0)) begin
                reset_n = 1'b1;
                #1;
                check("reset release must not load d_i");
            end
        end
        @(negedge clk);
        #1;                                    // P+6
        d_i = d_next;                          // value the next edge will sample
        #1;                                    // P+7
        check("d_i change in low phase");
        if (rst_chance != 0 && !reset_n && ($urandom_range(1) == 0)) begin
            reset_n = 1'b1;                    // short reset pulse, released before the edge
            #1;
            check("reset release must not load d_i (low phase)");
        end
    endtask

    // ------------------------------------------------------------------ test
    initial begin
        logic [W-1:0] tmp;
        errors  = 0;
        done    = 1'b0;
        reset_n = 1'b1;
        d_i     = '1;
        exp_q   = '0;

        // 1. Async reset: asserted at t=2ns, before the very first clock edge (t=5ns),
        //    so q_o can only clear if the reset really is asynchronous.
        #2;
        reset_n = 1'b0;
        exp_q   = '0;
        #1;
        check("async reset before any clock edge");

        // 2. Reset held over several clock edges while d_i is non-zero: q_o stays 0.
        repeat (4) run_cycle(rand_t() | T'(1), 0);

        // 3. Release reset between edges: q_o must still be 0 until the next edge.
        reset_n = 1'b1;
        #1;
        check("reset release must not load d_i");

        // 4. Directed data patterns.
        run_cycle('1, 0);
        run_cycle('0, 0);
        tmp = '0;
        for (int i = 0; i < W; i++) begin     // walking one
            tmp    = '0;
            tmp[i] = 1'b1;
            run_cycle(T'(tmp), 0);
        end
        for (int i = 0; i < W; i++) begin     // walking zero
            tmp    = '1;
            tmp[i] = 1'b0;
            run_cycle(T'(tmp), 0);
        end
        for (int i = 0; i < W; i++) tmp[i] = (i % 2 == 0);
        run_cycle(T'(tmp), 0);                // 0101...
        run_cycle(T'(~tmp), 0);               // 1010...

        // 5. Directed async reset in the middle of a cycle with q_o != 0, in both clock phases.
        run_cycle('1, 0);
        @(posedge clk); #1;                    // q_o = all ones now
        exp_q = '1;
        check("pre-reset value");
        #2;                                    // high phase
        reset_n = 1'b0; exp_q = '0; #1;
        check("async reset in clock high phase");
        reset_n = 1'b1; #1;
        check("release in high phase keeps 0");
        run_cycle('1, 0);
        @(posedge clk); #1;
        exp_q = '1;
        check("recapture after reset");
        @(negedge clk); #2;                    // low phase
        reset_n = 1'b0; exp_q = '0; #1;
        check("async reset in clock low phase");
        reset_n = 1'b1; #1;

        // 6. Constrained-random data with random async reset pulses.
        repeat (NUM_RAND) run_cycle(rand_t(), 8);

        // 7. Leave reset released and drain one edge.
        reset_n = 1'b1;
        run_cycle(rand_t(), 0);
        run_cycle(rand_t(), 0);

        done = 1'b1;
    end
endmodule
