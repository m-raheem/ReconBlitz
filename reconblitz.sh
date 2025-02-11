#!/bin/bash
# Check if a domain argument is provided

export PATH=$PATH:/home/kali/go/bin

if [ $# -eq 0 ]; then
  echo "Usage: $0 <domain>"
  exit 1
fi

# Define a cleanup function
cleanup() {
    echo "Cleaning up..."
    # Add any cleanup commands here if needed
    exit 0
}

# Trap Ctrl + C (SIGINT) and call cleanup function
trap cleanup SIGINT

# Split the domain based on the . delimiter
IFS='.' read -r -a parts <<< "$1"

# Store the first part of the domain
part1="${parts[0]}"
part2="${parts[1]}"

dir_path="/home/kali/Desktop/targets/$part1"
dir_screenshot="$dir_path/screenshot"

# Check if the directory exists
if [ -d "$dir_path" ]; then
  echo "[*] Directory $dir_path already exists ...."
else
  # Create the directory
  mkdir -p "$dir_path"
  echo "[+] Directory $dir_path created ...."
fi

mkdir -p $dir_screenshot

# Run Amass scan
echo "[+] running Amass subdomain scan ...."
amass enum -d "$1" -brute -min-for-recursive 3 -active -r 8.8.8.8,1.1.1.1 -w /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt -timeout 5 -max-dns-queries 100 -p 80,443 -nocolor -o "$dir_path/amass-subdomain.txt" -if ~/.config/amass/datastore.yaml >> /dev/null

# Filter and sort Amass scan results
cat "$dir_path/amass-subdomain.txt" | grep -oE "([a-zA-Z0-9_-]+\.)*$1" | sort -u > "$dir_path/found-subdomains.txt"

#Run Subfinder
echo "[+] running Subfinder subdomain scan ...."
subfinder -d "$1" -silent >> "$dir_path/subfinder-domain.txt"
cat "$dir_path/subfinder-domain.txt" | sort -u  >> "$dir_path/found-subdomains.txt"

#Run AssetFinder
echo "[+] running Assetfinder subdomain scan ...."
assetfinder "$1" > "$dir_path/assetfinder-subdomain.txt" 

cat "$dir_path/assetfinder-subdomain.txt" | grep -oE "([a-zA-Z0-9_-]+\.)*$1" | sort -u >> "$dir_path/found-subdomains.txt"

# CHeck ALIVE DOMAINS
cat "$dir_path/found-subdomains.txt" | sort -u > "$dir_path/subdomains.txt"
echo "[+] Subdomains for $1 saved at : $dir_path/subdomains.txt ...."

echo "[*] Total Alive Subdomains : "

cat "$dir_path/subdomains.txt" | httpx-toolkit -fc 404 -silent | awk -F/ '{print $3}' | tee -a "$dir_path/alive-subdomains.txt" | wc -l  
echo "[+] Alive subdomains for $1 saved at : $dir_path/alive-subdomains.txt ...."

#ScreenShots
echo "[+] GoWitness started taking screenshots of all alive HOSTS and will be saved in $dir_path/screenshot...."
gowitness file -f "$dir_path/alive-subdomains.txt" -P $dir_screenshot --timeout 20

#Subdomain TakerOver
echo "[+] Subdomain takerover using subjacker ...."
subjack -w "$dir_path/alive-subdomains.txt" -t 100 -timeout 30 -ssl -v 3 -o "$dir_path/subdomain-takeover.txt"

echo "[+] Passive hunting for URLs ...."
cat "$dir_path/alive-subdomains.txt" | (gau || hakrawler || waybackurls || katana) | httpx-toolkit -nc -silent | tee -a "$dir_path/active-urls.txt"



