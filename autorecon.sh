#!/bin/bash

set -e

# ========== Colors ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# ========== Help Menu ==========
function show_help() {
    echo -e "${YELLOW}Usage:${NC} $0 -d <domain> [--quick]"
    echo -e "  -d, --domain         Target domain"
    echo -e "  --quick              Quick mode (skips screenshots and heavy scans)"
    exit 1
}

# ========== Argument Parsing ==========
DOMAIN=""
QUICK=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        --quick)
            QUICK=true
            shift
            ;;
        *)
            show_help
            ;;
    esac
done

if [[ -z "$DOMAIN" ]]; then
    show_help
fi

# ========== Directories ==========
OUTDIR="recon0/$DOMAIN"
mkdir -p "$OUTDIR"/{logs,nuclei,ports,screenshots,js,ffuf}

# ========== Tool Check ==========
function check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[!] $1 not found. Attempting to install...${NC}"
        go install github.com/projectdiscovery/$1/v2/cmd/$1@latest 2>/dev/null || go install github.com/projectdiscovery/$1/cmd/$1@latest
        echo -e "${GREEN}[+] Installed $1${NC}"
    else
        echo -e "${GREEN}[+] Found tool: $1${NC}"
    fi
}

echo -e "${BLUE}[*] Checking required tools...${NC}"
check_tool subfinder
check_tool naabu
check_tool nuclei
check_tool dnsx
check_tool gau
check_tool gowitness
check_tool ffuf

# ========== Nuclei Templates ==========
if [ ! -d "$HOME/nuclei-templates" ]; then
    echo -e "${YELLOW}[~] Nuclei templates not found. Downloading...${NC}"
    git clone https://github.com/projectdiscovery/nuclei-templates.git "$HOME/nuclei-templates"
else
    echo -e "${GREEN}[+] Nuclei templates already present.${NC}"
fi

# ========== Subfinder ==========
echo -e "${BLUE}[*] Running subfinder...${NC}"
subfinder -d "$DOMAIN" -all -silent -o "$OUTDIR/subdomains.txt"

# ========== Naabu ==========
echo -e "${BLUE}[*] Running naabu for ports...${NC}"
naabu -list "$OUTDIR/subdomains.txt" -o "$OUTDIR/ports/ports.txt" -silent

# ========== Nuclei ==========
echo -e "${BLUE}[*] Running nuclei vulnerability scans...${NC}"
nuclei -l "$OUTDIR/subdomains.txt" -t "$HOME/nuclei-templates" -o "$OUTDIR/nuclei/results.txt" || echo -e "${RED}[!] nuclei failed${NC}"

# ========== DNSx ==========
echo -e "${BLUE}[*] Running dnsx DNS probing...${NC}"
dnsx -l "$OUTDIR/subdomains.txt" -silent -a -o "$OUTDIR/active_subdomains.txt"

# ========== GAU ==========
echo -e "${BLUE}[*] Running gau to gather URLs...${NC}"
gau -subs "$DOMAIN" | tee "$OUTDIR/urls.txt"

# ========== Gowitness ==========
if [ "$QUICK" = false ]; then
    echo -e "${BLUE}[*] Running gowitness to screenshot URLs...${NC}"
    gowitness file -f "$OUTDIR/active_subdomains.txt" --destination "$OUTDIR/screenshots" || echo -e "${RED}[!] gowitness failed${NC}"
else
    echo -e "${YELLOW}[~] Skipping screenshots (--quick enabled)${NC}"
fi

# ========== FFUF ==========
echo -e "${BLUE}[*] Running ffuf for fuzzing...${NC}"
ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt \
     -u http://$DOMAIN/FUZZ \
     -mc 200,301,302,307,401,403,405,500 \
     -of json -o "$OUTDIR/ffuf.json" || echo -e "${RED}[!] ffuf failed${NC}"

# ========== Done ==========
echo -e "${GREEN}[✔] Reconnaissance completed for $DOMAIN${NC}"
echo -e "${GREEN}[✔] Output saved in $OUTDIR${NC}"
