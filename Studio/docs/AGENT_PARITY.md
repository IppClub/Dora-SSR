# Dora Agent 迁移对照

## 构建工具增量

`./build-tool` 直接提取原 build 参数分支和 handler，逐目标顺序调用宿主构建接口，保留部分失败统计、取消后停止派发、修复状态及新项目/失败测试状态更新。新增测试覆盖混合 path/paths 顺序、空值拒绝、部分失败及取消/成功状态；仍使用测试构建后端，真实编译 Worker 尚未绑定，不宣称全语言构建可用。

## 删除工具真实存储验证

Chrome workspace.browser.mjs 已将二进制删除从直接后端调用改为共享执行器→原语义校验→默认 guard→原删除 handler→本地提交。输出 success/reversible/binary 均为 true；数据库中资源消失，恢复旧检查点后字节仍为 `[0,255,128]`。原存储、编辑和升级回归保持通过。此为测试宿主整链，正式模型/面板尚未调用。

## 删除工具处理器增量

首次测试发现 JS 对象保留 undefined 字段，而 Lua table 的 nil 字段不存在，导致成功删除输出未通过 JSON 校验。当前删除适配器在返回前剔除顶层 undefined 字段，保留原 Lua 对象形状；修复后完整构建及 65 项测试通过。其他处理器仍需逐项检查同类跨运行时差异。

共享包提供原 delete_file 语义分支和原 handler，唯一提交调用在 Studio 构建时改为 await。经共享执行器/默认 guard 验证空路径、计划文档和记忆文档删除被拒绝；合法删除返回原可恢复/检查点字段，成功后更新 workflow。测试使用明确的异步测试后端，真实本地后端已有独立验证但两者整链尚待串联。

## 删除存储适配增量

本地编辑后端支持 delete 操作，复用单次提交、revision 条件检查和原子检查点；二进制删除可由完整旧快照恢复。Chrome 直接后端测试删除资源形成 r12、恢复检查点形成 r13，资源字节一致；删除当前入口使快照无效时保存拒绝、当前项目不变。

原 delete_file handler/语义校验尚未绑定，调用者仍须经过原保护文档 guard；后端不是独立授权 API。入口删除限制源于当前 Studio 快照不允许缺失入口，与原生临时缺入口工作流的兼容仍需处理，不能宣称完整删除工具对齐。

## 编辑工具到真实持久化的浏览器验证

Chrome 152 workspace.browser.mjs 已串联共享 schema→edit 语义校验→默认 guard→原 edit handler→LocalWorkspace 后端。在同一批次中合法源码替换成功，越界路径和二进制覆盖各自失败；原 handler 报 partial=true、actualSaved=true、成功 1/失败 2。关闭重开后 r10 源码为新内容、二进制未改变，checkpoint r9 与提交前项目完全相同。

这是浏览器测试宿主中的真实工具持久化链路，不是正式 Agent 面板发起，也没有模型请求或自动编译试玩；这些仍需继续接入。

## 本地编辑后端增量

`apps/web/src/agent-edit-backend.ts` 为单次工具调用绑定项目/revision/task，检查文本目标，复制快照暂存变更，经 LocalWorkspace.save(..., checkpoint=true) 原子提交后才更新读回状态。重复提交、身份不符、二进制覆盖、非法/虚拟路径与不匹配 create/write 拒绝；最终快照仍由共享契约校验。失败后需要重新绑定，不能自动重试旧修改。

Chrome 真实 IndexedDB 测试：r8 绑定提交 r9，检查点 r8 与原项目相同；另一个仍绑定 r8 的提交失败，r9 源码不被覆盖。当前测试直接调用后端，尚未串联正式 UI→执行器→编辑 handler→持久化，也未验证取消期间提交边界。checkpointId 为绑定项目内的旧 revision，不能作为跨项目全局 ID 使用。

## 异步提交边界适配

Studio 构建通过 AST 将原 editFile 中唯一的 Tools.applyFileChanges 调用改为 await；若原提交调用数量变化则构建失败要求复核。原生源文件不变，同步与异步后端均可接入。保存后读回和 workflow 更新必须在提交完成后进行。

新增测试用受控 Promise 验证等待期间不读回、不报告完成、不更新 workflow；提交失败返回 actualSaved=false 且不标记已编辑。真实 LocalWorkspace/revision 检查点后端仍待连接，取消期间事务是否已经落盘仍须由宿主明确处理。

## 编辑处理器接入增量

`./edit-handler` 提取原 editFile 和所需政策函数，每实例注入 Tools 的目标检查、原子提交与读回接口。测试使用内存后端，验证同文件有序暂存、部分失败、一次提交、保存核对及编辑计数。真实 revision/检查点持久化后端仍待接入，不能把内存测试当作用户项目保存成功。

