#!/bin/bash

echo "Setting up ReconBlitz..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Updating package lists..."
sudo apt update -y

echo "Checking and Installing Go..."
if ! command_exists go; then
    sudo apt install -y golang
    echo "Setting up Go environment..."
    export PATH=$PATH:/usr/local/go/bin
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc
else
    echo "Go is already installed."
fi

echo "Installing required tools..."
declare -A tools=(
    ["amass"]="github.com/OWASP/Amass/v3/...@master"
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    ["assetfinder"]="github.com/tomnomnom/assetfinder@latest"
    ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    ["gowitness"]="github.com/sensepost/gowitness@latest"
    ["subjack"]="github.com/haccer/subjack@latest"
    ["gau"]="github.com/lc/gau@latest"
    ["hakrawler"]="github.com/hakluke/hakrawler@latest"
    ["waybackurls"]="github.com/tomnomnom/waybackurls@latest"
    ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
)

for tool in "${!tools[@]}"; do
    if ! command_exists "$tool"; then
        echo "Installing $tool..."
        go install -v "${tools[$tool]}"
    else
        echo "$tool is already installed."
    fi
done

echo "Moving script to /usr/local/bin/..."
sudo mv reconblitz.sh /usr/local/bin/reconblitz
sudo chmod +x /usr/local/bin/reconblitz

echo "Installation completed!"
echo "To start using ReconBlitz, run: reconblitz <domain>"
