# LibGodot → Metal 多缓冲 → bgfx → Dora 动态原型

macOS / Apple Silicon 的可选实验。Godot 使用原生 Metal 渲染器持续运行，GDScript `_process(delta)` 旋转立方体；Dora 使用 Sprite 显示多缓冲纹理快照。每个生产帧通过一次 GPU blit 进入环形纹理，bgfx 接入同一个环形 `MTLTexture` 对象。传图通路不读回 CPU 像素。

## 运行

需要 Xcode、Python 3、xmake 和网络连接。在仓库根目录执行：

```sh
Tools/LibGodotMetalProbe/run.sh
```

默认三个共享缓冲、1,800 个 Dora 更新帧（约 30 秒）后自动退出。首次运行下载固定 Godot `4.6-stable`，校验归档 SHA-256，在本地 venv 构建裁剪的 LibGodot。依赖和生成的 Dora.app 位于 `build/godot-metal-probe/`；不替换系统 Godot。

- `--build-only`：只构建。
- `DORA_GODOT_PROBE_BUFFERS=2|3|4`：环形缓冲数量。
- `DORA_GODOT_PROBE_FRAMES=1800`：验证运行帧数，范围 600–36000。
- `DORA_GODOT_PROBE_KEEP_OPEN=1`：达到验证帧数后继续动画，手动关闭窗口。
- `DORA_GODOT_PROBE_OUTPUT=/absolute/path`：本次结果目录，默认 `build/godot-metal-probe/results`。
- `DORA_GODOT_PROBE_UNLIMITED=1`：关闭 Dora 的 CPU 帧率限制。
- `DORA_GODOT_PROBE_GPU_WORK=1000000`：每个消费帧加入可控的 Metal compute 负载，用来积压消费者队列、验证缓冲复用等待；默认 0。
- `JOBS=4`：调整编译并发。

没有 KEEP_OPEN 时，启动器设有进程超时；GPU 同步死锁会作为失败退出。

双缓冲压力测试示例：

```sh
DORA_GODOT_PROBE_BUFFERS=2 \
DORA_GODOT_PROBE_FRAMES=1200 \
DORA_GODOT_PROBE_GPU_WORK=1000000 \
DORA_GODOT_PROBE_UNLIMITED=1 \
DORA_GODOT_PROBE_OUTPUT="$PWD/build/godot-metal-probe/double-buffer-stress" \
Tools/LibGodotMetalProbe/run.sh
```

## GPU 同步与缓冲所有权

每个缓冲区都有私有 Metal 纹理、`ready` SharedEvent 和 `consumed` SharedEvent，两条事件时间线只递增。

1. **预留**：Dora 逻辑线程选取当前未显示的槽位，冻结其最后一个读票据。后续帧继续显示当前槽位，直到新槽位发布。
2. **生产**：在 Dora 主线程推进一次 LibGodot 场景迭代，执行 GDScript 动画，再调用 Godot 离屏 draw。
3. **非阻塞背压**：预留槽位最后一次消费尚未完成时，本轮延后生产、继续显示当前快照，不阻塞 CPU。Godot 内部会同步等待自己的 frame fence；若提前向生产队列放入尚未完成的消费依赖，可能阻塞宿主返回消费提交循环。
4. **保护覆盖**：Godot 同一个 Metal command queue 上的 blit 命令先等目标槽位的 `consumed >= 最后读票据`，再把本帧 Viewport 复制到槽位，最后发出 `ready = 生产序号`。
5. **发布**：把新槽位和生产序号发布给 Dora 逻辑线程，更新 Sprite 的 Texture2D。
6. **消费**：在 bgfx 实际提交的 Metal 命令缓冲中，所有绘制前编码 `ready` 等待；全部采样编码器结束后编码 `consumed = bgfx帧号`。
7. **回收**：同一生产帧可能显示多次。每个消费帧都有独立读票据，生产者等待最后一个票据，避免只等首次读取完成就覆盖仍在显示的纹理。

帧间的共享同步采用 GPU event wait/signal；原型没有逐帧 `waitUntilCompleted()`。Godot/bgfx 自身仍可能为内部资源和队列节流而等待 CPU。原型在退出时等待生产队列排空，并检查所有消费 command buffer 的完成状态。

Godot 的原始 Viewport 始终由 Godot 队列访问；快照 blit 也提交到同一队列，确保下一次 Viewport 写入不会与上一次复制竞争。消费者只访问环形快照纹理。

## 验证产物

结果目录包含：

- `run.log`：生产、消费、GPU wait/signal、完成回调和错误计数。
- `frames.csv`：每个实际 bgfx 消费帧对应的缓冲槽、生产序号及编码时已完成的 ready 值。
- `captures.csv`：截图所对应的确切生产序号、缓冲槽和 bgfx 帧号。
- `animation-*.png`：Dora 节点变换保持不变时的多张动画截图。
- `dora-transformed-frame.png`：同一动态画面叠加 Dora 节点旋转、缩放和透明度后的截图。

安装 Pillow 后运行：

```sh
python3 Tools/LibGodotMetalProbe/verify_outputs.py
python3 Tools/LibGodotMetalProbe/verify_outputs.py build/godot-metal-probe/double-buffer-stress
```

验证器会保存 `verification.json`，检查：