错误消息的非法字符处理当前使用 JS toWellFormed；与原 Lua 非法 UTF-8 删除行为尚未等价验证。计划模式逐项拒绝、保存失败/读回失败、重复全文保护及真实持久化仍需扩展执行器集成测试。

## 文本替换规则增量

共享包 `./text-edit` 从原 Utils.ts/Policy.ts 提取替换、匹配计数、行尾归一化、缩进及空白容错函数。没有另写替换算法。测试覆盖字面替换（含 $&）、CRLF/CR、缩进保留、空白回退、歧义及缺失目标拒绝。

这些纯函数尚未连接实际写入 handler，不能绕过唯一匹配、逐项权限检查或 revision 条件提交；原生 Lua 同输入对照仍待完成。

## edit_file 语义校验增量

`./edit-validation` 从原 Validation.ts 提取 edit_file 分支，复用原批次解析，拒绝混用单项/批次格式及无效单项，保持批次内的同文替换等错误留给 handler 逐项处理。测试验证规范化不改变输入、批次共享路径、混合格式拒绝及共享执行器阻断非法单项。

原写入 handler 还包含行尾归一化、唯一匹配、缩进容错替换、逐项 guard、单检查点提交及保存后核对，后续必须一并保留；不能用简单字符串替换替代完整编辑能力。实际 revision 写入尚未接通。

## 文档加载校验增量

`./documents` 校验资源包版本/语言、命名空间、安全路径、重复记录、体积及文本 SHA-256，校验全部通过后返回只读绑定所需文本。首次异步操作前捕获所有记录，避免校验期间变更输入；构建保留 UTF-8 BOM，确保哈希与文本字节一致。测试真实双语包以及篡改、语言错误、重复、遍历路径和迟到修改。

哈希只证明包内一致性，不证明来源可信；正式宿主必须从自身可信构建产物加载，不能把任意用户上传的文档包当成官方资源。

## 真实文档资源构建增量

`scripts/agent-docs.mjs` 使用原 Workspace.ts 的 isDoraDocFileInScope 函数，构建中英文 Dora/Love/TIC80 API 和教程只读资源包，路径沿用 @dora-doc/<docType>/...。包内保存原 UTF-8 文本及逐文件 SHA-256，不读取技能目录或用户文件，遇符号链接拒绝构建。

测试读取两种语言的真实 Dora.d.ts，对比源文件文本/哈希，并通过快照后端读取，核查教程存在及路径唯一。专用 Agent Host 构建现在完整性固定这两个资源包；每次可信启动快照校验包内逐文件哈希后，将 822 个 API/教程文件展开到原版 Agent 预期的 `Script/Lib/Dora/<language>` 与 `Doc/<language>/Tutorial` 目录，因此继续直接使用原 `search_dora_doc` 排序、分页、读取和命名空间逻辑。Agent 技能读取和当前引擎日志采集仍未接通，不能视为所有虚拟资源迁移完成。

## 虚拟读取接口增量

快照后端接受宿主显式提供的只读文档/日志文本绑定，支持准确的 @dora-doc/... 和 @dora_full_logs.txt 路径，继续使用原行范围格式化。每次绑定固定文本，跨项目拒绝、缺失明确失败；项目内同名文件或 ./ 路径别名不能冒充引擎日志/内置文档。测试覆盖这些边界及输入后续修改隔离。

文档已由可信 Host 快照按原目录结构接入，不再依赖项目文件冒充内置文档。当前 runId 日志采集仍待接入；接口本身不证明日志来源。现有 Agent 技能虚拟文件路径也仍需盘点适配，不能遗漏。

## 项目快照读取增量

共享包 `./snapshot-read` 绑定一份经验证、复制的不可变项目快照，以 projectId 检查调用身份，拒绝非法路径、缺失文件和二进制文本读取；不访问宿主磁盘。行范围与提示格式直接提取原 Workspace.ts 的 formatReadSlice。全链路测试通过原 schema/语义校验/guard/handler 读取实际快照文本，验证负行号、输入后续修改隔离、跨项目拒绝和二进制拒绝。完整构建及 55 项测试通过。

尚未由正式 App 或模型会话调用；内置文档及引擎日志虚拟路径尚未提供，当前缺失时明确失败。快照读取不等同于完整 read_file 能力交付。

## read_file 处理器增量

`./read-handler` 提取原 readOneFile/readFile，通过 createReadHandler 注入每实例独立的读取后端，不使用全局可变绑定。保留批读取部分失败/计数/顺序、压缩恢复阶段 160 行裁剪及中英文提示。测试贯穿 schema→语义校验→默认 guard→原 handler，使用测试读取后端验证部分失败和裁剪；不同实例绑定不串用。真实项目文件、文档虚拟路径和引擎日志后端仍待接入，不代表读取工具已交付。

