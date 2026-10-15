# Dora Agent 数据库存储与生命周期治理设计

状态：第一阶段与通用 BLOB/codec 改造均已实现并通过验收
最后更新：2026-07-24
进度跟踪：[PROGRESS.md](./PROGRESS.md)

## 1. 背景

Dora 默认数据库 `dora.db` 同时保存普通配置和 Agent 运行历史。Agent 引入 task、step、checkpoint 后，数据库开始承载大量工具参数、工具结果以及文件编辑前后的完整正文。

2026-07-24 对本机数据库进行只读分析时得到以下数据：

| 项目 | 结果 |
| --- | ---: |
| 数据库文件大小 | 约 255 MiB |
| `AgentCheckpointEntry` | 约 167 MiB，4,881 行 |
| `AgentSessionStep` | 约 85 MiB，16,923 行 |
| checkpoint 前后正文 UTF-8 字节总量 | 约 163.2 MiB |
| checkpoint 正文完全去重后 | 约 84.7 MiB |
| 可由内容去重直接消除的重复量 | 约 48.1% |
| 无任何 session 引用的 task | 478 个 |
| 上述 task 对应的 checkpoint 正文 | 约 32.4 MiB |
| SQLite `freelist_count` | 3 页 |

当前文件变大主要是有效记录持续累积，并不是 SQLite 已经删除数据但没有执行 `VACUUM`。直接运行 `VACUUM` 基本无法解决当前问题。

## 2. 当前行为与问题

### 2.1 checkpoint 保存放大

每次文件编辑都会在 `AgentCheckpointEntry` 中保存完整的：

- `before_content`
- `after_content`

连续多次修改同一个大文件时，相邻 checkpoint 会反复保存几乎相同的完整正文。它保证了 diff 和回滚的独立性，但带来了明显的存储放大。

### 2.2 历史 step 长期保存

`AgentSessionStep` 会保存：

- reasoning
- tool params
- tool result
- checkpoint 关联
- 文件清单

前端目前只展示当前 task 的 step。旧 task 的完整 step 在新 task 开始后不再可见，但仍永久保存在数据库。

### 2.3 session 删除没有覆盖 task 数据

当前删除 session 时会删除：

- `AgentSessionStep`
- `AgentSessionMessage`
- `AgentSession`

但不会删除：

- `AgentTask`
- `AgentCheckpoint`
- `AgentCheckpointEntry`

因此删除项目或子 Agent session 后可能留下失去生命周期归属的 task 和 checkpoint。

### 2.4 子 Agent 交接仍依赖 checkpoint

子 Agent 完成交接后，其 session 会被删除，但主 Agent 的交接卡片仍允许：

- 查看子 Agent 的合并变更
- 回滚子 Agent 的整轮变更

交接结果中的 `changeSet` 只保存文件路径、操作、checkpoint ID 等摘要。实际 diff 和回滚仍通过 `sourceTaskId` 读取子 Agent checkpoint。因此不能在子 Agent session 删除时直接删除其 checkpoint。

### 2.5 后端接口归属校验不足

前端只加载当前 task 的 checkpoint，但部分接口仍可直接通过已知的 `taskId` 或 `checkpointId` 查询和回滚旧记录。服务端需要以 session 当前可操作 task 集合为准进行校验，不能只依赖前端隐藏。

## 3. 设计目标

1. 数据库占用随“当前仍可操作的 Agent 状态”变化，不随历史 task 数量无限增长。
2. 保留当前 task 的逐 checkpoint diff、单 checkpoint 回滚和整轮回滚。
3. 保留当前主 task 中子 Agent 交接卡片的 diff 与回滚能力。
4. 保证停止后继续同一 task 时 checkpoint 不丢失。
5. 让所有清理操作具有事务性、可恢复性和明确的引用判断。
6. 避免频繁执行小型 `DELETE` 或 `VACUUM` 阻塞引擎。
7. 保留历史用户消息、Agent 总结和轻量变更摘要。
8. 将 Agent 数据存储切换到独立 `agent.db`，避免 Agent 维护影响默认配置库。
9. 以完整 schema 基线替代旧表重建、补列和增量兼容代码。
10. checkpoint 文件正文以压缩形式落库，仅在 diff 或回滚等按需路径解压。

## 4. 非目标

第一阶段不做以下工作：

- 不改变 Agent 的 LLM context 和记忆压缩行为。
- 不允许跨历史 task 恢复 checkpoint 操作。
- 不在每次 checkpoint 创建后立即清理数据库。
- 不在每次删除后运行 `VACUUM`。
- 不迁移或兼容 `dora.db` 中已有的 Agent 会话数据；切换后应用层从空的 Agent 存储开始。
- 不保留旧 Agent schema 的逐版本 `ALTER TABLE` 升级链。
- 不使用 Base64 包装压缩正文；额外编码会放大存储和 CPU 开销。
- 不引入公开的 `DBBlob` userdata；Lua 字符串本身可作为二进制字节串。
- 不以 patch 链替换完整正文；patch 链会提高回滚恢复复杂度。

