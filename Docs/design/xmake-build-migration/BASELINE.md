# Dora-SSR Native 构建迁移基线

> 冻结日期：2026-09-30
> 用途：迁移期对照现有入口、输出和发行包；不代表这些旧入口已经通过本轮运行时验收。

## 1. 平台命令与输出

| 平台 | Debug 基线 | Release 基线 | 主输出 |
| --- | --- | --- | --- |
| macOS | `Tools/build-scripts/build_macos.sh debug` | `Tools/build-scripts/build_macos.sh release` | Debug：`Projects/macOS/build/Debug/Dora.app`；Release：`Projects/macOS/build/Release/dora.xcarchive/Products/Applications/Dora.app` |
| iOS simulator | `Tools/build-scripts/build_ios.sh debug` | `Tools/build-scripts/build_ios.sh release` | Xcode `Simulator` target 的 Debug/Release `.app` |
| Linux | `Tools/build-scripts/build_linux.sh debug` | `Tools/build-scripts/build_linux.sh release` | `Projects/Linux/build/dora-ssr` |
| Windows x86 | `Tools\\build-scripts\\build_windows.bat debug` | `Tools\\build-scripts\\build_windows.bat release` | `Projects\\Windows\\build\\Debug|Release\\Dora.exe` 与 `wa.dll` |
| Android | `Tools/build-scripts/build_android.sh debug` | `Tools/build-scripts/build_android.sh release` | `Projects/Android/Dora/app/build/outputs/apk/debug|release` |
| Web single-thread | `Tools/build-scripts/build_web.sh` | 同一入口，默认 Release | `build/web`；`result/dora-web-build-probe`；`result/dora-web-player` |
| Web pthread/Love | `DORA_WEB_PTHREADS=1 Tools/build-scripts/build_web.sh` | 同一入口，默认 Release | `result/dora-web-player-pthreads`；`result/love-pthread-player` |

所有旧入口都会先构建 tolua++ 生成代码以及 SDL2、bgfx、Love、Theora、Wa、Rust 等依赖。迁移后的 xmake 目标必须保留依赖顺序，但不能继续把这些脚本当作 Native 编译事实来源。

## 2. CI 基线

| 平台 | Workflow | 当前 Native 入口 | 迁移验收重点 |
| --- | --- | --- | --- |
| macOS | `.github/workflows/macos.yml` | `build_macos.sh` | Debug、Release archive、universal ZIP、Homebrew 输入 |
| iOS | `.github/workflows/ios.yml` | `build_ios.sh` | simulator Debug；后续补 device/signing 门禁 |
| Linux | `.github/workflows/linux.yml`、`linux-appimage.yml` | `build_linux.sh` | x86_64/aarch64、Debug/Release、AppImage |
| Windows | `.github/workflows/windows.yml` | `build_windows.bat` | x86 Debug/Release、ZIP 中 `Dora.exe`/`wa.dll`/Assets |
| Android | `.github/workflows/android.yml` | `build_android.sh` / `build_lib_android.sh` | Gradle APK、三 ABI、签名 |
| Web | `.github/workflows/web.yml` | `build_web.sh` | macOS/Linux 构建、single-thread、pthread/Love、浏览器检查 |

Linux workflow 仍固定 xmake `v2.9.4`，其余多数 job 使用 `latest`。迁移完成前必须统一为 `latest` 并在日志输出实际版本。

## 3. 发行产物结构

### macOS

- `dora-ssr-<tag>-macos-universal.zip`
  - `Dora.app/`
- `web-ide-files.zip`

### Linux

- `dora-ssr-linux-x86_64.AppImage`
- `dora-ssr-linux-aarch64.AppImage`

### Windows

- `dora-ssr-<tag>-windows-x86.zip`
  - `Dora.exe`
  - `wa.dll`
  - `www/`
  - `dora-wa/`
  - `Audio/`、`Doc/`、`Font/`、`Image/`、`Script/`
  - `gamecontrollerdb.txt`
  - `LICENSES/`
  - `Shader/Love/varying.def.sc`

### Android

- `dora-ssr-<tag>-android.zip`
  - `dora-ssr-<tag>-android.apk`

### Web

- build probe：`dora-player.html`、`dora-player.js`、`dora-player.wasm`、`index.html`
- Dora Player：`dora-player-runtime.{html,js,wasm,data}`、`dora-web-manifest.json`、`dora-web-features.json`、`dora-audio-mixer.wasm`、`audio-worklet.js`、`assets/`、`index.html`，pthread profile 另含 worker 文件
- Love pthread Player：`love-pthread-player.{html,js,wasm,data}`、`index.html`、音频 worklet/mixer，必要时含 worker 文件

## 4. 自动化对照

过渡期运行：

```sh
xmake audit-manifests
```

该任务会验证 xmake 引擎清单无重复、所有路径存在，并与 `Projects/CMake/DoraEngineSources.cmake` 的 580 个基线条目完全一致。旧 CMake 删除后，任务应改为对照冻结快照或仅执行仓库存在性与平台覆盖检查。

配置与依赖证据：

```sh
xmake f -c -y -p macosx -a arm64 -m debug
xmake build dora-host-tools
xmake doctor --platform=host
```

2026-09-30 本机证据：xmake `3.0.8+20260323`；xmake-repo 管理的 Go `1.27.1`、Rust/Cargo `1.96.1`、rustup `1.29.1`；路径均位于 `~/.xmake/packages`。

## 5. 未冻结项

- 每个平台完整宏、framework、链接库、PCH 和逐文件参数仍需生成机器可比较快照；
- iOS device 签名、Android 三 ABI 包内容以及各平台真实 runtime smoke 尚未在本轮执行；
- 发行包结构来自当前 workflow/脚本，仍需用一次 tag 等价 dry run 复核。
