# Open Source EDA — Season One

Companion repo for the **Open Source EDA** YouTube series: simulating, debugging
and verifying real hardware using only free, open source tools — and a browser.

No licences, no local install. Every episode runs in a GitHub Codespace with the
toolchain already set up.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/raulbehl/open-source-eda)

---

## ▶️ Episode 1 — From Zero to Waveforms: Open Source EDA in One Sitting

**Available now.** <!-- TODO: add video link -->

By the end of this episode you'll have open source EDA tools running and be
debugging a real design in the Surfer waveform viewer.

### What's in the box

| Tool | What it's for |
| --- | --- |
| [Verilator](https://github.com/verilator/verilator) | SystemVerilog simulator — latest stable, built from source |
| [Surfer](https://surfer-project.org/) | Waveform viewer, runs inside VS Code |
| [cocotb](https://www.cocotb.org/) | Python testbenches (pre-installed for later episodes) |

The environment is defined in [`.devcontainer/`](.devcontainer):
`Dockerfile` (Ubuntu 24.04 + build deps + cocotb) and `setup.sh` (builds Verilator).

### Try it

1. Click **Open in GitHub Codespaces** above and wait for the build to finish.
2. Run the testbench:

   ```bash
   cd dff/testbench
   make            # build and run — ends with "TEST PASSED"
   ```

3. Dump waveforms and open them:

   ```bash
   make wave       # writes dff_tb.vcd
   ```

   Then right-click `dff_tb.vcd` in the Explorer → **Open With… → Surfer**.

### The design

[`dff/`](dff) is a D flip-flop with an asynchronous active-low reset and a
parameterised data type (`parameter type T`). The self-checking testbench runs
the same checker against five types — 1-bit, 8-bit, 32-bit, 64-bit and a packed
struct — covering async reset in both clock phases, directed patterns and
constrained-random data.

```
dff/
├── rtl/dff.sv
└── testbench/
    ├── dff_tb.sv        top: clock, five DUT instances, verdict
    ├── dff_tb_unit.sv   per-type checker
    ├── dff_tb_pkg.sv    packed struct type
    └── Makefile         make | make wave | make lint | make clean
```

---

## ⏭️ Next up — Episode 2: Building Verilator From Source

Why this season builds the latest Verilator instead of installing the one your
distro ships — and what that control buys you for the rest of the series.

**Subscribe to get notified when it drops.** <!-- TODO: add channel link -->

---

## The season

| # | Episode | |
| --- | --- | --- |
| 1 | From Zero to Waveforms: Open Source EDA in One Sitting | ✅ Available |
| 2 | Building Verilator From Source | ⏭️ Next |
| 3 | Your First RTL Design in Verilator | 🔒 Coming soon |
| 4 | Verification in Python: Cocotb From Scratch | 🔒 Coming soon |
| 5 | Waveforms & Debugging RTL with GTKWave / Surfer | 🔒 Coming soon |
| 6 | Writing Your First SystemVerilog Testbench for Verilator | 🔒 Coming soon |
| 7 | Assertions & Coverage in Verilator | 🔒 Coming soon |
| 8 | UVM 101: Building a UVM Testbench with Verilator | 🔒 Coming soon |
| 9 | Formal Verification 101: Yosys + SBY From Scratch | 🔒 Coming soon |
| 10 | Writing Your First Formal Properties | 🔒 Coming soon |
| 11 | Real-World Cocotb: Randomized Tests + a CI Pipeline | 🔒 Coming soon |

Code for each episode lands in this repo when the episode is published.
