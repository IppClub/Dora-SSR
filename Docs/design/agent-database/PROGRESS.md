# Dora Agent 数据库治理开发进度

关联设计：[README.md](./README.md)
最后更新：2026-07-24

## 状态定义

| 状态 | 含义 |
| --- | --- |
| 待开始 | 尚未进入开发 |
| 进行中 | 正在实现或验证 |
| 已完成 | 实现与对应验收均通过 |
| 阻塞 | 存在需要决策或外部条件的阻塞 |
| 延后 | 不属于当前阶段 |

## 总体进度

| 阶段 | 状态 | 目标 |
| --- | --- | --- |
| D0 现状审计与方案设计 | 已完成 | 确认增长来源、操作语义和清理边界 |
| D1 独立 Agent 数据库与 schema 新基线 | 已完成 | 空库切换、checkpoint 正文压缩并移除旧表结构兼容代码 |
| D2 引用模型与接口约束 | 已完成 | 建立当前可操作 task 闭包 |
| D3 生命周期清理 | 已完成 | 阻止 step/checkpoint 跨历史 task 无界累积 |
| D4 测试与空间验收 | 已完成 | 验证功能正确性与占用趋稳 |
| D5 checkpoint 内容去重 | 延后 | 降低单个长 task 的峰值占用 |
| D6 通用 BLOB 通道与 codec 简化 | 已完成 | 无损传递 SQLite BLOB，并移除私有 magic envelope |

## 开发任务

