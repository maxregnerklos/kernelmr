#!/bin/bash
# =========================================
#         _____              _
#        |  ___| __ ___  ___| |__
#        | |_ | '__/ _ \/ __| '_ \
#        |  _|| | |  __/\__ \ | | |
#        |_|  |_|  \___||___/_| |_|
#
# =========================================
#
#  Sony GKI - The kernel build script for Sony GKI
#  The Fresh Project
#  Copyright (C) 2019-2021 TenSeventy7
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#  =========================
#

# Utility directories
ORIGIN_DIR=$(pwd)
CURRENT_BUILD_USER=$(whoami)

# Toolchain options
BUILD_PREF_COMPILER='clang'
BUILD_PREF_COMPILER_VERSION='proton'

# Local toolchain directory
TOOLCHAIN=$HOME/toolchains/exynos9610_toolchains_fresh

# External toolchain directory
TOOLCHAIN_EXT=$(pwd)/toolchain

DEVICE_DB_DIR="${ORIGIN_DIR}/Documentation/device-db"

export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11.0.0
export ${ARCH}

script_echo() {
    echo "  $1"
}

exit_script() {
    kill -INT $$
}

download_toolchain() {
    git clone https://gitlab.com/TenSeventy7/exynos9610_toolchains_fresh.git ${TOOLCHAIN_EXT} --single-branch -b ${BUILD_PREF_COMPILER_VERSION} --depth 1 2>&1 | sed 's/^/     /'
    verify_toolchain
}

verify_toolchain() {
    sleep 2
    script_echo " "

    if [[ -d "${TOOLCHAIN}" ]]; then
        script_echo "I: Toolchain found at default location"
        export PATH="${TOOLCHAIN}/bin:$PATH"
        export LD_LIBRARY_PATH="${TOOLCHAIN}/lib:$LD_LIBRARY_PATH"
    elif [[ -d "${TOOLCHAIN_EXT}" ]]; then
        script_echo "I: Toolchain found at repository root"
        cd ${TOOLCHAIN_EXT}
        git pull
        cd ${ORIGIN_DIR}
        export PATH="${TOOLCHAIN_EXT}/bin:$PATH"
        export LD_LIBRARY_PATH="${TOOLCHAIN_EXT}/lib:$LD_LIBRARY_PATH"

        if [[ ${BUILD_KERNEL_CI} == 'true' ]]; then
            if [[ ${BUILD_PREF_COMPILER_VERSION} == 'proton' ]]; then
                sudo mkdir -p /root/build/install/aarch64-linux-gnu
                sudo cp -r "${TOOLCHAIN_EXT}/lib" /root/build/install/aarch64-linux-gnu/
                sudo chown ${CURRENT_BUILD_USER} /root /root/build /root/build/install /root/build/install/aarch64-linux-gnu /root/build/install/aarch64-linux-gnu/lib
            fi
        fi
    else
        script_echo "I: Toolchain not found at default location or repository root"
        script_echo "   Downloading recommended toolchain at ${TOOLCHAIN_EXT}..."
        download_toolchain
    fi

    # Proton Clang 13
    # export CLANG_TRIPLE=aarch64-linux-gnu-
    export CROSS_COMPILE=aarch64-linux-gnu-
    export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    export CC=${BUILD_PREF_COMPILER}
}

update_magisk() {
    script_echo " "
    script_echo "I: Updating Magisk..."

    if [[ "x${BUILD_KERNEL_MAGISK_BRANCH}" == "xcanary" ]]; then
        MAGISK_BRANCH="canary"
    elif [[ "x${BUILD_KERNEL_MAGISK_BRANCH}" == "xlocal" ]]; then
        MAGISK_BRANCH="local"
    else
        MAGISK_BRANCH=""
    fi

    ${ORIGIN_DIR}/usr/magisk/update_magisk.sh ${MAGISK_BRANCH} 2>&1 | sed 's/^/     /'
}

fill_magisk_config() {
    MAGISK_USR_DIR="${ORIGIN_DIR}/usr/magisk/"

    script_echo " "
    script_echo "I: Configuring Magisk..."

    if [[ -f "$MAGISK_USR_DIR/backup_magisk" ]]; then
        rm "$MAGISK_USR_DIR/backup_magisk"
    fi

    echo "KEEPVERITY=true" >> "$MAGISK_USR_DIR/backup_magisk"
    echo "KEEPFORCEENCRYPT=true" >> "$MAGISK_USR_DIR/backup_magisk"
    echo "RECOVERYMODE=false" >> "$MAGISK_USR_DIR/backup_magisk"
    echo "PREINITDEVICE=userdata" >> "$MAGISK_USR_DIR/backup_magisk"

    # Create a unique random seed per-build
    script_echo "   - Generating a unique random seed for this build..."
    RANDOMSEED=$(tr -dc 'a-f0-9' < /dev/urandom | head -c 16)
    echo "RANDOMSEED=0x$RANDOMSEED" >> "$MAGISK_USR_DIR/backup_magisk"
}

