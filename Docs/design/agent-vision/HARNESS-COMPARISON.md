# DeepSeek Harness 与 OpenCode 多模态接入比较

调查日期：2026-09-05。关联：[供应商调查](./PROVIDERS.md) · [设计](./README.md) · [进度](./PROGRESS.md)。

**核心发现：两者内置的读图工具主要负责把图片交给当前模型，不能直接等同于“纯文本 Agent 调用独立视觉模型”。** 独立视觉分析可通过定制工具、子 Agent 或社区插件实现。Dora 应明确区分图片载入与图片分析。

本次从官方仓库取得源码并只读检查，没有安装依赖、运行项目测试或发起模型调用。检索到的测试和录制 fixture 是上游已有证据，不是本次实测结果。

## 1. 版本边界

| 项目 | 本次源码版本 | 说明 |
| --- | --- | --- |
| DeepSeek Harness | `d347e703908d0406b7a7ef80e3a0e594d86b2215` | 2026-09-04 的提交，提交主题为合并 `dsh-0.1.3-alpha.1` 发布分支；不推断用户已安装此版本 |
| OpenCode | `bbd72fb8b0bb6de580d2041a0150016227c63ac0` | 本次获取的默认分支快照；仓库并存 V1 与 V2 实现，以下分别说明 |

特别注意：不能将 OpenCode 简化描述为“统一通过 AI SDK”。V1 的 `packages/opencode` 使用 AI SDK 路线；当前 V2 的 `packages/core` 与 `packages/llm` 已有自己的规范消息和协议实现。

## 2. DeepSeek Harness

### 2.1 图片从哪里进入

两条入口最终汇入同一种内部图片内容：用户上传图片，或 Agent 调用 `read_image` 读取图片文件。附件服务把图片规范化、持久化为不可变引用，消息中保存 `ImageAttachmentRef`，包括 ID、格式、字节数和尺寸，不把供应商 wire JSON 当作通用历史。

附件采用内容寻址去重，并区分持久化的规范图片与按模型预算派生的请求图片。请求变体有自己的缓存，不改写已保存的会话历史。这个分层可以直接借鉴到 Dora 的 `assetId` 与模型传输层。[附件类型](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/attachment/attachment/src/types.ts)、[本地附件实现说明](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/attachment/attachment-local/README.md)

### 2.2 `read_image` 并没有调用另一个模型

