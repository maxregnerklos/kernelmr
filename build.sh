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
LOG_FILE="${ORIGIN_DIR}/build.log"

# Toolchain options
BUILD_PREF_COMPILER='clang'
BUILD_PREF_COMPILER_VERSION='proton'

# Local toolchain directory
TOOLCHAIN=$HOME/toolchains/exynos9610_toolchains_fresh

export ARCH=arm64
export SUBARCH=arm64
export ANDROID_MAJOR_VERSION=r
export PLATFORM_VERSION=11.0.0
export ${ARCH}

script_echo() {
    echo "  $1" | tee -a "${LOG_FILE}"
}

exit_script() {
    script_echo "Exiting script..."
    exit 1
}

download_toolchain() {
    git clone https://gitlab.com/TenSeventy7/exynos9610_toolchains_fresh.git ${TOOLCHAIN} --single-branch -b ${BUILD_PREF_COMPILER_VERSION} --depth 1 2>&1 | sed 's/^/     /' | tee -a "${LOG_FILE}"
    verify_toolchain
}

verify_toolchain() {
    sleep 2
    script_echo " "

    if [[ -d "${TOOLCHAIN}" ]]; then
        script_echo "I: Toolchain found at default location"
    else
        script_echo "I: Toolchain not found at default location"
        script_echo "   Downloading recommended toolchain at ${TOOLCHAIN}..."
        download_toolchain
    fi

    # Proton Clang 13
    export CROSS_COMPILE=aarch64-linux-gnu-
    export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
    export CC=${BUILD_PREF_COMPILER}
}

clean_up() {
    script_echo "Cleaning up build environment..."
    make clean
    make mrproper
}

# Process command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
            script_echo "Showing usage information..."
            exit_script
            ;;
        *)
            script_echo "Error: Unknown option '$1'"
            exit_script
            ;;
    esac
done

# Switch to the kernel source directory
cd "${ORIGIN_DIR}" || exit_script

# Print build configuration
script_echo " "
script_echo "I: Build configuration:"
script_echo "   - Toolchain: ${BUILD_PREF_COMPILER} ${BUILD_PREF_COMPILER_VERSION}"

# Start the build process
script_echo " "
script_echo "I: Starting the kernel build process..."
sleep 2

# Additional options for building
BUILD_OPTS="SELINUX_DEFCON_0=y"

# Build command
make "${BUILD_OPTS}" pdx225_defconfig
make -j$(nproc --all) 2>&1 | sed 's/^/  /' | tee -a "${LOG_FILE}"

# Check if the build was successful
if [[ $? -eq 0 ]]; then
    script_echo " "
    script_echo "I: Kernel build completed successfully."
else
    script_echo " "
    script_echo "E: Kernel build failed. Please check the build logs for errors."
    clean_up
fi
