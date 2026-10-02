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

One codespace has the toolchain for the **whole season** — you set it up once
and keep using it as new episodes come out.

| Tool | What it's for |
| --- | --- |
| [Verilator](https://github.com/verilator/verilator) 5.052 | SystemVerilog simulator, built from source |
| [Surfer](https://surfer-project.org/) | Waveform viewer, runs inside VS Code |
| [cocotb](https://www.cocotb.org/) | Python testbenches |
| [UVM](https://www.accellera.org/downloads/standards/uvm) 2020.3.2 | Accellera UVM library, at `$UVM_HOME` |
| [Yosys](https://github.com/YosysHQ/yosys) 0.69 | Synthesis, with the slang SystemVerilog frontend (`read_slang`) |
| [SBY](https://github.com/YosysHQ/sby) | Formal verification front end |
| Yices 2, Bitwuzla, Z3 | SMT solvers for SBY (and Z3 for Verilator's `randomize()`) |
| [OpenSTA](https://github.com/parallaxsw/OpenSTA) | Static timing analysis |

The environment is defined in [`.devcontainer/Dockerfile`](.devcontainer/Dockerfile)
and published as a prebuilt image, so a new codespace only downloads it —
nothing is compiled when you open one.

### Try it

1. Click **Open in GitHub Codespaces** above and wait for it to start.
2. Run the testbench:

   ```bash
   cd ep01-zero-to-waveforms/testbench
   make            # build and run — ends with "TEST PASSED"
   ```

3. Dump waveforms and open them:

   ```bash
   make wave       # writes dff_tb.vcd
   ```

   Then right-click `dff_tb.vcd` in the Explorer → **Open With… → Surfer**.

### The design

[`ep01-zero-to-waveforms/`](ep01-zero-to-waveforms) is a D flip-flop with an
asynchronous active-low reset and a parameterised data type (`parameter type T`). The self-checking testbench runs
the same checker against five types — 1-bit, 8-bit, 32-bit, 64-bit and a packed
struct — covering async reset in both clock phases, directed patterns and
constrained-random data.

```
ep01-zero-to-waveforms/
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

## Getting new episodes

Each episode lands in its own `epNN-…/` folder on `main`. Keep the codespace you
already have — there's no need to start a new one.

**Saving your own work.** The first time you commit and push from the
codespace, GitHub offers to create a fork for you. Say yes: your work goes to
your fork, and this repo becomes `upstream`.

**When a new episode is out:**

```bash
git pull upstream main     # or `git pull` if you haven't forked yet
```

The new episode folder appears next to your own code. Keep your work in your
own files or folders and the pull won't conflict with it.

> **Unused codespaces are deleted after 30 days.** Push your work to your fork
> so nothing is lost; if your codespace does go, just open a new one from the
> badge above and clone your fork.

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