源码中的 `assertImageCapableRoute` 解析当前请求的 provider/model，要求它明确声明 `inputModalities` 包含 `image`；未知或文本模型直接返回错误，并提示切换模型。之后才读取和登记图片，返回“文本说明 + image attachment block”。工具内没有另一次视觉 LLM 调用。[能力检查与工具返回](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/fs/tool-fs/src/read-image.ts#L119)

因此其实际路径是：

```text
当前视觉 Agent → read_image(path) → 图片附件
             → 下一轮仍由当前模型看图、推理和调用工具
```

官方 DeepSeek adapter 的模型目录已经明确包含 `deepseek-v4-flash-vision-exp`，并标记 `inputModalities: ['text', 'image']`；不能依据早期版本或第三方补丁推断当前官方 Harness 不支持 DeepSeek 视觉模型。[模型目录](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/llm/llm-deepseek/src/index.ts#L106)

### 2.3 如何适配供应商

- 官方 DeepSeek 走专用 `llm-deepseek` adapter；其他供应商还有 `llm-pi-ai` 插件，通过 profile 配置 provider、协议、端点、模型与能力，再转换为 pi-ai 的上下文。[pi-ai 接入说明](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/llm/llm-pi-ai/README.md)
- DeepSeek 视觉请求优先使用 Files API 文件引用，文件解析失败时有 Base64 回退路径；上游还处理文件缓存、失效和请求预算。Dora 首版不必照搬这套复杂上传策略，可先内联图片。[adapter](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/llm/llm-deepseek/src/adapter.ts#L565)
- 内部工具结果可以含图片；DeepSeek Chat 序列化时先生成文本 `tool` 消息，连续工具结果结束后追加承载图片的 `user` 消息。它不是把图片 JSON 字符串塞进 tool 文本。[序列化](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/llm/llm-deepseek/src/serialize.ts)
- 图片预算超限有逐张保留身份信息的卸载机制；后续重读可恢复。图片缩放后的尺寸与坐标关系也会提供给模型。[请求图片与投影](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/llm/llm-pi-ai/README.md)

### 2.4 如何实现独立视觉模型

官方 `tool-subagent` 允许为工具实例配置 `agentOptions.provider/model`；支持此能力的后端可以创建使用另一模型的子 Agent。还可配置 persona 和工具过滤，具体取决于后端能力。前台一次性调用返回子 Agent 的最终文本。[子 Agent 配置](https://github.com/deepseek-ai/deepseek-harness/blob/d347e703908d0406b7a7ef80e3a0e594d86b2215/packages/subagent/tool-subagent/README.md)

据此可以组合出一个“视觉子 Agent”：主模型给出问题和可访问图片位置 → 子模型调用 `read_image` → 返回报告。**这是由通用子 Agent 能力组合出的方案，不是发现了一个内置 `analyze_image`。** 图片必须对子运行环境可访问，不能假设所有远程 / 子进程后端共享父会话的附件。

若只需要单次分析，定制一个直接调用 LLM service 的视觉工具比启动完整子 Agent 更简单；这属于对 Dora 的工程建议。

## 3. OpenCode

### 3.1 V1：AI SDK + 模型能力目录

V1 模型配置有 `modalities.input`，provider 将其转换为 `capabilities.input.image`；`attachment` 是另一字段，不能代替 image 能力声明。[模型配置映射](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/opencode/src/provider/provider.ts)

用户图片以 file part 进入历史，`read` 工具也可返回图片附件。`message-v2.ts` 再投影成 AI SDK 消息：支持原生 tool media 的路线保留媒体结果；不支持的路线抽取工具图片，追加为 user 消息。随后调用对应 provider SDK。[图片读取](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/opencode/src/tool/read.ts)、[历史投影](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/opencode/src/session/message-v2.ts)

对声明不支持的图片输入，`unsupportedParts` 会转换为明确的“模型不支持”文本，而不是自动启动另一个视觉模型。[不支持输入处理](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/opencode/src/provider/transform.ts#L409)

### 3.2 V2：规范消息 + 独立协议层

V2 的直接附件经物化后进入 session；用户图片转成通用 `media` part。`read` 工具识别图片、规范化后返回文本说明和 file 内容。工具结果再转换为统一 `ToolResultPart`，最后由协议层编码。[read 工具](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/core/src/tool/read.ts#L45)、[session 到 LLM 的投影](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/core/src/session/runner/to-llm-message.ts)

| V2 协议实现 | 工具图片处理 |
| --- | --- |
| OpenAI Chat | 输出文本 tool 结果，累计图片，然后在连续 tool 结果之后追加 user 图片内容 |
| OpenAI Responses | 保留为 `function_call_output.output` 中的图片内容 |
| Anthropic Messages | 转换为 `tool_result` 内的原生 image/source |
| Gemini | 单独转换为 `functionResponse` 与图像 `inlineData` 等 Part，不复用 Chat JSON |

源码：[Chat](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/llm/src/protocols/openai-chat.ts#L264)、[Responses](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/llm/src/protocols/openai-responses.ts)、[Anthropic](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/llm/src/protocols/anthropic-messages.ts)、[Gemini](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/llm/src/protocols/gemini.ts)。

V2 的回放投影还会检查历史与当前 provider/model 是否相同，再决定是否复用 provider metadata；只有元数据而没有文本的 reasoning 也可能保留。这与 Dora 需要独立保存协议回放状态的判断一致。[回放条件](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/core/src/session/runner/to-llm-message.ts#L73)

### 3.3 取景、图片处理与模型选择不是同一件事

V2 官方附件文档限定当前可见图片类型，并说明自动缩放配置；直接附件和 `read` 图片均有处理路径。但处理后的图片仍送给当前选定的模型，服务端还可能拒绝不支持的模型组合。[V2 附件文档](https://opencode.ai/v2/docs/attachments)

OpenCode 的 `read` 读取已经存在的文件，并不自动解决 Dora 游戏引擎中 Remix 遮挡的问题。截图来源正确性仍应由 Dora 独立保证。

### 3.4 独立视觉模型：V1 子 Agent 可以组合，V2 不外推

V1 的 `task` 明确使用 `next.model`，未指定才继承父模型，并从子 Agent 的回答提取文本。因此可以配置一个视觉子 Agent，让它在可访问的工作区读取图片后返回分析。[V1 task 模型选择](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/opencode/src/tool/task.ts#L181)

本次 V2 内置工具列表仍将 `task` 移植列为 TODO；**不能把 V1 的子 Agent 方案直接宣称为当前 V2 内置可用方案。** V2 可以开发专用工具，但需按 V2 扩展接口单独实现与验证。[V2 内置工具边界](https://github.com/anomalyco/opencode/blob/bbd72fb8b0bb6de580d2041a0150016227c63ac0/packages/core/src/tool/builtins.ts#L26)

## 4. 社区插件：独立视觉分析已有先例

以下不是两项目官方内置功能。本次只核对插件作者文档，未安装、审计完整实现或验证其与最新主线兼容性。

| 社区插件 | 作者描述的实现 | 对 Dora 的参考价值 |
| --- | --- | --- |
| [dsh-multimodal](https://github.com/MC5lan/dsh-multimodal) | 对图片先调用独立配置的视觉服务转写，再让 DeepSeek 基于文本继续；提供转写缓存和独立 OCR 工具 | 证明 provider 解耦的可行路径；它的默认图片路线是自动预处理，不等于由主 Agent 主动调用分析工具 |
| [opencode-multimodal](https://github.com/zensi-dev/opencode-multimodal) | 在 `experimental.chat.messages.transform` 中，为当前模型不支持的附件调用配置的辅助模型，再用分析文本替代附件；同模型的多图可一起分析 | 可借鉴多图联合分析、带任务问题的提示和内容缓存；该 hook 属于其目标版本，不承诺 V2 可直接复用 |

因此要区分三种产品行为：原生图片透传、自动视觉预处理、显式视觉分析工具。用户提出的 Dora 方案属于第三种，主 Agent 可决定何时拍图、问什么、是否对比和复查。

## 5. 对 Dora 的设计建议

建议采用两边已经体现的附件与协议分层，同时把分析作为明确的独立能力：

```text
纯文本主 Agent
  ├─ preview_game → 游戏图像资产 assetId
  └─ analyze_image(assetIds, question, criteria)
       ├─ 读取并校验图像资产
       ├─ 根据独立 vision profile 准备请求
       ├─ 调用多模态模型（首版无工具、无独立 Agent loop）
       └─ 返回文字分析 + 来源 + 图片引用
```

1. **区分载入和分析。** `view_image/read_image` 只表示载入图像；`analyze_image` 才承诺调用视觉模型并返回报告。主模型是纯文本时，不开放一个仅返回原图却宣称已分析的工具。
2. **保存原图和分析记录。** 主模型得到报告，UI 可展示原图。记录 runId、assetId、模型配置标识和问题，区分视觉观察、原因推测与未能判断。
3. **首版视觉服务保持单次请求。** 无工具、无视觉会话续跑，减少签名和历史复杂度；主 Agent 原有 loop 继续负责决策。仍需正确解析所选模型的响应与流式完成状态。
4. **同一问题的对照图片合并分析。** 图片排序与标签稳定，不逐张转写后丢失空间或前后变化关系。
5. **缓存包含上下文。** 缓存键至少包含有序图片摘要、问题、验收条件、视觉 profile 版本和处理参数；换问题不能沿用旧描述，失败结果不充当成功缓存。
6. **资源和生命周期可追踪。** 取消传播到视觉请求；超时返回明确失败；重试不重新运行游戏；每次分析的 usage 归入工具成本，避免主模型 usage 漏计。
7. **完整子 Agent 留给复杂检查。** 当视觉分析需要自行放大、选图、多步查证时，再扩展为受限视觉子 Agent，限定工具和轮数。

2026-09-05 用户已确定采用独立视觉工具与同服务默认能力；不新增用户看图模型配置和切换。README 与 PROGRESS 已同步，原 E02 拆入首版 T03/T04、M01—M04。本文 vision profile 在首版由内置目录生成，并非用户配置；功能尚未实施。

## 6. 检查与证据边界

- 已核对：两官方源码快照、图片入口、工具返回、模型能力、协议转换及可见的子 Agent 模型选择路径。
- 已看到但未运行：Harness `read-image.spec.ts`、DeepSeek adapter 的图像 / Files 回退测试；OpenCode 的 tool-runtime 测试、协议媒体 fixture 和 session 投影测试。
- 未验证：实际供应商请求、模型视觉质量、最新版应用运行行为、社区插件兼容性、Dora 游戏截图与分析闭环。
- 本文源码链接固定到提交，后续实现时需检查上游变化；不以旧 issue 或插件宣传替代当前源码结论。
