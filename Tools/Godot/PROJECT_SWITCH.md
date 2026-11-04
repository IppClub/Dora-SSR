# 进程内项目卸载与切换

按 2026-11-04 的决定，保留一个进程内 LibGodot 实例和渲染设备，在项目边界重建 SceneTree。此方案不销毁、重建 LibGodot，也不以 Worker 进程承载工程切换。

## 当前可用范围

macOS Metal、Linux EGL、Windows x64 WGL、Android EGL 和 WebGL2 的项目卸载和切换默认启用，无需环境变量。能力由匹配运行库的项目生命周期接口确认；旧实验环境开关已移除。保留基础 bridge ABI 1，增加可选的项目生命周期扩展；宿主用它确认项目清理成功，没有增加动态库。

在 macOS Metal / Linux EGL / Windows x64 WGL / Android EGL / WebGL2 上，移除一个活动 `GodotNode` 会在宿主 GPU 读取排空、PCM 生产停止之后卸载工程。卸载完成后，可创建另一个 `GodotNode` 加载已导入的工程目录或独立 PCK。一次只允许一个活动节点；同工程重开也会清理项目状态。`restartScene` 仍是当前项目的场景重启。

当前清理包括：

- 场景树、Autoload、定时器、Tween、排队回调及工程注册的 Engine singleton。
- GDScript 全局常量、静态脚本、解析/编译缓存、全局类列表和 `res://` 资源身份。
- 项目设置与内建默认值、功能覆盖、资源包挂载、UID、InputMap 和按下状态。
- 工程主题、主翻译域、全局 shader 参数、音频总线、待播放项与混音余量、默认 TLS 证书。

渲染器、设备和 LibGodot 对象继续存活。新的 SceneTree 使用上游主场景、Autoload、窗口拉伸初始化流程，不再次执行 `Main::setup2()`。

## 限制与未完成项

macOS Metal、Linux EGL、Windows x64 WGL、Android EGL、WebGL2 已作为默认功能开放；下述平台与项目兼容性边界仍然适用。

- 已接入 macOS Metal、Linux EGL、Windows x64 WGL、Android EGL 和 WebGL2；Linux ARM64 Debug 已在 Ubuntu / Mesa virgl 虚拟机动态验收；Linux x64、Release 及长期显存稳定性仍待验证。Windows x64 Debug WGL 已在 Parallels Windows 11 ARM VM 的 x64 普通进程通过：复用先前五次加载/边界控制证据，修复阴影采样后只复验 B→A→B 的完整画面与同步；物理 Windows GPU、Release 和长期稳定性未覆盖；Android arm64 Release EGL已在API35／SwiftShader模拟器完成五次真实项目切换，保留已知shader binary回退告警，严格缓存无告警仍未验收；WebGL2默认Release已在宿主浏览器验收，见下文；iOS 和 D3D12 尚未接入项目切换。
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

常驻Renderer的shader cache使用宿主缓存目录 `Dora/LibGodot-4.6/metal` 或 `Dora/LibGodot-4.6/egl` 或 `Dora/LibGodot-4.6/wgl`，不跟随 `user://` 在切换时改变根路径，也不写回作者工程。缓存仍然启用，按上游shader哈希管理。

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

### Linux EGL

三个串行驱动 `run_project_switch.py`、`run_real_project_switch.py` 和 `run_project_lifecycle_edges.py` 接受 `--binary /path/to/ordinary/Dora --asset-source /path/to/Assets`，替代 macOS 的 `--app`。运行库必须是匹配的 Linux EGL 包，资源导入使用 Godot 4.6。无桌面会话时用 `tests/with_weston.py --logs /fresh/weston -- <同一命令>` 包装，保留实际 EGL 渲染器日志。

项目边界先排空两侧 GPU 队列并解除 Godot FBO 对宿主纹理的挂接，再清理项目。EGL producer context 和常驻 renderer 保留，空闲纹理环按新项目的尺寸及 2/3/4 缓冲数重建。稳态依旧直接写 Dora/bgfx 纹理，不增加 framebuffer blit。卸载完成通知从渲染线程返回逻辑线程后，控制器才启动下一项目。