- 每个环形槽被反复使用，生产序号不倒退，消费帧号不重复。
- 所有生产 blit、消费 command buffer 都完成，wait/signal 数相等，GPU 错误和遗留票据均为零。
- Godot 绘制的上下两条 16 位帧号条码相等，且**等于该截图的提交记录**，检测抽样画面的撕裂、过期和错槽。
- 在 Dora 节点变换保持不变时，立方体区域持续变化，排除靠 Dora 节点变换伪装动画或只有条码变化的情况。

截图会读回最终 Dora 合成结果，这是验证产物，不是两引擎之间的传图通路。条码和画面检查是抽样验证，GPU 完成与错误计数覆盖每个已提交帧。

## 本机验证记录（2026-10-27）

Apple M1 Pro / macOS 26.6.2，全部通过：

| 场景 | 缓冲数 | Godot 生产并完成 | Dora 消费并完成 | 编码时复用尚未完成 | GPU 错误 |
| --- | --- | --- | --- | --- | --- |
| 默认连续动画 | 3 | 1789 | 1800 | 0 | 0 |
| 无 CPU 帧率限制 + GPU compute 压力 | 2 | 601 | 1200 | 593 | 0 |
| Metal API Validation + GPU compute 压力 | 2 | 303 | 600 | 296 | 0 |

总计 3,600 个消费帧。所有抽样帧号与提交记录完全一致，画面中心的立方体持续变化；所有 GPU wait/signal 成对，退出无遗留票据、Godot 错误或 bgfx 资源泄漏报告。Metal 验证层日志明确记录 `Metal API Validation Enabled`，并观测到 1 次编码时生产事件尚未完成。这里的“尚未完成”是 CPU 编码时读取事件值的统计，不是 GPU 停顿时长测量。

压力场景中同一生产帧通常消费两次，覆盖了“重复显示时必须等最后一次读取完成”的复用路径。三组验证结果分别位于 `results`、`double-buffer-stress`、`metal-validation` 目录。

## 当前代码回归（2026-10-28）

运行 `Tools/LibGodotMetalProbe/test_matrix.sh`，三组均开启 Metal API Validation 和不限 CPU 帧率：

| 场景 | 缓冲数 | 生产并完成 | 消费并完成 | 延后生产次数 | GPU 错误 |
| --- | --- | --- | --- | --- | --- |
| 连续动画 | 3 | 895 | 1800 | 13 | 0 |
| GPU compute 压力 | 2 | 202 | 1200 | 799 | 0 |
| GPU compute 压力 | 4 | 300 | 600 | 5 | 0 |

合计 3,600 个消费帧，所有抽样上下条码与该帧提交记录一致，立方体区域持续变化，全部 wait/signal 配对完成，遗留票据为零。报告：`build/godot-metal-probe/current-matrix/verification.json`。

本次首次双缓冲重跑发现 Godot 内部四次 `timeout waiting for fence`，尽管最终 GPU 计数完整，仍判为失败。修复在逻辑线程增加非阻塞背压，消费未完成便延后生产；上述结果为修复后重跑。旧失败日志保留在 `build/godot-metal-probe/fence-timeout-before-fix/run.log`。这些是有限帧数的压力验证，尚不代表长期运行、设备丢失或其他 GPU 后端验证。

正式 `GodotNode` 及项目/输入/生命周期测试见 [Tools/Godot](../Godot/README.md)。

另完成三缓冲 36,000 个消费帧的约十分钟连续运行，开启 Metal API Validation。
35,875 个生产帧全部完成，36,000 次消费 wait/signal 全部完成，GPU 错误和遗留
票据均为零；122 个抽样帧号匹配提交记录，立方体持续变化。报告位于
`build/godot-metal-probe/soak-36000/verification.json`。这仍是本机有限时间验证，
不代表设备丢失恢复或其他平台通过。

## 构建边界与限制

- `DORA_BUILD_LIBGODOT_METAL_PROBE=1` 才编译宿主、启动入口及 bgfx Metal 的两个 GPU 编码钩子；普通 Dora 构建没有这些调用。
- `prepare_godot.py` 只修改下载到 build 目录的 Godot：实验模块、无窗口 Metal 显示后端、Headless OS 宿主，以及跳过屏幕呈现管线和启动画面。Dora 保持 NSApplication、窗口和最终呈现的所有权。
- LibGodot 仅导出六个 C 入口，隔离两引擎不同版本 glslang/C++ 符号。固定源码归档 SHA-256 为 `b451eaa16d3abe0c7430e9ce1c4e83b146e5670e5b683dd8995c931fc82b57a0`。
- 共享纹理由两边 ARC 引用和 bgfx Metal 包装自己的 retain 保留；Dora 逻辑线程在退出时释放 bgfx 包装，bgfx shutdown 排空消费者后再销毁 Godot。动态库保留到进程退出。
- 仅覆盖单 runtime、单节点、640×360 RGBA8 Viewport、同一 MTLDevice 和当前 Dora 提交路径；未实现窗口尺寸变化、设备丢失、运行时重启、多个 Godot 项目、输入/音频桥接和其他平台。
- 2/3/4 个环形 RGBA8 纹理固定占用约 1.76/2.64/3.52 MiB，另有 Godot Viewport、Dora 目标、Shader 等正常资源。验证 trace 会随运行帧数增长。
- Debug / 无优化构建和附加 GPU 压力负载不用于评估正式运行性能。
