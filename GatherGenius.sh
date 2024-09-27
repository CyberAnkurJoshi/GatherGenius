#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Tool information
TOOL_NAME="Gather Genius"
LINKEDIN_URL="https://www.linkedin.com/in/theankurjoshi"  # Replace with your LinkedIn URL

# Print tool information in large text
echo -e "${GREEN}=== $(figlet -f slant "$TOOL_NAME") ===${NC}"
echo -e "${YELLOW}Created by: $LINKEDIN_URL${NC}"
echo

# Check for required commands
for cmd in dig whois amass nmap openssl nikto wpscan subfinder assetfinder dnsx gobuster dirb; do
    command -v $cmd >/dev/null 2>&1 || { echo -e "${RED}$cmd is not installed. Exiting.${NC}"; exit 1; }
done

# Check for optional command whatweb
if ! command -v whatweb >/dev/null 2>&1; then
    echo -e "${RED}Error: whatweb is not installed.${NC}"
    echo -e "${YELLOW}You can install it using one of the following commands:${NC}"
    echo -e "${YELLOW}For Debian/Ubuntu: sudo apt install whatweb${NC}"
    echo -e "${YELLOW}For Fedora: sudo dnf install whatweb${NC}"
    echo -e "${YELLOW}For Arch Linux: sudo pacman -S whatweb${NC}"
    echo -e "${YELLOW}For macOS (using Homebrew): brew install whatweb${NC}"
    echo -e "${YELLOW}Please install whatweb and run the script again for proper functioning.${NC}"
    exit 1
fi

# Retry mechanism for commands
function retry_command() {
    local retries=3
    local count=0
    local command="$1"

    until $command; do
        exit_status=$?
        count=$((count + 1))
        if [ $count -ge $retries ]; then
            echo -e "${RED}Command failed after $retries attempts: $command${NC}"
            return $exit_status
        fi
        echo -e "${YELLOW}Retrying... ($count/$retries)${NC}"
        sleep 2
    done
}

# Function to gather DNS records
function get_dns_records() {
    echo -e "${GREEN}=== DNS Records for $1 ===${NC}"
    retry_command "dig +short A $1"
    retry_command "dig +short MX $1"
    retry_command "dig +short NS $1"
    retry_command "dig +short TXT $1"
    retry_command "dig +short CNAME $1"
    echo
}

# Function to gather WHOIS information
function get_whois_info() {
    echo -e "${GREEN}=== WHOIS Information for $1 ===${NC}"
    retry_command "whois $1"
    echo
}

# Function to find subdomains using Amass, Subfinder, Assetfinder, and DNSX
function find_subdomains() {
    echo -e "${GREEN}=== Subdomains for $1 ===${NC}"
    echo -e "${YELLOW}Using Amass:${NC}"
    amass enum -d $1 | while read -r subdomain; do
        ip=$(dig +short "$subdomain")
        if [ -n "$ip" ]; then
            echo "$subdomain --> $ip"
        fi
    done

    echo -e "${YELLOW}Using Subfinder:${NC}"
    subfinder -d $1 | while read -r subdomain; do
        ip=$(dig +short "$subdomain")
        if [ -n "$ip" ]; then
            echo "$subdomain --> $ip"
        fi
    done

    echo -e "${YELLOW}Using Assetfinder:${NC}"
    assetfinder --subs-only $1 | while read -r subdomain; do
        ip=$(dig +short "$subdomain")
        if [ -n "$ip" ]; then
            echo "$subdomain --> $ip"
        fi
    done

    echo -e "${YELLOW}Using DNSX:${NC}"
    dnsx -d $1 | while read -r subdomain; do
        ip=$(dig +short "$subdomain")
        if [ -n "$ip" ]; then
            echo "$subdomain --> $ip"
        fi
    done

    echo
}

# Function for Google dorking
function google_dorking() {
    echo -e "${GREEN}=== Google Dorking for $1 ===${NC}"
    query="site:$1"
    echo -e "${YELLOW}Search results for: $query${NC}"
    curl -s "https://www.google.com/search?q=$query" | grep -oP '(?<=<h3 class="zBAuLc">).*?(?=</h3>)'
    echo
}

