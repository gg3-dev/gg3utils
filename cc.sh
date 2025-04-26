#!/bin/bash

# ─────────────────────────────────────────────────────────────
# GG3 Command Center (cc.sh)
# Version 0.1
#
# Launch platform for GG3-Utils scripts.
# Author: Juan Garcia (0x1G / GG3-DevNet)
# ─────────────────────────────────────────────────────────────

# Define Dialog exit codes
: "${DIALOG_OK=0}"
: "${DIALOG_CANCEL=1}"
: "${DIALOG_ESC=255}"

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

trap ctrl_c INT

# ─────────────────────────────────────────────────────────────
# Core Functions (Wrappers for each script)
# ─────────────────────────────────────────────────────────────

function ctrl_c() {
    clear
    echo -e "\n${COLORS[yellow]}[${COLORS[blue]}CTRL+C${COLORS[yellow]}] ${COLORS[green]}Exiting GG3-Command Center...${COLORS[reset]}\n"
    exit 1
}

function Run_Net3() {
    clear
    python3 ./net3.py
    echo -e "${COLORS[green]}Press ${COLORS[yellow]}[${COLORS[blue]}ENTER${COLORS[yellow]}] ${COLORS[green]}to return to menu...${COLORS[reset]}"
    read -r
}

function Run_SysInfo() {
    clear
    summary_type=$(dialog --inputbox "Enter --full for a full summary or leave blank for basic summary:" 10 50 3>&1 1>&2 2>&3)
    exit_status=$?
    
    if [ $exit_status -eq "$DIALOG_OK" ]; then
        # Validate flag before calling the script
        if [[ "$summary_type" != "--full" && -n "$summary_type" ]]; then
            echo -e "${COLORS[red]}Invalid flag '${summary_type}'.${COLORS[reset]} Defaulting to basic summary..."
            summary_type=""
        fi

        # Call sys_info.sh with validated input
        clear
        bash ./sys_info.sh "$summary_type"

        echo -e "${COLORS[green]}Press ${COLORS[yellow]}[${COLORS[blue]}ENTER${COLORS[yellow]}] ${COLORS[green]}to return to menu...${COLORS[reset]}"
        read -r
    fi
}

function Run_QuickNetDiag() {
    clear
    bash ./quick_net_diag.sh
}

function Run_PortScanner() {
    clear
    ip=$(dialog --inputbox "Enter target IP or domain for port scan:" 10 50 3>&1 1>&2 2>&3)
    exit_status=$?
    if [ $exit_status -eq "$DIALOG_OK" ]; then
        clear
        python3 ./port_scanner.py --target "$ip"
        echo -e "${COLORS[green]}Press ${COLORS[yellow]}[${COLORS[blue]}ENTER${COLORS[yellow]}] ${COLORS[green]}to return to menu...${COLORS[reset]}"
        read -r
    else
        clear
        echo "${COLORS[yellow]}[${COLORS[red]}CANCELLED${COLORS[yellow]}]${COLORS[reset]} Port scan aborted."
    fi
}

function Run_ServiceChecker() {
    clear
    services=$(dialog --inputbox "Enter service names to check (comma-separated) or leave blank for defaults:" 10 60 3>&1 1>&2 2>&3)
    exit_status=$?
    if [ $exit_status -eq "$DIALOG_OK" ]; then
        if [ -z "$services" ]; then
            clear
            python3 ./service_checker.py
        else
            clear
            python3 ./service_checker.py --services "$services"
        fi
    else
        clear
        echo "${COLORS[yellow]}[${COLORS[red]}CANCELLED${COLORS[yellow]}]${COLORS[reset]} Service check aborted."
    fi
}

function Run_LoggingUtils() {
    clear
    dev_comment=$(dialog --inputbox "Enter DEV Comment to Log:" 10 60 3>&1 1>&2 2>&3)
    exit_status=$?
    if [ $exit_status -eq "$DIALOG_OK" ]; then
        clear
        python3 ./logging_utils.py --message "$dev_comment" --level DEV
        echo -e "${COLORS[green]}Press ${COLORS[yellow]}[${COLORS[blue]}ENTER${COLORS[yellow]}] ${COLORS[green]}to return to menu...${COLORS[reset]}"
        read -r
    else
        clear
        echo "${COLORS[yellow]}[${COLORS[red]}CANCELLED${COLORS[yellow]}]${COLORS[reset]} ${COLORS[purple]}DEV${COLORS[reset]} comment creation aborted."
    fi
}

clear
echo -e "

 ██████╗  ██████╗ ██████╗       ██████╗ ███████╗██╗   ██╗
██╔════╝ ██╔════╝ ╚════██╗      ██╔══██╗██╔════╝██║   ██║
██║  ███╗██║  ███╗ █████╔╝█████╗██║  ██║█████╗  ██║   ██║
██║   ██║██║   ██║ ╚═══██╗╚════╝██║  ██║██╔══╝  ╚██╗ ██╔╝
╚██████╔╝╚██████╔╝██████╔╝      ██████╔╝███████╗ ╚████╔╝ 
 ╚═════╝  ╚═════╝ ╚═════╝       ╚═════╝ ╚══════╝  ╚═══╝                           
                                ${COLORS[red]}GG3 ${COLORS[yellow]}Command Center ${COLORS[green]}v${COLORS[purple]}0.1"
echo -e "${COLORS[reset]}"
sleep 3


# ─────────────────────────────────────────────────────────────
# Infinite Menu Loop
# ─────────────────────────────────────────────────────────────

while true; do
    exec 3>&1
    CHOICE=$(dialog --clear --backtitle "GG3-Utils Command Center" \
        --title "[ MAIN MENU ]" \
        --ok-label "SELECT" --cancel-label "EXIT" \
        --menu "Choose a script to run:" 15 50 8 \
        1 "Run GG3 Net3 Toolkit" \
        2 "Show System Info" \
        3 "Run Quick Network Diagnostics" \
        4 "Run Port Scanner" \
        5 "Run Service Checker" \
        6 "Run Logging Utils (Manual log creation)" \
        2>&1 1>&3)

    exit_status=$?
    exec 3>&-

    case $exit_status in
    "$DIALOG_CANCEL" | "$DIALOG_ESC")
        clear
        echo -e "${COLORS[yellow]}[${COLORS[blue]}EXITING${COLORS[reset]} ${COLORS[red]}GG3-Command Center${COLORS[yellow]}] ${COLORS[green]}Goodbye${COLORS[reset]}, ${COLORS[purple]}$USER${COLORS[reset]}!"
        exit
        ;;
    esac

    case $CHOICE in
    1)
        Run_Net3
        ;;
    2)
        Run_SysInfo
        ;;
    3)
        Run_QuickNetDiag
        ;;
    4)
        Run_PortScanner
        ;;
    5)
        Run_ServiceChecker
        ;;
    6)
        Run_LoggingUtils
        ;;
    esac

done
