#!/usr/bin/env bash
# Builds the latest stable Verilator from source.
# Build deps are installed by the Dockerfile; re-running skips the build if new enough.
set -euo pipefail
set -x   # echo each command so the creation log shows where it fails

# cocotb needs Verilator >= 5.036; the SV testbench needs >= 5.018 (--binary --timing).
MIN_VERILATOR=5.036

have_ver=""
if command -v verilator >/dev/null 2>&1; then
  have_ver=$(verilator --version | awk '{print $2}')
fi

if [ -z "$have_ver" ] || \
   [ "$(printf '%s\n%s\n' "$MIN_VERILATOR" "$have_ver" | sort -V | head -n1)" != "$MIN_VERILATOR" ]; then
  echo "Verilator ${have_ver:-not installed} < $MIN_VERILATOR -- building latest stable from source"
  sudo rm -rf /tmp/verilator
  git clone --depth 1 --branch stable https://github.com/verilator/verilator /tmp/verilator
  (
    cd /tmp/verilator
    unset VERILATOR_ROOT
    autoconf
    ./configure
    make -j"$(nproc)"
    sudo make install
  )
  sudo rm -rf /tmp/verilator
else
  echo "Verilator $have_ver already >= $MIN_VERILATOR -- skipping build"
fi

hash -r
verilator --version
