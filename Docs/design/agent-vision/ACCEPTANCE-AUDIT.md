# 首版验收审计（2026-09-06）

结论：首版功能、本地验收与三个真实游戏开发评测完成。本表按最终代码与证据核对；早期失败保留，不能用所有 JSON 的 success 字段简单计票。移动真机由用户明确延期。未覆盖的持续 OS 方向输入及其他平台不宣称通过；游戏评测完成不等于所有玩法认证。

| 要求 | 当前证据 | 结论 / 仍需核对 |
| --- | --- | --- |
| Remix 覆盖下取得本次游戏帧 | engine/smoke-result.json、window.tga、game.png、preview-pipeline-result.json | 本地通过；真实帧标记、游戏 HUD 与工具 UI 分离 |
| 相机、后处理、UI/UI3D、NanoVG、嵌套 RT、只渲染一次 | engine/layer-capture-result.json、layer-render-count.json、layer-game-*.png | 本地通过，最终 44 帧重复渲染计数 0 |
| systemUI 排序、根/子可见性及清理 | engine/system-ui-pixel-result.json、system-ui-state-contract.lua | 5 组像素与清理通过；native-children-visible-result.json 验证真实回读下原生 childrenVisible 隐藏/恢复及清理 |
| GPU 提交前/回读中取消与迟到结果 | engine/capture-cancel-result.json、capture-late-result.json | 8+9 项通过；主工具取消另见 preview-cancel |
| 项目入口运行权、争用、用户接管 | engine/entry-lease-contract-result.json、concurrent-entry-result.json、preview-takeover-result.json | 8+9+6 项通过；真实工具层双向争用，不冒称两个独立主 Agent 并发 |
| 预览启动异常、取消、超时、部分结果 | engine/preview-cancel-result.json、Preview.ts | 启动死循环和运行取消通过；第一帧发布后取消的 5 项检查通过：engine/preview-partial-result.json |
| 本地横竖屏/尺寸、后台恢复、资源 | G01—G03 图片；engine/preview-background*-result.json、preview-resource-extended-result.json | 本地窗口恢复及正式构建 40 轮稳定通过；不代表移动 OS 挂起，也不代表所有 GPU 后端 |
| 资产原子发布、归属、损坏/路径拒绝、孤儿与配额 | engine/asset-contract-result.json、asset-http-result.json、asset-lifecycle-result.json、vision-quota-contract-result.json、global-quota-result.json | 已有对应边界检查通过 |
| 父子会话/删除/改名生命周期 | engine/session-assets-lifecycle-result.json、session-assets-rename-integrated-result.json | 实际 DB/文件检查通过 |
| 固定同服务默认、未知端点不开放、无配置切换 | VisionBinding.ts、engine/vision-response-contract-result.json、真实会话记录 | 两家固定绑定通过；品牌和自定义网关不外推 |
| 独立单次视觉请求、纯文本主历史、实际图片输入 | G01/G02/G03/session 记录、engine/vision-http-result.json、VisionAnalysis.ts | 两家真实闭环和请求形状证据；不把接口成功当视觉正确 |
| 响应错误、拒绝、取消/超时、预算与 Unicode | engine/vision-http-result.json、vision-budget-result.json、vision-input-contract-result.json | 9 项 HTTP、6 项预算、22 项输入边界通过 |
| 视觉循环收敛、综合报告、受控上下文与压缩因果链 | vision-loop-contract-result.json、vision-compression-contract-result.json、vision-capture-budget-result.json、preview-game-contract-result.json、LIVE-ACCEPTANCE-2026-09-07.md、DEEPSEEK-LIVE-ACCEPTANCE-2026-09-07.md、VisionBudget.ts、HistoryProjection.ts | 契约和真实预算检查通过；会话 216 使用 3 批次/5 帧/2 请求，会话 217 纯 DeepSeek 使用 2 批次/4 帧/2 请求，均完成基线、集中修改和终态复查，非视觉轮 0 调用；压缩保留检查目的与结论并移除图片元数据。会话 216 的 3 次非法时间参数和会话 217 的 2 次非法入口参数均发生在捕获前；现已明确时间契约、接受源码入口，并由外层命令自动返回失败原因。真实源码入口与捕获回归通过 |
| 进程重启及强制上下文压缩后旧图复用 | G03/restart-landscape-session.json、compression-session.json | 556/557 实际任务通过；不要用模块单测代替 |
| XML 工具模式 | engine/vision-xml-result.json、web-session/xml-before-fix-session.json | 实测发现数组文本未解析；已修复并通过 10 项契约，修复数组及完成/修复规则后，212/565 实际 XML 取景→分析→最终文本 DONE；10+9 项契约通过。旧 561—564 失败保留 |
| 计划模式仅分析旧图，禁止启动游戏 | Registry.ts、DoraAgent.ts 的模式/能力过滤 | 12 项注册断言通过；web-session/plan-result.json 的真实 plan 请求通过，仅分析旧图、入口 runId 不变、源码不变 |
| Web IDE 实际会话图片、模型、报告、缺失占位 | web-session/session.json、ui-result.json、RESULT.md | 真实会话 211/559 及 12 项 UI 观察通过 |
| 本机 Remix 图片与放大交互 | PROGRESS 真实 Remix 记录；G03 会话 | 实际操作通过；移动真机延期 |
| G01 真实 Agent 游戏开发评测 | G01/RESULT.md、baseline/vision session、manual-observations.json | 视觉准确子集、鼠标/空格玩法检查；无修改收益，不虚构提升 |
| G02 真实 Agent 游戏开发评测 | G02/RESULT.md、camera-fix-session.json、runtime-result.json、runtime-visual-review.json | 开场布局改善；动态原图发现相机错误，560 修复后同路线 625 帧通过；模拟输入与 OS 输入分开 |
| G03 真实 Agent 游戏开发评测 | G03/RESULT.md、各任务 session、input-fixed-code | 坐标不作为核心验收要求；保留遮挡/OCR 误判；恢复/压缩通过；快速重开修复由独立输入探针发现，558 主动停止后实际输入验证 |
| 捕获源尺寸与分析配置版本 | engine/source-size-profile-result.json | 实际管线 8 项通过，旧资产不补写虚构原始尺寸 |
| 构建、生成产物及最终文档一致 | 原生/前端构建记录，Agent XML 修复编译日志 | 原生/Agent/前端构建通过，最终原生二进制 hash 与记录一致；最新定性观察提示编译通过并同步 Lua，文档链接及范围核对通过：validation/build/final-audit.json。未宣称仓库全量 TypeScript 检查无错误 |

