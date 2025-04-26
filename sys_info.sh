#!/bin/bash
# sys_info.sh
# Collects and displays system information (basic and extended modes).
# Supports terminal output, file logging, and external Python logging.
# Author: Juan Garcia (aka 0x1G / GG3-DevNet)
# Created: 2025-04-18
# Usage: ./sys_info.sh --summary|--full [--log <file>] [--pylog] [--noterm]

set -euo pipefail # Exit on error, unset variable use, or broken pipeline

# ========================
# Configuration Variables
# ========================
MODE="summary"                      # Default mode is 'summary' unless overridden
LOG_FILE=""                         # Path to log file (optional)
TERM_OUT=true                       # Output to terminal by default
USE_PYTHON_LOGGER=false             # Use external Python logger if requested
LOGGING_SCRIPT="./logging_utils.py" # Path to external Python logging utility

# ========================
# ANSI Color Codes (Associative Array)
# ========================
# Used to colorize terminal output.
# Key = color name, Value = ANSI escape code.
declare -A COLORS=(
    [black]='\033[0;30m'
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [yellow]='\033[0;33m'
    [blue]='\033[0;34m'
    [purple]='\033[0;35m'
    [cyan]='\033[0;36m'
    [white]='\033[0;37m'
    [reset]='\033[0m'
)

# ========================
# Error Trap
# ========================

# Trap errors globally and pass failed command and line number to handler.
trap 'error_handler "$BASH_COMMAND" $LINENO' ERR

# ========================
# Function Definitions
# ========================

# Error handler function
error_handler() {
    local cmd="$1"
    local line="$2"
    local error_message="Command '$cmd' failed at line $line with exit code $?"

    if [[ "$USE_PYTHON_LOGGER" == true ]]; then
        python3 "$LOGGING_SCRIPT" --message "$error_message" --level ERROR
    else
        echo -e "\n[ERROR] $error_message" >&2
    fi

    exit 1
}

# Gathers basic system information (non-colorized).
print_summary() {
    local main_disk
    main_disk=$(lsblk -d -o NAME,SIZE,TYPE | awk '$3=="disk" {print $1, $2; exit}')
    printf "User@Host: %s@%s\n" "$(whoami)" "$(hostname)"
    printf "OS: %s\n" "$(grep '^PRETTY_NAME' /etc/os-release | cut -d= -f2 | tr -d '"')"
    printf "Kernel: %s\n" "$(uname -r)"
    printf "Uptime: %s\n" "$(uptime -p)"
    printf "IP Addr: %s\n" "$(ip a | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n1)"
    printf "CPU: %s\n" "$(lscpu | awk -F: '/Model name/ {print $2}' | sed 's/^[ \t]*//')"
    printf "GPU: %s\n" "$(lspci | grep VGA)"
    printf "Memory: %s\n" "$(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    printf "Disk: %s\n" "$main_disk"
}

# Gathers and colorizes basic system information for terminal display.
color_print() {
    local main_disk
    main_disk=$(lsblk -d -o NAME,SIZE,TYPE | awk '$3=="disk" {print $1, $2; exit}')
    printf "${COLORS[yellow]}User@Host:${COLORS[reset]} ${COLORS[blue]}%s${COLORS[reset]}@${COLORS[green]}%s${COLORS[reset]}\n" "$(whoami)" "$(hostname)"
    printf "${COLORS[yellow]}OS:${COLORS[reset]} ${COLORS[red]}%s${COLORS[reset]}\n" "$(grep '^PRETTY_NAME' /etc/os-release | cut -d= -f2 | tr -d '"')"
    printf "${COLORS[yellow]}Kernel:${COLORS[reset]} %s\n" "$(uname -r)"
    printf "${COLORS[yellow]}Uptime:${COLORS[reset]} %s\n" "$(uptime -p)"
    printf "${COLORS[yellow]}IP Addr:${COLORS[reset]} ${COLORS[purple]}%s${COLORS[reset]}\n" "$(ip a | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n1)"
    printf "${COLORS[yellow]}CPU:${COLORS[reset]} %s\n" "$(lscpu | awk -F: '/Model name/ {print $2}' | sed 's/^[ \t]*//')"
    printf "${COLORS[yellow]}GPU:${COLORS[reset]} %s\n" "$(lspci | grep VGA)"
    printf "${COLORS[yellow]}Memory:${COLORS[reset]} %s\n" "$(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    printf "${COLORS[yellow]}Disk:${COLORS[reset]} %s\n" "$main_disk"
}

