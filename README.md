# ReconBlitz

## Overview

ReconBlitz is a powerful automated reconnaissance tool designed for penetration testers and bug bounty hunters. It performs subdomain enumeration, active scanning, and vulnerability detection efficiently using multiple reconnaissance tools.

## Features

- Automated **subdomain enumeration** using Amass, Subfinder, and Assetfinder.
- **Live subdomain detection** using Httpx.
- **Screenshot capture** of live domains with GoWitness.
- **Subdomain takeover detection** using Subjack.
- **Passive URL discovery** using Gau, Hakrawler, Waybackurls, and Katana.

## Installation

### **Requirements**
- Linux (Kali Linux preferred)
- `Go` installed
- Required tools:
  - Amass
  - Subfinder
  - Assetfinder
  - Httpx
  - GoWitness
  - Subjack
  - Gau, Hakrawler, Waybackurls, Katana

### **Setup**
To install all dependencies and set up the tool, run:

```bash
chmod +x setup.sh
./setup.sh
