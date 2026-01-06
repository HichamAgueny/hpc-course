#!/bin/bash
# ---------------------------------------------------------------
# nvidia-smi cheatsheet for HPC class
# ---------------------------------------------------------------

# 1. Show only GPU 0, 1 and 2 with their names
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv,noheader

# 2. Show utilization over a 5‑second interval (live monitor)
nvidia-smi -l 5

# 3. Show memory usage & temperature
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu --format=csv

# 4. Find the GPU topology (NVLink vs PCIe)
nvidia-smi topo -m

# 5. Set a memory limit for a subset of GPUs (e.g. limit GPU 2 to 8 GB)
nvidia-smi --gpu=2 --mem=8192

# 6. Enable exclusive process mode on GPU 1 (prevents other jobs from sharing)
nvidia-smi -i 1 --mode=EXCLUSIVE_PROCESS

# 7. Export a CSV dump that can be plotted later
nvidia-smi --query-gpu=temperature.gpu,memory.used,memory.total --format=csv > gpu_stats.csv

