# Dora Agent 图像多模态供应商接入调查

调查日期：2026-09-05；GLM 实测补充：2026-09-06。关联：[设计](./README.md) · [开发进度](./PROGRESS.md)。

**接口调查结论：图片资产可以共用，供应商请求与参数仍需分别适配。**

首版范围已按用户决定更新：由当前 Agent 服务配置自动绑定默认视觉能力，`analyze_image` 内部发起无工具、无历史的单次视觉请求，向主模型返回文本报告；不新增用户看图模型配置或切换。本文原生多模态 loop、工具图片与回放状态研究保留为后续参考，当前交付范围以 README / PROGRESS 为准。

本文主体为官方文档调查和源码核对。后续已完成 DeepSeek 独立静态图片请求，见[验证记录](./validation/README.md)；GLM 已确认国内 Coding Plan，按官方视觉 MCP 的 HTTP profile 完成 `glm-5.3-flash` 与 `glm-4.6v` 各 5 次静态请求验证，当前默认选型为 `glm-5.3-flash`。下文“支持”除特别标明外指文档能力；火山 / BytePlus 部分动态文档正文无法完整取得，明确保留证据缺口。

## 1. 范围与当前接入点

以 [Web IDE 配置](../../../Tools/dora-dora/src/LLMConfigDialog.tsx) 的 `BUILTIN_TEMPLATES` 和 [移动配置](../../../Assets/Script/Dev/Mobile/LLMSetup.tsx) 的 `mobileLLMPresets` 为范围：18 个内置配置，覆盖直连、聚合网关、Coding Plan 和本地服务；另调查未内置的 Claude、Gemini 原生接口作为架构参照。

当前 [Utils.ts](../../../Assets/Script/Lib/Agent/Utils.ts) 使用字符串 `Message.content`、Chat 风格请求和 `reasoning_content` 字符串；流式归并主要保留文本、推理文本及已知工具字段。[HistoryProjection.ts](../../../Assets/Script/Lib/Agent/Runtime/HistoryProjection.ts) 会清除无 `tool_calls` 的 assistant 消息的 `reasoning_content`。这些是接入改造点，不是当前协议实现通过多模态验收的证据。

必须区分四种能力：图片输入、工具调用、同一请求中图像与工具并用、工具执行后携带图像继续推理。只通过第一项，仍不能宣称支持 Dora 的自主视觉验证。

## 2. 内置配置逐项调查

所有端点和默认模型列均来自当前源码，不表示其精确模型 ID 已经向供应商验证。表中的“另选模型”是配置建议，不自动替用户切换模型或计费服务。

