# cudaq-env

This repository provides a **Docker build environment for [CUDA-Q (CUDA Quantum)](https://github.com/NVIDIA/cuda-quantum)**.  
The container installs and configures all dependencies required to build and package CUDA-Q from source using **AlmaLinux 8** and **CUDA 12.6**.

The purpose of this repository is to demonstrate a **working reproducible CUDA-Q build environment**.

---

## 🧩 Features

- **Base image:** `almalinux:8`  
- **CUDA Toolkit:** 12.6  
- **GCC Toolchain:** GCC 11 (via `gcc-toolset-11`)  
- **Python:** 3.11 with `build`, `auditwheel`, and `numpy`  
- **LLVM components:** `clang`, `flang`, `lld`, `mlir`, `openmp`, and Python bindings  
- **Wheel packaging:** Builds and repairs the CUDA-Q Python wheel using `auditwheel`

---

## 🚀 How to Build the CUDA-Q Environment

### 1. Clone the CUDA-Q repository

Before building the Docker image, clone the official CUDA-Q repository **next to this folder** on your host system:

```bash
git clone https://github.com/NVIDIA/cuda-quantum.git
```
Your directory structure should now look like this:

```graphql
parent-folder/
├── cudaq-env/          # This repository
│   └── Dockerfile
└── cuda-quantum/       # Cloned CUDA-Q source code
```
>[!NOTE]
>The Dockerfile copies the `cuda-quantum` source directory into the image.
>Make sure both `cudaq-env` and `cuda-quantum` are in the same parent directory.

---

### 2. Build the Docker image
From inside the `cudaq-env` directory:

```bash
docker build -t cudaq-env .
```
This will:

- Upgrade system packages
- Install Python 3.11, CMake, Ninja, Git, and CUDA Toolkit
- Set up the GCC toolchain
- Build LLVM and CUDA-Q from source
- Produce a Python wheel for CUDA-Q

---

### 3. Run the container
Once built, you can start an interactive shell inside the environment:

```bash
docker run -it cudaq-env /bin/bash
```
Inside the container, the CUDA-Q build output (including wheels) will be located under:

```bash
/src/cuda-quantum/wheelhouse/
```

---

### 🧱 Environment Variables

| Variable                         | Description                                             |
| -------------------------------- | ------------------------------------------------------- |
| `CUDA_VERSION`                   | CUDA toolkit version (default: `12.6`)                  |
| `DISTRIBUTION`                   | CUDA repository distribution (default: `rhel8`)         |
| `GCC_TOOLCHAIN`                  | GCC toolchain path (`/opt/rh/gcc-toolset-11/root/usr/`) |
| `LLVM_INSTALL_PREFIX`            | Installation prefix for LLVM (`/usr/local/llvm`)        |
| `CUQUANTUM_INSTALL_PREFIX`, etc. | Prefix paths for various CUDA-Q dependencies            |

---

### 🧰 Build Process Overview
The Dockerfile performs these main steps:

1. System setup — installs AlmaLinux 8 dependencies.
2. CUDA installation — pulls CUDA Toolkit 12.6 from NVIDIA’s repository.
3. GCC toolchain setup — enables GCC 11 for CUDA compatibility.
4. LLVM build — installs LLVM components required by CUDA-Q.
5. CUDA-Q wheel build — builds and repairs the CUDA-Q Python package with `auditwheel`.

---

### 🧪 Verifying the Build
After the image finishes building, you can verify that the CUDA-Q wheel was created inside the container:

```bash
ls /src/cuda-quantum/wheelhouse/
```
You should see something like:

```bash
cuda_quantum-<version>-cp311-cp311-manylinux_2_28_x86_64.whl
```
You can test the wheel by installing it within the container:

```bash
pip install wheelhouse/cuda_quantum-*.whl
```

---

### 🧾 Notes

- You may need to adjust `DISTRIBUTION` and `CUDA_ARCH_FOLDER` in the Dockerfile for your platform.
- Several large CUDA libraries (`libcublas`, `libcusolver`, etc.) are intentionally excluded during wheel repair to reduce image size.
This environment is intended for **building**, not running, CUDA-Q workloads.

---

## 📚 References

- [CUDA Quantum (CUDA-Q) GitHub](https://github.com/NVIDIA/cuda-quantum)  
- [Install CUDA Quantum (CUDA-Q) from Source](https://nvidia.github.io/cuda-quantum/latest/using/install/data_center_install.html)