# Function for advanced network scanning
function advanced_network_scanning() {
    echo -e "${GREEN}=== Advanced Network Scanning for $1 ===${NC}"
    echo -e "${YELLOW}Running Nmap scan...${NC}"
    retry_command "nmap -A -T4 $1"
    echo
}

# Function for reverse IP lookup
function reverse_ip_lookup() {
    echo -e "${GREEN}=== Reverse IP Lookup for $1 ===${NC}"
    ip=$(dig +short A $1)
    echo -e "${YELLOW}IP Address: $ip${NC}"
    echo -e "${YELLOW}Other domains hosted on this IP:${NC}"
    curl -s "https://api.hackertarget.com/reverseiplookup/?q=$ip"
    echo
}

# Function to get SSL certificate information
function get_ssl_info() {
    echo -e "${GREEN}=== SSL Certificate Information for $1 ===${NC}"
    echo | openssl s_client -connect $1:443 -servername $1 2>/dev/null | openssl x509 -noout -text
    echo
}

# Function to detect web technologies
function detect_web_technologies() {
    echo -e "${GREEN}=== Web Technologies for $1 ===${NC}"
    whatweb $1
    echo
}

# Function for vulnerability scanning with Nikto and WPScan
function vulnerability_scanning() {
    echo -e "${GREEN}=== Vulnerability Scanning for $1 ===${NC}"
    echo -e "${YELLOW}Running Nikto scan...${NC}"
    retry_command "nikto -h $1"

    # Check if WPScan is applicable (only for WordPress sites)
    echo -e "${YELLOW}Running WPScan (if applicable)...${NC}"
    retry_command "wpscan --url $1 --no-banner"
    echo
}

# Function for content discovery using Gobuster
function content_discovery() {
    echo -e "${GREEN}=== Content Discovery for $1 ===${NC}"
    echo -e "${YELLOW}Using Gobuster:${NC}"
    gobuster dir -u "http://$1" -w /path/to/wordlist.txt -t 50
    echo
}

# Function for social media scraping
function social_media_scraping() {
    echo -e "${GREEN}=== Social Media Accounts for $1 ===${NC}"
    echo -e "${YELLOW}Searching for social media accounts...${NC}"

    # Example of social media platforms to check
    platforms=("facebook.com" "twitter.com" "linkedin.com" "instagram.com" "github.com")

    for platform in "${platforms[@]}"; do
        echo -e "${YELLOW}Checking for $platform...${NC}"
        if curl -s "https://$platform/$1" --head | grep "200 OK" >/dev/null; then
            echo "Found: https://$platform/$1"
        else
            echo "Not found: https://$platform/$1"
        fi
    done
    echo
}

# Function for traceroute
function perform_traceroute() {
    echo -e "${GREEN}=== Traceroute to $1 ===${NC}"
    retry_command "traceroute $1"
    echo
}

# Function for ping sweep
function ping_sweep() {
    echo -e "${GREEN}=== Ping Sweep for $1 ===${NC}"
    for i in {1..254}; do
        ip="$1.$i"
        if ping -c 1 -W 1 $ip >/dev/null; then
            echo "$ip is up"
        else
            echo "$ip is down"
        fi
    done
    echo
}

# Main script execution
if [ $# -eq 0 ]; then
    echo -e "${RED}Usage: $0 <domain>${NC}"
    exit 1
fi

DOMAIN=$1

get_dns_records $DOMAIN
get_whois_info $DOMAIN
find_subdomains $DOMAIN
google_dorking $DOMAIN
advanced_network_scanning $DOMAIN
reverse_ip_lookup $DOMAIN
get_ssl_info $DOMAIN
detect_web_technologies $DOMAIN
vulnerability_scanning $DOMAIN
content_discovery $DOMAIN
social_media_scraping $DOMAIN
perform_traceroute $DOMAIN
ping_sweep $DOMAIN