| 配置 ID | 当前模型 / 路由 | 图像接入路线与当前结论 |
| --- | --- | --- |
| `deepseek` | `deepseek-v4-pro`；官方 `/v1/chat/completions` | **平台已支持图像多模态**：`deepseek-v4-flash-vision-exp`。列为首版视觉候选；当前默认 `deepseek-v4-pro` 需显式另选模型。Chat 使用 `image_url`，另有 Anthropic / Responses 兼容路线。[DS] |
| `moonshot` | `kimi-k3`；`api.moonshot.cn/v1/chat/completions` | K3 文档描述原生视觉，可走 Chat `image_url`；优先候选。需特别修正完整推理历史回传，并核验当前 `.cn` 区域配置。[KM] |
| `qwen` | `qwen3.7-max`；DashScope compatible-mode | 视觉文档提供 Chat `image_url`。本次未确认这个精确默认 ID 的视觉与工具组合，先登记官方视觉模型及区域权限，不能把所有 Qwen Max 当成同一能力。[QW] |
| `openrouter` | `~anthropic/claude-sonnet-latest`；`openrouter.ai/api/v1` | 走网关 Chat `image_url`；实际模型和上游路由决定图像与工具支持。动态别名须记录解析结果，推理可能为 `reasoning_details` 数组。[OR] |
| `openai` | `gpt-5.6`；`api.openai.com/v1/chat/completions` | Chat 图像协议明确；精确 ID 与当前账户能力待确认。Responses 是另一协议，不能只替换 URL。[OA] |
| `aihubmix` | `gpt-5.6-luna`；`aihubmix.com/v1/chat/completions` | 官方提供 Chat `image_url` 示例；精确模型、工具组合、上游字段保留需要网关实测，不能完全继承 OpenAI 直连结论。[AH] |
| `siliconflow` | `deepseek-ai/DeepSeek-V4-Pro`；`api.siliconflow.cn/v1` | 官方视觉接口用 `image_url`，应选择平台实际托管的视觉模型；当前 DeepSeek 默认 ID 的视觉能力未获证实。`detail` 语义有差别。[SF] |
| `volcengine` | `doubao-seed-2-0-pro-260215`；北京 `/api/v3` | 拟沿用现有 Chat 路线；该精确模型、尺寸限制、工具组合尚需核对可访问的完整官方参数页和实际配置。[ARK] |
| `volcengine-coding-plan` | `ark-code-latest`；北京 `/api/coding/v3` | 单独 profile。套餐路由与按量 API 不能合并推断；别名实际模型及直接图像能力待确认。[ARK] |
| `byteplus` | `dola-seed-2-1-turbo-260628`；新加坡 `/api/v3` | 官方 ModelArk 示例有 Chat `image_url`，另有 Responses；精确默认 ID 和完整图像限制待补证据。[BP] |
| `byteplus-coding-plan` | `ark-code-latest`；新加坡 `/api/coding/v3` | 单独记录海外套餐、区域及解析模型；不能从国内方舟或按量端点外推。[BP] |
| `minimax` | `MiniMax-M2.7`；`api.minimax.io/v1` | 最新文档的原生图像输入限定 M3；当前 M2.7 不能直接据此开启。M3 有 Chat 与 Anthropic 两条路线。[MM] |
| `minimax-cn` | `MiniMax-M2.7`；`api.minimaxi.com/v1` | 同样需明确选择视觉模型；保留国内区域配置，核对可用性，不因国际文档示例而替换域名 / 凭据。[MM] |
| `mimo` | `mimo-v2.5-pro`；`api.xiaomimimo.com/v1` | 官方图像指南明确支持 `mimo-v2.5`，不能等同于 `mimo-v2.5-pro`；提供 Chat 与 Anthropic 两种编码。[MI] |
| `zai` | `glm-5.2`；`open.bigmodel.cn/api/paas/v4` | GLM-5.2 模型页标为文本输入；应显式另选视觉模型，例如文档中的 GLM-5V-Turbo，后者列出视觉与函数调用。[GL] |
| `zai-coding-plan` | `glm-5.2`；`open.bigmodel.cn/api/coding/paas/v4` | 官方视觉 MCP 是独立入口；0.1.5 包默认 `glm-5.3-flash`；Dora 通过同域视觉请求 profile 固定并实测该模型，可在 Dora 内实现 HTTP 适配而不安装 MCP。见 [套餐验证](./validation/GLM-CODING-PLAN.md)；不把 `glm-5.2` 本身标为支持图片。[GL] |
| `ollama` | `llama3.2`；`localhost:11434/v1` | 优先现有 OpenAI 兼容接口 + 实际加载的视觉模型；默认文本模型不等于视觉模型。原生 `/api/chat` 使用独立 `images` 数组。[OL] |
| `vllm` | `meta-llama/Llama-3.1-8B-Instruct`；`localhost:8000/v1` | 必须部署视觉模型、适配模板及工具解析器；当前文本模型不能靠改请求获得视觉。Chat 图像兼容不代表自动工具解析配置已启用。[VL] |

`localhost` 指运行 Dora HTTP 客户端的设备。Go/Remix 在手机运行时，它不是开发者电脑；图片源也不能以手机 loopback URL 交给云端下载。

