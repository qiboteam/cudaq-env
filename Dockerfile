FROM almalinux:8

RUN dnf -y upgrade
RUN dnf install -y python3.11 python3.11-pip python3.11-devel
RUN dnf install -y git
RUN dnf install -y cmake
RUN dnf --enablerepo=powertools install -y ninja-build
RUN python3.11 -m pip install -U pip
RUN python3.11 -m pip install numpy build auditwheel patchelf
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled powertools


ENV CUDA_VERSION=12.6
ENV CUDA_DOWNLOAD_URL=https://developer.download.nvidia.com/compute/cuda/repos
# Go to the url above, set the variables below to a suitable distribution
# and subfolder for your platform, and uncomment the line below.
ENV DISTRIBUTION=rhel8
ENV CUDA_ARCH_FOLDER=x86_64
RUN dnf config-manager --add-repo "${CUDA_DOWNLOAD_URL}/${DISTRIBUTION}/${CUDA_ARCH_FOLDER}/cuda-${DISTRIBUTION}.repo"
RUN dnf install -y --nobest --setopt=install_weak_deps=False \
    cuda-toolkit-$(echo ${CUDA_VERSION} | tr . -)


ENV CUQUANTUM_INSTALL_PREFIX=/usr/local/cuquantum
ENV CUTENSOR_INSTALL_PREFIX=/usr/local/cutensor
ENV LLVM_INSTALL_PREFIX=/usr/local/llvm
ENV BLAS_INSTALL_PREFIX=/usr/local/blas
ENV ZLIB_INSTALL_PREFIX=/usr/local/zlib
ENV OPENSSL_INSTALL_PREFIX=/usr/local/openssl
ENV CURL_INSTALL_PREFIX=/usr/local/curl
ENV AWS_INSTALL_PREFIX=/usr/local/aws


RUN dnf install -y wget


ENV GCC_VERSION=11
RUN dnf install -y --nobest --setopt=install_weak_deps=False \
    gcc-toolset-${GCC_VERSION}

ENV GCC_TOOLCHAIN=/opt/rh/gcc-toolset-11/root/usr/
ENV CXX="${GCC_TOOLCHAIN}/bin/g++"
ENV CC="${GCC_TOOLCHAIN}/bin/gcc"
ENV CUDACXX=/usr/local/cuda/bin/nvcc
ENV CUDAHOSTCXX="${GCC_TOOLCHAIN}/bin/g++"

COPY .. /src
WORKDIR /src/cuda-quantum

RUN rm -rf wheelhouse/

RUN LLVM_PROJECTS='clang;flang;lld;mlir;python-bindings;openmp;runtimes' \
    bash scripts/install_prerequisites.sh -t llvm

ENV CC="$LLVM_INSTALL_PREFIX/bin/clang"
ENV CXX="$LLVM_INSTALL_PREFIX/bin/clang++"
ENV FC="$LLVM_INSTALL_PREFIX/bin/flang-new"
RUN python3.11 -m build --wheel

RUN python3.11 -m auditwheel -v repair $(find . -name 'cuda_quantum*.whl') \
    --plat $(echo $(find . -name 'cuda_quantum*.whl') | grep -o '[a-z]*linux_[^\.]*' | sed -re 's/^linux_/manylinux_2_28_/') \
    --exclude libcublas.so.11 \
    --exclude libcublasLt.so.11 \
    --exclude libcurand.so.10 \
    --exclude libcusolver.so.11 \
    --exclude libcusparse.so.11 \
    --exclude libcutensor.so.2 \
    --exclude libcutensornet.so.2 \
    --exclude libcustatevec.so.1 \
    --exclude libcudensitymat.so.0 \
    --exclude libcudart.so.11.0 \
    --exclude libnvToolsExt.so.1 \
    --exclude libnvidia-ml.so.1 \
    --exclude libcuda.so.1
