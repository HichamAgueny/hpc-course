# HPC‑Course‑Examples
This repo is deliberately structured so that each practical topic lives in its own folder, includes a short tutorial, ready‑to‑run scripts.  

## Course Overview
This repository accompanies an **HPC fundamentals course** (lecture + lab).  
Students will learn to:

* Submit and monitor jobs on a Slurm scheduler.  
* Query GPU health and topology with `nvidia-smi`.  
* Inspect Lustre storage characteristics.  
* Compare GPU‑aware and GPU‑non‑aware MPI bandwidth on an HPC system.  

All material is provided as **self‑contained examples** that can be explored on a single workstation or on an actual cluster.

---  
## SSH Setup to Olivia HPC cluster
```
ssh username@olivia.sigma2.no

Out:(hicham@login.olivia.sigma2.no) One-time password (OATH) for `hicham': 

Out:(hicham@login.olivia.sigma2.no) Password:
```
```
mkdir /cluster/work/projects/nn14000k/$USER
cd /cluster/work/projects/nn14000k/$USER

```
```bash
# Clone the repo first
git clone https://github.com/your-org/hpc-course.git
cd hpc-course

```

# Repository Layout
```
hpc-course/
│
│─ presentation.pdf    # full slide deck for the class
│   
├─ examples/
│   ├─ 01_slurm_basics/
│   ├─ 02_nvidia_smi/
│   ├─ 03_lustre_info/
│   └─ 04_gpu_bandwidth/
├─ LICENSE
├─ README.md               # ← you are here
```

---  

## Running the Labs

### Slurm Basics (Lab 1)
* Goal: Submit and monitor jobs on a Slurm scheduler.  
```bash
cd examples/01_slurm_basics
Follow instruction in the README file
```

### `nvidia-smi` Cheat‑Sheet (Lab 2)
* Goal: Query GPU health and topology with `nvidia-smi`.  
```bash
cd examples/02_nvidia_smi
Follow instruction in the README file
```

###  Lustre Filesystem Inspection (Lab 3)
* Goal: Inspect Lustre storage characteristics.  
```bash
cd examples/04_lustre_info
Follow instruction in the README file
```

### GPU Bandwidth Comparison (Lab 4)
* Goal: Compare GPU‑aware and GPU‑non‑aware MPI bandwidth on an HPC system.  
```bash
cd examples/04_gpu_bandwidth/gpu_aware_mpi
Follow instruction in the README file`
```

---  

## 📬  Contact
* **Instructor:** Dr. Hicham Agueny – hicham.agueny@uib.no  