## 3. 协议层：哪些可共用，哪些必须分开

下表描述原生服务的基线。兼容网关可以只实现其中一部分，必须另外登记。

| 协议 | HTTP / 鉴权 | 图片字段 | 工具观察和流式处理 |
| --- | --- | --- | --- |
| OpenAI Chat Completions | `POST /v1/chat/completions`；Bearer | user `content[]` 中 `image_url.url`，通常为公开 URL 或 Data URL | tool 内容按文本基线处理；所有 tool 回复后追加内部观察对应的 user 图像消息；SSE `choices[].delta` |
| OpenAI Responses | `POST /v1/responses`；Bearer | `input_image`，字段 `image_url` / `file_id` | `function_call_output.output` 可按官方支持的图像内容数组返回；独立响应 item / 事件解析，保留 reasoning items。[OA] |
| Anthropic Messages | `POST /v1/messages`；`x-api-key`、`anthropic-version` | `image.source`，Base64 方式为 `type / media_type / data` | user 内 `tool_result` 可嵌图片；assistant 为 `tool_use`。SSE content block、JSON 参数增量与签名分别归并。[CL] |
| Gemini GenerateContent | `POST /v1beta/models/{model}:generateContent`；`x-goog-api-key` | `contents[].parts[].inlineData` 的 `mimeType / data`，或 `fileData` | 独立 `functionCall / functionResponse`；流式使用 `streamGenerateContent` 路线，保留原 Part 上的签名。[GE] |
| Gemini OpenAI 兼容 | `/v1beta/openai/chat/completions`；Bearer | Chat `image_url` | 保留 Google 的工具扩展字段；不能因外层兼容而丢弃 `extra_content.google.thought_signature`。[GE] |
| Ollama 原生 | `POST /api/chat`；由部署决定鉴权 | message `images: [原始 Base64]` | 原生消息与流式帧不同于 Chat SSE；暂不作为首版新增适配器。[OL] |

Gemini 当前官方文档还提供 **Interactions API**，其 `function_result` / 内容块与 GenerateContent 的 Part 结构不同。未来接入需明确选择哪套 API，不以含糊的 `protocol: gemini` 混装两者。本设计暂把它列为独立后续路线。[GE]

### 3.1 最小图片编码示例

以下均为结构示意，`BASE64` 是不含文件路径的编码字节；省略真实模型 ID、鉴权、工具声明及上文。Dora 内部只保存资产引用，在发送边界生成这些结构。

Chat user 观察：

```json
{
  "role": "user",
  "content": [
    {"type": "text", "text": "工具观察 tc_1 / run_1 / asset_1：请检查游戏 HUD 是否被裁切。"},
    {"type": "image_url", "image_url": {"url": "data:image/png;base64,BASE64"}}
  ]
}
```

这条消息只能出现在对应工具结果全部返回之后；内部仍然是工具观察，不伪造真实用户指令。

Responses 原生工具图像结果：

```json
{
  "type": "function_call_output",
  "call_id": "call_1",
  "output": [{"type": "input_image", "image_url": "data:image/png;base64,BASE64"}]
}
```

Claude 原生工具结果：

```json
{
  "role": "user",
  "content": [{
    "type": "tool_result",
    "tool_use_id": "toolu_1",
    "content": [
      {"type": "text", "text": "run_1 / asset_1，游戏运行后的画面"},
      {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": "BASE64"}}
    ]
  }]
}
```

Gemini GenerateContent 用户图片 Part：

```json
{
  "contents": [{"role": "user", "parts": [
    {"text": "请检查图中的游戏 HUD"},
    {"inlineData": {"mimeType": "image/png", "data": "BASE64"}}
  ]}]
}
```

这只是图像输入样例，不代表可以把工具返回一律替换为此结构。原生工具结果必须按具体 Gemini API / 模型版本处理；有多模态函数结果能力的版本应采用其原生结果结构。[GE]