Linux 一次性串行入口（隔离夹具 → 取消/旧库边界 → 官方游戏）：

```sh
python3 "$DORA_TEST_REPO/Test/Godot/run_linux_project_switch.py" \
  --godot /path/to/Godot-4.6-linux.arm64 \
  --binary /path/to/ordinary/Dora --asset-source Assets \
  --runtime-package /path/to/sealed/linux-runtime \
  --legacy-runtime-package /path/to/previous/linux-runtime \
  --repository /path/to/godot-demo-projects \
  --output /path/to/fresh-output
```

`--legacy-runtime-package` 可省略；传入时验证缺少项目生命周期扩展的旧库会拒绝继续切换。驱动自动管理各组独立 Weston；虚拟机的启动/关闭由调用者负责。真实游戏使用 `2d/dodge_the_creeps` 和 `3d/squash_the_creeps`，不改作者源码，报告中保留仓库 revision、执行文件摘要、截图与真实渲染器。

Linux 本地验收：官方工程 revision `52e30044658448149b04e8f69b475eebbfbd8f6e`，Godot 4.6；Mesa 25.2.8 / virgl (Apple M1 Pro Compat) / OpenGL ES 3.0。八轮源码/PCK切换使用同一 LibGodot、八棵不同 SceneTree，24张截图；每轮149–169共享帧，公开D键让2D角色移动约226像素。GPU错误、未完成读取、blit和音频欠载均0；重复访问后2D/3D项目卸载对象数分别246/243、资源1、场景节点0。隔离夹具七轮、重复订阅、无主场景拒绝恢复、默认队列、启动前取消及旧库拒绝也通过。完整结果在 `build/godot-project-linux-v1/acceptance-v3/verification.json`，详细过程保留在同级任务目录的 `PROGRESS-DRAFT.md`；这不代替长期GPU显存或更多工程兼容性验收。

### Windows x64 WGL

宿主启动前设置 `DORA_GODOT_WINDOWS_GL=1`，使用匹配的 x64 WGL 运行库与普通 Dora.exe：

```sh
python "$DORA_TEST_REPO/Test/Godot/run_project_switch_windows.py" \
  --binary C:/Dora/Dora.exe --asset-source C:/Dora/Assets \
  --runtime-package C:/runtime --project-a C:/prepared-dodge \
  --project-b C:/squash/game.pck \
  --source-revision 52e30044658448149b04e8f69b475eebbfbd8f6e \
  --output C:/fresh-output
```

默认一轮 `A源码(2) → B的PCK(3) → A(4) → B(2) → A(3)`，同时检查取消、失败恢复、活动实例拒绝和重复卸载通知。`--targeted-3d` 只跑 `B(3) → A(4) → B(2)`，复用先前边界证据，不代表再次执行完整五次组合。

本地范围：Windows 11 ARM VM，x64 Debug 普通宿主，Parallels OpenGL 3.3 / Metal (Apple M1 Pro)。原版 Godot 4.6 也在该环境出现阴影开启时几何缺失；只对 Windows 的 Parallels GL vendor 使用手动投影后的深度比较采样，其他驱动保留 `textureProjLod`。阴影、原有滤波、正交相机与4×MSAA保持开启。原始PCK未改动，修复后9图、158/163/216共享帧、公开输入约209像素位移、非零PCM、零blit/错误/未完成读取/欠载通过；重复3D卸载对象243、资源1、节点0。证据见 `build/godot-wgl-shadow-v1/targeted-projection/verification.json`；先前五次生命周期及边界证据见 `build/godot-project-wgl-v1/acceptance/`。不扩展为物理硬件或其他平台验收。

### Android EGL

匹配的新运行库和宿主默认提供卸载通知及项目切换。Java/JNI服务、Activity、LibGodot、renderer和EGL context均保留；只结束项目级场景与状态，不提供Java插件或文件系统沙箱隔离。嵌入模式从实际工程目录/PCK解析资源，独立Godot APK的资源根目录行为不变。常驻shader cache根位于Android缓存目录下的 `Dora/LibGodot-4.6/egl`。

