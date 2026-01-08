#!/bin/bash
# -------------------------------------------------
#  GPU inspection script – ready to paste & run
# -------------------------------------------------

echo "=== 1️⃣  ALL GPUs ==="
nvidia-smi

echo -e "\n=== 2️⃣  GPU NAMES for GPUs 0‑2 ==="
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv,noheader

echo -e "\n=== 3️⃣  MEM / TEMP / POWER (CSV) ==="
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw \
           --format=csv,noheader

echo -e "\n=== 4️⃣  Export CSV dump to gpu_stats.csv ==="
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw \
           --format=csv,noheader > gpu_stats.csv
echo "   → CSV file created: $(pwd)/gpu_stats.csv"

echo -e "\n=== 5️⃣  GPU TOPOLOGY ==="
nvidia-smi topo -m


