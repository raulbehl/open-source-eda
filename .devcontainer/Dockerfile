FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# apt-get update runs in the same layer as the install, so the
# "Unable to locate package" error you hit can't happen here
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git help2man perl python3 python3-pip python3-venv make autoconf g++ \
      flex bison ccache libgoogle-perftools-dev numactl perl-doc \
      libfl2 libfl-dev zlib1g zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*
