#!/usr/bin/env python3

"""
logging_utils.py

Provides the log_event() function for standardized, colorized event logging.

Appends timestamped log entries to a logfile and prints color-coded messages
to the console. Supports INFO, WARNING, ERROR, and DEBUG levels.
Handles permission errors safely during file writes.

Author: Juan Garcia (aka 0x1G / GG3-DevNet)
Created: 2025-04-17
"""

import argparse
from datetime import datetime

# ANSI color codes for terminal output
colors = {
    "RED": "\033[31m",
    "GREEN": "\033[32m",
    "YELLOW": "\033[33m",
    "BLUE": "\033[34m",
    "MAGENTA": "\033[35m",
    "WHITE": "\033[37m",
    "REDBACK": "\033[41m",
    "WHITEBACK": "\033[47m",
    "DEVBOLD": "\033[1;30;47m",
    "RESET": "\033[0m",
}

# Mapping of log levels to their respective colors
level_colors = {
    "INFO": colors["WHITE"],
    "WARNING": colors["YELLOW"],
    "ERROR": colors["RED"],
    "DEBUG": colors["BLUE"],
    "CRITICAL": colors["REDBACK"],
    "DEV": colors["DEVBOLD"]
}

def log_event(message, level="INFO", logfile="gg3utils.log", quiet=False):
    """
    Appends a timestamped log entry to the specified logfile.

    Args:
        message (str): The log message to record.
        level (str, optional): The severity level of the event.
            One of: "INFO", "WARNING", "ERROR", "DEBUG". Defaults to "INFO".
        logfile (str, optional): Path to the logfile. Defaults to "gg3utils.log".

    Format:
        [YYYY-MM-DD HH:MM:SS] [LEVEL]: message
    """
    
    # Choose color based on log level
    level_color = level_colors.get(level, colors["WHITE"])

    # Generate current timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Format log line for file output
    log_line = f"[{timestamp}] [{level}]: {message}\n"

    try:
        # Append log line to the logfile
        with open(logfile, "a") as f:
            f.write(log_line)

            # Print the log event to console with colors
            if not quiet:
            # Only print if not quiet
                print(
                    f'{colors["WHITE"]}[{colors["MAGENTA"]}{timestamp}{colors["WHITE"]}] '
                    f'{colors["WHITE"]}[{level_color}{level}{colors["RESET"]}{colors["WHITE"]}]: '
                    f'{colors["WHITE"]}"{colors["GREEN"]}{message}{colors["WHITE"]}"{colors["RESET"]}'
                )
    except PermissionError as e:
        # Handle permission error during file write
        print(f"{type(e)}: {str(e).capitalize()}")
        raise

def main():
    parser = argparse.ArgumentParser(description="Log an event with a message and severity level.")
    parser.add_argument("--message", "-m", required=True, help="Message to log.")
    parser.add_argument("--level", "-l", default="INFO", choices=["INFO", "WARNING", "ERROR", "DEBUG", "CRITICAL", "DEV"], help="Log level.")
    parser.add_argument("--logfile", "-f", default="gg3utils.log", help="Path to logfile.")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress console output.")
    
    args = parser.parse_args()
    
    log_event(args.message, level=args.level, logfile=args.logfile, quiet=args.quiet)

if __name__ == "__main__":
    main()