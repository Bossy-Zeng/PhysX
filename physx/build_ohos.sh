#!/bin/bash +x
#
# Build PhysX for OpenHarmony (OHOS) arm64-v8a
#

set -e

# PhysX root directory
export PHYSX_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PM_PxShared_PATH="$PHYSX_ROOT_DIR/../pxshared"
export PM_CMakeModules_PATH="$PHYSX_ROOT_DIR/../externals/cmakemodules"
export PM_opengllinux_PATH="$PHYSX_ROOT_DIR/../externals/opengl-linux"
export PM_TARGA_PATH="$PHYSX_ROOT_DIR/../externals/targa"
export PM_CGLINUX_PATH="$PHYSX_ROOT_DIR/../externals/cg-linux"
export PM_GLEWLINUX_PATH="$PHYSX_ROOT_DIR/../externals/glew-linux"
export PM_PATHS="$PM_opengllinux_PATH;$PM_TARGA_PATH;$PM_CGLINUX_PATH;$PM_GLEWLINUX_PATH"

# OHOS NDK path - use environment variable or default
if [ -z "$OHOS_NDK" ]; then
    export OHOS_NDK="/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native"
    echo "OHOS_NDK not set, using default: $OHOS_NDK"
fi

# Verify OHOS NDK exists
if [ ! -d "$OHOS_NDK/llvm" ]; then
    echo "ERROR: OHOS NDK not found at $OHOS_NDK"
    echo "Please set OHOS_NDK environment variable to the OHOS NDK native path"
    exit 1
fi

echo "============================================"
echo "Building PhysX for OHOS arm64-v8a"
echo "PHYSX_ROOT_DIR: $PHYSX_ROOT_DIR"
echo "OHOS_NDK: $OHOS_NDK"
echo "============================================"

# Build configurations
CONFIGS="release"
if [ "$1" = "all" ]; then
    CONFIGS="debug checked profile release"
fi

TOOLCHAIN_FILE="$PHYSX_ROOT_DIR/../externals/cmakemodules/ohos/ohos.toolchain.cmake"

for CONFIG in $CONFIGS; do
    echo ""
    echo "============================================"
    echo "Building configuration: $CONFIG"
    echo "============================================"

    BUILD_DIR="$PHYSX_ROOT_DIR/compiler/ohos-arm64-v8a-$CONFIG"
    
    # Clean and create build directory
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    
    cd "$BUILD_DIR"
    
    cmake "$PHYSX_ROOT_DIR/compiler/public" \
        -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=$CONFIG \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
        -DOHOS_NDK="$OHOS_NDK" \
        -DTARGET_BUILD_PLATFORM=ohos \
        -DPX_OUTPUT_ARCH=arm \
        -DPHYSX_ROOT_DIR="$PHYSX_ROOT_DIR" \
        -DPX_OUTPUT_LIB_DIR="$PHYSX_ROOT_DIR" \
        -DPX_OUTPUT_BIN_DIR="$PHYSX_ROOT_DIR" \
        -DPX_OUTPUT_DLL_DIR="$PHYSX_ROOT_DIR" \
        -DCMAKE_PREFIX_PATH="$PM_PATHS" \
        -DPX_BUILDSNIPPETS=OFF \
        -DPX_BUILDPUBLICSAMPLES=OFF \
        -DPX_GENERATE_STATIC_LIBRARIES=ON \
        -DCMAKE_INSTALL_PREFIX="$PHYSX_ROOT_DIR/install/ohos/PhysX" \
        --no-warn-unused-cli
    
    echo ""
    echo "Compiling $CONFIG..."
    make -j$(sysctl -n hw.ncpu)
    
    echo ""
    echo "Configuration $CONFIG completed successfully!"
    echo "Output directory: $BUILD_DIR"
    
    cd "$PHYSX_ROOT_DIR"
done

echo ""
echo "============================================"
echo "All builds completed!"
echo "============================================"

# List output libraries
echo ""
echo "Generated static libraries:"
find "$PHYSX_ROOT_DIR/bin" -name "*.a" -path "*ohos*" 2>/dev/null || \
find "$PHYSX_ROOT_DIR/compiler/ohos-arm64-v8a-release" -name "*.a" 2>/dev/null || \
echo "Looking for .a files in build directories..."

echo ""
echo "Library files:"
find "$PHYSX_ROOT_DIR/compiler" -name "*.a" -path "*ohos*" 2>/dev/null