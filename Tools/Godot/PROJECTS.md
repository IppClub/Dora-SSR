# Godot 工程与试玩包

`project.py` 提供本地分发流程：仓库/源码 ZIP → 识别工程 → 独立副本导入 → Dora 试玩，或导出 PCK → 归档 → 校验安装 → Dora 试玩。生产逻辑位于 `project_delivery.py`，回归程序位于 Dora-Example `Test/Godot`。

## Web IDE 新建工程与 Agent 开发

Web IDE 的“新建工程目录 → 创建为项目”提供 `Godot 2D` 和 `Godot 3D`。工程根目录同时包含 `init.ts`、`project.godot`、`main.tscn`、`main.gd`；`init.ts` 是 Dora 宿主入口，其余文件是可用官方编辑器打开的标准 Godot 工程。基础模板使用程序化图形，不需要先导入外部素材；创建完成后沿用普通工程的 Agent 会话入口。

桌面 Agent 的 `build` 在发现目标所在的 Godot 工程后，先通过匹配的 Godot **4.7.2 stable** 编辑器执行无界面资源导入，再加载检查工程脚本、场景和资源，最后执行 Dora 脚本构建。建议以工程目录调用 `build`；即使目标是 `init.ts`，也不会跳过所在 Godot 工程的检查。Godot 3、声明依赖 C#/Mono 的工程和原生 GDExtension sidecar 会被拒绝。

可通过启动 Dora 进程的环境变量 `DORA_GODOT_EDITOR` 指定编辑器可执行文件（macOS 也接受 `.app` 路径）。未指定时，macOS 检查 `/Applications/Godot.app/Contents/MacOS/Godot`，并尝试 PATH 中的 `godot`、`godot4`；其它桌面平台尝试 PATH。版本不匹配或缺少编辑器会报告工具配置错误。

Agent 开发构建直接导入当前源码工程，正常生成 `.uid`、`.import` 等元数据及 `.godot` 缓存；这与下方 `project.py` 的独立副本交付流程不同。诊断另存于 `.agent/godot/import.log`、`.agent/godot/validate.log`。导入或检查失败、超时、取消及输出超限均不会记为构建通过；检查成功也不代表游戏逻辑或 GPU 画面已验收。试玩和截图仍通过 Dora 宿主入口进行。

Godot 开发面向桌面 Dora 的 Web IDE。Dora Studio 面向轻量的浏览器游戏开发，明确不支持 Godot 开发，也不规划为其接入编辑器导入服务。移动端当前没有编辑器导入服务；包含 Godot 运行库不等于可以进行编辑器资源导入。

## 从仓库运行

可指定工程目录、`project.godot`，或只包含一个工程的仓库。多工程仓库用 `--project` 选择相对目录。Git URL 会 clone 到本次工作目录；源码 ZIP 会先解包，省略 `.git` 和 `.godot`，再重新导入。

```sh
python3 Tools/Godot/project.py inspect /path/to/repository
python3 Tools/Godot/project.py import /path/to/repository.zip --output /path/to/new-repository
python3 Tools/Godot/project.py clone https://example.org/game.git --output /path/to/new-clone

python3 Tools/Godot/project.py run /path/to/repository \
  --project path/to/game \
  --godot /path/to/Godot-4.7.2 \
  --app /path/to/ordinary/Dora.app \
  --runtime-package /path/to/godot-runtime/package \
  --work-dir /path/to/new-preview
```

`run` 的输入也可以直接使用 Git URL 或源码 ZIP。Linux/Windows 用 `--binary /path/to/Dora --asset-source /path/to/Assets` 替代 `--app`。运行库必须匹配宿主平台和图形后端；本轮实际验收为 macOS Metal。

导入使用 Godot **4.7 stable**（本轮固定 4.7.2） 编辑器，可通过 `--godot` 或 `DORA_GODOT_EDITOR` 指定。编辑器在独立副本内执行 `--headless --editor --import`，不会由工具改写作者仓库；导入前后核对源文件摘要。工程代码/编辑器插件仍会执行，这个目录隔离不构成代码沙箱。

已有导入缓存也会在独立副本中重新生成，避免携带其他 Godot 版本或平台的旧缓存。仅准备工程、不启动 Dora：

```sh
python3 Tools/Godot/project.py prepare /path/to/repository \
  --godot /path/to/Godot-4.7.2 --output /path/to/new-prepared
```

