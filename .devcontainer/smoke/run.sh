#!/usr/bin/env bash
# Smoke-tests the devcontainer image: every tool runs, and each does one real job.
# Run from the repo root inside the image (the image workflow does this before publishing).
set -euo pipefail
cd "$(dirname "$0")"
step() { echo; echo "=== $*"; }

step "versions"
verilator --version
yosys -V
sby --help >/dev/null && echo "sby ok"
yices --version | head -1
bitwuzla --version
z3 --version
sta -version </dev/null
python -c "import cocotb; print('cocotb', cocotb.__version__)"

step "Verilator: Ep 1 dff testbench"
make -C ../../ep01-zero-to-waveforms/testbench clean run | tee /tmp/dff.log
grep -q "TEST PASSED" /tmp/dff.log
make -C ../../ep01-zero-to-waveforms/testbench clean

step "Verilator + UVM 2020.3.2 (DPI build)"
rm -rf /tmp/uvm_obj
verilator --binary --timing --vpi -Wno-fatal -Wno-lint -Wno-style -j 0 --top-module hello \
  +incdir+"$UVM_HOME/src" "$UVM_HOME/src/uvm_pkg.sv" uvm_hello.sv \
  --CFLAGS -O0 --Mdir /tmp/uvm_obj "$UVM_HOME/src/dpi/uvm_dpi.cc"
/tmp/uvm_obj/Vhello +UVM_NO_RELNOTES | tee /tmp/uvm.log
grep -q "UVM TEST PASSED" /tmp/uvm.log
grep -q "UVM_ERROR :    0" /tmp/uvm.log
grep -q "UVM_FATAL :    0" /tmp/uvm.log
rm -rf /tmp/uvm_obj

step "Yosys + slang: synthesise counter"
yosys -p "read_slang counter.sv; synth -top counter; stat" > /tmp/yosys.log
tail -n 25 /tmp/yosys.log
grep -q "End of script" /tmp/yosys.log

step "SBY: prove counter never exceeds 9 (yices)"
rm -rf /tmp/sby && sby -f -d /tmp/sby counter.sby | tee /tmp/sby.log
grep -q "DONE (PASS" /tmp/sby.log
rm -rf /tmp/sby

step "Verilator randomize() uses z3"
cat > /tmp/rand.sv <<'SV'
module rand_tb;
  class item; rand bit [7:0] x; constraint c { x > 200; } endclass
  initial begin
    item it = new;
    repeat (20) begin
      if (!it.randomize()) $fatal(1, "randomize failed");
      if (it.x <= 200) $fatal(1, "constraint violated: %0d", it.x);
    end
    $display("RANDOMIZE OK");
    $finish;
  end
endmodule
SV
rm -rf /tmp/rand_obj
verilator --binary --timing -Wno-fatal --Mdir /tmp/rand_obj -o rand_tb /tmp/rand.sv
/tmp/rand_obj/rand_tb | tee /tmp/rand.log
grep -q "RANDOMIZE OK" /tmp/rand.log
rm -rf /tmp/rand_obj /tmp/rand.sv

echo; echo "ALL SMOKE TESTS PASSED"
