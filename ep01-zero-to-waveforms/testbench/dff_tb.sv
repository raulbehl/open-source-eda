// Top-level testbench: clock, five dff_tb_unit instances (one per type T), final verdict.

module dff_tb
    import dff_tb_pkg::*;
;
    localparam int N = 5;

    logic            clk;
    logic [N-1:0]    done;
    int unsigned     errs [N];

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    dff_tb_unit #(.T(logic),        .NAME("logic"))       u_bit (.clk(clk), .done(done[0]), .errors(errs[0]));
    dff_tb_unit #(.T(logic [7:0]),  .NAME("logic[7:0]"))  u_b8  (.clk(clk), .done(done[1]), .errors(errs[1]));
    dff_tb_unit #(.T(logic [31:0]), .NAME("logic[31:0]")) u_b32 (.clk(clk), .done(done[2]), .errors(errs[2]));
    dff_tb_unit #(.T(logic [63:0]), .NAME("logic[63:0]")) u_b64 (.clk(clk), .done(done[3]), .errors(errs[3]));
    dff_tb_unit #(.T(pkt_t),        .NAME("pkt_t"))       u_pkt (.clk(clk), .done(done[4]), .errors(errs[4]));

    initial begin
        $dumpfile("dff_tb.vcd");
        $dumpvars(0, dff_tb);
    end

    // Watchdog
    initial begin
        #50_000_000;
        $fatal(1, "TIMEOUT: testbench did not finish");
    end

    initial begin
        int unsigned total;
        wait (&done);
        #10;
        total = 0;
        for (int i = 0; i < N; i++) total += errs[i];
        $display("--------------------------------------------");
        if (total == 0) begin
            $display("TEST PASSED (%0d DUT instances, %0t)", N, $time);
            $finish;
        end else begin
            $fatal(1, "TEST FAILED: %0d error(s)", total);
        end
    end
endmodule