## 保留的失败与解释

- preview-resource-result.json 的 6 轮增长是线程池预热样本不足。后续类型诊断与正式构建 40 轮进入平台，不能删除旧失败，也不能继续将其解释为捕获泄漏。
- preview-takeover-before-fix.json 在新入口启动完成前断言 HUD，属于测试时序错误；修正后原实现通过，试验性 Entry 改动已撤回。
- G02/runtime-before-camera-fix 保存逻辑成功但视觉失败；当前视觉成功来自最小相机修复后的同路线复拍。
- XML 首次真实任务 561 无法处理数组字段，主动停止；不得将未来复测成功改写为首轮成功。

## 最终范围与判定

- 用户补充后，视觉模型仅做定性观察，主 Agent 分析源码确定具体坐标与修改；不以精确像素坐标或 PNG 字节数衡量识图效果。历史越界数值不再单独作为核心验收失败，原报告保留。
- 最终提示规则更新已编译；没有为这次纯提示调整再次消费供应商请求，不能声称它已提高模型准确率。
- 时延记录为实际取景/工具耗时和视觉 HTTP 往返；GPU、编码、网络和供应商推理没有分项计时。40 轮本地资源稳定性不外推移动端或其他 GPU 后端。
- GLM-4.6V 实际 API 请求通过，Coding Plan 账单归属未核查。图片字节限额是传输/存储保护；用量以返回 usage 记录，不以文件大小估算费用。
- 更广供应商、视觉用户配置、主模型直接收图和跨调用自动试玩属于后续范围。三个游戏的行为检查分别注明真实应用输入、模拟输入与人工原图核对，避免混淆。