## 5. 生命周期模型

### 5.1 task 分类

| 类型 | 含义 | 重型数据保留 |
| --- | --- | --- |
| 当前 task | 任一 session 的 `current_task_id` | 保留 step 与 checkpoint |
| 被当前 task 引用的子 task | 当前主 task 的交接卡片引用的 `sourceTaskId` | 保留 checkpoint；子 session/step 可删除 |
| 历史普通 task | 已被新 task 替代，前端不可操作 | 删除 step 与 checkpoint，保留消息和总结 |
| 历史交接 task | 承载交接卡片的主 task 已被新 task 替代 | 删除自身 step，并释放其子 task 引用 |
| 孤儿 task | 不属于 session 当前状态、历史消息或有效 task 引用 | 删除 task 及其所有从属数据 |

### 5.2 当前可操作 task 集合

定义 `operableTasks`：

1. 将所有 `AgentSession.current_task_id` 加入根集合。
2. 从根集合中的 task 出发，沿 task 引用关系递归加入目标 task。
3. 递归过程需要去重并防止循环。

只有 `operableTasks` 中的 task 可以：

- 枚举 checkpoint
- 查看 checkpoint/task diff
- 执行 checkpoint/task rollback
- 保留完整 checkpoint 正文

停止或失败的当前 task 仍在根集合中，因此“继续”复用 task ID 时不会丢失 checkpoint。

### 5.3 显式 task 引用

新增表：

```sql
CREATE TABLE AgentTaskReference(
    owner_task_id INTEGER NOT NULL,
    target_task_id INTEGER NOT NULL,
    kind TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    PRIMARY KEY(owner_task_id, target_task_id, kind)
);

CREATE INDEX idx_agent_task_ref_target
ON AgentTaskReference(target_task_id);
```

第一阶段使用的 `kind`：

- `sub_agent_handoff`：主 task 的交接 step 引用子 Agent task。

写入交接 step 与 task 引用必须处于同一个事务。主 task 被清理时，删除它拥有的引用；失去最后一个有效引用的子 task 随后成为清理候选。

不能把 `result_json` 中的 `sourceTaskId` 作为长期引用真相来源。JSON 只用于 UI 展示和兼容已有交接结果，生命周期判断使用 `AgentTaskReference`。

## 6. 数据清理策略

### 6.1 新 task 开始

新 task 成功创建并成为 session 的 `current_task_id` 后：

1. 重新计算 `operableTasks`。
2. 找到刚刚失去可操作性的旧 task。
3. 确认旧 task 不处于 `RUNNING`、`WAITING_USER` 或 finalizing 状态。
4. 确认最终 Agent 消息和轻量变更摘要已经落库。
5. 按 task 执行重型数据清理。

历史普通 task 清理内容：

```text
AgentCheckpointEntry
AgentCheckpoint
AgentSessionStep
AgentTaskReference（owner 为该 task）
```

历史 `AgentTask` 是否删除取决于是否仍被消息或其它轻量记录引用。保留 task 行的成本很低，可以在第一阶段优先保留，避免破坏历史消息的 task 分组。

### 6.2 子 Agent 交接

子 Agent 完成交接时：

1. 计算 `changeSet` 和 handoff evidence。
2. 写入交接结果文件。
3. 在主 task 中写入 `sub_agent_handoff` step。
4. 写入 `AgentTaskReference(owner=主 task, target=子 task)`。
5. 提交事务后才允许删除子 session、子 step 和子消息。
6. 子 task checkpoint 由引用关系继续保活。

当承载交接卡片的主 task 被下一个主 task 替代时：

1. 删除主 task 拥有的引用。
2. 重新计算子 task 是否仍被其它当前 task 引用。
3. 没有其它引用时删除子 task checkpoint。

### 6.3 session 与项目删除

删除 session 前先收集：

- session 当前 task
- session step/message 涉及的 task
- 这些 task 拥有或被拥有的引用

删除项目时，应在事务中清除该项目的完整 Agent 数据。由于 `AgentTask` 当前没有 `project_root`，不能仅凭 task 表独立判断归属。第一阶段通过 session、step、message 和 task 引用闭包收集；后续可考虑给 task 增加 `project_root` 或 `root_session_id`，简化删除与审计。

### 6.4 孤儿审计与清理

新的 `agent.db` 从空库开始，因此不需要解析或回填 `dora.db` 中的旧 handoff 引用。

运行期仍应提供可重复的孤儿审计：

1. 建立 `AgentTaskReference`。
2. 计算当前 `operableTasks`。
3. 统计不属于当前集合的 task、checkpoint、entry 和正文总字节数。
4. 将清理统计写入日志。
5. 分批清理运行异常可能遗留的孤儿数据。
6. 每个 task 的清理保持事务原子性。

