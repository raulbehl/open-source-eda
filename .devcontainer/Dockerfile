# Open Source EDA — Season One toolchain.
#
# Built once by .github/workflows/devcontainer-image.yml and published to
# ghcr.io/raulbehl/open-source-eda. Codespaces pull the finished image, so
# nothing is compiled when a viewer opens one.
#
# Everything the whole season needs is in here up front, so a viewer's
# codespace never has to be rebuilt mid-season. Every tool is pinned.

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG VERILATOR_VERSION=v5.052
ARG YOSYS_VERSION=v0.69
ARG SBY_COMMIT=b1a1e98cba941ec8433f8dc27f416cd7bb7f14be
ARG YICES_VERSION=yices-2.7.0
ARG BITWUZLA_VERSION=0.9.1
ARG CUDD_VERSION=3.0.0
ARG OPENSTA_COMMIT=7a034b56de14b485ddf8fd97b420a6f37a91c00d
ARG UVM_SHA256=4664ac015f23c72106dd785906aa874d70932ea63f74b85de1e32fa5339c15eb

# Build + runtime dependencies for everything below.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git make cmake ninja-build meson pkg-config autoconf gperf g++ clang lld \
      flex bison help2man perl perl-doc gawk curl ca-certificates \
      ccache libgoogle-perftools-dev numactl \
      libfl2 libfl-dev zlib1g zlib1g-dev \
      libffi-dev libreadline-dev tcl-dev swig libeigen3-dev \
      libgmp-dev libmpfr-dev \
      graphviz xdot \
      z3 \
      python3 python3-dev python3-pip python3-venv \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

# ---- Verilator: simulation (and UVM, which needs >= 5.052) ------------------
RUN git clone --depth 1 --branch ${VERILATOR_VERSION} https://github.com/verilator/verilator \
 && cd verilator && unset VERILATOR_ROOT \
 && autoconf && ./configure && make -j"$(nproc)" && make install \
 && cd .. && rm -rf verilator

# ---- Yosys: synthesis. v0.67+ has the slang SystemVerilog frontend built in -
RUN git clone --depth 1 --branch ${YOSYS_VERSION} --recurse-submodules --shallow-submodules \
      https://github.com/YosysHQ/yosys \
 && cd yosys \
 && cmake -B build . -DCMAKE_BUILD_TYPE=Release -DYOSYS_ENABLE_UNIT_TESTS=OFF \
      -DYOSYS_USE_BUNDLED_LIBS=ON \
 && cmake --build build -j"$(nproc)" && cmake --install build \
 && ldconfig \
 && cd .. && rm -rf yosys

# ---- SBY: formal front end ---------------------------------------------------
RUN git clone https://github.com/YosysHQ/sby \
 && cd sby && git checkout ${SBY_COMMIT} && make install PREFIX=/usr/local \
 && cd .. && rm -rf sby

# ---- Solvers: Yices 2 (SBY's default), Bitwuzla; Z3 comes from apt ----------
RUN git clone --depth 1 --branch ${YICES_VERSION} https://github.com/SRI-CSL/yices2 \
 && cd yices2 && autoconf && ./configure && make -j"$(nproc)" && make install \
 && ldconfig && cd .. && rm -rf yices2

RUN git clone --depth 1 --branch ${BITWUZLA_VERSION} https://github.com/bitwuzla/bitwuzla \
 && cd bitwuzla && ./configure.py --prefix /usr/local \
 && cd build && ninja install \
 && ldconfig && cd ../.. && rm -rf bitwuzla

# ---- OpenSTA: static timing analysis (needs CUDD) ----------------------------
RUN git clone --depth 1 --branch ${CUDD_VERSION} https://github.com/cuddorg/cudd \
 && cd cudd \
 # git checkout scrambles mtimes, so make tries to regenerate these with
 # aclocal-1.14 (which nobody has). Re-stamp them in dependency order.
 && touch aclocal.m4 && sleep 1 && touch Makefile.in config.h.in configure \
 && ./configure --prefix=/opt/cudd && make -j"$(nproc)" && make install \
 && cd .. && rm -rf cudd \
 && git clone https://github.com/parallaxsw/OpenSTA \
 && cd OpenSTA && git checkout ${OPENSTA_COMMIT} \
 && cmake -B build . -DCMAKE_BUILD_TYPE=Release -DCUDD_DIR=/opt/cudd \
 && cmake --build build -j"$(nproc)" \
 && install -m 755 build/sta /usr/local/bin/sta \
 && cd .. && rm -rf OpenSTA

# ---- UVM 2020.3.2 (Accellera kit, unmodified) --------------------------------
RUN curl -fsSL "https://www.accellera.org/images/downloads/standards/uvm/1800.2-2020.3.2%20Release.gz" -o uvm.tgz \
 && echo "${UVM_SHA256}  uvm.tgz" | sha256sum -c - \
 && tar xzf uvm.tgz -C /opt && rm uvm.tgz
ENV UVM_HOME=/opt/1800.2-2020.3.2

# ---- cocotb in a venv (Ubuntu 24.04 blocks system-wide pip, PEP 668) ---------
# Owned by 'vscode' so viewers can pip install more without sudo.
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
RUN python3 -m venv /opt/venv \
 && pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir cocotb pytest \
 && chown -R vscode:vscode /opt/venv

WORKDIR /