### 3.2 传输选择

首版建议使用 PNG / JPEG 内联传输：没有公网托管与 URL 过期前置条件，适合设备本地取景。Base64 会令请求体大约增大到原字节数的 4/3，应另算序列化与峰值内存预算。

公开 URL、供应商 Files API 后续再按 profile 开启。SDK 接受本地路径通常意味着 SDK 帮忙读文件，并不代表 REST 服务能读取 Dora 本地路径。供应商 `file_id` 仅是特定端点、凭据和生命周期下的缓存，不能替代持久化 `assetId`。

## 4. 供应商差异中真正影响实现的部分

### 4.1 OpenAI、Claude、Gemini

OpenAI 的 Chat 与 Responses 图片结构不同，尤其是工具图片返回；不能把 Chat 的 tool 文本限制推广到 Responses。推理模型的工具循环还要求回传相关 reasoning items，采用服务端会话引用还是客户端无状态历史必须显式设计。[OA]

Claude 可直接在 `tool_result.content` 放图片。流式 thinking 的签名也会单独到达：即使没有可显示的 thinking 文本，签名仍可能需要保存。必须按 block 顺序恢复，不能把所有结果压平为 `content + reasoning_content`。[CL]

Gemini 3 的函数调用有 thought signature 回传要求，缺失可导致 4xx。GenerateContent 要保留签名所属的 Part，OpenAI 兼容路线也有工具扩展字段；不能跨 Part 合并、重排或只保存函数名与参数。[GE]

### 4.2 DeepSeek 与 Kimi

DeepSeek **已经支持图像多模态**，官方明确列出 `deepseek-v4-flash-vision-exp`，应纳入首版视觉模型候选。它支持内联 Data URL、公开图片 URL 和 Files API 引用，并提供 Chat、Anthropic、Responses 三条接口路线。Chat 图片放在 user 消息；Responses 还可通过原生函数结果返回图片。当前 Dora 默认的 `deepseek-v4-pro` 与此视觉模型不同，不能仅打开一个通用开关。[DS]

建议增加独立的 DeepSeek 视觉配置，首版用 Chat + PNG Data URL，保留原文本配置。图片与工具并用、后续工具循环、流式和恢复仍需实测。Files API 的引用结构按 DeepSeek profile 实现，不默认套用 OpenAI Files 编码。[DS]

Kimi K3 官方视觉指南包含 `image_url` 数组用法；其推理指南要求多轮及工具循环完整保留 `reasoning_content`。当前 Dora 无工具 assistant 推理被清除、缺失时可能补空字符串的做法，不能替代原始数据。K3 的 thinking 配置规则也不能从旧 K2 型号继承；应按模型生成参数。[KM]

### 4.3 Qwen、SiliconFlow 与聚合网关

Qwen 同时有 OpenAI 兼容接口和 DashScope 原生多模态接口，后者的 `image`、SDK 路径行为不同；Dora 优先现有兼容路线。区域 / 工作空间端点、像素控制和高分辨率参数按 profile 配置。`qwen3.7-max` 的精确支持仍待登记。[QW]

SiliconFlow 文档对 `detail` 的默认与取值解释和其他平台不同，不能把 `auto` 当通用质量策略。OpenRouter 的模型路由和推理字段同样需要单独处理，尤其要完整保留 `reasoning_details`。AiHubMix 的图片示例证明接口形状，并不证明所有模型、工具或上游扩展均可透传。[SF][OR][AH]

### 4.4 MiniMax、MiMo 与 GLM

MiniMax 当前文档已提供 M3 的原生图片输入，不能沿用旧搜索摘要中的“MiniMax 全部不支持图片”。但当前 Dora 预设仍是 M2.7；原生 Anthropic 兼容表明确标注 image 为 M3 only。Chat 的 `detail` 是 `low/default/high`，不是统一的 `low/auto/high`；文档列出图像 10 MB、请求体 64 MB。推理还可能有 `reasoning_details`，需专用回放策略。[MM]