该审计只作用于 `agent.db`，不读取旧 `dora.db` Agent 表来恢复会话。

## 7. 事务与调度

### 7.1 删除粒度

日常清理按 task 合并为一个事务，不按 checkpoint 或 entry 逐事务删除：

```sql
BEGIN;
DELETE FROM AgentCheckpointEntry
WHERE checkpoint_id IN (
    SELECT id FROM AgentCheckpoint WHERE task_id = ?
);
DELETE FROM AgentCheckpoint WHERE task_id = ?;
DELETE FROM AgentSessionStep WHERE task_id = ?;
DELETE FROM AgentTaskReference WHERE owner_task_id = ?;
COMMIT;
```

实际实现应使用 `DB.transaction()`，不手工拼接 `BEGIN`/`COMMIT`。

### 7.2 执行时机

允许清理：

- 新 task 已成功切换后
- Agent 不在等待工具结果落库时
- 子 Agent 交接事务完成后
- 项目删除时
- 启动迁移的空闲阶段

禁止清理：

- task 正在运行
- task 正在等待问卷反馈
- task 正在 stopping/finalizing
- 旧 runner 尚未发出 `task_finished`
- 交接结果与引用尚未共同提交

### 7.3 大型迁移

首次历史清理可能涉及上百 MiB 数据。为避免 Web IDE 长时间无响应：

- 以 task 为最小事务单位。
- 每批限制 task 数量或预计正文大小。
- 批次之间让出游戏帧。
- 日志记录累计清理行数和字节数。
- 中止后下次启动可根据迁移版本和现存记录继续。

## 8. SQLite 文件空间管理

### 8.1 DELETE 后的预期

SQLite 删除记录后，数据库文件通常不会立即缩小。释放的页会进入 freelist，后续 Agent 写入可以复用。

只要重型数据保留量受到生命周期约束，即使文件保持历史峰值大小，也不应继续无界增长。

### 8.2 VACUUM 策略

不在日常 task 清理后执行 `VACUUM`。

仅在以下条件同时满足时考虑整理：

- 没有运行中、等待用户或 finalizing 的 Agent task。
- 空闲页占用达到明显阈值，例如至少 64 MiB 且超过数据库页面的 25%。
- 可用磁盘空间足够完成数据库重建。
- 当前没有其它数据库写事务。

第一阶段可以只提供维护函数和日志，不自动在交互过程中运行。首次迁移完成后，即使暂不 `VACUUM`，新数据也会优先复用空闲页。

### 8.3 auto-vacuum

不建议直接启用 `auto_vacuum=FULL`，因为它会在每次事务提交时移动和截断页面，可能增加写入成本和碎片。

`auto_vacuum=INCREMENTAL` 可作为后续选项，但从当前 `NONE` 切换需要先重建数据库。应在完成生命周期清理并获得性能数据后再决定。

## 9. 接口约束

checkpoint 相关服务端接口统一接收 `sessionId`，并执行：

1. 读取 session 当前 task。
2. 计算该 task 可到达的 task 引用闭包。
3. 校验传入 task/checkpoint 属于闭包。
4. 校验 checkpoint 对应的项目根目录与 session 一致。
5. 校验成功后才允许 list、diff 或 rollback。

需要覆盖：

- `/agent/checkpoint/list`
- `/agent/checkpoint/diff`
- `/agent/task/diff`
- `/agent/checkpoint/rollback`
- `/agent/task/rollback`

旧历史 ID 即使仍暂时存在于数据库，也不能绕过当前 UI 生命周期直接操作。

## 10. checkpoint 正文压缩与可选去重

生命周期清理解决跨 task 的长期无界增长。正文压缩降低每个可操作 task 及子 Agent 交接 checkpoint 的实际占用。

### 10.1 存储格式

新的 `AgentCheckpointEntry` 不再使用 `before_content`/`after_content` TEXT 列，改为：

```sql
CREATE TABLE AgentCheckpointEntry(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    checkpoint_id INTEGER NOT NULL,
    ord INTEGER NOT NULL,
    path TEXT NOT NULL,
    op TEXT NOT NULL,
    before_exists INTEGER NOT NULL,
    before_data BLOB,
    after_exists INTEGER NOT NULL,
    after_data BLOB,
    bytes_before INTEGER NOT NULL DEFAULT 0,
    bytes_after INTEGER NOT NULL DEFAULT 0
);
```

`bytes_before` 和 `bytes_after` 表示未压缩 UTF-8 字节数。压缩后大小通过 SQLite `length(before_data)`/`length(after_data)` 统计。

压缩格式不再使用自定义 magic、版本号、codec 标记或原始长度
envelope，而是利用 SQLite 值自身的存储类型区分：

- `TEXT`：正文小于 512 bytes，或者压缩后没有实际收益，直接保存原文。
- `BLOB`：使用项目已有 miniz 生成的标准 zlib 数据，采用快速压缩等级。

