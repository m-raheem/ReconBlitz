#!/bin/bash

echo "Setting up ReconBlitz..."
echo "Updating package lists..."
sudo apt update -y

echo "Installing Go..."
sudo apt install -y golang

echo "Setting up Go environment..."
export PATH=$PATH:/usr/local/go/bin
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

echo "Installing required tools..."
go install -v github.com/OWASP/Amass/v3/...@master
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/sensepost/gowitness@latest
go install -v github.com/haccer/subjack@latest
go install -v github.com/lc/gau@latest
go install -v github.com/hakluke/hakrawler@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest

echo "Moving script to /usr/local/bin/..."
sudo mv reconblitz.sh /usr/local/bin/reconblitz
sudo chmod +x /usr/local/bin/reconblitz

echo "Installation completed!"
echo "To start using ReconBlitz, run: ./reconblitz.sh <domain>"
