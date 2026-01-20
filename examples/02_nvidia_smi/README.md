## Guide for inspecting NVIDIA GPUs on a Slurm‑managed cluster

---  
## Commands  
### 1.0 Launch an interactive session
To run the `nvidia-smi` commands on a GPU‑enabled node, you need to launch an interactive shell with Slurm first:  
```bash
srun -A nn14000k -p accel --nodes=1 --gpus=1 --ntasks-per-node=1  --cpus-per-task 1 --mem=1G --time=00:15:00 --reservation=geilo_winter_school_gpu --pty bash -i
```  
Then paste the commands below inside that shell.

---
### 1.1  GPU-monitoring with nvidia-smi (details below)

```bash
# 1. All GPUs
nvidia-smi

# 2. Names of GPUs 
nvidia-smi --query-gpu=name --format=csv

or for a specific GPU ID
nvidia-smi -i 0,1 --query-gpu=name --format=csv

# 3. Memory / Temperature / Power (CSV)
nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv

# 4. Execute the ´nvidia‑smi´ query 10 times, once every 2 seconds.
for i in {1..10}; do nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv; sleep 2; done

# 4. Export to CSV for later plotting
for i in {1..10}; do nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv; sleep 2; done > gpu-stats.csv

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
| NVIDIA-SMI 565.57.01    Driver Version: 565.57.01    CUDA Version: 12.7     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GH200 120GB  On   | 00000009:01:00.0 Off |                    0 |
| N/A   27C    P0    159W / 900W|  16341MiB / 97871MiB |      0%   E. Process |
|                               |                      |          Disabled    |
+-------------------------------+----------------------+----------------------+
|   1  NVIDIA GH200 120GB  On   | 00000019:01:00.0 Off |                    0 |
| N/A   27C    P0    137W / 900W|  14417MiB / 97871MiB |      0%   E. Process |
|                               |                      |          Disabled    |
+-------------------------------+----------------------+----------------------+
|   2  NVIDIA GH200 120GB  On   | 00000029:01:00.0 Off |                    0 |
| N/A   27C    P0    144W / 900W|    563MiB / 97871MiB |      0%   E. Process |
|                               |                      |          Disabled    |
+-------------------------------+----------------------+----------------------+
|   3  NVIDIA GH200 120GB  On   | 00000039:01:00.0 Off |                    0 |
| N/A   23C    P0     78W / 900W|      1MiB / 97871MiB |      0%   E. Process |
|                               |                      |          Disabled    |
+-------------------------------+----------------------+----------------------+

+-------------------------------------------------------------------------------------+
| Processes:                                                                          |
|  GPU   GI   CI        PID   Type   Process name                         GPU Memory  |
|        ID   ID                                                            Usage     |
|=====================================================================================|
|    0   N/A  N/A    200099      C   ...iki/master_thesis/hf_env/bin/python  16332MiB |
|    1   N/A  N/A    200111      C   ...iki/master_thesis/hf_env/bin/python  14408MiB |
|    2   N/A  N/A   2001214      C   ...ro-benchmarks/mpi/pt2pt/osu_latency    554MiB |
+-------------------------------------------------------------------------------------+
```

---  

### 2.2 Show **only GPUs 0, 1 and 2** and print just their **names**  

```bash
# List GPUs 0‑2 and print a CSV column `name` 
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv
```
 
**NVIDIA GPU Output**
```
NVIDIA GH200 120GB
NVIDIA GH200 120GB
NVIDIA GH200 120GB
```

> `-i` selects the GPU indices you want to query.  

---  

### 2.3 Show **memory usage, temperature & power draw** for every visible GPU  

```bash
# CSV with four fields: used memory, total memory, temperature, power draw
nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv
```

*Sample output*  

```
| Index | Utilization (%) | Memory Used (MiB) | Memory Total (MiB) | Temperature (°C) | Power Draw (W) |
|-------|-----------------|-------------------|--------------------|------------------|----------------|
| 0     | 100             | 90680             | 97871              | 42               | 516.88         |
| 1     | 100             | 90679             | 97871              | 37               | 338.83         |
| 2     | 100             | 90683             | 97871              | 37               | 317.68         |
```

---  
### 2.4 Execute the ´nvidia‑smi´ query 10 times, once every 2 seconds.
```bash
for i in {1..10}; do nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv; sleep 2; done
```