`AgentCheckpointEntry` 的字段仍声明为 `BLOB`，但 SQLite 的动态类型允许
同一字段按行保存 `TEXT` 或 `BLOB`。这使 raw 回退无需额外格式标记。

以当前 4,881 条 checkpoint entry 的 9,762 份 before/after 内容测算：

- 原始 UTF-8 正文约 163.2 MiB。
- 使用 zlib 快速级别、512 bytes 阈值和 TEXT 回退后，预计存储总量约 60.8 MiB。
- 预计减少约 62.8%；本地全量扫描压缩耗时约 2.6 秒。
- 8,902 份内容使用 deflate，860 份小文本或无收益内容使用 raw。

这是离线全量测算，不代表单次编辑延迟；正式验收仍以实际 checkpoint 写入的 P50/P95 为准。

### 10.2 原生 SQL codec

Lua 字符串是带长度的二进制字节串，`Content:load()` 也通过
`lua_pushlstring()` 返回二进制文件。数据库查询应遵循同一规则：

1. C++ 对 SQLite `TEXT` 和 `BLOB` 都使用 `Column::getString()` 按
   `sqlite3_column_bytes()` 返回的长度复制，不能通过零结尾的
   `getText()` 构造字符串。
2. `DB::Col` 继续使用 `std::string` 承载文本或二进制字节，不增加
   `DBBlob` 类型。
3. Lua 绑定继续通过 `tolua_pushslice()`，最终调用
   `lua_pushlstring(data, size)`，完整保留内嵌 `\0`。
4. Lua 字符串作为查询参数时仍默认绑定为 SQLite `TEXT`；需要写入
   通用 BLOB 时由 SQL 表达式产生，例如 `CAST(? AS BLOB)`，压缩文本则
   使用 `dora_compress_text(?)`。

底层 SQLite 连接注册两个原生 SQL 函数：

```sql
dora_compress_text(text)        -> TEXT 或 zlib BLOB
dora_decompress_text(text|blob) -> TEXT
```

写入：

```sql
INSERT INTO agent.AgentCheckpointEntry(..., before_data, after_data, ...)
VALUES(..., dora_compress_text(?), dora_compress_text(?), ...);
```

按需读取：

```sql
SELECT dora_decompress_text(before_data),
       dora_decompress_text(after_data)
FROM agent.AgentCheckpointEntry
WHERE checkpoint_id = ?;
```

这样：

- TypeScript 继续传递和接收普通 UTF-8 字符串。
- 小文本或无压缩收益的正文以 TEXT 保存，可压缩正文以标准 zlib BLOB 保存。
- 不需要 Base64。
- 通用 DB 查询也能把任意 BLOB 作为 Lua 二进制字符串返回。
- 现有通用 DBRow 不需要增加公开 BLOB 类型。

`SELECT data FROM table_name` 返回字段的原始存储内容：TEXT 是原文，
BLOB 是压缩后的二进制字符串，不会自动解压。需要读取逻辑正文的路径
必须显式调用 `dora_decompress_text(data)`。

`dora_decompress_text()` 对 TEXT 直接返回原值；对 BLOB 执行流式 zlib
解压，并校验：

- zlib header、数据块与 checksum 完整性
- 输入已被完整消费且压缩流正常结束
- 解压后的输出不超过合理上限

校验失败时返回数据库错误，使 diff/回滚明确失败，不能用空字符串代替
损坏正文。因为没有格式版本字段，将来若替换压缩算法，应提升
`agent.user_version` 并按既定策略重建 Agent schema，而不是在同一字段中
长期兼容多种私有格式。

### 10.3 延迟解压

压缩只有在查询路径不随意解压时才有价值。checkpoint 查询拆分为：

- metadata 查询：ID、路径、操作、exists、字节数，不读取正文。
- content 查询：仅 diff、rollback 或确实需要恢复文件时调用解压函数。

需要同步调整：

- `applyFileChanges()` 使用已经在内存中的 before/after 状态写文件，不在插入后立刻查询并解压同一 checkpoint。
- `listCheckpoints()` 和 `summarizeTaskChangeSet()` 只读 metadata。
- `getTaskChangeSetDiff()` 每个路径只解压首次 before 和最终 after，不解压中间版本。
- `rollbackCheckpoint()` 与 `rollbackTaskChangeSet()` 按实际回滚顺序解压。
- 子 Agent handoff 摘要只读取路径和操作；用户展开 diff 或点击回滚时才解压。

### 10.4 写入与性能策略

- 压缩发生在 checkpoint 落库前，失败则不应用文件修改。
- 使用快速压缩等级，优先控制交互延迟。
- 单个 checkpoint 的 entry 在同一事务中写入。
- 记录 raw bytes、stored bytes、压缩耗时和解压耗时的调试指标。
- 大文本压缩需要纳入 Agent task 的 stopping/finalizing 安全边界。
- 压缩正文不进入日志。

