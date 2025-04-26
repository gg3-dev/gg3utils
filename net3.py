#!/usr/bin/env python3
"""
GG3 Network Toolkit v0.2

A modular Python CLI tool designed for basic network, service, and security operations.

Features:
- Network connectivity tests (ping, DNS lookup)
- System service management (restart, status)
- Basic security scans (nmap)
- Color-coded output for clarity
- Simple REPL (read-eval-print loop) user interface

Author: Juan Garcia (aka 0x1G / GG3-DevNet)
Version: 0.2
"""

import os
import re
import argparse
import subprocess

# --- ANSI Color Definitions for Terminal Output ---
colors = {
    'RED': "\033[31m",
    'GREEN': "\033[32m",
    'YELLOW': "\033[33m",
    'BLUE': "\033[34m",
    'MAGENTA': "\033[35m",
    'WHITE': "\033[37m",
    'REDBACK': "\033[41m",
    'RESET': "\033[0m",
}

# --- Banner ---
def print_banner():
    """Displays a program banner."""
    print(f"""
╔══════════════════════════════════════════╗
║         {colors['REDBACK']}GG3{colors['RESET']} {colors['RED']}Network Toolkit {colors['GREEN']}v{colors['MAGENTA']}0.2{colors['RESET']}         ║
╚══════════════════════════════════════════╝
""")

# --- Menu ---
def show_menu():
    """Displays the available commands to the user."""
    print(f"""
Available Commands:

{colors['YELLOW']}[{colors['GREEN']}networking{colors['YELLOW']}]{colors['RESET']}
  networking --ping <IP>           Ping a target IP
  networking --dns <domain>        Check DNS resolution

{colors['YELLOW']}[{colors['GREEN']}services{colors['YELLOW']}]{colors['RESET']}
  services --restart <service>     Restart a system service
  services --status <service>      Check the status of a service

{colors['YELLOW']}[{colors['GREEN']}security{colors['YELLOW']}]{colors['RESET']}
  security --nmap <target>          Run a basic nmap scan

Special Commands:
  exit, quit        Exit the program
""")

# --- Core Functions ---
def do_ping(ip):
    """Pings a target IP address."""
    print(f"{colors['YELLOW']}[{colors['RESET']}NETWORKING{colors['YELLOW']}]{colors['RESET']} {colors['GREEN']}Pinging {colors['MAGENTA']}{ip}{colors['RESET']}\n")
    subprocess.call(["ping", "-c5", ip])

def check_dns(domain):
    """Performs a DNS lookup for a given domain."""
    print(f"{colors['YELLOW']}[{colors['RESET']}NETWORKING{colors['YELLOW']}]{colors['RESET']} {colors['GREEN']}Checking DNS for {colors['MAGENTA']}{domain}{colors['RESET']}\n")
    try:
        result = subprocess.run(["nslookup", domain], capture_output=True, text=True)
        output = result.stdout

        # Regex to find lines containing clean IP addresses
        matches = re.findall(r'(.*)\b(\d{1,3}(?:\.\d{1,3}){3})\b\s', output)

        interesting = ["Server", "Address"]  # Keywords to display
        found = False

        for before, ip in matches:
            before = before.strip()
            if any(keyword in before for keyword in interesting):
                label = before.split(":")[0].upper()
                print(f"{colors['YELLOW']}[{colors['RESET']}{label}{colors['YELLOW']}]{colors['RESET']} {colors['MAGENTA']}{ip}{colors['RESET']}")
                found = True

        if not found:
            print(f"{colors['YELLOW']}[{colors['RED']}!{colors['YELLOW']}] {colors['RESET']}No matching Server or Address entries found.")

    except Exception as e:
        print(f"{colors['YELLOW']}[{colors['RED']}ERROR{colors['YELLOW']}]{colors['RESET']} {colors['GREEN']}DNS lookup failed: {colors['MAGENTA']}{e}{colors['RESET']}")

