#!/bin/bash

# Check if a domain argument is provided

export PATH=$PATH:/home/kali/go/bin



if [ $# -ne 2 ]; then

  echo "Usage: $0 <domain folder> <subdomain>"

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

IFS='.' read -r -a subparts <<< "$2"



# Store the first part of the domain

part1="${parts[0]}"

part2="${parts[1]}"

subpart1="${subparts[0]}"

subpart2="${subparts[1]}"





path="/home/kali/Desktop/targets/$part1"



dir_path="/home/kali/Desktop/targets/$part1/$subpart1"



# Check if the directory exists

if [ -d "$path" ]; then

  echo "[*] Directory $path already exists ...."

else

  # Create the directory

  mkdir -p "$path"

  echo "[+] Directory $path created ...."

fi



# Check if the sub directory exists

if [ -d "$dir_path" ]; then

  echo "[*] Directory $dir_path already exists ...."

else

  # Create the directory

  mkdir -p "$dir_path"

  echo "[+] Directory $dir_path created ...."

fi



echo "[+] Passive hunting for URLs ...."

echo "$2" | (gau --subs || waybackurls) > "$dir_path/urls.txt"

cat "$dir_path/urls.txt" | httpx-toolkit -nc -silent | tee -a "$dir_path/active-urls.txt"



#Crawling Active URLS

echo "[+] Crawl URLS from the active urls ...."

gospider -S "$dir_path/active-urls.txt" -d 5 -c 10 --sitemap --no-redirect > "$dir_path/gospider.txt"



# Gospider output fetcher



echo "[+] creating URL DIV ...."

mkdir -p "$dir_path/urls-div"

# Gospider division of urls

input_file="$dir_path/gospider.txt"  # Replace with your actual file



while IFS= read -r line; do

    if [[ $line =~ \[([^][]+)\] ]]; then

        current_name="${BASH_REMATCH[1]}"

        output_file="$dir_path/urls-div/${current_name}.txt"

    fi

    echo "$line" >> "$output_file"

done < "$input_file"



#FeroxBuster Doing Busting using wordlist

echo "[+] feroxbuster doing directory Busting ...."

echo "$2" | feroxbuster --stdin --silent -o "$dir_path/feroxbusting.txt" -E -B -g -t 100 --time-limit 10m -C 404,400,500



#Unique urls 

echo "[+] unique URLS form all sources ...."

cat "$dir_path/feroxbusting.txt" "$dir_path/gospider.txt" "$dir_path/active-urls.txt" | uniq | sort -u > "$dir_path/uniq-active-urls.txt"

