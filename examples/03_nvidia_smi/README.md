## Guide for inspecting NVIDIA GPUs on a Slurm‑managed cluster

---  
## Commands  
### 1.0 Launch an interactive session
To run the `nvidia-smi` commands on a GPU‑enabled node, you need to launch an interactive shell with Slurm first:  
```bash
srun -A nn14000k -p accel --nodes=1 --gpus=1 --ntasks-per-node=1  --cpus-per-task 1 --mem=1G --time=00:15:00 --pty bash -i
```  
Then paste the commands below inside that shell.

---
### 1.1  GPU-monitoring with nvidia-smi (details below)

```bash
# 1. All GPUs
nvidia-smi

# 2. Names of GPUs 0,1,2 (CSV, no header)
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv,noheader

# 3. Memory / Temperature / Power (CSV)
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw \
           --format=csv,noheader

# 4. Export to CSV for later plotting
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw \
           --format=csv,noheader > gpu_stats.csv

# 5. GPU interconnect topology
nvidia-smi topo -m
```
---  

## 2 Details
### 2.1 Show **all** GPUs that the node can see  

```bash
# Basic dump – one line per GPU with all fields
nvidia-smi
```

*Output example*  

```
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 525.85.12   Driver Version: 525.85.12   CUDA Version: 12.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap| Memory-Usage | GPU-Util  Compute M. |
|                               |         |               |
+-----------------------------------------------------------------------------+
| 0    Tesla T4           Off  | 00000000:3B:00.0 Off | 0%   |
| 30C    P0    15W / 70W |   1234MiB / 15109MiB |   12%      Default |
|                               |         |               |
+-----------------------------------------------------------------------------+
| 1    Tesla T4           Off  | 00000000:3B:00.1 Off | 0%   |
| 31C    P0    12W / 70W |   567MiB / 15109MiB |   0%      Default |
+-----------------------------------------------------------------------------+
```

---  

### 2.2 Show **only GPUs 0, 1 and 2** and print just their **names**  

```bash
# List GPUs 0‑2 and print a CSV column `name` (no header)
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv,noheader
```

*Sample output*  

```
GH200,
A100-SXM4
```

> `-i` selects the GPU indices you want to query.  
> `--format=csv,noheader` removes the header line and uses commas as separators – perfect for downstream scripting.

---  

### 2.3 Show **memory usage, temperature & power draw** for every visible GPU  

```bash
# CSV with four fields: used memory, total memory, temperature, power draw
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw \
           --format=csv,noheader
```

*Sample output*  

```
1234, 15109, 67, 13
567,  15109, 31, 5
```

| Column | Meaning |
|--------|---------|
| `memory.used`   | Used memory in **MiB** |
| `memory.total`  | Total memory in **MiB** |
| `temperature.gpu` | Temperature in **°C** |
| `power.draw`    | Power consumption in **Watts** |

---  

### 2.4 Export the above data to a **CSV file** for later plotting  

```bash
# One‑shot dump → ./gpu_stats.csv
nvidia-smi --query-gpu=memory.used,memory.total,temperature.gpu,power.draw \
           --format=csv,noheader > gpu_stats.csv
```

*File `gpu_stats.csv`* (example)

```
1234,15109,67,13
567,15109,31,5
```

> Keep the file, load it into Python/R/Matlab, and plot memory usage over time, temperature trends, etc.

---  

### 2.5 (Bonus) Examine the **GPU topology** – how GPUs are linked  

```bash
nvidia-smi topo -m
```

#### What you’ll see  

The command prints a **matrix** that maps each GPU to the interconnect used to talk to every other GPU.  

```
        GPU0    GPU1    GPU2    GPU3        CPU Affinity
GPU0    X        PHB     PHB     PHB      CPU Affinity
GPU1    PHB      X       PHB     PHB      CPU Affinity
GPU2    PHB      PHB     X       NV1      CPU Affinity
GPU3    PHB      PHB     NV1     X        CPU Affinity
```

| Symbol | Description |
|--------|-------------|
| **`X`** | The GPU compares to itself (always `X`). |
| **`PHB`** | *Peer‑to‑Peer Host‑Bridge* – typical **PCIe** traffic between GPUs on the same node. |
| **`NV1`** | *NVLink* (or NVSwitch) – a high‑speed, non‑PCIe fabric. If you see `NV1` or `NV2` it means those two GPUs are connected via NVLink. Anything else (e.g., `SYS`, `SLI`) indicates a different bus or a non‑supported path. |
| **`CPU Affinity`** column shows which CPU sockets each GPU is attached to (useful for NUMA‑aware jobs). |

**Interpretation**  

* If **all entries** (except the diagonal `X`) are `PHB`, every GPU talks to every other GPU over **PCIe** (the common default).  
* If you see **`NV1`** or **`NV2`** between specific GPUs, those pairs are linked via **NVLink**, which offers far higher bandwidth and lower latency.  
* The presence of **different symbols** tells you that the topology is heterogeneous – some GPUs may be on PCIe while others are on NVLink.

---  

## 3️⃣  Running the whole block in one go  

If you want a single copy‑&‑paste script, copy everything below (including the “#!/bin/bash” line).  
Save it as `check_gpus.sh`, make it executable (`chmod +x check_gpus.sh`), then run it.

```bash
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
# -------------------------------------------------

Copy any of the sections above into your terminal, and you’ll have a complete, reproducible snapshot of your GPUs—including memory, temperature, power, and how they talk to each other.
