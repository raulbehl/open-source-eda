TOP    := dff_tb
SRCS   := ../rtl/dff.sv dff_tb_pkg.sv dff_tb_unit.sv dff_tb.sv
VFLAGS := --binary --timing -Wall --timescale 1ns/1ps --top-module $(TOP) --Mdir obj_dir -j 0

.PHONY: all run lint wave clean
all: run

obj_dir/V$(TOP): $(SRCS)
	verilator $(VFLAGS) $(SRCS)

run: obj_dir/V$(TOP)
	./obj_dir/V$(TOP)

lint:
	verilator --lint-only --timing -Wall --timescale 1ns/1ps --top-module $(TOP) $(SRCS)

# Dump dff_tb.vcd
wave: clean
	verilator $(VFLAGS) --trace -DDUMP $(SRCS)
	./obj_dir/V$(TOP)

clean:
	rm -rf obj_dir dff_tb.vcd