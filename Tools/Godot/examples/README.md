# GodotNode 1.0 示例

这里提供两个可编辑的 GDScript 项目：

| 项目 | 内容 | 输入 |
| --- | --- | --- |
| [2d](2d/main.gd) | 自绘网格和持续运动的小球 | 点击切换小球颜色 |
| [3d](3d/main.gd) | 灯光、材质、相机和旋转立方体 | 持续动画 |

[host.lua](host.lua) 是 Dora 侧的入口：创建 GodotNode、按视口缩放、等待异步启动，并处理错误。两个项目没有外部素材，不需要先运行 Godot 编辑器；可以用 Godot 4.6 编辑器打开后修改。

## 准备运行库

需要包含本整合的普通 Dora 宿主，以及本仓库工具构建的匹配运行库。不要使用 `DORA_BUILD_GODOT_NODE_TEST` 测试宿主，也不要直接替换成上游原版 LibGodot；原版没有 Dora 的桥接 ABI。

macOS Release 运行库：在仓库根目录执行：

```sh
DORA_GODOT_TARGET=template_release Tools/Godot/build_runtime.sh
python3 Tools/Godot/verify_package.py build/godot-runtime/release/package
```

Linux 使用 `build_linux_runtime.sh`，Windows 使用 `build_windows_runtime.py`。具体工具链、构建参数和包路径见 [构建说明](../README.md)。运行库与宿主必须采用相同架构。

## macOS 直接运行

已有普通 `Dora.app` 后，在仓库根目录执行：

```sh
python3 Tools/Godot/examples/stage_native.py \
  --example 2d --app /absolute/path/to/Dora.app \
  --runtime-package build/godot-runtime/release/package \
  --output build/godot-example-2d
build/godot-example-2d/Dora.app/Contents/MacOS/Dora
```

改为 `--example 3d` 并使用新的输出目录即可运行 3D。每个示例单独启动进程，不在同一运行时内切换项目。

准备脚本会复制宿主、放入项目和运行库、附带 Godot 许可，并进行本地 ad-hoc 签名。它不覆盖原始应用；输出目录已存在时拒绝执行。生成的 `example.json` 记录启动命令与输入哈希。这是开发示例包，不是已经公证或可公开分发的安装包。

## Linux / Windows

使用普通可执行文件及其已有依赖，并提供 Dora 资源目录：

```sh
python3 Tools/Godot/examples/stage_native.py \
  --example 3d --binary /absolute/path/to/Dora --asset-source Assets \
  --runtime-package /absolute/path/to/runtime/package \
  --output build/godot-example-3d
```

执行输出中 `command` 对应的命令。可执行文件保留在原位置，依赖不被搬动；项目与运行库放在新的 `assets` 中。Linux 需要可用的 EGL OpenGL/OpenGLES 环境。Windows 使用 x64 宿主及匹配 DLL，启动前在 PowerShell 设置 `$env:DORA_GODOT_WINDOWS_GL="1"`；当前桥接不支持 Direct3D/Vulkan。

## 在自己的 Dora 项目中使用

将所选项目目录作为 `GodotProject` 放入资源根目录，将 `host.lua` 作为 Dora 入口。也可以直接创建节点：

```lua
local D = require("Dora")
local reason = D.GodotNode.getUnsupportedReason()
if reason ~= "" then print(reason); return end
local node = D.GodotNode("/absolute/path/to/project", "", 640, 360, 3)
if not node then print("Project or viewport is invalid"); return end
node:addTo(D.Director.ui)
-- 启动异步完成：检查 node.running 和 node.lastError。
```

能力查询通过只代表 GPU/后端满足要求；缺少运行库或项目启动失败仍会写入 `lastError`。成功创建不等于启动完成。

- 暂停/恢复：`node:pause()` / `node:resume()`。
- 重载当前场景：`node:restart()`；不是切换到另一个项目。
- 调整输出尺寸：`node:resizeViewport(800, 450)`；返回 true 表示请求被接受，提交完成后 `viewportSize` 才改变。
- 删除：`node:removeFromParent()`。退出应用前走正常关闭路径，让 GPU 和音频排空。
- 手动指针：`node:sendPointer(x, y, 1, true)`，随后发送 false；坐标为输出纹理左上角起算的像素。

Rust/Wa 对应接口、PCK、输入和音频说明见 [完整用法](../README.md)。GodotNode 不提供 C# 绑定，也不启用 Godot .NET/Mono 脚本；Dora 原有 C# 功能保留。

## Web / Android / iOS 边界

这两个 Godot 项目的源代码可作为移动/Web 工程的起点；`stage_native.py` 仅准备桌面目录和 macOS 应用，不生成 APK 或 Web Player。

- Web：使用包含 Godot 的 Player，并将项目纳入游戏资源清单；Godot 项目文件必须预加载并复制到 Godot WASM 的 VFS，不能只上传 HTML。部署、资源打包和浏览器要求见 [Web 用法](../README.md)。
- Android：APK 内需要匹配的 Java/JNI/运行库及 R8 keep 规则。Godot 读取真实沙箱目录或 PCK；先将项目复制到可写目录，再把绝对路径传给 GodotNode，不能直接把 APK asset 路径当作普通磁盘目录。
- iOS：Dora 基础保持 Apple2，GodotNode 独立要求 Apple4；当前仅验证模拟器的安全拒绝，未承诺真机正向共享。

当前单运行时、单项目、单活动节点；默认三缓冲，可选已验证的二/四缓冲。最终关闭后不承诺重新初始化。Web 上下文丢失采用安全停止与页面重载；完整 IME、设备原地恢复及物理硬件矩阵仍有未覆盖边界，见 [跟踪清单](../TRACKING.md)。