验收时比较：

- 未压缩字节与 BLOB 存储字节
- checkpoint 写入延迟 P50/P95
- task diff 首次展开延迟
- 单 checkpoint 和整 task 回滚延迟
- 中英文、空文本、大文件及包含多字节 UTF-8 的往返一致性

### 10.5 第二阶段内容去重

压缩作为新 `agent.db` schema 的首版能力实现；内容去重仍作为后续优化。

去重阶段增加内容寻址表，让 checkpoint entry 引用压缩正文 blob：

```sql
CREATE TABLE AgentFileBlob(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content_hash TEXT NOT NULL UNIQUE,
    encoding TEXT NOT NULL DEFAULT 'raw',
    content BLOB NOT NULL,
    raw_bytes INTEGER NOT NULL,
    stored_bytes INTEGER NOT NULL
);
```

`AgentCheckpointEntry` 改为保存：

- `before_blob_id`
- `after_blob_id`

设计要求：

- hash 基于未压缩正文，保证相同内容复用同一 blob。
- diff、apply 和 rollback 通过 blob ID 读取正文，行为保持不变。
- blob 回收以实际引用查询为准，避免手工 refcount 因异常退出失真。
- blob 内容复用同一 TEXT/zlib 存储规则和原生 SQL codec。
- 按 schema 新基线策略提升版本并重建，不增加从旧 entry BLOB 到 blob 表的长期兼容代码。

当前样本仅做完整内容去重即可从约 163.2 MiB 降至约 84.7 MiB，因此值得作为第二阶段实施。

## 11. 独立 Agent 数据库

独立 `agent.db` 作为本方案的存储基础先行实施。新版本不迁移 `dora.db` 中已有的 Agent 数据，首次切换后前端看到空的会话列表；用户创建新 Agent 会话时，在 `agent.db` 中重新建立 session、task 和 checkpoint 数据。

### 11.1 目标文件与职责

```text
<Application Support>/IppClub/DoraSSR/
├── dora.db   # 引擎和 Web IDE 普通配置
└── agent.db  # Agent session、task、step、message、checkpoint 和存储元数据
```

存放在 `agent.db` 的表包括：

- `AgentSession`
- `AgentSessionMessage`
- `AgentSessionStep`
- `AgentTask`
- `AgentCheckpoint`
- `AgentCheckpointEntry`
- `AgentTaskReference`

问卷临时上下文继续保存在项目 `.agent/questionnaire`，不进入数据库。项目中的 `.agent/plan`、子 Agent 结果等文件也不会因数据库切换而删除，但它们不会被用于重建已经清空的旧 session。

### 11.2 连接方式

当前 Dora TypeScript 只暴露一个全局 `DB` 单例，底层固定打开 `dora.db`，但允许执行 SQL 并检查 attached database。因此第一版不新增第二套脚本 DB 对象，而是在 Agent 存储初始化时执行：

```sql
ATTACH DATABASE ? AS agent;
```

所有 Agent SQL 使用固定 schema 前缀，例如：

```sql
SELECT * FROM agent.AgentSession;
```

该方式具有以下特点：

- `agent.db` 是独立物理文件。
- 继续复用现有 DB 工作线程和同步/异步接口。
- 生命周期事务只写 `agent` schema，不再与普通配置表争用同一数据库页面。
- `ATTACH` 名称固定为 `agent`，文件路径使用参数绑定，不接受外部 schema 名称。

物理文件隔离不等于并发连接隔离：两个 schema 仍共享同一个 Dora DB 工作线程，长事务仍可能延迟普通配置操作。第一版继续通过分批清理和空闲调度控制延迟；只有实测证明仍有明显阻塞时，才考虑在 C++ 层新增第二个独立 DB 连接与线程。

需要新增统一的 Agent 存储模块，集中管理：

- attach 与初始化
- schema 版本
- 表名和 schema 前缀
- transaction/query/exec 包装
- 完整性检查
- 维护和空间统计

`AgentSession.ts` 与 `Tools.ts` 不再各自硬编码未限定的 Agent 表名。

### 11.3 初始化失败策略

如果 `agent.db` 无法创建、打开或 attach：

- 不删除或修改 `dora.db` 中的旧数据。
- Agent 功能返回明确的“Agent 数据库不可用”错误。
- 普通引擎配置功能继续使用 `dora.db`。
- 不允许回退到旧 Agent 表继续运行。
- 日志记录路径和 SQLite 错误，但不记录 Agent 正文。

不能静默回退到继续向 `dora.db` 写 Agent 数据，否则会形成两个互不一致的数据源。

### 11.4 空库切换

首次运行新版本时：