| ID | 工作项 | 状态 | 依赖 | 完成标准 | 备注 |
| --- | --- | --- | --- | --- | --- |
| D0.1 | 统计当前数据库表占用 | 已完成 | - | 获得表大小、行数和正文规模 | 样本数据库约 255 MiB |
| D0.2 | 分析 checkpoint/step 生命周期 | 已完成 | - | 确认前端只操作当前 task | 子 Agent 交接为例外引用 |
| D0.3 | 编写设计与进度文档 | 已完成 | D0.1, D0.2 | 文档包含迁移、验收和回退方案 | 本目录 |
| D1.1 | 提取统一 Agent 存储访问层 | 已完成 | D0.3 | Agent 表名、schema、事务和查询集中管理 | 固定使用 `agent` schema |
| D1.2 | 实现首版 checkpoint 文本 codec | 已完成 | D1.1 | `dora_compress_text`/`dora_decompress_text` 往返一致 | 首版 envelope 已由 D6 替换 |
| D1.3 | 实现 `agent.db` attach 与完整 schema 建表 | 已完成 | D1.2 | 独立文件、压缩 BLOB 字段与 `agent.user_version` 建立成功 | attach 失败不影响普通配置 |
| D1.4 | 实现 schema 版本重置策略 | 已完成 | D1.3 | 低版本整体重建，高版本拒绝打开 | 未知旧表也会清除 |
| D1.5 | 删除 AgentSession 旧兼容代码 | 已完成 | D1.3 | 移除旧 user_version、补列、局部重建逻辑 | 合并重复建表入口 |
| D1.6 | 删除 AgentTask 和问卷表兼容代码 | 已完成 | D1.3 | 移除 work_mode 补列和旧问卷表清理 | 问卷继续使用文件 |
| D1.7 | 将所有 Agent SQL 切换到 `agent` schema | 已完成 | D1.4-D1.6 | `dora.db` 不再新增 Agent 记录 | 禁止静默回退 |
| D1.8 | 拆分 checkpoint metadata/content 查询 | 已完成 | D1.7 | 列表、摘要和 handoff 不解压正文 | task diff 只解压首尾 |
| D1.9 | 实现旧 Agent 表一次性删除 | 已完成 | D1.8 | 新库可用后原子 drop `main.Agent*` | 包含旧 `AgentQuestionnaire` |
| D1.10 | 验证空历史与新会话重建 | 已完成 | D1.9 | 首次升级列表为空，新会话跨重启恢复 | 3 条 `LLMConfig` 保留 |
| D2.1 | 新增 `AgentTaskReference` schema | 已完成 | D1.7 | 表、索引和幂等建表完成 | 首个 kind 为 `sub_agent_handoff` |
| D2.2 | 实现 task 引用写入与删除 | 已完成 | D2.1 | 交接 step 与引用原子提交 | 不依赖 JSON 做生命周期判断 |
| D2.3 | 实现 `operableTasks` 引用闭包 | 已完成 | D2.1 | 当前 task 与递归子 task 计算正确 | 已防循环 |
| D2.4 | checkpoint API 增加 session 归属校验 | 已完成 | D2.3 | 旧 ID 和跨项目 ID 被拒绝 | list/diff/rollback 均验证 |
| D3.1 | 提取按 task 清理事务 | 已完成 | D2.3 | entry、checkpoint、step、owner ref 原子清理 | 消息引用 task 仅保留轻量行 |
| D3.2 | 新 task 切换后清理旧重型数据 | 已完成 | D3.1 | 旧普通 task 不再保留 checkpoint/step | 新 task 切换后触发 |
| D3.3 | 修正子 Agent session 删除路径 | 已完成 | D2.2, D3.1 | 子 session 删除但被引用 checkpoint 保留 | 主 task 失效后递归回收 |
| D3.4 | 修正项目删除路径 | 已完成 | D3.1 | 项目删除后无 Agent 孤儿记录 | session 相关 task 全量收集 |
| D3.5 | 增加清理调度与 finalizing 防护 | 已完成 | D3.1 | 运行、停止、问卷和交接期间不会误清理 | 每次孤儿批次最多 4 task |
| D3.6 | 增加孤儿审计与日志 | 已完成 | D3.1 | 输出候选 task、checkpoint、entry、step、引用和字节数 | 只审计 `agent.db` |
| D4.1 | 当前 task checkpoint 回归测试 | 已完成 | D3 | diff、单点回滚、整轮回滚通过 | 覆盖 create/write/delete |
| D4.2 | 停止后继续回归测试 | 已完成 | D3 | 复用 task ID 且 checkpoint 不丢失 | current task 根集合与跨重启恢复通过 |
| D4.3 | 子 Agent 交接回归测试 | 已完成 | D3.3 | session 删除后仍可 diff/rollback | 引用保活与主 task 替换回收通过 |
| D4.4 | API 越权与旧 ID 测试 | 已完成 | D2.4 | 非 operable task 操作全部失败 | 跨 session、跨项目、历史 ID 均拒绝 |
| D4.5 | 事务故障注入测试 | 已完成 | D3.1 | 失败后无半清理状态 | SQLite trigger 注入失败后完整回滚 |
| D4.6 | 100 task 空间稳定性测试 | 已完成 | D3.6 | 重型行数不随历史 task 线性增长 | 仅保留当前 1 checkpoint/entry |
| D4.7 | 独立数据库与版本差异测试 | 已完成 | D1 | attach/建表/低高版本/旧表清理行为正确 | 同版本损坏也明确拒绝 |
| D4.8 | 双库空间验收 | 已完成 | D1.9, D3 | 分别统计 `dora.db` 与 `agent.db` | 255 MiB / 88 KiB；暂不 VACUUM |
| D4.9 | 兼容代码清理审计 | 已完成 | D1.5, D1.6 | Agent 表操作无补列、局部重建和旧问卷表分支 | `LLMConfig` 明确排除 |
| D4.10 | checkpoint codec 正确性测试 | 已完成 | D1.2 | UTF-8、空/小/大文本往返一致，损坏数据明确失败 | 覆盖 raw/deflate |
| D4.11 | 延迟解压与性能测试 | 已完成 | D1.8 | metadata 路径不解压且写入/diff/回滚延迟达标 | P50 7.68 ms，P95 9.25 ms |
| D5.1 | 设计并实现内容寻址 blob | 延后 | D4, D6 | before/after 相同正文复用 | 复用 TEXT/zlib 存储规则 |
| D5.2 | 将 entry 改为 blob 引用并实现 GC | 延后 | D5.1 | 正文引用正确且无孤儿 blob | 不维护手工 refcount |
| D5.3 | 去重、回滚与空间回归测试 | 延后 | D5.2 | diff/rollback 语义不变且占用进一步下降 | schema 升级仍整体重建 |
| D6.1 | 修正通用 DB BLOB 查询 | 已完成 | D4 | `Column::getString()` 按长度复制，内嵌 `\0` 无损到达 Lua | 不增加 `DBBlob` |
| D6.2 | 简化文本压缩格式 | 已完成 | D6.1 | TEXT 原文回退、BLOB 保存标准 zlib 数据 | 直接更新 schema v1 基线，不增加升级兼容 |
| D6.3 | 实现受限流式解压 | 已完成 | D6.2 | 完整消费输入、校验 zlib 流并限制最大输出 | 64 KiB 分块，最大 256 MiB |
| D6.4 | 补充 BLOB 与 codec 回归测试 | 已完成 | D6.1-D6.3 | 覆盖零字节、空/小/大文本、随机 BLOB、损坏流和输出上限 | sync/async query 均通过 |