MiMo 图像指南明确列出 `mimo-v2.5`；默认 `mimo-v2.5-pro` 不应据名称自动开通。Chat 采用 Data URL，Anthropic 采用 `source`；其 URL 图片大小和 Base64 字符串大小限制分别计算，不能只检查编码前文件大小。[MI]

GLM-5.2 是文本模型，GLM-5V-Turbo 文档则列出图像及函数调用。Coding Plan 视觉 MCP 属于独立工具服务，不等于当前 glm-5.2 模型变成多模态。Dora 移动引擎也不能假设能直接运行 Node MCP 进程；若走独立视觉分析服务，主模型收到的是报告，须保留这一证据边界。[GL]

### 4.5 Ark / BytePlus 与本地部署

国内方舟与海外 BytePlus 的区域端点、模型命名、Coding Plan 别名都需分别登记。已取得的 BytePlus 官方示例展示 Chat `image_url` 以及独立 Responses 路线，但本次部分动态文档只能获取标题 / 页面框架；未据此填写精确图片上限或声称当前四个默认配置全部可用。后续应补全官方参数正文及实际模型权限证据。[ARK][BP]

Ollama 原生 REST 期待 `images` 中的 Base64，SDK 才负责路径读取。vLLM 还需部署兼容视觉模型、chat template，并配置自动工具选择与工具解析器；服务支持两种能力不等于任意权重支持二者并用。首版优先已有 Chat 兼容入口，测试记录服务版本与模型 / 模板配置。[OL][VL]

## 5. 对 Dora 设计的补充建议

以下是基于上述文档和源码的工程建议，尚未实现。

### 5.1 Profile 应描述能力组合，而非品牌布尔值

```ts
// 概念结构；后续按 TSTL、持久化与配置迁移约束落实。
interface VisionProfile {
  provider: string;
  protocol: string; // 明确 chat / responses / anthropic / gemini-generate-content 等
  endpointClass: string; // 区域、按量 / coding-plan、自托管
  model: string;
  imageInput: "unknown" | "unsupported" | "documented" | "verified";
  imageWithTools: "unknown" | "unsupported" | "documented" | "verified";
  toolImageMode: "text-tool-then-observation" | "native";
  imageTransport: ("data-url" | "base64-block" | "public-url" | "file-id")[];
  replayPolicy: string;
  limitsProfile: string;
}
```

限制记录至少分为编码前字节、编码后请求体、单图像素 / 边长、张数、支持 MIME、detail 枚举及模型输入预算。未知字段不填猜测的供应商上限；可以另设 Dora 自身保守预算，但必须标注为产品策略。

### 5.2 新增协议回放状态

内部可读文本 / 图片资产之外，增加由适配器管理的版本化 `providerState`：保存要求回传的响应 items、content blocks、reasoning details、工具签名及顺序。仅保留协议允许回传的字段，不盲目回传 HTTP 响应头或完整网络包。

- 流式和非流式必须得到等价的可重放结构；空文本不等于空状态。
- 签名、加密块和关联 ID 不参与文本裁剪、摘要改写或通用字段清洗。
- 在安全的回合边界压缩；进行中的 assistant / tool 循环作为整体保留。完成回合要按协议策略处理，不能一律删除推理。
- 状态按供应商、端点、模型 / 凭据配置作用域隔离；切换配置时建立新投影，不跨供应商复用签名 / 文件句柄。
- 调试日志只保留可诊断的类型、数量、摘要与关联 ID；不输出 Base64 图片、凭据或原始加密状态。

这要求检查 Utils、HistoryProjection、Memory / Storage、消息复制、子任务交接与 StepDebugLog 全链路。仅修改 `postLLM` 的请求体会遗漏恢复与下一轮工具请求。

### 5.3 当前首版开发顺序