## read_file 语义校验增量

共享包 `./read-validation` 从原 Validation.ts 提取 read_file 分支及行号辅助函数，默认限制直接读取原 Config.ts，不维护第二份默认值。测试覆盖默认 1–300、负行号、取整、混合顶层/批读取顺序、空路径、零行号与无顶层路径的行号拒绝；通过共享执行器验证语义错误不会派发 handler。解析必须在 schema 校验之后调用。

仍未连接真实文件读取或虚拟文档/日志；其他工具语义校验以及原生 Lua 同输入对照待完成。局部提取并不代表原 validateAgentToolInput 全部迁移。

## 执行器接入增量

共享包新增 `./executor`，直接打包原 Executor.ts，导入指向已生成的 registry/schema/guards，异常字符串转换采用局部 String 绑定。注册表仍无真实 handler，未绑定调用返回 TOOL_HANDLER_MISSING，不伪装成功。

测试使用明确的测试 handler，验证 schema→语义规范化→guard→handler 顺序、默认禁用 guard、调用前/返回后取消、处理器异常、非法输出和未知工具。此为执行框架验证，不代表真实 14 项工具、模型循环或原生 Lua 行为对照完成；实际语义校验器与宿主 handler 仍待绑定。

## Guard 接入增量

共享包新增 `./guards`，打包原 Guards.ts，依赖的计划目录常量和纯路径函数从原 Policy.ts 按 AST 提取，编辑解析复用 ./file-edits。Lua trim 模式仅适配原有 ASCII 空白模式，未知模式明确报错，不加载原生文件系统。

测试覆盖角色、工作模式、禁用工具、计划目录、保护的计划文档/记忆目录及批编辑逐项检查入口。批次的顶层 guard 按原逻辑放行，后续 handler 必须逐项调用检查，不能仅靠顶层 guard 直接写入。该 guard 不替代 Studio 文件系统的路径穿越/项目授权校验；原生对照与真实写入执行仍待完成。

## 编辑解析接入增量

共享包 `./file-edits` 在构建时直接提取原 Validation.ts 的 getAgentFileEditInputs，不加载 Dora 路径/配置依赖。完整构建与 48 项测试通过，新增共享路径、逐项路径覆盖、同文件有序编辑、单项兼容形式、不修改输入及 schema 拒绝 null 项测试。解析器必须在 schema 校验之后调用；它不是路径授权或写入器。

执行器尚未迁移：原 Guards.ts 的计划路径/保护文档规则仍依赖 Runtime/Policy 和 Validation，Policy 还包含 Dora 文件系统及 Lua 字符串依赖。不得用空 guard 列表绕过这些规则。后续需保留原 schema→语义校验→guard→取消检查→handler→取消检查→输出校验顺序，以及批编辑逐项 guard/检查点行为。

## Schema 校验器接入增量

工作区包新增 `./json-schema` 导出，直接打包原 `Agent/JsonSchema.ts`，局部绑定 Dora json.null、math、tostring 和 utf8.len，不污染宿主全局，也不加载引擎。当前绑定覆盖 JSON 标量及有效 Unicode 码点计数；非法 UTF-16/UTF-8 的跨运行时行为还需单独对照。

完整构建与 47 项测试通过：全部角色/模式下暴露的 schema 均可编译，read_file 批输入/空输入/额外字段、null、中文与 emoji 字符长度、非整数/Infinity、循环引用和错误数量限制通过。尚未执行原生 Lua 同输入对照；这不是工具语义验证、guard 或实际执行器的迁移完成证明。

核查日期：2026-09-15。源码基线 commit：`f68dcbcb08b339ccb8ba95e17884e86bb49705e1`；核查时 `Assets/Script/Lib/Agent` 无工作区变更。

本表是迁移输入，不是已实现声明。Studio 当前未接通 Agent，全部行为对照仍待完成。

## 已确认的工具入口

`Assets/Script/Lib/Agent/Tool/Registry.ts` 实际注册 14 个工具：

| 能力 | 工具 | Studio 宿主适配位置 |
| --- | --- | --- |
| 文件与搜索 | read_file、edit_file、delete_file、grep_files、glob_files | 项目快照、revision 条件写入、文档/日志虚拟路径；保留批处理和检查点语义 |
| 文档与构建 | search_dora_doc、build | 内置文档索引及浏览器编译；不能只覆盖 TS happy path |
| 网络与视觉 | fetch_url、analyze_image | 受限网络服务、浏览器截图与原有供应商能力绑定 |
| 受控命令 | execute_command | 项目命令环境，不能替换为任意服务器 Shell |
| 子任务与交互 | list_sub_agents、spawn_sub_agent、ask_user | 会话树、问题状态、恢复与取消传播 |
| 完成报告 | finish | 原有角色/模式规则与验证报告，不另设“生成完代码即完成”标准 |

