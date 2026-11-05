# LLM 供应商模板核查

核查日期：2026-11-05。范围为 Web IDE 的 `LLMConfigDialog.tsx` 和移动端的 `LLMSetup.tsx`（及其生成 Lua）。模板用于新增配置或主动套用模板；不自动覆盖数据库中已有配置。

## 本次更新

| 模板 | 默认模型 | 参数调整 |
| --- | --- | --- |
| DeepSeek | `deepseek-flash` | 保留 1,000,000 上下文、辅助请求关闭思考 |
| Moonshot | `kimi-k3.1-pro` | 1,000,000 上下文，辅助请求 `reasoning_effort: low` |
| Qwen | `qwen3.8-max` | 1,000,000 上下文，辅助请求 `enable_thinking: false` |
| SiliconFlow | `deepseek-ai/DeepSeek-V4.1-Flash` | 保留保守的 128,000 上下文和 `enable_thinking: false` |
| MiniMax / MiniMax (CN) | `MiniMax-M3.1-Flash` | 1,000,000 上下文，辅助请求使用 `thinking.type: adaptive`、`reasoning_effort: low` |
| Xiaomi MiMo | `mimo-v2.6-pro` | 1,000,000 上下文，保留原有输出参数与辅助请求关闭思考 |
| ZAI / ZAI Coding Plan | `glm-5.3` | 1,000,000 上下文，显式开启思考，辅助请求使用 `reasoning_effort: low` |

GLM-5.3 和 MiniMax-M3.1-Flash 均不能关闭思考，不能沿用旧模板的关闭思考参数。主请求沿用供应商默认思考强度；低强度设置仅作用于辅助请求。最大输出仍采用工程默认 64,000。

## 保留与后续适配

- OpenAI 保留 `gpt-5.6`。GPT-6 系列虽有更新，但官方要求带工具的 Chat Completions 工作流迁往 Responses API；当前 Agent 使用 Chat Completions，不能仅改模型名完成升级。
- AiHubMix 保留 `gpt-5.6-luna`；官方供应商目录仍列出此模型，未将上游新模型在中转服务的协议兼容性视为已验证。
- OpenRouter 保留 `~anthropic/claude-sonnet-latest`，该别名已自动跟随 Sonnet 家族最新版。
- VolcEngine 保留 `doubao-seed-2-0-pro-260215`。新版 `doubao-seed-2-1-pro-260915` 默认启用思考摘要，官方要求多轮工具调用回传 `encrypted_content`；当前 Agent 尚未实现该字段的接收与回传，需先完成协议适配。
- VolcEngine / BytePlus Coding Plan 保留 `ark-code-latest`，不固定套餐路由后的具体模型。
- BytePlus 保留 `dola-seed-2-1-turbo-260628`，官方当前文档仍使用该 ID，支持辅助请求关闭思考。
- Ollama / vLLM 的模型是本地部署示例，实际需与用户已安装或正在服务的模型一致，未自动升级示例名称。

以上为官方文档核查和本地编译检查；未使用用户密钥进行付费调用，也不代表每个账号、地域或套餐的实时可用性已经实测。

## 官方依据

- [DeepSeek 模型与价格](https://api-docs.deepseek.com/quick_start/pricing/)、[Flash 发布公告](https://www.deepseek.com/en/news/deepseek-v4-1-flash/)
- [Kimi K3.1 Pro](https://platform.kimi.ai/docs/guide/kimi-k3-1-pro-quickstart)
- [Qwen3.8 Max](https://help.aliyun.com/zh/model-studio/qwen3-8-max)、[混合思考模式](https://help.aliyun.com/en/model-studio/deep-thinking)
- [SiliconFlow 更新公告](https://docs.siliconflow.cn/docs/release-notes/overview)、[Chat API](https://docs.siliconflow.cn/docs/api/chat-completions-post)
- [MiniMax OpenAI 兼容 API](https://platform.minimax.io/docs/api-reference/text-openai-api)
- [MiMo 模型列表](https://mimo.mi.com/docs/quick-start/model)、[旧模型下线公告](https://mimo.mi.com/docs/updates/deprecate)
- [GLM-5.3](https://docs.bigmodel.cn/cn/guide/models/text/glm-5.3)
- [OpenAI 新模型迁移说明](https://developers.openai.com/api/docs/guides/latest-model)、[发布记录](https://developers.openai.com/api/docs/changelog)
- [AiHubMix OpenAI 模型目录](https://aihubmix.com/authors/openai)
- [OpenRouter Sonnet 别名](https://openrouter.ai/~anthropic/claude-sonnet-latest/api)
- [VolcEngine 深度思考与加密内容回传](https://console.volcengine.com/ark/region:cn-beijing/docs/deep-thinking)
- [BytePlus 深度思考](https://docs.byteplus.com/en/docs/modelark/deep-thinking?redirect=1)
