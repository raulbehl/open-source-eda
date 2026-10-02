#!/usr/bin/env bash
# Sets up the Open Source EDA toolchain in a Codespace / devcontainer.
# Safe to re-run: skips the Verilator build if a new-enough one is installed.
set -euo pipefail

# cocotb needs Verilator >= 5.036; the SV testbench needs >= 5.018 (--binary --timing).
MIN_VERILATOR=5.036

# 1. Drop the Yarn apt source shipped in the universal image. Its signing key
#    expires and breaks every apt-get update. No-op on the plain Ubuntu image.
grep -rl 'dl.yarnpkg.com' /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null \
  | xargs -r sudo rm -f

# 2. Refresh package lists BEFORE installing anything. On a fresh container the
#    lists are empty, which is what caused "Unable to locate package".
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe
sudo apt-get update

# 3. Build Verilator from source if it's missing or older than the floor.
have_ver=""
if command -v verilator >/dev/null 2>&1; then
  have_ver=$(verilator --version | awk '{print $2}')
fi

if [ -z "$have_ver" ] || \
   [ "$(printf '%s\n%s\n' "$MIN_VERILATOR" "$have_ver" | sort -V | head -n1)" != "$MIN_VERILATOR" ]; then
  echo "Verilator ${have_ver:-not installed} < $MIN_VERILATOR -- building latest stable from source"
  sudo apt-get install -y --no-install-recommends \
    git make autoconf g++ flex bison help2man perl python3 \
    ccache libgoogle-perftools-dev numactl \
    libfl2 libfl-dev zlib1g zlib1g-dev z3
  sudo apt-get remove -y verilator || true
  sudo rm -rf /tmp/verilator
  git clone --depth 1 --branch stable https://github.com/verilator/verilator /tmp/verilator
  (
    cd /tmp/verilator
    unset VERILATOR_ROOT          # per Verilator's install guide
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