# Extends summary with additional system information (routing, ports, storage).
print_full() {
    print_summary
    printf "Current Logged-In Users: %s\n" "$(who | awk '{print $1}' | sort | uniq | tr '\n' ' ')"
    printf "Routing Table: %s\n" "$(ip r | grep default | tr -s ' ')"
    printf "Listening Ports: %s\n" "$(ss -tunlp | grep LISTEN | awk '{print $5}' | tr '\n' ' ')"
    printf "Block Devices: %s\n" "$(lsblk -dno NAME,SIZE | tr '\n' ' ')"
    printf "USB Devices: %s\n" "$(lsusb | awk -F': ' '{print $2}' | tr '\n' ' ')"
    printf "Filesystem Usage: %s\n" "$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
    printf "Full Memory Usage: %s\n" "$(free -m | awk '/Mem:/ {print $3"MiB/"$2"MiB used"}')"
    printf "Kernel Info: %s\n" "$(uname -a)"
}

# Colorized version of extended system information.
color_full() {
    color_print
    printf "${COLORS[yellow]}Current Logged-In Users:${COLORS[reset]} %s\n" "$(who | awk '{print $1}' | sort | uniq | tr '\n' ' ')"
    printf "${COLORS[yellow]}Routing Table:${COLORS[reset]} %s\n" "$(ip r | grep default | tr -s ' ')"
    printf "${COLORS[yellow]}Listening Ports:${COLORS[reset]} %s\n" "$(ss -tunlp | grep LISTEN | awk '{print $5}' | tr '\n' ' ')"
    printf "${COLORS[yellow]}Block Devices:${COLORS[reset]} %s\n" "$(lsblk -dno NAME,SIZE | tr '\n' ' ')"
    printf "${COLORS[yellow]}USB Devices:${COLORS[reset]} %s\n" "$(lsusb | awk -F': ' '{print $2}' | tr '\n' ' ')"
    printf "${COLORS[yellow]}Filesystem Usage:${COLORS[reset]} %s\n" "$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
    printf "${COLORS[yellow]}Full Memory Usage:${COLORS[reset]} %s\n" "$(free -m | awk '/Mem:/ {print $3"MiB/"$2"MiB used"}')"
    printf "${COLORS[yellow]}Kernel Info:${COLORS[reset]} %s\n" "$(uname -a)"
}

# Pipes system output line-by-line into the Python logging utility.
log_with_python() {
    while read -r line; do
        # Only run if the line is not empty
        [[ -n "$line" ]] && python3 "$LOGGING_SCRIPT" --message "$line" --level INFO --quiet
    done
    printf "\n"
}

# ========================
# Pre-Parsing Sanity Check
# ========================
# If no arguments are supplied, show usage and exit.
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 --summary|--full [--log <file>] [--pylog] [--noterm]"
    exit 1
fi

# ========================
# Argument Parsing
# ========================

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    if [[ -z "$1" ]]; then
        MODE="summary"
        shift
        continue
    fi
    case $1 in
    --summary)
        MODE="summary"
        shift
        ;;
    --full)
        MODE="full"
        shift
        ;;
    --noterm)
        TERM_OUT=false
        shift
        ;;
    --log)
        LOG_FILE="$2"
        shift 2
        ;;
    --pylog)
        USE_PYTHON_LOGGER=true
        LOG_FILE="" # Clear log file if Python logger is selected
        shift
        ;;
    --help)
        echo "Usage: $0 --summary|--full [--log <file>] [--pylog] [--noterm]"
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage."
        exit 1
        ;;
    esac
done

# ========================
# Main Execution Logic
# ========================

# Decide execution based on mode and output settings
if [[ "$USE_PYTHON_LOGGER" == true ]]; then
    if [[ "$MODE" == "full" ]]; then
        print_full | log_with_python
    else
        print_summary | log_with_python
    fi
elif [[ -n "$LOG_FILE" ]]; then
    if [[ "$MODE" == "full" ]]; then
        print_full | tee -a "$LOG_FILE"
    else
        print_summary | tee -a "$LOG_FILE"
    fi
fi

if [[ "$TERM_OUT" == true ]]; then
    if [[ "$MODE" == "full" ]]; then
        color_full
        printf "\n"
    else
        color_print
        printf "\n"
    fi
fi