## 验收记录

| 日期 | 验收项 | 结果 | 证据 |
| --- | --- | --- | --- |
| 2026-07-24 | 当前数据库只读审计 | 通过 | 确认主要占用来自 checkpoint entry 和 session step |
| 2026-07-24 | 子 Agent 交接依赖复核 | 通过 | 交接卡片通过 `sourceTaskId` 查询 task diff/rollback |
| 2026-07-24 | checkpoint 压缩收益测算 | 通过 | 163.2 MiB 原文预计压至 60.8 MiB，减少 62.8%；全量快速压缩约 2.6 秒 |
| 2026-07-24 | 首版 codec 与 checkpoint 功能回归 | 通过 | 当时的 envelope 版本覆盖空/小/大 UTF-8、损坏数据、create/write/delete、单点与整轮回滚；现已由 D6 替换 |
| 2026-07-24 | 引用闭包与生命周期回归 | 通过 | 子 task 引用保活、主 task 替换回收、项目删除和 100 task 稳定性均通过 |
| 2026-07-24 | API 归属与事务故障注入 | 通过 | 跨项目/历史 ID 拒绝；清理中止后 entry/checkpoint/step 均完整保留 |
| 2026-07-24 | schema 与跨重启回归 | 通过 | 同版本恢复、低版本重建、高版本/结构损坏拒绝、普通配置可用 |
| 2026-07-24 | 性能与双库空间验收 | 通过 | 写入 P50/P95 7.68/9.25 ms；task diff 1.67 ms；`agent.db` 88 KiB |
| 2026-07-24 | D6 原生与 Agent 构建 | 通过 | macOS Debug 构建成功；Agent TypeScript 以 `Assets/Script/Lib` 为 projectRoot 13/13 |
| 2026-07-24 | D6 BLOB 往返 | 通过 | sync/async 均无损返回含内嵌零字节的 4 KiB BLOB |
| 2026-07-24 | D6 codec 与防护 | 通过 | TEXT 回退、跨 64 KiB 分块 zlib、损坏流、尾随数据及 257 MiB 输出上限均通过 |

## 待决策

| 项目 | 建议 | 决策状态 |
| --- | --- | --- |
| 删除旧 Agent 表后是否自动 `VACUUM` | 暂不自动；先复用 freelist，提供空闲期维护入口 | 已按建议实施 |
| task 是否增加 `project_root`/`root_session_id` | 第二阶段评估；可显著简化项目删除与审计 | 待确认 |
| 历史消息保留期限 | 当前继续保留；其占用远低于 step/checkpoint | 待确认 |
| checkpoint blob 压缩格式 | 小于 512 B 或无收益时保存 TEXT，其余保存标准 zlib BLOB；不使用私有 magic envelope | 已实施 |
| SQLite BLOB 的 Lua 表示 | C++ 按长度复制到 `std::string`，Lua 以二进制字符串接收；不增加 `DBBlob` | 已实施 |
| `agent.db` 连接方式 | 使用现有 DB 单例执行 `ATTACH DATABASE ... AS agent` | 已确定 |
| 是否迁移旧 Agent 会话 | 不迁移；首次切换显示空历史 | 已确定 |
| 是否支持新旧数据库双写 | 不支持；所有 Agent SQL 直接切换到 `agent` schema | 已确定 |
| 低版本 `agent.db` 如何升级 | 整体重建当前 schema，不做增量兼容 | 已确定 |
| `LLMConfig` 是否随历史重置 | 不重置；继续保存在 `dora.db` | 已确定 |