1. attach `agent.db`。
2. 读取 `PRAGMA agent.user_version`。
3. 按当前 schema 基线幂等建立 Agent 表与索引。
4. 设置当前 `agent.user_version`。
5. 所有 Agent 查询直接使用 `agent` schema。
6. 不检查、复制或转换 `main.Agent*` 的旧记录。
7. 如果这是新建的 `agent.db`，应用层得到空 session 列表。
8. 如果 `agent.db` 已由相同 schema 版本使用过，则保留其中已有数据并正常恢复。

切换过程不双写，也不提供旧会话导入入口。`agent.user_version` 只用于识别当前 `agent.db` schema；低版本默认整体重建。

### 11.5 schema 新基线与兼容代码清理

这次空库切换同时建立 Agent 表结构的新基线。运行时不再逐列兼容旧结构。

需要删除的现有兼容逻辑包括：

- `AgentSession.ts` 中读取主库 `PRAGMA user_version` 的旧版本判断。
- schema 版本不一致时只重建 session/message/step 的 `recreateSchema()` 分支。
- `hasTableColumn()` 与 `ensureSessionMetricsColumn()`。
- `ensureSessionWorkModeColumn()`。
- `ensureMessageDisplayContentColumn()`。
- `Tools.ts` 中检查 `AgentTask.work_mode` 后执行 `ALTER TABLE` 的逻辑。
- 为兼容短期数据库问卷方案而反复执行的 `DROP TABLE AgentQuestionnaire`。
- 分散在 `AgentSession.ts`、`Tools.ts` 中的重复建表入口。

新的统一存储模块只保留一份完整 schema 定义和以下版本策略：

| 情况 | 行为 |
| --- | --- |
| `agent.db` 不存在 | 创建当前 schema 并设置当前版本 |
| 版本等于当前版本 | 直接使用；不执行逐列补丁 |
| 版本低于当前版本 | 清空并重建整个 Agent schema；会话历史再次重置 |
| 版本高于当前版本 | 拒绝启动 Agent，避免旧程序破坏新数据 |
| 版本一致但结构校验失败 | 报 Agent 数据库结构错误，不自动做猜测性修复 |

未来如修改 Agent 表结构，默认通过提升 `AGENT_SCHEMA_VERSION` 触发整体重建，不再积累 `ALTER TABLE` 兼容分支。只有未来明确要求保留 Agent 历史时，才单独设计一次性迁移。

`LLMConfig` 继续留在 `dora.db`。它属于用户模型配置，新的空 Agent 会话仍依赖它才能启动，不在本次 Agent 历史重置和兼容代码清理范围内。其现有表结构策略如需调整，应作为独立改动处理。

`AgentPanel` 中仅用于 React key 或显示降级的 `legacy` 命名，以及 prompt/config 文件兼容逻辑，也不属于数据库表兼容代码，不在本次清理范围内。

### 11.6 旧 Agent 表清理

成功 attach 并建立 `agent.db` schema 后，可以用一个可重复事务删除 `dora.db` 中的旧 Agent 表。删除顺序从依赖表到父表：

```text
AgentCheckpointEntry
AgentCheckpoint
AgentSessionStep
AgentSessionMessage
AgentSession
AgentTask
AgentQuestionnaire
```

清理规则：

- 不读取旧表内容来恢复 session 或 handoff。
- 仅在 `agent.db` 已可正常读写后清理。
- 使用 `DROP TABLE IF EXISTS`，使异常退出后可以安全重试。
- 所有旧表删除放在同一事务。
- 不需要保存旧表迁移标记；`DROP TABLE IF EXISTS` 本身可重复执行。
- 如果 attach 或建表失败，不触碰 `dora.db`。

旧表从 `dora.db` 删除后：

- `dora.db` 的空闲页可被普通配置数据复用。
- 不在旧表删除事务内运行 `VACUUM`。
- 可在空闲期单独整理 `dora.db`，让配置库恢复到较小文件。
- 整理失败不影响 `agent.db` 中的新会话数据。

`agent.db` 后续可以采用自己的容量统计、备份、清理和 `VACUUM` 策略，不影响普通配置库。

### 11.7 向后兼容与降级

本方案明确不兼容旧 Agent 数据：

- 升级后，`dora.db` 中的旧 session、step 和 checkpoint 不会出现在前端。
- 项目文件和 Agent 实际修改过的源代码不受影响。
- 降级到只认识 `dora.db` 的旧版本后，旧版本也看不到 `agent.db` 中的新会话。
- 降级版本若重新创建 Agent 表和会话，再次升级时这些记录仍会被忽略并清理。
- 不提供两个数据库之间的自动合并。

发布说明应明确“Agent 会话历史将在本次存储切换后重置”。

## 12. 验收标准

### 12.1 功能

