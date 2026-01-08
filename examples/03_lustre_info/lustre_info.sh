#!/bin/bash
# ---------------------------------------------------------------
# Quick Lustre diagnostics
# ---------------------------------------------------------------

# Show overall filesystem utilization
lfs df -h

# Show per‑project usage (replace projectid with your project)
lfs quota -p projectid

# Show the sum of all objects (files+dirs) in a directory
lfs summary -p /path/to/mydir

# Check for file‑system errors
lfs check -A

# Migrate a file to a different pool (example: move to "cold")
lfs migrate import /path/to/oldfile /coldpool/

# List all available Lustre pools
lfs pool -v