1. 游戏取景仍独立解决 Go/Remix 遮挡，固定图片测试不能替代取景验收。
2. 编写代码维护的默认视觉目录，优先当前模型，其次同服务 / 区域 / 套餐默认视觉型号；未知不启用。
3. 接入单次视觉服务和 `analyze_image`，不向视觉请求传递主 Agent 工具或全部历史；不新增视觉配置 UI。
4. 验证纯文本主 Agent 调用工具、接收文字报告、修改、复拍再分析；预算、错误、取消与恢复见 PROGRESS M01—M04。
5. 原生图片工具结果、跨调用视觉回放、用户模型选择与多协议扩展留待后续。此前独立视觉路线 E02 已并入首版，不再延期。

## 6. 协议研究验收与待补证据

下表保留原生多模态 Agent 路线的研究用例。首版独立视觉工具不要求视觉模型调用 tools；当前验收以 PROGRESS M01—M04 为准，C03—C05 的原生工具和签名要求属于后续直接多模态路线。

| 编号 | 验证内容 | 通过证据 |
| --- | --- | --- |
| C01 | 单图真实输入 | 图片包含只存在于像素中的随机标记 / 图形关系；模型辨认正确，请求检查确认图片 part 存在 |
| C02 | 多图关联 | 两张图顺序、标签和 assetId 可追溯；回答正确区分两个场景 |
| C03 | 完整工具循环 | assistant 调工具 → 图像结果 → 看图决策 → 再调工具；ID 配对、消息顺序与原生结果结构合法 |
| C04 | 流式等价与中断 | 文本、分片工具参数、推理 / 签名可重建；取消不提交半条 assistant 状态；无重复工具执行 |
| C05 | 历史恢复 | 保存、重启、继续、上下文压缩后合法；所需签名 / reasoning 内容不丢失 |
| C06 | 不支持与参数边界 | 文本模型、未知 ID、非法 detail、尺寸 / 请求体超限得到明确失败；不静默丢图并报告看过 |
| C07 | 配置切换与网关路由 | 区域、套餐、模型变化不复用旧句柄 / 签名；记录实际模型和返回的路由信息 |
| C08 | 游戏闭环 | 输入来自 Remix 可见时的真实游戏合成图；修改后新图证明差异；附取景 runId 与时间 |

当前 DeepSeek 与 GLM 国内 Coding Plan 独立请求覆盖了 C01/C02 的简单样例子集，见验证记录；C03—C08 未执行，不以静态样例代替完整验收。每个模型记录端点类别、精确模型、请求参数、适配器 / 服务版本、日期、图像规格、返回 usage、错误摘要和通过项。不得把“列表出现该模型”当成 C01—C08 通过。

优先待补：四个 Ark / BytePlus 配置的完整官方参数与套餐模型解析；Qwen / OpenAI / 聚合网关默认 ID 的精确能力；实际账户的区域权限；所有候选的图像与工具组合实测。

## 7. 官方资料索引与证据边界

以下均为官方资料。网页会更新，日期是本次读取日期，不是冻结的服务承诺。搜索摘要与正文有差异时以实际打开的正文为准；未完整取得的正文明确注明。示例模型不是自动修改 Dora 预设的依据。

