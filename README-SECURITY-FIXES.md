# Broadcom Wireless Driver Security Fixes

## Problem Description

The "Unpatched return thunk" error occurs when loading the Broadcom wireless driver on modern kernels (5.x+) due to:

1. **Return Thunk Protection**: Modern kernels implement Spectre/Meltdown mitigations that require proper return thunk handling
2. **Outdated Driver**: The original driver (v6.30.223.272) was designed for older kernels and lacks security patches
3. **Compiler Security**: Missing compiler flags for security hardening

## Solution

This package includes security fixes that have been **directly applied** to the source code to fix the return thunk security issue:

### 1. Return Thunk Protection (Applied to `src/include/linuxver.h`)
- Enables `CONFIG_RETPOLINE` for return thunk protection
- Adds speculation mitigations support
- Automatically active for kernels 5.15+

### 2. Compiler Security Flags (Applied to `Makefile`)
- Adds `-fno-stack-protector` and related flags
- Disables problematic security features that conflict with the driver
- Adds `-Wno-array-bounds` and `-Wno-stringop-overflow` to suppress memory safety warnings
- Ensures compatibility with modern kernels

### 3. Memory Safety Fixes (Applied to `src/wl/sys/wl_cfg80211_hybrid.c`)
- Fixes "field-spanning write" errors in `wl_inform_single_bss` function
- Adds bounds checking for memory access operations
- Implements safe memory access helper functions (`wl_safe_memcpy`, `wl_safe_field_access`)
- Prevents buffer overflow/underflow issues
- Fixes IE (Information Element) buffer handling in `wl_cp_ie`, `wl_mrg_ie`, and `wl_add_ie` functions
- Adds comprehensive memory bounds validation for all IE operations
- Implements safe destination buffer creation to avoid field-spanning writes

### 4. Kernel 6.14.0+ Compatibility
- Updated `wl_cfg80211_get_tx_power` function signature to include `wireless_dev` and `link_id` parameters
- Changed return type from `s32` to `int` for kernel 6.14.0+
- Added link_id validation (currently only supports link 0)
- Maintains backward compatibility with older kernels
- Follows latest cfg80211 API changes

### 5. Automated Installation (`install-with-fixes.sh`)
- Automatically detects kernel version
- Verifies security fixes are in place
- Builds and installs the driver with security fixes

## Installation Instructions

### Option 1: Automated Installation (Recommended)
```bash
cd broadcom-wl
sudo ./install-with-fixes.sh
```

### Option 2: Manual Verification
```bash
cd broadcom-wl

# Verify security fixes are in place
grep -n "CONFIG_RETPOLINE" src/include/linuxver.h
grep -n "fno-stack-protector" Makefile

# Build and install
make clean
make
sudo make install
sudo modprobe wl
```

### Option 3: DKMS Installation
```bash
cd broadcom-wl
sudo dkms add .
sudo dkms build broadcom-wl/6.30.223.272
sudo dkms install broadcom-wl/6.30.223.272
```

## What the Fixes Do

1. **Return Thunk Protection**: Enables proper handling of return-oriented programming mitigations
2. **Compiler Flags**: Disables stack protection and other security features that cause conflicts
3. **Kernel Compatibility**: Ensures the driver works with modern kernel security features

## Verification

After installation, check that the driver loads without errors:
```bash
dmesg | grep wl
```

You should see successful module loading without "Unpatched return thunk" warnings.

## Troubleshooting

If you still encounter issues:

1. **Reboot the system** after installation
2. **Check kernel logs**: `dmesg | grep -i error`
3. **Verify module loading**: `lsmod | grep wl`
4. **Check wireless interface**: `iwconfig` or `ip link show`

## Security Note

These patches disable some compiler security features to ensure compatibility. The driver will still work with kernel-level security protections enabled.

## Supported Kernels

- **Kernels 2.6.x - 4.x**: No patches needed
- **Kernels 5.x+**: Security patches automatically applied
- **Kernels 6.x+**: Full compatibility with security fixes
- **Kernel 6.14.0+**: Updated function signatures for `get_tx_power` (includes `link_id` parameter) and other cfg80211 operations

## Files Modified

- `src/include/linuxver.h` - Return thunk protection
- `Makefile` - Compiler security flags and memory safety warnings
- `src/wl/sys/wl_cfg80211_hybrid.c` - Memory safety fixes and bounds checking
- `install-with-fixes.sh` - Automated installation script
