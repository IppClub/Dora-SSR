# FrameTask 并行调度开销优化方案

状态：已完成

最后更新：2026-08-27

跟踪任务：[Kanban #14](../../../docs/kanban/.archive/14-frametask.md)

## 1. 背景

Dora 已使用固定大小的 `AsyncThread` 线程池执行 PlayRho island 求解和
Broad-phase 候选对查询。线程池保留一个逻辑核心给调用线程，
`runFrameTasks()` 会把一个任务留给调用线程，其余任务提交给 worker，然后统一等待。

当前并行计算在大工作量场景中已经有收益，但切换到并行路径仍包含较明显的固定成本：

1. 每个阶段构造 `std::vector<std::function<void()>>`。
2. 每个 worker 任务单独获取提交锁并增加 TaskGroup pending。
3. 每个任务分别分配 `std::function` 和通用 `QEvent`，再进入 worker 队列。
4. 每次完成都通过 TaskGroup mutex 更新 pending。
5. Broad-phase 每次并行查询重新创建任务数组和每任务结果数组。
6. worker 数量目前主要由硬件并发数决定，没有根据本帧工作量缩减。

Release A/B 表明 Broad-phase 在 256 个移动 proxy 附近只有轻微收益，
稀疏的 256 proxy 场景仍会退化；512 个以上移动 proxy 才较稳定地获得收益。
因此目前默认以 512 个移动 proxy 作为并行阈值。

本方案的目标是降低并行阶段的固定调度和临时内存成本，使 island、Broad-phase
以及未来渲染 CPU 任务共同受益，同时保持现有异常传播、线程安全和确定性语义。

## 2. 当前基线

### 2.1 Broad-phase Release A/B

以下结果测量完整 `playrho::d2::Step()`，不是只测树查询，因此可作为保守的端到端基线：

| 移动 proxy | 分布 | 当前并行相对串行 |
| ---: | --- | ---: |
| 128 | 密集 | 约 0.81x |
| 256 | 密集 | 约 1.08x |
| 512 | 密集 | 约 1.29x |
| 2048 | 密集 | 约 1.44x |
| 4096 | 密集 | 约 1.46x |
| 256 | 稀疏 | 约 0.84x～0.92x |
| 512 | 稀疏 | 约 1.09x |
| 2048 | 稀疏 | 约 1.26x～1.28x |

### 2.2 必须保持的语义

- `runFrameTasks()` 使用持久的 FrameTaskGroup，并串行化不同帧阶段的调用。
- 主线程完成自己的任务后会继续领取尚未被 worker 领取的当前批次任务；当普通长任务
  占满线程池时，帧任务退化为调用线程执行，而不是等待普通任务释放 worker。
- 调用线程固定执行第一个任务，并可继续领取尚未被 worker 领取的任务。
- 所有已接受任务完成后才能返回。
- worker 与调用线程抛出的异常都必须在任务全部结束后汇总，并在调用线程重抛。
- 同一线程池的 worker 不得递归等待 FrameTaskGroup。
- PlayRho worker 不调用 listener，也不写回 Body、Contact 或 Manifold。
- Broad-phase worker 只读 DynamicTree，产生候选 `ProxyKey` 并做局部排序去重。
- 主线程按稳定顺序多路归并并创建 Contact。

## 3. 目标与非目标

### 3.1 目标

- 减少每个 FrameTask batch 的锁、堆分配、事件封装和唤醒次数。
- 让 island、Broad-phase 和未来渲染 CPU 计算复用同一批量接口。
- 在不牺牲大场景吞吐的前提下，降低并行计算的有效启用门槛。
- 保持串行与并行世界状态、Contact 和 listener 顺序一致。
- 保持普通 `Async::run()`、独立 `newThread()` 和带 finisher API 的行为不变。
- 每个阶段都可单独 A/B 和回退。

### 3.2 非目标

- 本轮不并行化 `UpdateContacts` 或 contact manifold 计算。
- 本轮不把 listener、Contact 创建或物理状态写回移入 worker。
- 本轮不更换 Dora 的线程库或创建第二套物理线程池。
- 本轮不使用每任务一个 `std::async` 或动态创建线程。
- 未通过 Release A/B 前，不降低生产默认的 512 proxy 阈值。

## 4. 分阶段方案

### 4.1 P0：补充分项基线

先把完整 Step 时间拆分为以下指标：

- FrameTask batch 的任务准备时间。
- 提交至 worker 队列的时间。
- 调用线程任务执行时间。
- worker 最后完成时间和主线程等待时间。
- Broad-phase 查询、合并、排序去重、`AddContacts` 各自耗时。
- 每批任务数、移动 proxy 数、候选对数量和 DynamicTree 叶节点数量。

采样应在 Release 构建中默认关闭，通过测试或显式诊断开关启用，避免影响正式路径。

完成标准：能够区分调度固定成本、负载不均和主线程后处理瓶颈。

### 4.2 P1：FrameTask 批量提交接口

为 `AsyncThread` 增加面向索引任务的批量执行入口。接口应表达“一个 batch、多个索引任务”，
而不是要求调用方构造多个拥有型 `std::function`：

```cpp
void runFrameTasks(
    std::size_t taskCount,
    FunctionRef<void(std::size_t)> task);
```

具体函数引用类型以 Dora 现有基础设施为准，但必须满足：

- 回调生命周期覆盖整个阻塞调用。
- 一次获取提交锁并登记整个 batch。
- 一个任务继续由调用线程执行。
- 提交失败的任务在调用线程执行或安全取消，不能遗留 pending。
- 所有 accepted worker 任务结束后才返回。
- 调用线程和 worker 异常按现有语义汇总。
- 原有 vector 接口可以暂时保留为兼容包装，待调用点迁移后再决定是否删除。

完成标准：PlayRho 调用点不再为每个 batch 构造 `vector<std::function<void()>>`。

### 4.3 P2：轻量 FrameTask batch 状态与完成计数

为 FrameTask batch 使用专用状态，避免每个任务调用通用 TaskGroup 的加锁 `add()` 和
`complete()`：

- 提交时一次设置 worker pending 数。
- 正常完成使用原子递减。
- 只有最后一个 worker 通知等待者。
- 首个异常安全写入 batch，后续异常立即记录或按既有规则报告。
- 等待方在全部任务结束后重抛首个异常。
- batch 状态跨帧复用前必须完全重置，且禁止上一批仍在运行时复用。

不要先修改通用 TaskGroup 的并发语义。专用 batch 验证稳定后，再评估是否能安全复用到
其他 TaskGroup 场景。

完成标准：正常无异常路径不再为每个任务获取 TaskGroup mutex。

### 4.4 P3：轻量专用队列项

如果 P1 和 P2 后 profiling 仍显示事件封装占比较高，为 FrameTask 增加固定结构的队列项：

```cpp
struct FrameTaskItem {
    FrameBatchState* batch;
    std::uint32_t index;
};
```

该路径绕过通用 `QEvent`、字符串事件类型分派和逐任务 `std::function` 堆分配，
但仍复用现有 worker、任务窃取、停止流程和 semaphore。

约束：

- 不复制悬空的回调引用。
- cancel 必须准确结算所有尚未执行的 batch item。
- shutdown、自线程停止和异常路径必须继续通过现有 Async 回归测试。
- 不为了减少一次唤醒引入持续忙等；移动设备功耗不能明显上升。

完成标准：FrameTask 的热路径不再创建通用事件对象。

### 4.5 P4：Broad-phase scratch 跨帧复用

让每个 Broad-phase 执行槽保留独立候选数组容量：

- 每帧 `clear()` 后复用 capacity。
- worker 之间不共享可写容器或 allocator。
- 主线程仍在任务结束后统一合并到世界的 PMR 容器。
- 对异常峰值容量设置回收策略，避免一次极端场景永久占用大量内存。
- 世界复制、移动和析构必须保持正确。

完成标准：稳定场景中不再每帧重新分配每任务候选数组的主要容量。

### 4.6 P5：按工作量自适应任务数

并行阈值和任务数应分开：阈值决定是否并行，任务数决定使用多少执行槽。

初始策略可采用每任务至少 128～256 个移动 proxy：

```text
taskCount = min(maxConcurrency, ceil(movedProxyCount / targetProxiesPerTask))
```

后续可根据上一帧候选对数量或查询节点访问量修正，因为相同 proxy 数量下，
密集与稀疏场景的查询成本差异明显。

策略要求：

- 固定输入和固定线程数时决策稳定。
- 不因单帧噪声频繁在串行和并行之间振荡。
- 并行任务数至少为 2，串行路径不创建 batch。
- 保留明确的配置项以强制串行或强制并行，供测试和诊断使用。

完成标准：512 proxy 场景的调度任务数不会无条件等于全部硬件线程数。

### 4.7 P6：可选的 worker 局部排序与稳定归并

只有 profiling 显示主线程排序去重成为主要瓶颈时才实施：

- worker 对自己的候选数组局部排序和去重。
- 主线程进行确定性的多路归并和最终去重。
- 最终 `ProxyKey` 顺序必须与全量稳定排序兼容。
- `AddContacts` 和 listener 仍只在主线程执行。

这是 Broad-phase 算法优化，不属于切换并行的固定成本优化，不应与 P1～P3 混在同一次
A/B 中。

## 5. 验证方案

### 5.1 正确性

- 固定种子串行/并行重放至少 120 帧。
- 每帧比较世界状态、Contact 集合和 listener 顺序。
- 断言任何 listener 都没有在 worker 上执行。
- 覆盖 0、1、阈值前、阈值点和阈值后的移动 proxy 数。
- 覆盖线程池停止、任务拒绝、调用线程异常和 worker 异常。
- 覆盖连续多个 PhysicsWorld 串行复用同一个 FrameTaskGroup。
- ASan 完成密集和稀疏高 proxy 压力测试。
- TSAN 完成固定种子和高 proxy 压力测试。

### 5.2 Release A/B

沿用当前 Broad-phase benchmark，至少覆盖：

- 密集：128、256、512、2048、4096 个移动 proxy。
- 稀疏：256、512、2048 个移动 proxy。
- 串行、当前实现、新实现三路比较。
- 每个场景多进程运行，交替 A/B 顺序，报告中位数和波动范围。
- 单独复测现有 large-island 场景，确认通用调度优化没有退化 island 求解。
- 在 Loli War 正式进入游戏并完成角色选择后采集持续运行区间，作为真实负载补充证据。

### 5.3 进入下一阶段的门槛

每个阶段必须单独满足以下条件才继续：

- 固定种子、ASan 和 TSAN 全部通过。
- 2048/4096 密集场景不得比当前并行基线明显退化。
- 512 proxy 密集和稀疏场景的中位数不退化。
- 256 proxy 场景改善后才能讨论下调默认阈值。
- 性能变化小于测量波动时，不保留复杂度明显增加的实现。

## 6. 风险与回退

| 风险 | 控制措施 | 回退点 |
| --- | --- | --- |
| 批量状态过早复用 | 阻塞返回前验证 pending 为零，并在 Debug 断言代次 | 保留现有 vector 接口 |
| 回调引用悬空 | batch 只允许阻塞执行，队列项不得越过调用返回 | 回退到拥有型任务 |
| cancel 遗留 pending | 取消队列项时逐项结算或批量结算未执行数量 | 保留通用 TaskGroup 路径 |
| 原子竞争替代 mutex 竞争 | 每个 worker 只在 batch 结束时更新一次计数 | 降低 taskCount |
| worker 唤醒影响功耗 | 不引入常驻忙等，继续使用阻塞 semaphore | 回退专用唤醒策略 |
| scratch 保留过多内存 | 设置容量水位和延迟收缩规则 | 禁用跨帧 scratch |
| 自适应策略振荡 | 使用分段阈值或滞回，保留强制配置 | 固定 512 proxy 阈值 |

## 7. 建议实施顺序

1. P0 补充分项计时，保存当前基线。
2. P1 实现批量 FrameTask API，并迁移 island 与 Broad-phase。
3. P2 使用专用原子 batch 状态。
4. 重新运行正确性、Sanitizer 和 Release A/B。
5. 只有事件和分配仍是热点时实施 P3。
6. P4 与 P5 分别独立 A/B，不与调度核心修改混合。
7. 只有排序成为明确瓶颈时考虑 P6。

优先目标不是追求最低的并行阈值，而是在真实负载下让调度成本与任务工作量匹配，
并保持 Dora 所有使用 FrameTask 的子系统共享一套可验证的并行基础设施。

## 8. 实施结果

### 8.1 已完成的实现

- `AsyncThread::runFrameTasks(taskCount, task, stats)` 提供索引式批量入口；原 vector
  入口保留为兼容包装。
- FrameTask 使用跨帧持久的专用 batch state、原子 pending 和首异常汇总；最后完成者
  与等待者通过同一互斥锁交接，避免条件变量丢唤醒。
- FrameTask 使用中心轻量队列项 `{state, index}`，不再为每个索引构造通用事件和拥有型
  `std::function`。线程池停止会结算尚未执行的队列项；队列分配失败时由调用线程接管
  剩余索引。
- island 与 Broad-phase 均迁移到索引式 executor，调用线程继续承担一个执行槽。
- Broad-phase 每个执行槽跨帧复用候选数组；单槽容量超过 65536 个候选时收缩，避免
  极端峰值永久保留。
- Broad-phase 默认按每任务 128 个移动 proxy 计算任务数，最多使用
  `workerCount + 1` 个执行槽；生产并行阈值仍为 512。
- profiling 证明密集场景的主线程全量排序成为瓶颈后，实施了 worker 局部排序去重和
  主线程稳定多路归并。最终 `ProxyKey` 顺序稳定，`AddContacts` 和 listener 仍只在
  stepping thread 执行。
- `FrameTaskDispatchStats` 与可选 `BroadPhaseProfiler` 提供提交、调用线程、等待、查询、
  归并、排序和 Contact 创建分项计时；未配置 profiler 时 Broad-phase 热路径不读时钟。

### 8.2 Release A/B

测试机器有 9 个 pool worker，加上调用线程共 10 个执行槽。FrameTask 微基准每个场景
执行 3000 个 batch；Broad-phase 每个场景执行 6 组、每组 30 帧，并额外独立运行 3 个
进程。下表报告 3 个进程的中位数和范围：

| 场景 | 任务数 | 最终并行相对串行中位数 | 三进程范围 |
| --- | ---: | ---: | ---: |
| 256 密集 | 2 | 1.19x | 1.18x～1.20x |
| 512 密集 | 4 | 1.52x | 1.52x～1.52x |
| 2048 密集 | 10 | 1.84x | 1.83x～1.84x |
| 4096 密集 | 10 | 1.86x | 1.85x～1.86x |
| 256 稀疏 | 2 | 0.97x | 0.97x～0.99x |
| 512 稀疏 | 4 | 1.11x | 1.11x～1.11x |
| 2048 稀疏 | 10 | 1.28x | 1.27x～1.28x |

索引式 FrameTask 相对旧 TaskGroup 逐任务提交的中位加速约为：2 任务 `1.31x`、
4 任务 `1.24x`、10 任务 `1.33x`。密集 4096 proxy 的分项结果中，旧主线程全量排序
约为 `1.27 ms`；局部排序和稳定归并后，主线程归并约为 `0.15 ms`，完整 Step 的并行
加速由约 `1.48x` 提高到约 `1.86x`。

large-island 复测中，调用线程参与相对旧的全 worker 路径提升约 `1%～10%`；相对纯串行
最高约 `2.04x`，没有因通用 FrameTask 调度优化发生退化。

### 8.3 正确性与工具验证

- Debug 与 Release 固定种子回放通过：串行/并行世界、Contact 集合和 begin/end/pre/post
  listener 顺序一致，且 listener 未在 worker 调用。
- TaskGroup、FrameTask 调用线程/worker 异常、递归拒绝、线程池停止、队列取消和停止后
  调用线程回退测试通过。
- 最终 ASan 通过 TaskGroup/取消、固定种子，以及 4096 密集和 2048 稀疏各 12 帧压力回放；
  macOS ASan 不支持 leak detector，因此该项只覆盖地址错误。
- 最终 TSAN 通过固定种子和同一高 proxy 压力回放，没有数据竞争报告。通用
  `AsyncTaskGroupCpp` 中故意从 worker 抛异常的测试在当前 TSAN 运行库下会直接终止，
  因而 TSAN 结论限定为本次 FrameTask/PlayRho 目标路径；该异常路径已由 Debug、Release
  和 ASan 覆盖。
- Loli War 使用 Release 引擎实际启动，按 A 选择 Flandre，并在确认进入正式战斗后才采样。
  后续 300 帧窗口平均帧时为 `16.667～16.913 ms`，p95 为 `16.667～16.668 ms`；活跃进程
  CPU 平均约 `102.6%`，内存约 `211～244 MB`。调用栈样本包含 PlayRho `Step`、island
  求解和 `UpdateContacts`。该项只作为真实路径稳定性证据，不作为修改前后 A/B。

### 8.4 最终决策

- 保留 P1～P6 的最终实现；P3 和 P6 都有 profiling 与 Release A/B 支持。
- 不下调生产默认的 512 proxy 阈值：256 密集虽已有收益，但 256 稀疏中位数仍约为
  `0.97x`，不满足“不同分布均稳定改善”的门槛。
- 512 proxy 自适应为 4 个任务而不是占满 10 个执行槽，达到了降低切换开销的目标。
- 后续若要继续降低阈值，应引入查询节点访问量或上一帧候选密度，而不是只依据 proxy 数量。
