# DEPRECATION NOTICE
As Aseprite has a pretty comprehensive building guide and now even a build script for all relevant platforms, this script is no longer useful and you can use their official resources to more easily compile Aseprite for development or personal use. This script may or may not work in the future, but it appears to have problems currently. I have attempted to fix those build issues, but as there is the aforementioned official script now, this is no longer necessary. This repo will stay publically accessible, but will be archived, if anyone wants to see how the script worked and wants to maybe use some used techniques in their own scripts.

# Upsprite
## A script for automatically building Aseprite on Linux

## Installation
Before running the install script, make sure your distro specific dependencies listed in the Dependencies section are installed or just run the correct install command.
For installing Aseprite make sure upsprite.sh has execution permissions, simply run ./upsprite and follow any promtps given.
If you want to automate the installation with your own scripts and integrate upsprite, or just quickly run upsprite without prompts, you can run the script with `--prebuilt` to automatically use the prebuilt skia, `--rebuild-skia` for automatically removing and rebuilding/redownloading skia and `--full` for automatically building skia, independent of whether there is a prebuilt package available or not. You can also use the `--local-skia` flag to use the existing instance of skia, whether it's the prebuilt version or the self-coppiled one. You can't use `--rebuild-skia`, `--full` or `--prebuilt` when using the `--local-skia` flag.

## Uninstall
Just run upsprite.sh with the `--uninstall` flag.

## Dependencies

You will need the following dependencies on Ubuntu/Debian:

    sudo apt-get install -y g++ clang libc++-dev libc++abi-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev

Or use clang-10 packages (or newer) in case that clang in your distribution is older than clang 10.0:

    sudo apt-get install -y clang-10 libc++-10-dev libc++abi-10-dev

On Fedora:

    sudo dnf install -y gcc-c++ clang libcxx-devel cmake ninja-build libX11-devel libXcursor-devel libXi-devel mesa-libGL-devel fontconfig-devel

On Arch:

    sudo pacman -S gcc clang libc++ cmake ninja libx11 libxcursor mesa-libgl fontconfig

On SUSE:

    sudo zypper install gcc-c++ clang libc++-devel libc++abi-devel cmake ninja libX11-devel libXcursor-devel libXi-devel Mesa-libGL-devel fontconfig-devel

## Issues?
If you encounter any issues, either try to find the cause from the command line output or submit an issue on the upsprite github repo.
