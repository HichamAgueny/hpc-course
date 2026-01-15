# Lustre File System: Command-Line Usage Guide

This document provides a reference for checking disk space usage, storage targets, and inode quotas on the Lustre file system using the command line.

## 1. Checking Disk Space Capacity

### Standard Lustre Report
To view the disk usage of the file system, including detailed usage for every Object Storage Target (OST) and Metadata Target (MDT), use:

```bash
lfs df -h
```

* **-h**: Human-readable output (e.g., 100G, 5.2T).
* **Note**: This output can be very long as it lists every individual storage server target.

### Filesystem Summary Only

Because `lfs df` prints details for every target, you often only want the total summary for the whole filesystem. Pipe the output to `grep` to isolate the summary line:

```bash
lfs df -h | grep "filesystem_summary"
```

* **Usage**: Best for quickly checking if the entire cluster is full without scrolling through hundreds of lines of server targets.

### Clean, Formatted Mount View

If you prefer using the standard Linux `df` command but want a cleaner output that filters only Lustre mounts and formats the columns neatly (removing raw device IDs), use this command:

```bash
df -H -t lustre | awk '{sub(/.*:/,"",$1); printf "%-25s %8s %8s %8s %4s %s\n", $1, $2, $3, $4, $5, $6}'
```

* **df -H**: Human-readable (Powers of 1000, e.g., 1kB = 1000 bytes).
* **-t lustre**: Filters to show only Lustre filesystems.
* **awk**: Post-processes the text to remove IP/Device prefixes and aligns columns for readability.

---

## 2. Checking Inode Usage (File Counts)

In High-Performance Computing (HPC), it is common to run out of "file slots" (inodes) before running out of actual disk space, especially if generating millions of small files.

To check inode usage:

```bash
lfs df -i
```

* **Inodes**: Represents the number of files and directories.
* **IUsed**: The number of inodes currently used.
* **IFree**: The number of inodes remaining.
* **%IUse**: The percentage of inodes used.

**Tip:** If you cannot write files but `df -h` shows plenty of space, run `lfs df -i`. You likely hit the inode limit.

---

## 3. Quick Reference Table

| Goal | Command |
| --- | --- |
| **Full Detailed Report** | `lfs df -h` |
| **Total Summary Only** | `lfs df -h / grep "filesystem_summary"` |
| **File Count / Inodes** | `lfs df -i` |
| **Pretty Print Table** | `df -H -t lustre | awk ...` (see section 1) |

## 4. Understanding the Units

* **-h (Binary)**: Powers of 1024.  bytes.
* **-H (SI)**: Powers of 1000.  bytes.

*Note: `lfs` defaults to `-h` (binary), whereas standard `df` can toggle between `-h` and `-H`.*

Here is a short section describing the script, formatted to fit perfectly into your `README.md`.

---

## 5. Automated Monitoring Script

To simplify the usage of these commands, we provide a Bash script (`lustre_monitor.sh`) that bundles them into an easy-to-use menu.

**Features:**

* **Clean Output:** Automatically formats `df` output to remove raw device IDs.
* **Quick Summary:** Filters out the noise of hundreds of OST targets to show just the total capacity.
* **Inode Check:** Easily switches to file count view to check for quota limits.

**Setup and Usage:**

1. **Save the script** as `lustre_monitor.sh`.
2. **Make it executable:**
```bash
chmod +x lustre_monitor.sh

```

3. **Run the script:**
```bash
./lustre_monitor.sh

```
