# GPU‑Aware MPI vs Non‑Aware MPI Bandwidth Demo

## What you will see
Two binaries are built from the same source (`mpi_naive.c`):
* **gpu_aware_mpi** – compiled with `-DGPU_AWARE` and linked against an MPI that was built with CUDA support.
* **non_aware_mpi** – compiled without that flag.

Both binaries launch two processes on the same node, each bound to a different GPU, and exchange a square matrix of size `N`.  
The measured *effective* bandwidth (GB/s) is printed at the end.

## Build & Run (example on a node that has two GPUs)

```bash
# 1️⃣  Load the appropriate modules
module load openmpi cuda/12.1

# 2️⃣  Build both versions
cd examples/05_gpu_bandwidth/gpu_aware_mpi
make            # builds `gpu_aware_mpi` with -DGPU_AWARE flag
cd ../gpu_non_aware_mpi
make            # builds `non_aware_mpi`

# 3️⃣  Run (example N=4096)
mpirun -np 2 --bind-to core ./gpu_aware_mpi 4096
mpirun -np 2 --bind-to core ./non_aware_mpi 4096

