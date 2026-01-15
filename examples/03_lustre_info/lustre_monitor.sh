#!/bin/bash

# ==========================================
# Lustre Filesystem Monitor
# A utility to visualize disk and inode usage
# ==========================================

# Colors for formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check if 'lfs' command exists
if ! command -v lfs &> /dev/null; then
    echo "Error: 'lfs' command not found. Are you on a Lustre client node?"
    exit 1
fi

show_menu() {
    echo -e "\n${BOLD}Lustre Monitoring Menu${NC}"
    echo "1) Show Clean Mount List (Human Readable)"
    echo "2) Show Filesystem Summary Only"
    echo "3) Show Inode Usage (File Counts)"
    echo "4) Show Full Detailed Report (All OSTs)"
    echo "5) Run All Checks"
    echo "0) Exit"
    echo -n "Select an option: "
}

# --- Command Functions ---

cmd_clean_df() {
    echo -e "\n${BLUE}--- Clean Mount List (df -H) ---${NC}"
    # The awk command filters /dev/ IDs and aligns columns
    df -H -t lustre | awk '{sub(/.*:/,"",$1); printf "%-25s %8s %8s %8s %4s %s\n", $1, $2, $3, $4, $5, $6}'
}

cmd_summary() {
    echo -e "\n${BLUE}--- Lustre Summary (lfs df -h) ---${NC}"
    lfs df -h | grep "filesystem_summary"
}

cmd_inodes() {
    echo -e "\n${BLUE}--- Inode Usage (lfs df -i) ---${NC}"
    lfs df -i
}

cmd_full() {
    echo -e "\n${BLUE}--- Full OST Details (lfs df -h) ---${NC}"
    lfs df -h
}

# --- Main Logic ---

while true; do
    show_menu
    read -r opt
    case $opt in
        1) cmd_clean_df ;;
        2) cmd_summary ;;
        3) cmd_inodes ;;
        4) cmd_full ;;
        5) 
           cmd_clean_df
           cmd_summary
           cmd_inodes
           ;;
        0) echo "Exiting."; exit 0 ;;
        *) echo -e "${GREEN}Invalid option.${NC}" ;;
    esac
done