*Sample output*  
```
| Index | Utilization (%) | Memory Used (MiB) | Memory Total (MiB) | Temperature (°C) | Power Draw (W) |
|-------|-----------------|-------------------|--------------------|------------------|----------------|
| 0     | 100             | 90680             | 97871              | 42               | 487.33         |
| 1     | 100             | 90678             | 97871              | 44               | 532.15         |
| 2     | 100             | 90677             | 97871              | 47               | 542.57         |
| 3     | 100             | 90683             | 97871              | 44               | 534.33         |
|       |                 |                   |                    |                  |                |
| 0     | 43              | 90680             | 97871              | 39               | 289.91         |
| 1     | 30              | 90678             | 97871              | 36               | 245.72         |
| 2     | 63              | 90677             | 97871              | 40               | 299.64         |
| 3     | 39              | 90683             | 97871              | 36               | 273.89         |
|       |                 |                   |                    |                  |                |
| 0     | 100             | 90680             | 97871              | —                | 544.20         |
| 1     | 100             | 90678             | 97871              | 44               | 513.16         |
| 2     | 100             | 90677             | 97871              | 45               | 542.77         |
| 3     | 100             | 90683             | 97871              | 44               | 532.87         |
```
---
### 2.5 Export the above data to a **CSV file** for later plotting  

```bash
# One‑shot dump → ./gpu_stats.csv
for i in {1..10}; do nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv; sleep 2; done > gpu_stats.csv
```

*File `gpu_stats.csv`*, which can be viewed using e.g. the command `vi`

```
vi gpu_stats.csv
```
---  

### 2.6 (Bonus) Examine the **GPU topology** – how GPUs are linked  

```bash
nvidia-smi topo -m
```

#### What you’ll see  

The command prints a **matrix** that maps each GPU to the interconnect used to talk to every other GPU.  

```
 | GPU   | GPU0 | GPU1 | GPU2 | GPU3 | CPU Affinity | NUMA Affinity | GPU NUMA ID |
|-------|------|------|------|------|--------------|---------------|-------------|
| GPU0  | X    | NV6  | NV6  | NV6  | 0-71         | 0             | 4           |
| GPU1  | NV6  | X    | NV6  | NV6  | 72-143       | 1             | 12          |
| GPU2  | NV6  | NV6  | X    | NV6  | 144-215      | 2             | 20          |
| GPU3  | NV6  | NV6  | NV6  | X    | 216-287      | 3             | 28          |

---

**Legend:**

- **X**     = Self  
- **NV6**   = Connection traversing a bonded set of # NVLinks
```
### Interpretation of Affinity and NUMA Information

- **CPU Affinity**  
  Indicates the range of CPU cores that are **logically closest** (in terms of memory access latency and bandwidth) to each GPU.  
  For example, `0–71` means that GPU0 is optimally paired with CPU cores 0 through 71. Binding compute tasks or processes to these cores can reduce communication overhead and improve performance.

- **NUMA Affinity**  
  Shows the **Non-Uniform Memory Access (NUMA) node** associated with each GPU. Modern multi-socket systems split memory and CPUs into NUMA nodes; accessing memory from a local NUMA node is faster than from a remote one.  
  A GPU with `NUMA Affinity = 0` should ideally use memory allocated on NUMA node 0 to minimize latency.

- **GPU NUMA ID**  
  Represents the **internal NUMA identifier** used by the GPU driver or system firmware to map the GPU to the system’s NUMA topology. GPU NUMA ID (like 4, 12, 20, 28) usually shows how the GPU is numbered in the system’s hardware layout. These IDs may not match CPU NUMA node numbers but are used internally for topology-aware scheduling (e.g., by NVIDIA’s `nvidia-smi topo -m`).

> 💡 **Best Practice**: For optimal performance in multi-GPU systems, pin each GPU’s workload to its associated CPU core range (**CPU Affinity**) and allocate memory on its corresponding **NUMA node** to avoid costly cross-node memory traffic.

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
nvidia-smi -i 0,1,2 --query-gpu=name --format=csv

echo -e "\n=== 3️⃣  MEM / TEMP / POWER (CSV) ==="
nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv; sleep 2; done

echo -e "\n=== 4️⃣  Export CSV dump to gpu_stats.csv ==="
for i in {1..10}; do nvidia-smi --query-gpu=index,utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw --format=csv; sleep 2; done > gpu-stats.csv
echo "   → CSV file created: $(pwd)/gpu_stats.csv"

echo -e "\n=== 5️⃣  GPU TOPOLOGY ==="
nvidia-smi topo -m
# -------------------------------------------------

Copy any of the sections above into your terminal, and you’ll have a complete, reproducible snapshot of your GPUs—including memory, temperature, power, and how they talk to each other.
