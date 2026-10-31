# AI 程序化 3D 创作工具包：首期边界与引擎接口后续项

实现位于配套 Dora-Example 的 `Example/Creation3D/`，回归与运行记录位于 `Test/Creation3D/`。本轮复用现有公开接口，不修改渲染器；四种离线基础 GLB 经过 Model3D 实例化，组合为场景。它不是运行时顶点生成 API，也不是完整 3D 编辑器。

## 现有接口已能支持的工作

Node3D 的层级与变换、实例材质、Model3D 的本地/世界 bounds 和按名称播放动画、相机/方向光预设，以及已有 Jolt fixture/body 接口，足以实现本轮工具包。资产单位、前向、脚底、允许占地、独立碰撞配置、动画语义和失败诊断由脚本配置负责。相同 seed 使用独立伪随机序列，布局不依赖引擎全局 RNG。

本轮不需要为了组合场景新增引擎 API。混合版约 343ms 首载长帧定位到同步 Model3D 冷加载；样例入口现通过已有 Cache.loadAsync 完成后台解析和分帧上传，再构造场景。没有新增线程、渲染或上传接口。Town 的碰撞保持脚本逻辑；Jolt 用独立最小用例验证外观适配、box 边界射线、落地与接触。两者的证据不互相替代。

## 已完成：结构化模型加载诊断

统一使用 `Cache.getLoadDiagnostics(filename)`，返回 version=1 JSON：state、modelPath 及包含 code、severity、stage、resourcePath、textureSlot、imageIndex、materialIndex、message 的诊断列表。同步和异步导入共用原因与上下文；按用户要求移除原独立纯文本错误 getter，getLoadState 仍供轻量轮询。

Creation3D 的 Loader/Adapter 已读取此报告。已验证缺资源、结构/索引错误、buffer 错误、外部及嵌入贴图解码、材质槽、并发隔离、取消、缓存命中和重试清错。越界 POSITION 引用也已从原生 panic 修正为结构化校验失败。API 详见 [Cache](../../docs/api/Class/Cache.mdx)，本轮记录在 Dora-Example `Test/Creation3D/DIAGNOSTICS.md`。

## 后续确实需要接口的需求

| 需求触发条件 | 引擎缺口 | 本轮处理 |
| --- | --- | --- |
| 脚本需要在内存中构造或修改任意可渲染顶点、索引、法线、UV，或逐帧变形 | 公开 Mesh3D / Geometry API、上传/更新与生命周期契约 | 单独后续任务；不把 Model3D 组合或物理 mesh fixture 称作实现 |

Mesh3D 后续应明确静态/动态缓冲、索引格式、bounds 更新、材质绑定、法线和切线策略、主线程/异步上传及销毁契约；不可仅开放内部 mesh handle。纹理解码诊断已从实际 loader 接出，没有建立另一套导入器。

GPU instancing、大型编辑器、完整动画混合与重定向、生成服务均未纳入本轮。当前运行数据记录实际三角形、draw、CPU 阶段与帧时间；资产字节数不能作为性能代理。达到明确预算上限后再评估批处理或其他性能接口。

## 验收状态

逻辑回归、资产失败/降级、动画包络和独立 Jolt 实测详见 Dora-Example 测试记录。真实窗口验收通过 `Test/Creation3D/input-basic.lua` 和 `input-mixed.lua` 分别执行，两种配置均完成两局、按钮与 R 键重来。初期窗口绑定超时在结束本轮自行启动的独立调试进程、改选当前工程 Dora.app 后解除，未修改权限；没有用直接调用玩法函数替代真实输入。实际输入还发现并修正了 Restart 按钮的锚点偏移和点击穿透。