返回 JSON 中的 `project` 可以直接传给现有 `Dora.GodotNode(project, ...)`。准备目录包含导入日志和来源/编辑器摘要。失败时保留日志，重试使用新输出目录。多工程选择路径在源码 ZIP 解包并去掉单层仓库包装目录后解析。

## 导出与加载试玩包

PCK 由 Godot 的标准 `--export-pack` 生成，保留导出后的资源、脚本和 remap。已有导出配置时指定 `--preset`；只有一个 preset 时自动选取。没有导出配置时，使用 `--platform` 在独立副本中生成基础配置。

```sh
python3 Tools/Godot/project.py export /path/to/repository \
  --godot /path/to/Godot-4.7.2 --id org.example.game --version 1.0.0 \
  --platform macOS --work-dir /path/to/new-build --output /path/to/new-game

python3 Tools/Godot/project.py archive /path/to/new-game \
  --output /path/to/game.dora-game
python3 Tools/Godot/project.py install /path/to/game.dora-game \
  --output /path/to/new-installed-game

python3 Tools/Godot/project.py run /path/to/game.dora-game \
  --app /path/to/ordinary/Dora.app \
  --runtime-package /path/to/godot-runtime/package \
  --work-dir /path/to/new-package-preview
```

已导出的试玩包不需要编辑器。`run` 也接受独立 `.pck`、安装目录或其中的 `game.json`。Godot 自带导出 ZIP 请选用 PCK 导出，源码 ZIP 与 Dora 试玩归档是两种不同输入。

包目录包含：

- `game.json`：游戏 ID、名称、版本、目标平台、Godot 4.7/无 Mono 要求（加载器保留已有 4.6 数据包声明兼容）、PCK 入口、资源摘要和可用 Git revision。
- `game.pck`：游戏数据，复用宿主的 LibGodot，不重复分发引擎二进制。
- `licenses/`：发现的工程/仓库根目录许可证；发布者仍须补齐实际素材和依赖的许可义务。

`.dora-game` 是上述目录的 ZIP。安装会验证路径、重复项、展开大小/文件数、清单、PCK 索引和 SHA-256，验证成功后才发布安装目录，不覆盖已有目录。默认上限为 4 GiB/10,000 项，可在显式 `install` 中调整。完整性校验不代表发行者签名或代码安全审核。

## 试玩行为与当前边界

默认窗口中按比例显示游戏，使用现有 GodotNode 的 GPU 共享路径。可选 `--width/--height/--buffers` 调整视口和缓冲数；`--duration 5 --capture /path/to/frame.png` 在可见运行后截图并结束。默认运行到用户关闭窗口。`--no-run` 只准备宿主和启动回执。

宿主副本使用普通 Dora 入口，拒绝专用 Godot 测试宿主。macOS 副本会做本地 ad-hoc 签名，原应用不改写；这不是发布签名或安装器。运行库由 `--runtime-package` 选择，原运行库和游戏包保持分离。

当前支持 Godot 4 的 GDScript/SceneTree 工程。Godot C#/Mono 与原生 GDExtension sidecar 分发明确拒绝；Dora 原有 C# 功能不受影响。作者工程依赖特定渲染器的效果仍需实际验证，不做自动等价转换。Git LFS、子模块等资源须在输入仓库中完整可用。

此入口每次试玩启动一个普通 Dora 进程，遵守现有 GUI 单实例规则，不向已运行的 Dora 强行切换工程。**常驻 Dora 内切换已另有 [macOS Metal / Linux EGL / Windows x64 WGL / Android EGL / WebGL2默认能力](PROJECT_SWITCH.md)，未接入本命令；其他平台与兼容性工作仍见 PROJECT-SWITCH-01**；本流程为其提供已准备目录/已验证 PCK。浏览器、移动端的分发 UI、存档隔离和来源信任机制尚未接入。

## 本地验证

```sh
xmake dora-test --repo=/path/to/Dora-Example --suite=godot-projects
python3 "$DORA_TEST_REPO/Test/Godot/run_project_delivery.py" \
  --godot /path/to/Godot-4.7.2 --app /path/to/ordinary/Dora.app \
  --runtime-package /path/to/godot-runtime/package --output /path/to/fresh-results
```

后者串行验证 clone/导入/原工程试玩、标准导出/归档/安装/包试玩，核对作者和 clone 摘要不变、导入 PNG 的实际像素、动态帧、零 blit 与 GPU 排空。它使用两个连续的 Dora 进程，不替代同一进程的跨工程切换或其他平台验收。