- **[OA] OpenAI：**[图像输入](https://developers.openai.com/api/docs/guides/images-vision)、[Chat 请求定义](https://developers.openai.com/api/reference/resources/chat/subresources/completions/methods/create)、[函数调用与图像结果](https://developers.openai.com/api/docs/guides/function-calling)。
- **[CL] Claude：**[Vision](https://platform.claude.com/docs/en/build-with-claude/vision)、[工具结果处理](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls)、[Thinking 与流式签名](https://platform.claude.com/docs/en/build-with-claude/thinking)、[工具循环与多轮回放](https://platform.claude.com/docs/en/build-with-claude/thinking-tool-workflows)。
- **[GE] Gemini：**[图像输入总览](https://ai.google.dev/gemini-api/docs/image-understanding)、[OpenAI 兼容接口](https://ai.google.dev/gemini-api/docs/openai)、[GenerateContent thought signatures](https://ai.google.dev/gemini-api/docs/generate-content/thought-signatures)、[当前函数调用指南（Interactions）](https://ai.google.dev/gemini-api/docs/function-calling)。两套原生 API 的结构不可混用。
- **[DS] DeepSeek：**[视觉接口](https://api-docs.deepseek.com/guides/vision/)。本次补充核对已直接读取完整官方正文，确认视觉模型、三种传输方式及三条协议路线。
- **[KM] Kimi：**[图像理解](https://platform.kimi.ai/docs/guide/use-kimi-vision-model)、[推理模型与历史保留](https://platform.kimi.ai/docs/guide/use-thinking-models)、[K3 快速开始](https://platform.kimi.ai/docs/guide/kimi-k3-quickstart)。国际文档示例不能证明国内账号权限。
- **[QW] Qwen：**[视觉理解与兼容接口](https://help.aliyun.com/zh/model-studio/vision/)。本次页面未确认预设 `qwen3.7-max` 的精确能力。
- **[OR] OpenRouter：**[图像理解](https://openrouter.ai/docs/guides/overview/multimodal/image-understanding)、[推理字段保留](https://openrouter.ai/docs/guides/best-practices/reasoning-tokens)。
- **[AH] AiHubMix：**[视觉 API](https://docs.aihubmix.com/cn/api/vision)。
- **[SF] SiliconFlow：**[Vision](https://docs.siliconflow.cn/docs/userguide/capabilities/vision)。
- **[ARK] 火山方舟：**[图像理解入口](https://www.volcengine.com/docs/82379/1362931)。动态正文未完整取得，浏览器补读也超时；本次不把搜索摘要中的型号、限额或套餐说明作为已核实结论。
- **[BP] BytePlus：**[图像理解入口](https://docs.byteplus.com/en/docs/ModelArk/1362931)、[ModelArk 视频 / 图像帧请求示例](https://docs.byteplus.com/en/docs/ModelArk/1895586)。图像页正文未完整取得；后者只支持本文的 Chat 图片字段与 Responses 分路判断，不用于推导静态图限制。
- **[MM] MiniMax：**[OpenAI 兼容 API](https://platform.minimax.io/docs/api-reference/text-openai-api)、[Anthropic 兼容能力表](https://platform.minimax.io/docs/api-reference/text-anthropic-api)。实际正文已更新为包含 M3，不能引用旧摘要声称整个平台只接收文本。
- **[MI] MiMo：**[图像理解与模型限制](https://mimo.mi.com/docs/en-US/quick-start/usage-guide/multimodal-understanding/image-understanding)。
- **[GL] 智谱：**[GLM-5.3 / GLM-5.3-Flash 官方仓库](https://github.com/zai-org/GLM-5)、[GLM-V 官方仓库](https://github.com/zai-org/GLM-V)、[GLM-5.2 文本模型](https://docs.bigmodel.cn/cn/guide/models/text/glm-5.2)、[GLM-5V-Turbo](https://docs.bigmodel.cn/cn/guide/models/vlm/glm-5v-turbo)、[Coding Plan 视觉 MCP](https://docs.bigmodel.cn/cn/coding-plan/mcp/vision-mcp-server)。GLM-V 发布记录明确将 `glm-5.3-flash` 标为原生多模态模型；GLM-5 仓库记录其 `reasoning_effort` 支持 `low`、`high`、`max`。
- **[OL] Ollama：**[原生视觉输入](https://docs.ollama.com/capabilities/vision)、[OpenAI 兼容](https://docs.ollama.com/api/openai-compatibility)。
- **[VL] vLLM：**[多模态输入](https://docs.vllm.ai/en/latest/features/multimodal_inputs/)、[工具解析与部署配置](https://docs.vllm.ai/en/latest/features/tool_calling/)。