def restart_service(service):
    """Restarts a given system service."""
    print(f"{colors['YELLOW']}[{colors['RESET']}SERVICES{colors['YELLOW']}]{colors['RESET']} {colors['GREEN']}Restarting {colors['MAGENTA']}{service}{colors['RESET']}")
    subprocess.call(["sudo", "systemctl", "restart", service])

def check_service_status(service):
    """Checks the status of a given system service."""
    print(f"{colors['YELLOW']}[{colors['RESET']}SERVICES{colors['YELLOW']}]{colors['RESET']} {colors['GREEN']}Checking status of {colors['MAGENTA']}{service}{colors['RESET']}")
    subprocess.call(["systemctl", "status", service])

def run_nmap(target):
    """Performs a basic aggressive nmap scan on a target."""
    print(f"{colors['YELLOW']}[{colors['RESET']}SECURITY{colors['YELLOW']}]{colors['RESET']} {colors['GREEN']}Running nmap scan on {colors['MAGENTA']}{target}{colors['RESET']}")
    with open(f"scan_{target}.txt", "w") as outfile:
        process = subprocess.Popen(["nmap", "-v", "-A", "-T4", target], stdout=subprocess.PIPE)
        for line in process.stdout:
            print(line.decode(), end="")  # Print to terminal
            outfile.write(line.decode())  # Write to file

# --- Argument Parser Setup ---
parser = argparse.ArgumentParser(
    description="GG3 Network Toolkit - Analyze, Manage, Secure your network."
)
subparsers = parser.add_subparsers(dest="command")

# Networking Commands
networking = subparsers.add_parser("networking", help="Networking operations")
networking.add_argument("--ping", help="Ping an IP address")
networking.add_argument("--dns", help="Check DNS resolution")

# Services Commands
services = subparsers.add_parser("services", help="Manage system services")
services.add_argument("--restart", help="Restart a service")
services.add_argument("--status", help="Check service status")

# Security Commands
security = subparsers.add_parser("security", help="Security operations")
security.add_argument("--nmap", help="Run a basic nmap scan")

# --- Main Program Loop ---
def main():
    """Main program loop that drives the REPL."""
    print_banner()
    show_menu()

    while True:
        try:
            user_input = input("\n> ").strip()

            if user_input.lower() in ("exit", "quit"):
                print(f"\n{colors['YELLOW']}[{colors['BLUE']}EXITING{colors['YELLOW']}] {colors['GREEN']}Goodbye!{colors['RESET']}\n")
                break

            if not user_input:
                continue  # Skip blank input

            args = parser.parse_args(user_input.split())

            # Command Handling
            if args.command == "networking":
                if args.ping:
                    do_ping(args.ping)
                if args.dns:
                    check_dns(args.dns)

            elif args.command == "services":
                if args.restart:
                    restart_service(args.restart)
                if args.status:
                    check_service_status(args.status)

            elif args.command == "security":
                if args.nmap:
                    run_nmap(args.nmap)

            print()  # Add spacing after each command
            
            # Wait for ENTER to return
            input(f"\n{colors['GREEN']}Press {colors['YELLOW']}[{colors['BLUE']}ENTER{colors['YELLOW']}]{colors['GREEN']} to return to menu...{colors['RESET']}")

            # Clear screen and show fresh banner + menu
            os.system("clear")  # or "cls" on Windows
            print_banner()
            show_menu()

        except SystemExit:
            print(f"\n{colors['YELLOW']}[{colors['RED']}ERROR{colors['YELLOW']}] {colors['GREEN']}Invalid command or missing arguments. Please try again.{colors['RESET']}")
            continue
        except KeyboardInterrupt:
            print(f"\n\n{colors['YELLOW']}[{colors['BLUE']}EXITING{colors['YELLOW']}] {colors['GREEN']}Caught {colors['MAGENTA']}Ctrl+C {colors['GREEN']}— Goodbye!{colors['RESET']}\n")
            break

# --- Program Entry Point ---
if __name__ == "__main__":
    main()
