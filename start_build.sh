#!/bin/bash
set -e

# === CONFIGURATION ===
DEFCONFIG=a70q_oneui_defconfig
OUT_DIR=out

# === ARCHITECTURE ===
export ARCH=arm64
export SUBARCH=arm64

# === COMPILER SETUP ===
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export CROSS_COMPILE_COMPAT=arm-linux-gnueabi-

export CC=clang
export AR=llvm-ar
export NM=llvm-nm
export OBJCOPY=llvm-objcopy
export OBJDUMP=llvm-objdump
export STRIP=llvm-strip
export LD=ld.lld

# === CCACHE ===
export USE_CCACHE=1
export CCACHE_EXEC=$(command -v ccache)
export CC="ccache clang"

# === BUILD THREADS ===
CORES=$(nproc --all)

# === START TIME ===
BUILD_START=$(date +%s)

echo ">>> Starting Kernel Build with $CORES cores..."
echo ">>> Using config: $DEFCONFIG"

# === CLEAN optional ===
# make O=$OUT_DIR clean

# === DEFCONFIG ===
make O=$OUT_DIR $DEFCONFIG

# === BUILD TARGET ===
make -j$CORES \
  O=$OUT_DIR \
  ARCH=$ARCH \
  SUBARCH=$SUBARCH \
  CROSS_COMPILE=$CROSS_COMPILE \
  CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32 \
  CROSS_COMPILE_COMPAT=$CROSS_COMPILE_COMPAT \
  CC="$CC" \
  AR=$AR NM=$NM OBJCOPY=$OBJCOPY OBJDUMP=$OBJDUMP STRIP=$STRIP LD=$LD \
  Image.gz-dtb

# === END TIME ===
BUILD_END=$(date +%s)
BUILD_DURATION=$((BUILD_END - BUILD_START))
BUILD_MINUTES=$(echo "scale=2; $BUILD_DURATION / 60" | bc)

echo ">>> Kernel build complete!"
echo ">>> Output file:"
find "$OUT_DIR" -name "Image.gz-dtb" || find "$OUT_DIR" -name "*.img" -o -name "*.dtb"

# === BUILD TIME ===
echo ">>> Total build time: ${BUILD_DURATION}s (~${BUILD_MINUTES} minutes)"

# === OPTIONAL: CCACHE STATS ===
ccache -s || true
