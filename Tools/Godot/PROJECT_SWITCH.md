# 进程内项目卸载与切换

按 2026-11-04 的决定，保留一个进程内 LibGodot 实例和渲染设备，在项目边界重建 SceneTree。此方案不销毁、重建 LibGodot，也不以 Worker 进程承载工程切换。

## 当前可用范围

macOS Metal 的项目卸载和切换默认启用，无需环境变量。能力由匹配运行库的项目生命周期接口确认；旧实验环境开关已移除。保留基础 bridge ABI 1，增加可选的项目生命周期扩展；宿主用它确认项目清理成功，没有增加动态库。

在 macOS Metal 上，移除一个活动 `GodotNode` 会在宿主 GPU 读取排空、PCM 生产线程停止之后卸载工程。卸载完成后，可创建另一个 `GodotNode` 加载已导入的工程目录或独立 PCK。一次只允许一个活动节点；同工程重开也会清理项目状态。`restartScene` 仍是当前项目的场景重启。

当前清理包括：

- 场景树、Autoload、定时器、Tween、排队回调及工程注册的 Engine singleton。
- GDScript 全局常量、静态脚本、解析/编译缓存、全局类列表和 `res://` 资源身份。
- 项目设置与内建默认值、功能覆盖、资源包挂载、UID、InputMap 和按下状态。
- 工程主题、主翻译域、全局 shader 参数、音频总线、待播放项与混音余量、默认 TLS 证书。

渲染器、设备和 LibGodot 对象继续存活。新的 SceneTree 使用上游主场景、Autoload、窗口拉伸初始化流程，不再次执行 `Main::setup2()`。

## 限制与未完成项

macOS Metal 已作为默认功能开放；下述平台与项目兼容性边界仍然适用。

- 仅接入并动态验证 macOS Metal；GL/EGL/WGL/WebGL2、iOS 和 D3D12 尚未接入项目切换。公共源码改动尚须逐平台构建和回归。
- 使用标准 SceneTree 与 GDScript。Godot C#/Mono、原生 GDExtension 不支持；Dora 原有 C# 不变。未 join 的脚本 Thread 会被拒绝。关闭时发现不支持状态，会保留暂停树用于最终退出，并拒绝再次打开项目。
- 工程必须释放自己创建的树外对象、线程、网络连接及外部回调。当前实现不保证任意第三方工程的全部全局副作用都被隔离；附加翻译域、服务器全局状态、树外引用和实际联网仍须审计。
- 首次引擎初始化失败后需重启 Dora；已成功启动后的无主场景项目拒绝与后续有效工程恢复已验证，其他失败阶段仍须补充。
- `GodotNode` 关闭在渲染线程排队执行；现在通过 `unloadAsync` 回调确认完成，`GodotPlayer` 以此串行切换。不能把 `running=false` 或固定延时当作卸载完成通知。
- `project.py run` 仍是单次试玩进程入口；常驻项目切换由 Lua 节点或控制器驱动，未接入工程浏览/Hub UI，也未改动单次试玩命令的环境隔离规则。

## 卸载通知与串行控制器

C++/Lua 的 `GodotNode:unloadAsync(function(ok, error) ... end)` 移除节点，在逻辑线程通知结果。成功回调之前，宿主GPU读取、PCM生产、Godot项目清理和客户端占用已全部释放。只读属性 `unloaded` 此时变为true。重复调用以及完成后的调用都异步得到同一结果；回调可直接创建下一个节点，不需要帧数或时间间隔。

旧库、其他后端或不安全状态会返回false及原因；此时不能声称项目已完整卸载。启动前取消也会清理已排队的宿主资源。应用退出、逻辑循环已停止后不保证派发剩余回调。

生产Lua模块位于 `Assets/Script/Lib/GodotPlayer.lua`，随常规Dora资源部署，附带TS声明。正常Dora脚本环境可以直接使用：

