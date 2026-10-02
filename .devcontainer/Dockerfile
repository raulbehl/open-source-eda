# Build deps for Verilator (built from source by setup.sh) + Python for cocotb
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git help2man perl perl-doc make autoconf g++ \
      flex bison ccache libgoogle-perftools-dev numactl \
      libfl2 libfl-dev zlib1g zlib1g-dev z3 \
      python3 python3-dev python3-pip python3-venv \
 && rm -rf /var/lib/apt/lists/*

# cocotb in a venv: Ubuntu 24.04 blocks system-wide pip (PEP 668).
# /opt/venv is owned by the 'vscode' user so viewers can pip install more packages without sudo.
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:${PATH}"
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
 && /opt/venv/bin/pip install --no-cache-dir cocotb \
 && chown -R vscode:vscode /opt/venv
