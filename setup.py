#!/usr/bin/env python3

import shutil
import subprocess
import sys
import os
from pathlib import Path

GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
RESET = "\033[0m"

REQUIRED_TOOLS = [
    "subfinder",
    "dnsx",
    "httpx",
    "naabu",
    "nuclei"
]

OPTIONAL_TOOLS = [
    "gau",
    "gowitness",
    "ffuf"
]

def info(msg):
    print(f"{GREEN}[+] {msg}{RESET}")

def warn(msg):
    print(f"{YELLOW}[!] {msg}{RESET}")

def error(msg):
    print(f"{RED}[✗] {msg}{RESET}")
    sys.exit(1)

def is_installed(tool):
    return shutil.which(tool) is not None

def verify_tools():
    info("Verifying required tools are installed...")
    missing = []
    for t in REQUIRED_TOOLS:
        if is_installed(t):
            info(f"{t} found")
        else:
            missing.append(t)
    if missing:
        error(f"Missing required tools: {', '.join(missing)}. Run bootstrap.sh first.")
    else:
        info("All required tools present.")

def optional_tools_status():
    info("Checking optional tools...")
    for t in OPTIONAL_TOOLS:
        if is_installed(t):
            info(f"{t} found")
        else:
            warn(f"{t} not found (optional)")

def update_nuclei_templates():
    # If nuclei supports template update
    if is_installed("nuclei"):
        info("Updating nuclei templates (if applicable)...")
        try:
            subprocess.run(["nuclei", "-update-templates"], check=True)
        except subprocess.CalledProcessError:
            warn("Failed to update nuclei templates.")
    else:
        warn("nuclei not installed; skipping template update.")

def main():
    info("Running post‑setup verification...")
    verify_tools()
    optional_tools_status()
    update_nuclei_templates()
    info("Setup.py done. Ready to run autorecon.sh.")

if __name__ == "__main__":
    main()
