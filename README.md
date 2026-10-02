# open-source-eda

# 1. Refresh package lists — and read the output for errors
sudo apt-get update

# 2. Make sure the "universe" repo is enabled (ccache, numactl, perftools live there)
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe
sudo apt-get update

# 3. Install
sudo apt-get install -y git help2man perl python3 python3-pip make autoconf g++ \
  flex bison ccache libgoogle-perftools-dev numactl perl-doc \
  libfl2 libfl-dev zlib1g zlib1g-dev z3

# 4. Build Verilator from source
git clone https://github.com/verilator/verilator && cd verilator && git checkout $(git describe --tags --abbrev=0)
autoconf && ./configure && make -j$(nproc) && sudo make install