- 当前 task 可查看每个 checkpoint diff。
- 当前 task 可单 checkpoint 回滚和整轮回滚。
- 停止后继续同一 task，checkpoint 保持可用。
- 新 task 建立后，旧普通 task checkpoint 被清理。
- 子 Agent session 删除后，当前主 task 交接卡片仍可查看完整 diff。
- 子 Agent session 删除后，当前主 task 仍可回滚子 task 变更。
- 主 task 被新 task 替代后，其子 task checkpoint 可被回收。
- 删除项目后不存在属于该项目的 Agent 孤儿数据。
- 伪造旧 task/checkpoint ID 无法绕过服务端归属校验。

### 12.2 数据一致性

- 清理事务中途失败时，不出现仅删除一半的 task 数据。
- `AgentTaskReference` 不存在指向缺失 task 的记录。
- `AgentSessionStep.checkpoint_id` 不指向已删除 checkpoint。
- checkpoint entry 不存在缺失父 checkpoint 的记录。
- `agent.db` schema 初始化可重复运行且结果一致。
- 压缩前后的正文按 UTF-8 字节完全一致。
- 损坏或截断的 checkpoint BLOB 会返回明确错误，不会写出空文件。

### 12.3 空间与性能

- 连续完成 100 个普通 task 后，checkpoint/step 行数不随 task 总数线性增长。
- 当前 task 和当前交接引用闭包之外不存在重型 checkpoint 正文。
- 清理后的空闲页可以被后续 Agent task 复用。
- 日常 task 切换清理不造成可感知的长时间 UI 阻塞。
- 首次升级后前端得到空 session 列表，新建会话正常写入 `agent.db`。
- `dora.db` 不再新增任何 Agent 表记录。
- 旧 Agent 表清理被中止后可以安全重试。
- `agent.db` attach 或建表失败时，普通配置数据库仍可使用且旧 Agent 表不被删除。
- 新建 Agent 会话后重启引擎，仍能恢复当前 session、task、checkpoint 和子 Agent 交接引用。
- 低版本 `agent.db` 会整体重建，不执行逐列 `ALTER TABLE`。
- 高于当前版本的 `agent.db` 会拒绝由旧程序打开，且文件不被删除。
- `LLMConfig` 在 Agent 历史重置后仍保留并可用于创建新会话。
- Agent 数据库代码中不再存在旧 session/task 表的补列、局部重建或问卷表清理分支。
- `AgentCheckpointEntry` 不再使用正文 TEXT 专用列；小文本使用 SQLite TEXT 回退，可压缩内容以标准 zlib BLOB 保存，整体存储体积小于原始正文总量。
- 通用 DB 查询可将包含内嵌零字节的 SQLite BLOB 无损传递为 Lua 字符串。
- list、摘要和 handoff 聚合不触发正文解压。
- checkpoint 写入、首次 diff 和回滚延迟满足交互验收阈值。

## 13. 风险与回退

| 风险 | 缓解 |
| --- | --- |
| 过早清理子 task checkpoint | 使用显式 task 引用闭包；交接 step 与引用同事务提交 |
| 新 task 建立失败却清理旧 task | 仅在新 task 已成为 `current_task_id` 后触发 |
| 停止过程仍有旧 runner 写入 | stopping/finalizing 和 stop token 清除前禁止清理 |
| 运行期批量清理阻塞引擎 | 按 task 分批、批次间让出帧 |
| JSON 引用漏判 | 运行时交接同步写入显式引用表 |
| DELETE 后文件没有立即缩小 | 明确 freelist 复用语义；达到阈值后再安排 VACUUM |
| 历史 UI 将来需要 checkpoint | 届时需要调整保留定义或引入用户可配置历史保留期 |
| attach 失败后回退旧表形成双数据源 | Agent 直接报存储不可用；禁止静默回退 |
| 用户误认为旧会话仍会保留 | 发布说明明确 Agent 会话历史重置 |
| 旧表过早删除且新库不可用 | `agent.db` attach、建表和读写检查成功后才删除旧表 |
| 独立数据库初始化影响普通配置 | attach 失败只禁用 Agent，`dora.db` 普通功能继续工作 |
| 提升 schema 版本导致会话历史重置 | 将重置策略作为明确产品约束，并在涉及结构升级的发布说明中提示 |
| 误把模型配置作为 Agent 历史删除 | `LLMConfig` 明确保留在 `dora.db`，不纳入旧 Agent 表清单 |
| BLOB 经现有 DBRow 路径被零字节截断 | C++ 使用 `Column::getString()` 按长度复制，Lua 使用 `lua_pushlstring()` |
| Lua 字符串写入时丢失 BLOB 类型 | 普通参数保持 TEXT；需要 BLOB 时通过 `CAST` 或 SQL 函数显式产生 |
| 调用方把压缩 BLOB 当作正文使用 | 逻辑正文查询统一显式调用 `dora_decompress_text()`；直接查询只承诺返回原始字节 |
| 压缩增加编辑等待时间 | 小正文或无收益正文直存 TEXT，较大正文使用快速等级并记录 P95 |
| 损坏压缩正文导致错误回滚 | zlib 流完整性、checksum 与最大输出上限校验失败即终止，不应用部分内容 |
| 查询摘要时无意解压全部历史 | metadata/content 查询分离，并增加调用路径测试 |

