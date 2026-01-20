# GPU‑aware MPI Bandwidth Test  

---  

## Purpose  

This repository contains a ready‑to‑run MPI program that measures the **bandwidth of data transfer between two GPUs** on the **Olivia** cluster.  

| Scenario | Communication mode | What happens under the hood |
|----------|-------------------|-----------------------------|
| **IPC enabled** | Direct **GPU‑to‑GPU** transfer via **NVlink* (Intra‑node). | Data never touches the host memory – the fastest possible path. |
| **IPC disabled** | Host‑mediated transfer (MPI → host → GPU). | Slower, useful as a baseline or when IPC is not available. |

Both the source code **has already been compiled** for the Olivia compute nodes, and two Slurm submission scripts are provided to run the two cases:

* `script_gpuaware_IPC_enabled_Olivia.sh`    → IPC **enabled**  
* `script_gpuaware_IPC_disabled_Olivia.sh`   → IPC **disabled**

Your only task is to **submit** the appropriate script with `sbatch` and compare the printed bandwidth results.

### Case I: IPC **enabled**  
  
```bash
cd gpu_aware_mpi
sbatch script_gpuaware_IPC_enabled_Olivia.sh
cat slurm/slurm_olivia_IPC_enabled*.out
```
### Case II: IPC **disabled**  

```bash
sbatch script_gpuaware_IPC_disabled_Olivia.sh
cat slurm/slurm_olivia_IPC_disabled*.out
```
---  

## 📂 Folder layout  

```
gpu_aware_mpi/
│
├─ gpuaware_bandwidth.f90   ← MPI-OpenACC source (already compiled)
├─ compile.sh               ← compile script (already executed)
│
├─ script_gpuaware_IPC_enabled_Olivia.sh    ← slurm script for the case of IPC enabled
├─ script_gpuaware_IPC_disabled_Olivia.sh   ← slurm script for the case of IPC disbaled
│
└─ slurm/                   ← (optional) slurm output
```

---  

## How to run  

### 1️⃣ Submit the *IPC‑enabled* job  

```bash
cd gpu_aware_mpi
sbatch script_gpuaware_IPC_enabled_Olivia.sh
```

The script will:

1. Load any required modules (e.g., `CrayEnv`, `cuda/12.6`, `cray-mpich`).  
2. Launch the pre‑compiled executable `gpuaware.olivia.exe` with the `srun` launcher.
3. Print a table like:

```
...
...
Size (B):    134217728 | Time/transfer (s):     0.001021 | Bandwidth (GB/s):      131.400
Size (B):    268435456 | Time/transfer (s):     0.002029 | Bandwidth (GB/s):      132.325
Size (B):    536870912 | Time/transfer (s):     0.004043 | Bandwidth (GB/s):      132.795
Size (B):   1073741824 | Time/transfer (s):     0.008071 | Bandwidth (GB/s):      133.040
```

### 2️⃣ Submit the *IPC‑disabled* job  

```bash
sbatch script_gpuaware_IPC_disabled_Olivia.sh
```

This script launches the same executable but **without** IPC support (i.e., `MPICH_GPU_IPC_ENABLED=0`).  
Typical output will show a lower bandwidth because data traverses host memory.

```
...
...
Size (B):    134217728 | Time/transfer (s):     0.017885 | Bandwidth (GB/s):        7.505
Size (B):    268435456 | Time/transfer (s):     0.036659 | Bandwidth (GB/s):        7.323
Size (B):    536870912 | Time/transfer (s):     0.074704 | Bandwidth (GB/s):        7.187
Size (B):   1073741824 | Time/transfer (s):     0.149939 | Bandwidth (GB/s):        7.161
```
### 3️⃣ Retrieve the results  

The job’s standard output (`.out`) is stored in Slurm’s `slurm_olivia_IPC_*-<jobid>.out` file in the submission directory.  
You can view it directly:

```bash
cd gpu_aware_mpi
cat slurm/slurm_olivia_IPC_enabled*.out
cat slurm/slurm_olivia_IPC_disabled*.out
```

And to view the status of your job:

```bash
squeue --me 
```

