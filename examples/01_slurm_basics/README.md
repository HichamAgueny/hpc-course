# **Slurm Quick‑Start Commands**  
---  
## 1. Command catalogue  

Below are ready‑to‑copy one‑liners. Replace the placeholder text (shown in **\<…\>**) with your own values before executing; and run them on your login or compute node

### 1.0 A tiny workflow example: Details below  

```bash
# 1️⃣ See the whole cluster status
sinfo

# 2️⃣ Look at the "accel" partition details
sinfo -p accel

# 3️⃣ Peek at a specific node that you know belongs to that partition
scontrol show node <node-name>

# 4️⃣ Submit a job, wait a few seconds, then check its status
squeue -p accel   # List all jobs that are currently running in the "accel" partition
scontrol show jobid <JobID>        # show allocation, state, node list, etc.
```
---
### 1.1 List **all** partitions and nodes (basic overview)  

```bash
# Print a concise status of every partition and its nodes
sinfo
```

**What you’ll see**  
A table with columns `PARTITION`, `NODES`, `STATE`, `TIMELIMIT`, `ACCOUNT`, etc. It gives you a quick health‑check of the whole cluster.

---

### 1.2 Show information for a **specific partition** (e.g., `accel`)  

```bash
# Detailed view of the "accel" partition only
sinfo -p accel
```

**Typical output sections**  

- `PARTITION` – name of the partition  
- `NODES` – total / idle / busy count  
- `TIMELIMIT` – default wall‑time limit  
- `AVAIL` – QOS/time‑limits if configured  
---

### 1.3 Show detailed node information for a **single node**  

```bash
# Replace <node-name> with the exact node identifier you want to inspect
scontrol show node <node-name>
```

**Example**  

```bash
scontrol show node gpu-1-6
```

The output is a long list of attributes (`NodeName`, `State`, `CPUs`, `RealMemory`, `Partition`, `Features`, …).  

*Tip:* For a compact one‑liner that prints only the most useful fields, you can pipe the result to `grep`/`awk`:

```bash
scontrol show node gpu-1-6 | grep -E 'NodeName|RealMemory|State|Partition'
```
---

### 1.4 Check **running jobs** in a given partition  

```bash
# List all jobs that are currently running in the "accel" partition
squeue -p accel
```

**What you get**  

| Column | Meaning |
|--------|---------|
| `JOBID` | Slurm job identification number |
| `PARTITION` | Partition the job is using |
| `USER` | Owner of the job |
| `ST`   | Job state (`R` = running, `PD` = pending, …) |
| `TIME` | Elapsed wall‑time (or “TIME” when still running) |
| `NODES`| Allocated node list |
| `SUBMIT/START_TIME` | When the job was submitted / started |

---
### 1.5 Submit a job status / resource query for a **specific JobID**  

```bash
# Provide the numeric job ID you want to inspect
scontrol show jobid <JobID>
```

**When you need it**  

- To see the exact list of nodes allocated to the job (`NodeName=` line).  
- To check the job’s state (`State=`), priority, accounting info, etc.  

**Example**  

```bash
scontrol show jobid 123456
```
---