Dora-Example的 `prepare_project_switch_android.py` 接受已导入的 `--project-a` 源码目录、Android目标的 `--project-b` PCK、`--source-revision` 和新的 `--output` 资源目录。使用 `dora.godot.test=false` 构建普通Release及独立 `tests/android/lifecycle` 控制器后运行：

```sh
python3 "$DORA_TEST_REPO/Test/Godot/run_android_project_switch.py" \
  --sdk "$ANDROID_HOME" --serial emulator-5554 --owned-avd DoraGodotRC1_example \
  --apk /path/to/ordinary-release.apk --runtime-package /path/to/android-runtime \
  --lifecycle-apk /path/to/controller.apk --assets-manifest /path/to/assets-manifest.json \
  --output /path/to/fresh-output
```

驱动只接受显式命名的专用模拟器，单进程执行 `A源码(2) → B的PCK(3) → A(4) → B(2) → A(3)`，补一次无主场景失败恢复、启动取消、活动实例拒绝及重复卸载通知；控制器在Lua完成后调用正常Activity.finish并导出平面证据及作者文件/PCK摘要。`--verify-only` 仅复核已导出的证据，不重启应用。模拟器创建、启动和关闭由调用者管理。

本轮范围：API35 ARM64、arm64非debuggable Release、SwiftShader／ANGLE GLES3.1。五次共享帧250/252/254/265/245、15图、2D公开输入约273像素位移、有效PCM、零blit/错误/未完成读取/欠载通过；作者源码/资源及PCK前后摘要一致，12个导入元数据文件的Godot4.6生成变化单独登记。重复2D/3D卸载对象245/242、资源1、节点0。复用现有Android普通Release对已知模拟器告警的分类，报告完整保留一次shader binary源码回退告警及 `shader_cache_clean=false`；不等同跨进程暖缓存或严格无告警验收。该缺口继续由ANDROID-SHADER-CACHE-01跟踪，不关闭缓存或隐藏告警。完整功能报告为 `build/godot-project-android-v1/acceptance-v2/verification.json`；首轮文件系统路径失败证据保留在同级 `acceptance/`，不增加其他平台或压力测试。

### WebGL2

匹配的默认Release Web宿主与运行库保留一个Godot WASM实例及其worker池，共用Dora的WebGL2 context。桥接只传递标量状态，函数指针不跨WASM表；Init能力协商保留旧协议，旧运行库不支持时卸载返回明确失败。启用Godot的Web包内置`GodotPlayer.lua`。

项目关闭先排空宿主读取和PCM，再卸载场景、解除借用纹理并回收复制到Godot文件系统的工程文件，之后才通知`unloadAsync`完成。只删除桥接拥有的副本及空目录，保留工程自行创建的其他文件和进程shader缓存；原Dora文件系统中的工程与`user://`数据不随卸载删除。资源复制失败会回滚，文件冲突会拒绝，不覆盖现存文件。重载后重新应用PCM混音模式，避免Web的Sample默认值绕过宿主音频。

本轮默认`dora-preset`、无原生诊断日志Release在宿主串行通过：Chrome156五次官方Dodge源码/Squash Web PCK交替（2/3/4/2/3缓冲），Firefox153、原生Safari26.6.2和Playwright WebKit26.5各A→B→A。共42张Dora合成截图，公开输入位移、动态画面、每轮非零PCM、GPU读取排空、零blit、工程副本哈希及卸载回收通过；同一实例、不同场景树，重复清理对象数稳定，资源1、节点0。Chrome补一次最终卸载后的真实context loss：平台服务关闭、拒绝重新加载，恢复仍需页面重载；不承诺丢失context内原地恢复。Firefox保留深度纹理比较过滤可能退化为NEAREST的驱动提示，Emscripten主线程等待提示也保持原有边界。

复现工具在Dora-Example `Test/Godot/tests/web/`：`prepare_project_switch.py`准备源码/PCK与主/冒烟包，`run_project_switch.cjs`串行运行Chrome/Firefox/WebKit，`run_project_switch_safari.py`使用已授权的原生Safari WebDriver，最后用`verify_project_switch.py`核对像素、资源哈希及生产C ABI计数。命令见README；详细证据暂存 `build/godot-project-web-v1/`。所有成功项通过后停止，未新增其他平台、移动浏览器或长期显存测试。
