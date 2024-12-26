#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# System Update Status
print_header "System Update Status"
if pacman -Qu > /dev/null 2>&1; then
    echo -e "${YELLOW}System updates available:${NC}"
    pacman -Qu | wc -l
else
    echo -e "${GREEN}System is up to date${NC}"
fi

# Disk Space
print_header "Disk Space Usage"
df -h / | awk 'NR==2 {print $5 " used (" $4 " free)"}'
DISK_USAGE=$(df -h / | awk 'NR==2 {sub(/%/,""); print $5}')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo -e "${RED}Warning: Low disk space!${NC}"
fi

# Memory Usage
print_header "Memory Status"
free -h | awk '/^Mem:/ {print "Total: " $2 "\nUsed: " $3 "\nFree: " $4 "\nBuffers/Cache: " $6}'

# System Load
print_header "System Load"
uptime | awk '{print "Load Average: " $(NF-2), $(NF-1), $NF}'

# Failed Services
print_header "Failed Services"
systemctl --failed

# Journal Errors
print_header "Recent System Errors"
journalctl -p 3 -b | tail -n 5

# Pacman Package Cache
print_header "Package Cache Status"
du -sh /var/cache/pacman/pkg/
echo "Number of packages in cache: $(find /var/cache/pacman/pkg/ -mindepth 1 -maxdepth 1 | wc -l)"

# Check for common issues
print_header "System Checks"

# Check for broken packages
if pacman -Qk > /dev/null 2>&1; then
    echo -e "${GREEN}No broken packages found${NC}"
else
    echo -e "${RED}Broken packages detected${NC}"
fi

# Check for orphaned packages
ORPHANS=$(pacman -Qtdq)
if [ -z "$ORPHANS" ]; then
    echo -e "${GREEN}No orphaned packages found${NC}"
else
    echo -e "${YELLOW}Orphaned packages found:${NC}"
    echo "$ORPHANS"
fi

# Check systemd-boot configuration if present
if command_exists bootctl; then
    print_header "Boot Configuration"
    bootctl status
fi

# Check important logs for errors
print_header "Important Log Files"
for log in /var/log/pacman.log /var/log/Xorg.0.log; do
    if [ -f "$log" ]; then
        echo -e "\nChecking $log for errors..."
        grep -i "error" "$log" | tail -n 3
    fi
done

# Network Status
print_header "Network Status"
ip a | grep "state UP" -A2

# Check for large files
print_header "Large Files (>1GB)"
find / -type f -size +1G -exec ls -lh {} \; 2>/dev/null

echo -e "\n${GREEN}Health check completed!${NC}"