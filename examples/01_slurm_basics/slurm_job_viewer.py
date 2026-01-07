#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
slurm_job_viewer – pretty‑prints JobInfo in three categories.
"""

import subprocess, sys, pathlib
from typing import Dict, Set

CATEGORY_KEYS = {
    "1": {"JobId","JobName","Partition","JobState","RunTime","TimeLimit","EndTime"},
    "2": {"NodeList","NumNodes","NumCPUs","NumTasks","ReqTRES","AllocTRES","Memory"},
    "3": {"Command","WorkDir","StdErr","StdOut","MailUser"},
}

def parse_scontrol_output(text: str) -> Dict[str, str]:
    mapping: Dict[str, str] = {}
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line: continue
        for token in line.split():
            if "=" not in token: continue
            key, value = token.split("=", 1)
            mapping[key] = value
    return mapping

def print_category(cat: str, data: Dict[str, str]) -> None:
    print(f"\n=== Category {cat} – {sorted(CATEGORY_KEYS[cat])} ===")
    shown = any(k in data for k in CATEGORY_KEYS[cat])
    for k in sorted(CATEGORY_KEYS[cat]):
        if k in data:
            print(f"{k:<15} → {data[k]}")
    if not shown: print("(none)")
    print()

def main() -> None:
    job_id = input("Enter Slurm JobId (e.g. 74940): ").strip()
    try:
        out = subprocess.check_output(
            ["scontrol","show","jobid",job_id], text=True, stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError as e:
        sys.exit(f"scontrol failed: {e}")
    kv = parse_scontrol_output(out)

    print("=== Slurm job viewer ===")
    choice = input("Categories (e.g. 1,3 or just press <Enter> to quit): ").strip()
    for cat in sorted({c.strip() for c in choice.split(",") if c.strip() in CATEGORY_KEYS}):
        print_category(cat, kv)

if __name__ == "__main__":
    main()