show_usage() {
    script_echo "Usage: ./build.sh -d|--device <device> -v|--variant <variant> [main options]"
    script_echo " "
    script_echo "Main options:"
    script_echo "-d, --device <device>     Set build device to build the kernel for. Required."
    script_echo "-a, --android <version>   Set Android version to build the kernel for. (Default: 11)"
    script_echo "-v, --variant <variant>   Set build variant to build the kernel for. Required."
    script_echo " "
    script_echo "-n, --no-clean            Do not clean and update Magisk before build."
    script_echo "-m, --magisk [canary]     Pre-root the kernel with Magisk. Optional flag to use canary builds."
    script_echo "                          Not available for 'recovery' variant."
    script_echo "-p, --permissive          Build kernel with SELinux fully permissive. NOT RECOMMENDED!"
    script_echo " "
    script_echo "-h, --help                Show this message."
    script_echo " "
    script_echo "Variant options:"
    script_echo "    oneui: Build Mint for use with stock and One UI-based ROMs."
    script_echo "     aosp: Build Mint for use with AOSP and AOSP-based Generic System Images (GSIs)."
    script_echo " recovery: Build Mint for use with recovery device trees. Doesn't build a ZIP."
    script_echo " "
    script_echo "Valid devices and their supported variants can be found in device-db/."
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -d|--device)
            DEVICE="$2"
            shift
            shift
            ;;
        -v|--variant)
            VARIANT="$2"
            shift
            shift
            ;;
        -a|--android)
            ANDROID_MAJOR_VERSION="$2"
            shift
            shift
            ;;
        -n|--no-clean)
            NO_CLEAN="true"
            shift
            ;;
        -m|--magisk)
            BUILD_KERNEL_MAGISK="true"
            BUILD_KERNEL_MAGISK_BRANCH="$2"
            shift
            shift
            ;;
        -p|--permissive)
            BUILD_KERNEL_PERMISSIVE="true"
            shift
            ;;
        -h|--help)
            show_usage
            exit_script
            ;;
        *)
            script_echo "Error: Unknown option '$1'"
            show_usage
            exit_script
            ;;
    esac
done

# Check required arguments
if [[ -z "${DEVICE}" || -z "${VARIANT}" ]]; then
    script_echo "Error: Missing required arguments."
    show_usage
    exit_script
fi

# Check if the device exists in the device database
DEVICE_ENTRY="${DEVICE_DB_DIR}/${DEVICE}"
if [[ ! -d "${DEVICE_ENTRY}" ]]; then
    script_echo "Error: Device '${DEVICE}' not found in the device database."
    exit_script
fi

# Check if the variant is supported for the specified device
SUPPORTED_VARIANTS=$(cat "${DEVICE_ENTRY}/variants")
if ! grep -q "${VARIANT}" <<< "${SUPPORTED_VARIANTS}"; then
    script_echo "Error: Variant '${VARIANT}' is not supported for device '${DEVICE}'."
    exit_script
fi

# Switch to the kernel source directory
cd "${ORIGIN_DIR}" || exit_script

# Clean up before building
if [[ "${NO_CLEAN}" != "true" ]]; then
    # Update Magisk if requested
    if [[ "${BUILD_KERNEL_MAGISK}" == "true" ]]; then
        update_magisk
    fi

    # Prepare Magisk config
    fill_magisk_config

    # Clean up
    script_echo "I: Cleaning up..."
    make clean && make mrproper
fi

# Print build configuration
script_echo " "
script_echo "I: Build configuration:"
script_echo "   - Device: ${DEVICE}"
script_echo "   - Variant: ${VARIANT}"
script_echo "   - Android version: ${ANDROID_MAJOR_VERSION}"
script_echo "   - Toolchain: ${BUILD_PREF_COMPILER} ${BUILD_PREF_COMPILER_VERSION}"
script_echo "   - Magisk: ${BUILD_KERNEL_MAGISK:-false} ${BUILD_KERNEL_MAGISK_BRANCH:-}"
script_echo "   - SELinux permissive: ${BUILD_KERNEL_PERMISSIVE:-false}"

# Start the build process
script_echo " "
script_echo "I: Starting the kernel build process..."
sleep 2

# Additional options for building
BUILD_OPTS="SELINUX_DEFCON_0=y"

# Add permissive option if requested
if [[ "${BUILD_KERNEL_PERMISSIVE}" == "true" ]]; then
    BUILD_OPTS+=" SELINUX_PERMISSIVE=y"
fi

# Build command
make "${BUILD_OPTS}" exynos9610_${DEVICE}_mint_defconfig
make -j$(nproc --all) 2>&1 | sed 's/^/  /'

# Check if the build was successful
if [[ $? -eq 0 ]]; then
    script_echo " "
    script_echo "I: Kernel build completed successfully."
else
    script_echo " "
    script_echo "E: Kernel build failed. Please check the build logs for errors."
fi
