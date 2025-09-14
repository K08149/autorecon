#!/usr/bin/env bash
set -e

# ─── Colors ───────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}[+] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[✗] $1${NC}"; exit 1; }

# ─── 1. Update and install core APT packages ───
info "Updating package lists..."
sudo apt update -y

APT_PKGS=(
  git
  curl
  wget
  unzip
  python3
  python3-venv
  python3-pip
  golang
  libpcap-dev
  jq
  ffuf
)

info "Installing system packages (APT)..."
for pkg in "${APT_PKGS[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    info "$pkg is already installed."
  else
    sudo apt install -y "$pkg" || warn "Failed to install $pkg"
  fi
done

# ─── 2. Ensure Go works ───────────
if ! command -v go &>/dev/null; then
  error "Go was not installed properly or not in PATH. Please check installation."
fi
info "Go is installed: $(go version)"

# ─── 3. Setup Go paths ─────────────
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
mkdir -p "$GOBIN"
export PATH="$PATH:$GOBIN"

# Ensure PATH is updated in bashrc
if ! grep -q 'export PATH=.*$HOME/go/bin' "$HOME/.bashrc"; then
  info "Adding \$HOME/go/bin to PATH in ~/.bashrc"
  echo "" >> ~/.bashrc
  echo "export PATH=\$PATH:\$HOME/go/bin" >> ~/.bashrc
fi

# ─── 4. Install Go‑based recon tools ─────────────
GO_TOOLS=(
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/lc/gau/v2/cmd/gau@latest"
  "github.com/sensepost/gowitness@latest"
)

info "Installing Go‑based recon tools. This may take several minutes..."
for tool in "${GO_TOOLS[@]}"; do
  TOOL_NAME=$(basename "${tool%%@*}")
  if command -v "$TOOL_NAME" &>/dev/null; then
    info "$TOOL_NAME is already installed."
  else
    info "Installing $TOOL_NAME..."
    GO111MODULE=on go install "$tool" \
      || warn "Failed to install $tool"
  fi
done

# ─── 5. Setup Python venv and requirements ───
if [ ! -d "venv" ]; then
  info "Creating Python virtual environment 'venv'..."
  python3 -m venv venv
else
  info "Virtual environment 'venv' already exists."
fi

info "Activating venv and installing Python requirements..."
# shellcheck disable=SC1091
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

info "Bootstrap complete. Please open a new terminal or run: source ~/.bashrc"
info "Then you can run: ./autorecon.sh -d <domain> [-v] [-q]"
