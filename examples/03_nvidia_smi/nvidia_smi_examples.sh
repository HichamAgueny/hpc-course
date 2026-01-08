#!/bin/bash
# ---------------------------------------------------------------
# nvidia-smi cheatsheet for HPC class
# ---------------------------------------------------------------
# 1. Show all GPUs
nvidia-smi 

# 1. Show only GPU 0, 1 and 2 with their names
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv,noheader

# 2. Show memory usage, temperature & power
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw --format=csv

# 3. Export a CSV dump that can be plotted later
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw --format=csv > gpu_stats.csv

# 4. Find the GPU topology (NVLink vs PCIe)
nvidia-smi topo -m



