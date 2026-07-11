# PhysX SDK for OpenHarmony (OHOS) ReadMe

## 平台要求

- OpenHarmony SDK API 9 或更高版本
- 目标架构：aarch64 (arm64-v8a)
- DevEco Studio 3.1 或更高版本

## 二进制文件位置

- 静态库：`bin/ohos.aarch64/release/`
  - `libPhysXFoundation.a`
  - `libPhysXPvdSDK.a`
  - `libPhysXCommon.a`
  - `libPhysXCooking.a`
  - `libPhysXExtensions.a`
  - `libPhysXCharacterKinematic.a`
  - `libPhysXVehicle.a`
  - `libPhysX.a`
- 动态库：`bin/ohos.aarch64/release/libPhysXCustom.so`

## 编译前提

- CMake 3.12 或更高版本
- Python 2.7.6 或更高版本
- DevEco Studio（提供 OHOS NDK）
- OHOS NDK 路径默认为：`/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native`
  - 可通过环境变量 `OHOS_NDK` 自定义

## 编译步骤

### 1. 编译静态库

```bash
cd physx
bash build_ohos.sh
```

编译所有配置（debug/checked/profile/release）：

```bash
bash build_ohos.sh all
```

生成的静态库位于 `physx/bin/ohos.aarch64/release/`。

### 2. 链接动态库

将静态库和 C API 封装链接为单个 `.so` 文件：

```bash
cd physx
bash link_shared.sh
```

生成 `physx/bin/ohos.aarch64/release/libPhysXCustom.so`。

该动态库包含：
- 所有 PhysX 静态库（Foundation → PvdSDK → Common → Cooking → Extensions → CharacterKinematic → Vehicle → PhysX）
- C API 封装（`PhysX_Initialize`、`PhysX_Shutdown`、`PhysX_SimulateBoxDrop` 等）
- 全部 C++ 符号导出（供 Unity 等引擎的 P/Invoke 调用）

## Unity 鸿蒙包集成

Unity 导出鸿蒙包后，将 `libPhysXCustom.so` 复制到项目的 `libs/arm64-v8a/` 目录：

```bash
cp physx/bin/ohos.aarch64/release/libPhysXCustom.so <Unity项目>/libs/arm64-v8a/
```

Unity 自带的 PhysX C# 绑定会通过 P/Invoke 调用原生 C++ API（如 `PxCreatePhysics`），这些符号已包含在 `libPhysXCustom.so` 中。

## 测试

`physx/test/PhysXTest.cs` 提供了 Unity 测试脚本，验证 PhysX 在鸿蒙设备上的运行状态：

- 初始化 PhysX（`PhysX_Initialize`）
- 获取版本号（`PhysX_GetVersionMajor/Minor/Patch`）
- 模拟箱子自由落体（`PhysX_SimulateBoxDrop`）

预期输出：
```
PhysX 4.1.1 OK
Box@1s=5.01m
Box@2s=0.50m
Box@5s=0.50m
```

## 关键文件说明

| 文件 | 说明 |
|------|------|
| `physx/build_ohos.sh` | 一键编译 OHOS 静态库 |
| `physx/link_shared.sh` | 链接静态库为 libPhysXCustom.so |
| `physx/source/c_api/PhysXCApi.cpp` | C API 封装（供 P/Invoke 调用） |
| `physx/test/PhysXTest.cs` | Unity 测试脚本 |
| `externals/cmakemodules/ohos/ohos.toolchain.cmake` | OHOS 交叉编译工具链 |
| `physx/source/compiler/cmake/ohos/` | CMake 配置文件 |

## 已知限制

- 仅支持 aarch64 架构
- 不支持 GPU 物理模拟
- 不包含 Snippet 渲染支持