## 14. 推荐开发顺序

1. 提取统一 Agent 存储访问层。
2. 让通用 DB 查询按长度把 SQLite BLOB 无损传递为 Lua 二进制字符串。
3. 实现不含私有 envelope 的 checkpoint 文本压缩/解压 SQL 函数。
4. 实现 `agent.db` attach、压缩字段 schema 初始化和空库切换。
5. 删除旧 schema version、逐列补丁、局部重建和问卷旧表兼容代码。
6. 将所有 Agent SQL 切换到 `agent` schema。
7. 将 checkpoint 读写拆分为 metadata 与按需解压路径。
8. 删除 `dora.db` 旧 Agent 表并验证空历史行为。
9. 增加 task 引用表和引用闭包查询。
10. 为 checkpoint API 增加服务端归属校验。
11. 修正 session、项目和子 Agent 交接的生命周期事务。
12. 在新 task 切换后清理旧 step/checkpoint。
13. 增加运行期孤儿审计和分批清理。
14. 完成功能、压缩、BLOB 往返、版本差异、异常、重启和空间回归测试。
15. 根据实测结果决定是否实现 blob 去重和 incremental vacuum。

## 15. 第一阶段实现结果

2026-07-24 已按本设计完成第一阶段改造：

- 新增统一 `AgentStorage` 模块，固定 attach `<appPath>/agent.db` 为 `agent` schema。
- Agent session、message、step、task、checkpoint、entry 与 task reference 全部切换到独立数据库。
- `dora.db` 中旧 `Agent*` 表仅在新库 schema、codec 与写入探针均成功后原子删除；`LLMConfig` 保留。
- schema 版本低于当前版本时清除整个 Agent schema 后重建；高版本和同版本结构损坏均明确拒绝。
- 通用 DB 查询对 SQLite TEXT/BLOB 均使用 `Column::getString()` 按长度
  复制，并通过 `lua_pushlstring()` 无损传递为 Lua 二进制字符串。
- checkpoint 正文通过原生 `dora_compress_text` / `dora_decompress_text`
  使用 TEXT 原文回退或标准 zlib BLOB 保存，不再包含私有 magic envelope。
- 当前未发布实现直接以 TEXT/zlib 规则作为 schema version 1 的最终基线，
  不为开发阶段的 envelope 格式增加版本升级或兼容分支。
- checkpoint 列表、变更摘要和 handoff 摘要只读 metadata；task diff 每个路径只解压最早 before 与最终 after。
- `AgentTaskReference` 维护子 Agent 交接引用，checkpoint API 统一按 session 可操作闭包校验。
- 新 task 切换、session/项目删除与运行期孤儿审计会按 task 事务回收重型数据；无消息引用的孤儿 task 行也会删除。
- 孤儿清理每次最多处理 4 个 task，使单次交互不会执行无界批量删除；后续请求可继续幂等清理。

运行时验收数据：

| 项目 | 结果 |
| --- | ---: |
| 56,320 bytes 可压缩正文 | 269 bytes |
| 40 次约 126 KiB 文件 checkpoint 写入 P50 | 7.68 ms |
| 40 次约 126 KiB 文件 checkpoint 写入 P95 | 9.25 ms |
| 40 checkpoint metadata 汇总 | 1.53 ms |
| 首次 task diff（仅首尾正文） | 1.67 ms |
| 40 checkpoint 整轮回滚 | 189.44 ms |
| 性能样本正文 raw / stored | 10,031,321 / 41,937 bytes |
| 连续 100 task 后重型保留 | 当前 1 checkpoint / 1 entry |
| 清理全部测试 session 后 | 0 session / 0 task / 0 checkpoint / 0 entry |

数据库验收：

- `dora.db`：255 MiB，旧 Agent 表为 0，`LLMConfig` 为 3 条；65,343 页中 65,329 页进入 freelist，未自动执行 `VACUUM`。
- `agent.db`：schema version 1；D6 测试未留下业务记录。
- 同版本跨引擎重启可恢复 session；低版本整体重建为空库；高版本与结构损坏均禁用 Agent，但普通 LLM 配置接口保持可用。
- 损坏 zlib、尾随数据和超过 256 MiB 的解压输出均返回数据库错误，不会被当作空正文。
- 同步与异步查询均已验证 4 KiB 二进制字符串（包含内嵌 `\0`）逐字节一致。
- 小文本和无压缩收益文本保存为 SQLite TEXT；可压缩大文本保存为 BLOB，
  解压正文跨越多个 64 KiB 输出块后仍逐字节一致。

所有运行时测试均在确认 8866 仅由一个目标 Dora 进程监听后执行。
