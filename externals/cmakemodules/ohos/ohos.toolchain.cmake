#
# CMake toolchain file for OpenHarmony (OHOS) cross-compilation
# Target: aarch64-linux-ohos (arm64-v8a)
#

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# OHOS NDK paths
if(NOT DEFINED OHOS_NDK)
    set(OHOS_NDK "$ENV{OHOS_NDK}" CACHE PATH "Path to OHOS NDK")
endif()

if(NOT OHOS_NDK)
    message(FATAL_ERROR "OHOS_NDK is not set. Please set OHOS_NDK environment variable to the OHOS NDK path (e.g., /Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native)")
endif()

set(OHOS_LLVM "${OHOS_NDK}/llvm")
set(OHOS_SYSROOT "${OHOS_NDK}/sysroot")

# Compilers
set(CMAKE_C_COMPILER "${OHOS_LLVM}/bin/aarch64-unknown-linux-ohos-clang")
set(CMAKE_CXX_COMPILER "${OHOS_LLVM}/bin/aarch64-unknown-linux-ohos-clang++")
set(CMAKE_AR "${OHOS_LLVM}/bin/llvm-ar")
set(CMAKE_RANLIB "${OHOS_LLVM}/bin/llvm-ranlib")
set(CMAKE_LINKER "${OHOS_LLVM}/bin/ld.lld")

# Search paths
set(CMAKE_FIND_ROOT_PATH "${OHOS_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set sysroot
set(CMAKE_SYSROOT "${OHOS_SYSROOT}")

# Flags
set(CMAKE_C_FLAGS "--target=aarch64-linux-ohos --sysroot=${OHOS_SYSROOT} -D__MUSL__" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "--target=aarch64-linux-ohos --sysroot=${OHOS_SYSROOT} -D__MUSL__" CACHE STRING "CXX flags")
set(CMAKE_EXE_LINKER_FLAGS "--target=aarch64-linux-ohos --sysroot=${OHOS_SYSROOT}" CACHE STRING "Linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "--target=aarch64-linux-ohos --sysroot=${OHOS_SYSROOT}" CACHE STRING "Shared linker flags")