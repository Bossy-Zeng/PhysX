#!/bin/bash
#
# Link PhysX static libraries into a single shared library (.so) for OHOS
#

set -e

# OHOS NDK path
if [ -z "$OHOS_NDK" ]; then
    export OHOS_NDK="/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native"
fi

if [ ! -d "$OHOS_NDK/llvm" ]; then
    echo "ERROR: OHOS NDK not found at $OHOS_NDK"
    exit 1
fi

CLANGXX="$OHOS_NDK/llvm/bin/aarch64-unknown-linux-ohos-clang++"
SYSROOT="$OHOS_NDK/sysroot"

PHYSX_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIB_DIR="$PHYSX_ROOT/bin/ohos.aarch64/release"
OUTPUT_DIR="$LIB_DIR"

if [ ! -d "$LIB_DIR" ]; then
    echo "ERROR: Library directory not found: $LIB_DIR"
    echo "Please run build_ohos.sh first"
    exit 1
fi

echo "============================================"
echo "Linking PhysX shared library for OHOS"
echo "OHOS_NDK: $OHOS_NDK"
echo "LIB_DIR: $LIB_DIR"
echo "============================================"

# Compile C API wrapper
CAPI_SRC="$PHYSX_ROOT/source/c_api/PhysXCApi.cpp"
CAPI_OBJ="$OUTPUT_DIR/PhysXCApi.o"
echo "Compiling C API wrapper..."
"$CLANGXX" --target=aarch64-linux-ohos --sysroot="$SYSROOT" -std=c++14 -O2 -fPIC -fno-strict-aliasing -DNDEBUG -DPX_PHYSX_STATIC_LIB -I"$PHYSX_ROOT/include" -I"$PHYSX_ROOT/../pxshared/include" -c "$CAPI_SRC" -o "$CAPI_OBJ"

# Link all static libraries into a single shared library
# Order matters: dependencies first (Foundation), dependents last (PhysX)
"$CLANGXX" \
    --target=aarch64-linux-ohos \
    --sysroot="$SYSROOT" \
    -shared \
    -o "$OUTPUT_DIR/libPhysXCustom.so" \
    "$CAPI_OBJ" \
    -Wl,--whole-archive \
    "$LIB_DIR/libPhysXFoundation.a" \
    "$LIB_DIR/libPhysXPvdSDK.a" \
    "$LIB_DIR/libPhysXCommon.a" \
    "$LIB_DIR/libPhysXCooking.a" \
    "$LIB_DIR/libPhysXExtensions.a" \
    "$LIB_DIR/libPhysXCharacterKinematic.a" \
    "$LIB_DIR/libPhysXVehicle.a" \
    "$LIB_DIR/libPhysX.a" \
    -Wl,--no-whole-archive \
    -lm -lpthread

echo ""
echo "Shared library created successfully!"
ls -lh "$OUTPUT_DIR/libPhysXCustom.so"