```lua
local Player = require("GodotPlayer")
local player = Player() -- 默认挂到 Director.ui；也可指定游戏父节点
player:switchAsync(projectA, {width=640, height=360, buffers=3}, function(ok, game, message)
    if not ok then print(message); return end
    -- game 已经 running，可发送输入、调整显示和开始试玩。
end)
-- 用户稍后选择另一个工程；并发提交的请求按 FIFO 处理。
player:switchAsync(projectB, {}, function(ok, game, message)
    if not ok then print(message) end
end)
-- 排空已经接受的请求并卸载；此后新请求返回 nil, reason。
player:closeAsync(function(ok, message) print(ok, message) end)
```

`switchAsync` / `unloadAsync` 返回请求ID，关闭后返回 `nil, reason`；选项在入队时复制。切换回调为 `(ok, game, message)`，单独卸载时game为nil。启动失败/超时也先等待原生卸载，再回调和处理下一个请求；卸载失败会使控制器faulted，后续请求逐个失败。用户回调抛错会记录错误，不阻塞队列。`closeAsync` 回调为 `(ok, message)`，重复关闭均得到结果。调用者应在销毁游戏父节点之前关闭控制器；它的调度节点位于Director.ui，不能仅丢弃Lua引用作为资源释放方式。

常驻Renderer的shader cache使用宿主缓存目录 `Dora/LibGodot-4.6/metal`，不跟随 `user://` 在切换时改变根路径，也不写回作者工程。缓存仍然启用，按上游shader哈希管理。

## 复现与验收

测试和夹具保存在 Dora-Example：

```sh
python3 "$DORA_TEST_REPO/Test/Godot/run_project_switch.py" \
  --godot /path/to/Godot-4.6 \
  --app /path/to/ordinary/Dora.app \
  --runtime-package /path/to/sealed/macos-runtime \
  --output /path/to/fresh-output
```

该驱动只启动一个普通 Dora 进程，测试 A → A → B → A → B 的 PCK → A 的 PCK → B，交替使用 2/3/4 缓冲。它核对同一 LibGodot 实例 ID、七个不同 SceneTree ID、静态变量/资源/Autoload/输入/设置隔离、用户 singleton 和音频总线清理、逐阶段画面像素、A 的有效音频及 B 的零残留音频、GPU 排空。另验证第二活动客户端拒绝、无主场景工程拒绝后恢复。

默认配置夹具报告为 `build/godot-project-default-v1/fixture/verification.json`，包括重复订阅、完成后订阅、失败恢复及单活动实例限制；不设置实验环境变量。控制器8项FIFO/回调重入/失败/超时/关闭契约覆盖不变。默认切换、启动取消与旧库缺少生命周期接口的明确拒绝见同目录 `edges/verification.json`。

真实项目使用官方godot-demo-projects的4.3分支固定提交 `52e30044658448149b04e8f69b475eebbfbd8f6e`（项目声明4.2），由Godot4.6导入未修改副本。Dodge the Creeps（2D）与Squash the Creeps（3D）源码/PCK交替8次，2/3/4缓冲、24张截图、公开输入引起的2D位移、动态画面、有效音频与GPU排空通过；相同项目的卸载后对象/资源计数重复一致，场景节点均0。默认配置复验报告为 `build/godot-project-default-v1/real/verification.json`。这证明本轮有界反复切换，不替代任意复杂工程或长期/GPU显存稳定性验收。

```sh
lua "$DORA_TEST_REPO/Test/Godot/tests/project_switch/controller_contract.lua" Assets/Script/Lib/GodotPlayer.lua
python3 "$DORA_TEST_REPO/Test/Godot/run_real_project_switch.py" \
  --godot /path/to/Godot-4.6 --app /path/to/ordinary/Dora.app \
  --runtime-package /path/to/sealed/macos-runtime \
  --repository /path/to/fixed-official-demo-repository --output /path/to/fresh-output
```

默认化记录暂存 `build/godot-project-default-v1/`；此前通知及缓存修复记录保留在 `build/godot-project-controller-v1/`，早期原型在 `build/godot-project-switch-v1/`。保留旧证据，不恢复已移除的history目录。
