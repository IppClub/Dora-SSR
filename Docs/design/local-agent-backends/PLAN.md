# 本地第三方 Agent 开发实施计划

本计划是 [设计方案](./README.md) 的可执行版本；实际完成状态和证据记录在 [PROGRESS.md](./PROGRESS.md)。当前交付 OpenCode、Codex、ZCode 和 Claude Code；macOS 已覆盖四种 Agent，Linux/Windows 已完成 OpenCode 跨平台主链路真实验收。

## 实施顺序

1. **跨平台进程桥**：在原生 Windows、macOS、Linux 构建中启用 xrt subprocess，通过窄 Lua API 暴露参数数组启动、增量 stdout/stderr、stdin 关闭、正常中断与进程树终止。
2. **本地 Agent 核心**：独立存储配置；实现四种 Adapter 的版本检测、真实验证、fresh/resume 参数、结构化事件解析、静默超时与停止。
3. **Dora 会话接入**：local 路径不解析 LLM 配置且不调用 Dora LLM；输出归一化到 `local_agent_message` Step，持久化 resume ID，支持新建外部 session。
4. **命令环境与项目 Skill**：根据当前 `App.executablePath` 与 `Content.assetPath` 生成私有 `dora` shim，仅向第三方 Agent 子进程注入 PATH；为 Claude Code 安装 `.claude/skills/{dora-engine-coding,dora-agent-command,music-generation}`，其它 Agent 安装对应的 `.agents/skills/*`，并保护无管理标记的用户自定义内容。Command Skill 通过 `dora cli agent command --input` 单向调用引擎现有 Lua/Git command；Music Skill 复用 Lua mode，不增加第二套音乐 RPC。
5. **Web IDE 界面**：Agent Configuration 以 Logo 卡片选择本地 Agent，允许沿用或调整默认参数，验证成功才激活；Composer 使用 `llm:<id>` / `local:<id>` 后端 ID，只显示已验证本地 Agent。
6. **验证**：运行生成构建、原生构建、Web IDE 构建、契约测试；在 macOS 使用本机 OpenCode、Codex、ZCode、Claude Code 做 fresh/resume/输出解析测试，再以浏览器模拟用户完成配置、选择、发送、反显、停止和新 session 验收；在 Linux/Windows 原生构建中安装 OpenCode，以真实 DeepSeek 模型验证配置检测、Skill 注入、`dora cli agent command` 和同一 external session 续接。

## 完成门槛

- 本地后端执行期间 Dora LLM 路径零调用。
- 四种 CLI 均使用非交互完整权限，并能捕获结构化消息与 session ID。
- 默认续接同一 external session；显式新建后下一轮 fresh；切换后端时不复用旧 session。
- Agent Step List 可持续反显消息，长输出有界，停止后无子进程残留。
- 第三方 Agent 能直接使用注入的 `dora cli doc/build/agent preview/status/log/command`；不依赖用户 PATH 或本机 alias，也不修改全局 shell 环境。shim 失败时有完整绝对命令降级。
- macOS 四种 Agent 真实验收通过；Linux/Windows 的 OpenCode 检测、真实模型调用、Dora 命令桥和 resume 已通过。两平台的 stop/kill-tree、Unicode/空格路径与 GUI PATH 边界仍需按发布矩阵补证，不能由本次成功路径外推。
- 不修改或依赖 `Studio/` 产品功能；本功能新增测试只放在 `Tools/dora-dora/scripts` 或原生测试位置。
