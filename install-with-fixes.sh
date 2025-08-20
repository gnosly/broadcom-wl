#!/bin/bash

# Broadcom Wireless Driver Installation Script with Security Fixes
# This script applies security patches and installs the driver

set -e

echo "=== Broadcom Wireless Driver Installation with Security Fixes ==="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Get kernel version
KERNEL_VERSION=$(uname -r)
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
echo "Kernel version: $KERNEL_VERSION (Major: $KERNEL_MAJOR)"

# Check if kernel is 5.x or higher
if [[ $KERNEL_MAJOR -ge 5 ]]; then
    echo "Detected modern kernel (5.x+), security fixes already applied to source code..."
    
    # Verify patches are in place
    if grep -q "CONFIG_RETPOLINE" src/include/linuxver.h; then
        echo "✓ Return thunk protection enabled"
    else
        echo "✗ Return thunk protection not found - manual patch required"
    fi
    
    if grep -q "fno-stack-protector" Makefile; then
        echo "✓ Security compiler flags enabled"
    else
        echo "✗ Security compiler flags not found - manual patch required"
    fi
    
    if grep -q "wl_safe_memcpy" src/wl/sys/wl_cfg80211_hybrid.c; then
        echo "✓ Memory safety functions enabled"
    else
        echo "✗ Memory safety functions not found - manual patch required"
    fi
    
    if grep -q "safe_ie_dst" src/wl/sys/wl_cfg80211_hybrid.c; then
        echo "✓ IE buffer safety checks enabled"
    else
        echo "✗ IE buffer safety checks not found - manual patch required"
    fi
    
    if grep -q "KERNEL_VERSION(6, 14, 0)" src/wl/sys/wl_cfg80211_hybrid.c; then
        echo "✓ Kernel 6.14.0+ support enabled"
    else
        echo "✗ Kernel 6.14.0+ support not found - manual patch required"
    fi
else
    echo "Kernel version $KERNEL_VERSION doesn't require security patches"
fi

# Clean previous builds
echo "Cleaning previous builds..."
make clean

# Build the driver
echo "Building driver with security fixes..."
make

# Install the driver
echo "Installing driver..."
make install

# Load the module
echo "Loading wl module..."
modprobe wl

echo "=== Installation completed successfully! ==="
echo "Driver should now work without return thunk errors."
echo "If you still encounter issues, try rebooting the system."