`tests/agent-baseline.test.mjs` 使用 TypeScript AST 读取注册数组，对上述名称集合和顺序设置漂移门槛，避免误把参数名计作工具。它不验证 schema、执行行为或完整能力等价。

## 不能直接搬到 Node 的依赖

- `DoraAgent.ts` 直接引用 Dora Content/Path；仍耦合 Memory、Tools、Config 和 Runtime 模块。
- `Tool/Registry.ts` 直接导入 Handlers，工具声明目前不是独立纯契约包。先解除声明与执行器绑定，再共享 schema，不复制一份注册表长期人工维护。
- `Tool/Executor.ts` 已有取消、schema、语义校验、guard、handler 顺序，异常使用 Lua `tostring`；迁移必须保留顺序并抽象平台异常格式化。
- `Session.ts` 依赖 Dora DB/HttpServer/emit；`Utils.ts` 依赖 HttpClient、DB、Director、once；`Memory.ts` 依赖 Content 和 Web IDE 同步。会话存储、传输、调度与文件系统需宿主接口。
- `Gen/Music.ts` 依赖 Audio、HttpServer、json；生成能力不能因为不在 14 个顶层工具名称中就遗漏。
- `Tool/Command.ts` 注入 previewGame 并处理其结果，试玩属于命令执行路径，不是单独注册的 play 工具。

## 尚需完成的完整盘点与对照

逐项继续核查：工具 schema/角色/plan-code 限制、tool_calling/XML 决策、命令注入与音乐音效完整 API、批处理/失败部分提交、并行与取消、压缩/记忆、会话/子任务恢复、检查点回滚、视觉预算与绑定、供应商配置、完成验证语义。每项需要原生与 Studio 的同输入结果对照。

14 个工具名称一致只是防遗漏的第一道门槛；不得以该测试通过宣布 Agent 已迁移。

## 契约提取验证

`scripts/agent-contracts.mjs` 从 Registry AST 中定位声明边界，保留原有声明/schema 构造函数及共享预算常量，在构建时生成可 JSON 序列化的工具契约。无需加载原生 Handlers、Validation 或 Dora JsonSchema，未复制或改写工具描述。专项验证 14 项、角色/模式、read_file 批处理 schema、并行标志及 ask_user 单独调用规则通过。

该适配器已接入工作区包 `@dora-studio/agent-contracts` 的构建，生成独立 dist/index.js；产物不需要运行时 TypeScript/esbuild 或原生执行器。尚未接入服务，不包含执行器、语义验证、guard 或供应商配置解析。提取测试通过不等同于 JS/Lua 执行行为一致。原生 Registry 和生成 Lua 本轮未修改。

构建产物验证：直接导入 dist/index.js，逐 main/sub × code/plan 比较显式禁用 fetch_url 时的完整决策 schema，与当前源码提取结果一致。该测试验证打包没有改变契约，不是独立的原生运行行为对照。

角色/能力增量：适配器进一步提取原 Registry 的选择函数（而非重新实现过滤条件），验证 main/sub × code/plan、disabledAgentTools，以及子 Agent finish 的六项必填报告字段。主 Agent 的 ask_user 仅在 plan 模式出现，spawn_sub_agent 不在 plan 或 sub 角色出现。3 项专项通过；这里验证显式禁用列表的过滤，不代表供应商配置到禁用列表的上游解析已迁移。
## execute_command 浏览器迁移检查（2026-09-15）

当前原 `Tool/Command.ts` 明确支持 `lua` 和 `git` 两种模式。Lua 路径依赖 Dora 调度器、协程/调试钩子、对象计数、项目模块加载与 Entry；`previewGame` 还依赖游戏捕获、视觉预算、文件保存及清理。Git 路径依赖 `Dora.Git`、DB、下载临时目录和网络安全检查。不能把简单试玩或 JavaScript eval 视为完整命令复刻，也不能默认 Git 模式已经由项目 ZIP 导入替代。

已从原 `Tool/EntryLease.ts` 提取占用管理函数，构建时读取原源码，状态改为每个宿主工厂独立持有。新增 3 项测试覆盖手动运行拒绝、并发工具互斥、其他操作无权清理、旧任务不能停止新 run、宿主隔离及清理失败后释放占用。全工作区构建与 88 项单元测试通过。

该模块尚未连接浏览器 RuntimeHost：适配必须满足原逻辑要求的同步 runId 递增契约；还需以真实运行环境验证命令取消/超时、捕获与资源回收。此处只是共享占用语义验证，不代表 execute_command 或自动试玩已完成。原生源码未改动。
