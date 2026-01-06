# HPC‑Course‑Examples
This repo is deliberately structured so that each practical topic lives in its own folder, includes a short tutorial, ready‑to‑run scripts.  

---  

## 📚  Table of Contents
1. [Course Overview](#course-overview)  
2. [Repository Layout](#repository-layout)  
3. [Prerequisites & Setup](#prerequisites--setup)  
4. [Running the Labs](#running-the-labs)  
5. [Example Topics & Scripts](#example-topics--scripts)  
   - Slurm basics & job‑viewer script  
   - Submitting & monitoring a real Slurm job  
   - `nvidia‑smi` cheat‑sheet  
   - Querying Lustre filesystem info  
   - GPU‑aware vs non‑aware MPI bandwidth demo  
6. [Assessments & Lab Manuals](#assessments--lab-manuals)  
7. [Running the Full Environment (Docker / Conda)](#running-the-full-environment)  
8. [Contributing & Issues](#contributing--issues)  
9. [License](#license)  

---  

## Course Overview
This repository accompanies an **HPC fundamentals course** (lecture + lab).  
Students will learn to:

* Submit and monitor jobs on a Slurm scheduler.  
* Parse Slurm accounting records and extract useful information programmatically.  
* Query GPU health and topology with `nvidia-smi`.  
* Inspect Lustre storage characteristics.  
* Compare GPU‑aware and GPU‑non‑aware MPI bandwidth on real hardware.  

All material is provided as **self‑contained examples** that can be explored on a single workstation or on an actual cluster.

---  

## Repository Layout
```
hpc-course/
│
├─ .github/                # GitHub Actions CI workflows
├─ .vscode/                # optional VS Code settings
├─ docs/
│   ├─ presentation.pdf    # full slide deck for the class
│   └─ handouts/grading_rubric.pdf
├─ examples/
│   ├─ 01_slurm_basics/
│   │   └─ slurm_job_viewer/   (Python script + sample data)
│   ├─ 02_slurm_example_job/
│   │   ├─ sbatch_script.slurm
│   │   └─ README.md
│   ├─ 03_nvidia_smi/
│   │   └─ nvidia_smi_examples.sh
│   ├─ 04_lustre_info/
│   │   └─ lustre_info.sh
│   └─ 05_gpu_bandwidth/
│       ├─ gpu_aware_mpi/
│       │   ├── Makefile
│       │   └─ mpi_naive.c
│       └─ gpu_non_aware_mpi/
│           ├── Makefile
│           └─ mpi_naive.c
├─ scripts/
│   └─ generate_examples.sh
├─ LICENSE
├─ README.md               # ← you are here
└─ .gitignore
```

---  

## Prerequisites & Setup
| Requirement | Reason |
|------------|--------|
| **Linux | All scripts assume a Unix‑like shell. |
| **Python 3.9+** | Needed for the Slurm‑viewer script and helper utilities. |
| **Slurm client** (`scontrol`, `squeue`, `sbatch`) | To generate real job accounting data. |
| **CUDA Toolkit** (if GPU labs are used) | Provides `nvidia-smi` and the CUDA runtime for MPI builds. |
| **OpenMPI** (or MPICH) built with CUDA support | For the GPU‑aware MPI demos. |

### Quick environment creation (conda)
```bash
# Clone the repo first
git clone https://github.com/your-org/hpc-course.git
cd hpc-course

```

The environment installs:
* Python, `pip`
* `openmpi` (CPU‑only build) **and** `openmpi-cuda` (GPU‑aware optional)

---  

## Running the Labs

### 1️⃣ Slurm Basics (Lab 1)
```bash
cd examples/01_slurm_basics
./slurm_job_viewer.py           # interactive mode
#   → enter a JobId (e.g. 12345) and select categories
```

*The script parses `scontrol show jobid` output and prints it in three labeled blocks.*  

A tiny sample file (`sample_slurm_data.txt`) is provided for testing on a machine **without** an active Slurm cluster.

### 2️⃣ Submitting a Real Job (Lab 2)
```bash
cd examples/02_slurm_example_job
sbatch sbatch_script.slurm      # submit
squeue -u $USER                 # view pending/running jobs
scontrol show jobid <JobId>    # detailed accounting info
```

The job runs a short `sleep 30` + `echo "Hello"` script; you can replace it with any executable.

### 3️⃣ `nvidia-smi` Cheat‑Sheet (Lab 3)
```bash
cd examples/03_nvidia_smi
./nvidia_smi_examples.sh
```
*All commands are annotated with comments explaining what they do.*

### 4️⃣ Lustre Filesystem Inspection (Lab 4)
```bash
cd examples/04_lustre_info
./lustre_info.sh
```
*Shows capacity, quotas, and basic diagnostics on a Lustre mount point.*

### 5️⃣ GPU Bandwidth Comparison (Lab 5)
```bash
cd examples/05_gpu_bandwidth/gpu_aware_mpi
make                         # builds `gpu_aware_mpi`
cd ../gpu_non_aware_mpi
make                         # builds `non_aware_mpi`

# Run a sample measurement (matrix size 4096)
sbatch job_gpu_aware_mpi 
sbatch job_non_aware_mpi 
```

*The two binaries measure the bandwidth of a transferring data between two GPUs.

A Python helper (`plot_bw.py`) can be used to generate a bandwidth‑vs‑size plot.

---  

## Example Topics & Scripts  

### 📂 `01_slurm_basics/slurm_job_viewer/`
* **`slurm_job_viewer.py`** – parses `scontrol show jobid` output and prints three categorized blocks (General, Resources, Location).  
* **`sample_slurm_data.txt`** – a tiny dump you can feed to the script when no running job exists.  
* **`README.md`** – step‑by‑step walkthrough and suggested exercises.

### 📂 `02_slurm_example_job/`
* **`example_job.sh`** – simple workload that prints “Hello” and sleeps.  
* **`sbatch_script.slurm`** – a minimal batch script that requests 2 CPUs, 1 GB memory, and a 5‑minute wall‑time limit.  
* **`README.md`** – explains submission, monitoring with `squeue`/`scontrol`, and how to inspect the job’s resource usage.

### 📂 `03_nvidia_smi/`
* **`nvidia_smi_examples.sh`** – a collection of practical `nvidia‑smi` commands (querying, monitoring, topology, memory limits, etc.).  
* **`README.md`** — explains each command and typical use‑cases.

### 📂 `04_lustre_info/`
* **`lustre_info.sh`** – runs a handful of `lfs` commands (`df`, `quota`, `summary`, `check`).  
* **`README.md`** — quick reference for gathering storage metrics on a Lustre filesystem.

### 📂 `05_gpu_bandwidth/`
* Two sub‑folders:
  * **`gpu_aware_mpi/`** – MPI built with `-DGPU_AWARE`; reads directly from GPU memory via CUDA‑aware MPI.  
  * **`gpu_non_aware_mpi/`** – same code compiled **without** the flag (forces data to be copied to host memory).  
* Each side contains a `Makefile` and the source (`mpi_naive.c`).  
* **`README.md`** — compilation instructions, sample run commands, and how to plot the results with `plot_bw.py`.

---  

## License
The code in this repository is released under the **MIT License** (see the `LICENSE` file).  
The PDFs and other non‑code assets are covered by the same license unless otherwise noted.

---  

## 📬  Contact
* **Instructor:** Dr. Hicham AGueny – hicham.agueny@uib.no  

---  

*Happy hacking, and enjoy exploring HPC!* 
