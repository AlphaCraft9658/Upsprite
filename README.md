# Upsprite
## A script for automatically building Aseprite on Linux

## Installation
Before running the install script, make sure your distro specific dependencies listed in the Dependencies section are installed or just run the correct install command.
For installing Aseprite make sure upsprite.sh has execution permissions, simply run ./upsprite and follow any promtps given.
If you want to automate the installation with your own scripts and integrate upsprite, or just quickly run without the prompts, you can run the script with `--prebuilt` to automatically use the prebuilt skia, `--rebuild-skia` for automatically removing and rebuilding/redownloading skia and `--full` for automatically building skia, independant of whether there is a prebuilt package available or not.

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
