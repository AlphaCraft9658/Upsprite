#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
full=false
prebuilt=false
rebuild=false
local=false
uninstall=false

while [ $# -gt 0 ]; do
  if [[ $1 == "--full" && "$prebuilt" = false ]]; then
    full=true
  elif [[ $1 == "--prebuilt" && "$full" = false ]]; then
    prebuilt=true
  elif [ $1 == "--rebuild-skia" ]; then
    rebuild=true
  elif [ $1 == "--local-skia" ]; then
    local=true
  elif [ $1 == "--uninstall" ]; then
    uninstall=true
    break
  fi
  shift
done

if [ "$uninstall" = true ]; then
  rm -f $HOME/.local/bin/aseprite
  rm -f $HOME/.local/share/applications/Aseprite.desktop
  exit 0
fi

if [[ "$prebuilt" = true && "$full" = true ]]; then
  echo "You can't both use the prebuilt and self-compile skia. Use either one of the flags \"--prebuilt\" and \"--full\"."
fi

if [[ ("$local" = true && "$rebuild" = true) || ("$local" = true && "$full" = true) || ("$local" = true && "$prebuilt" = true) ]]; then
  echo "You can't use the flags \"--rebuild\", \"--full\" or \"--prebuilt\" in combination with \"--local-skia\". Try again with a valid combination of flags."
  exit 1
fi

echo "----- Fetching Aseprite source -----"
if [ ! -d "$SCRIPT_DIR/aseprite" ]; then
  git clone --recursive https://github.com/aseprite/aseprite.git
else
  cd aseprite
  git pull
  git submodule update --init --recursive
  if [ -d "build" ]; then
    rm -rf build
  fi
  cd ..
fi

build_skia() {
  echo "----- Building skia -----"
  mkdir deps && cd deps
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  git clone -b aseprite-m124 https://github.com/aseprite/skia.git
  export PATH="${PWD}/depot_tools:${PATH}"
  cd skia
  python tools/git-sync-deps
  gn gen out/Release-x64 --args='is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false cc="clang" cxx="clang++" extra_cflags_cc=["-stdlib=libc++"] extra_ldflags=["-stdlib=libc++"]'
  ninja -C out/Release-x64 skia modules
}

skia_setup() {
  if $full; then
    echo "Building skia"
    build_skia
    return
  fi
  if [[ $(uname -m) == "x86_64" && "$prebuilt" = true && "$local" = false ]]; then
    curl -LO https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-Linux-Release-x64.zip
    mkdir deps
    unzip Skia-Linux-Release-x64.zip -d deps/skia
    rm Skia-Linux-Release-x64.zip
  elif [[ $(uname -m) == "x86_64" && $prebuilt = false && "$local" = false ]]; then
    input="x"
    printf "There is a prebuilt package of skia for your current architecture.\nDo you want to use the prebuilt archive? This will speed up the build process! (NOTE: If you encounter any issues while using the prebuilt package, try to re-run this script and tick n instead) (y/n): "
    set +e
    while [[ $input != "y" && $input != "n" ]]; do
      read -rsn1 input
      input=$(echo $input | tr '[:upper:]' '[:lower:]')
      if [ "$input" == "y" ]; then
        set -e
        echo
        curl -LO https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libc++.zip
        mkdir deps
        unzip Skia-Linux-Release-x64-libc++.zip -d deps/skia
        rm Skia-Linux-Release-x64-libc++.zip
      elif [ "$input" == "n" ]; then
        set -e
        printf "\n"
        build_skia
      fi
    done
  elif [ $prebuilt = false ]; then
    printf "There is no prebuilt package of skia for your architecture. Automatically building skia.\n"
    build_skia
  elif [ $prebuilt = true ]; then
    printf "The is no prebuilt package of skia for your architecture. Building skia anyway.\n"
    build_skia
  fi
}

echo "----- Skia setup -----"
if [[ -d "$SCRIPT_DIR/deps" && "$rebuild" = false && "$local" = false ]]; then
  printf "The directory $SCRIPT_DIR/deps already exists.\nIf you have encountered issues issues with the prebuilt archive in a previous attempt or want to rebuild/re-download skia, you should remove the directory first.\nDo you want to do that? (y/n): "
  input="x"
  set +e
  while [[ $input != "y" && $input != "n" ]]; do
    read -rsn1 input
    input=$(echo $input | tr '[:upper:]' '[:lower:]')
    if [ "$input" == "y" ]; then
      echo
      set -e
      rm -rf deps
      skia_setup
    fi
  done
elif [ "$rebuild" = true ]; then
  rm -rf deps
  skia_setup
elif [ "$local" = false ]; then
  skia_setup
fi

echo "----- Building Aseprite -----"
cd $SCRIPT_DIR/aseprite && mkdir build && cd build
export CC=clang
export CXX=clang++
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
  -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
  -DLAF_BACKEND=skia \
  -DSKIA_DIR=$SCRIPT_DIR/deps/skia \
  -DSKIA_LIBRARY_DIR=$SCRIPT_DIR/deps/skia/out/Release-x64 \
  -DSKIA_LIBRARY=$SCRIPT_DIR/deps/skia/out/Release-x64/libskia.a \
  -G Ninja \
  ..
ninja aseprite

ln -sf $SCRIPT_DIR/aseprite/build/bin/aseprite $HOME/.local/bin/aseprite
echo "[Desktop Entry]
Exec=aseprite
Icon=$SCRIPT_DIR/aseprite/build/bin/data/icons/ase256.png
Name=Aseprite
NoDisplay=false
StartupNotify=true
Terminal=false
Type=Application
X-KDE-SubstituteUID=false" > $HOME/.local/share/applications/Aseprite.desktop
echo "Successfully installed Aseprite!"
