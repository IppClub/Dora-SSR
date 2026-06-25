# DoraX TSX 属性处理模式确认稿

本文记录当前 DoraX 动态 TSX runtime 对属性的处理方式，用于确认哪些属性应该 patch、哪些会触发节点重建，以及哪些属性在 patch 时带有额外清理逻辑。

范围说明：

- **挂载**：第一次创建 Dora 节点时，仍走原有 TSX 单 pass 创建逻辑和各元素专用 handler。
- **动态更新**：`createRoot(parent).render(...)` 后再次 render 时，走 tree diff 和本文记录的 patch / recreate 逻辑。
- **未列为特殊处理的普通属性**：动态更新时默认执行 `(node as AnyTable)[name] = value`；属性从新 TSX 中移除时，默认跳过，不写入 `undefined`。只有确认 Dora 原属性支持 `undefined`，或存在明确清理 API 时才执行清理。
- **事件属性**：`onUnmount` 不按 Dora Slot 事件处理；`onMount` 是生命周期属性。

## 总体判定顺序

| 条件 | 处理模式 | 额外行为 |
| --- | --- | --- |
| 元素 `type` 变化 | 重建 | 旧节点递归 unmount，新节点重新 mount |
| `key` 变化 | 重建 | 同上 |
| 新元素是 `<draw-node>` | 总是重建 | draw shapes 是即时绘制命令，目前不做 shape diff |
| `onMount` 新旧值变化、增加或删除 | 重建 | `onMount` 只在 mount 时调用 |
| 非 patchable 的 `on*` 属性变化、增加或删除 | 重建 | 当前剩余典型项是 `custom-node.onCreate`；详见下表 |
| 元素命中特定结构属性变化规则 | 重建 | 见“元素级重建规则” |
| 以上均不命中 | patch | 走属性级 patch 和子节点 diff |

## 元素级重建规则

| 元素 | 触发重建的属性 / 条件 | 不触发重建的说明 |
| --- | --- | --- |
| 所有元素 | `type`、`key`、`onMount` 变化 | 普通属性默认 patch |
| `draw-node` | 任意更新都重建 | 子 shape 不做 diff |
| `grid` | `file`、`gridX`、`gridY` | `textureRect`、`depthWrite`、`blendFunc`、`effect` 默认 patch |
| `sprite` | `file` | 其它属性默认 patch |
| `video-node` | `file` | `looped` 当前不在重建规则中，动态更新按普通属性 patch |
| `tic80-node` | `file` | 其它属性默认 patch |
| `audio-source` | `file` | `autoRemove`、`bus`、`playMode` 等动态更新不重建，按普通属性或通用 patch 处理 |
| `particle` | `file` | `emit` 动态更新按普通属性 patch，不会自动再次调用 `start()` |
| `tile-node` | `file` | `layers` 当前不在重建规则中，动态更新按普通属性 patch |
| `playable` | `file` | `play`、`loop` 动态更新按普通属性 patch，不会自动再次调用 `play()` |
| `dragon-bone` | `file` | 继承 `playable` 规则 |
| `spine` | `file` | 继承 `playable` 规则 |
| `model` | `file` | `reversed` 默认 patch |
| `label` | `fontName`、`fontSize`、`sdf` | 文本内容有特殊 patch，见下表 |
| `align-node` | `windowRoot` | `style` 动态更新按普通属性 patch，不会重新调用 `css()` |
| `custom-node` | `onCreate` | 因为节点创建函数变化必须重新创建 |
| `body` | `type`、`world`、`fixedRotation`、`bullet`、`linearAcceleration`、fixture 子节点结构变化 | `group`、`y`、阻尼等非结构属性默认 patch |
| `physics-world` | 无专门重建规则 | `<contact>` 子节点变化走 `setShouldContact()` patch |

## 通用 Node 属性

| 属性 | 动态更新模式 | 挂载 / patch 行为 | 移除时行为 |
| --- | --- | --- | --- |
| `key` | diff 标识，不 patch 到节点 | 用于 keyed reconciliation | 不适用 |
| `children` | 不作为节点属性 patch | 子节点参与 diff | 被移除的子节点会 unmount |
| `ref` | patch | `ref.current = node`；ref 替换时清旧 ref 后写新 ref | 删除、替换、unmount 时清旧 `ref.current = undefined` |
| `onMount` | 变化触发重建 | mount 后调用 `onMount(node)` | 删除也触发重建 |
| `onUnmount` | patch 为生命周期元数据 | 不注册到 Dora 节点 | 节点 unmount 时调用旧元素上的 `onUnmount(node)` |
| `anchorX` | patch | 更新 `node.anchor.x`，保留当前 `anchor.y` | 删除时跳过，保留当前 `anchor.x` |
| `anchorY` | patch | 更新 `node.anchor.y`，保留当前 `anchor.x` | 删除时跳过，保留当前 `anchor.y` |
| `color3` | patch | 转换为 `Dora.Color3(value)` 后赋给 `node.color3` | 删除时跳过 |
| `transformTarget` | patch | 使用 `ref.current` 赋给 `node.transformTarget` | 原属性支持 `undefined`，删除时设为 `undefined` |
| `outlineColor` | patch | 转换为 `Dora.Color(value)` 后赋值 | 删除时跳过 |
| `smoothLower` | patch | 修改 `node.smooth.x`，保留当前 `smooth.y` | 删除时跳过，保留当前 `smooth.x` |
| `smoothUpper` | patch | 修改 `node.smooth.y`，保留当前 `smooth.x` | 删除时跳过，保留当前 `smooth.y` |
| 其它普通属性 | patch | `(node as AnyTable)[name] = value` | 默认跳过；除非已确认原属性支持 `undefined` |

## Slot 事件属性

这些属性动态更新时不会重建节点。变化时会先清理对应 slot，再注册新回调；删除时只清理对应 slot。

| 属性 | Dora Slot | 动态更新模式 | 额外清理 |
| --- | --- | --- | --- |
| `onActionEnd` | `Slot.ActionEnd` | patch | `node.slot(Slot.ActionEnd).clear()` 后重绑 |
| `onTapFilter` | `Slot.TapFilter` | patch | clear 后重绑；删除时 clear |
| `onTapBegan` | `Slot.TapBegan` | patch | clear 后重绑；删除时 clear |
| `onTapEnded` | `Slot.TapEnded` | patch | clear 后重绑；删除时 clear |
| `onTapped` | `Slot.Tapped` | patch | clear 后重绑；删除时 clear |
| `onTapMoved` | `Slot.TapMoved` | patch | clear 后重绑；删除时 clear |
| `onMouseWheel` | `Slot.MouseWheel` | patch | clear 后重绑；删除时 clear |
| `onGesture` | `Slot.Gesture` | patch | clear 后重绑；删除时 clear |
| `onEnter` | `Slot.Enter` | patch | clear 后重绑；删除时 clear |
| `onExit` | `Slot.Exit` | patch | clear 后重绑；删除时 clear |
| `onCleanup` | `Slot.Cleanup` | patch | clear 后重绑；删除时 clear |
| `onKeyDown` | `Slot.KeyDown` | patch | clear 后重绑；删除时 clear |
| `onKeyUp` | `Slot.KeyUp` | patch | clear 后重绑；删除时 clear |
| `onKeyPressed` | `Slot.KeyPressed` | patch | clear 后重绑；删除时 clear |
| `onAttachIME` | `Slot.AttachIME` | patch | clear 后重绑；删除时 clear |
| `onDetachIME` | `Slot.DetachIME` | patch | clear 后重绑；删除时 clear |
| `onTextInput` | `Slot.TextInput` | patch | clear 后重绑；删除时 clear |
| `onTextEditing` | `Slot.TextEditing` | patch | clear 后重绑；删除时 clear |
| `onButtonDown` | `Slot.ButtonDown` | patch | clear 后重绑；删除时 clear |
| `onButtonUp` | `Slot.ButtonUp` | patch | clear 后重绑；删除时 clear |
| `onAxis` | `Slot.Axis` | patch | clear 后重绑；删除时 clear |
| `onAnimationEnd` | `Slot.AnimationEnd` | patch | clear 后重绑；删除时 clear |
| `onFinished` | `Slot.Finished` | patch | clear 后重绑；删除时 clear |
| `onLayout` | `Slot.AlignLayout` | patch | clear 后重绑；删除时 clear |
| `onBodyEnter` | `Slot.BodyEnter` | patch | clear 后重绑；删除时 clear |
| `onBodyLeave` | `Slot.BodyLeave` | patch | clear 后重绑；删除时 clear |
| `onContactStart` | `Slot.ContactStart` | patch | clear 后重绑；删除时 clear |
| `onContactEnd` | `Slot.ContactEnd` | patch | clear 后重绑；删除时 clear |

挂载时还有这些自动开启行为：

| 条件 | 挂载时行为 | 动态 patch 时当前行为 |
| --- | --- | --- |
| 设置 tap / mouse / gesture 相关事件，且 `touchEnabled !== false` | 自动 `node.touchEnabled = true` | 新增或保留相关事件时自动 `node.touchEnabled = true` |
| 设置 key 相关事件，且 `keyboardEnabled !== false` | 自动 `node.keyboardEnabled = true` | 新增或保留相关事件时自动 `node.keyboardEnabled = true` |
| 设置 controller 相关事件，且 `controllerEnabled !== false` | 自动 `node.controllerEnabled = true` | 新增或保留相关事件时自动 `node.controllerEnabled = true` |
| `body` 设置 `onContactStart` 或 `onContactEnd`，且 `receivingContact !== false` | 自动 `body.receivingContact = true` | 新增或保留 contact 事件时自动 `body.receivingContact = true` |

## Singlecast 回调属性

| 属性 | 所属元素 | 动态更新模式 | 额外清理 |
| --- | --- | --- | --- |
| `onUpdate` | 所有 `node` 派生元素 | patch | 新值为函数时调用 `node.schedule(fn)`；新值为 `Dora.Job` 时调用 `node.schedule(job)`；删除时调用 `node.unschedule()` |
| `onContactFilter` | `body` | patch | 新值调用 `body.onContactFilter(fn)` 替换旧 filter；删除时设置为 `() => true`，保持当前默认放行行为，避免旧 filter 残留 |

## 元素专用属性

下表按“当前动态更新阶段”的实际行为列出。挂载阶段可能会调用专用构造函数或 helper 方法；如果某属性只在挂载 handler 中有特殊逻辑，但动态阶段没有专门 patch 分支，则这里按动态阶段记录为普通 patch。

| 元素 | 属性 | 动态更新模式 | 备注 |
| --- | --- | --- | --- |
| `clip-node` | `stencil` | patch | 动态阶段按普通属性赋值，不会重新 `toNode()` 创建 stencil；原属性支持 `undefined`，删除时设为 `undefined` |
| `playable` | `file` | 重建 | 构造资源 |
| `playable` | `play`、`loop` | 特殊 patch | `play` 存在且 `play` 或 `loop` 变化时调用 `play(play, loop === true)` |
| `playable` | `onAnimationEnd` | slot patch | 见 Slot 事件表 |
| `dragon-bone` | `file` | 重建 | 构造资源 |
| `dragon-bone` | `hitTestEnabled` | 普通 patch | 挂载时会设为 `true`；动态阶段按属性赋值 |
| `spine` | `file` | 重建 | 构造资源 |
| `spine` | `hitTestEnabled` | 普通 patch | 同上 |
| `model` | `file` | 重建 | 构造资源 |
| `model` | `reversed` | 普通 patch | 直接属性赋值 |
| `draw-node` | `depthWrite`、`blendFunc` | 重建 | 因 `<draw-node>` 任意更新都重建 |
| `draw-node` | shape children | 重建 | shape 命令重新绘制 |
| `grid` | `file`、`gridX`、`gridY` | 重建 | 构造参数 |
| `grid` | `textureRect`、`depthWrite`、`blendFunc`、`effect` | 普通 patch | 直接属性赋值 |
| `sprite` | `file` | 重建 | 构造资源 |
| `sprite` | `textureRect`、`depthWrite`、`blendFunc`、`effect`、`alphaRef`、`uwrap`、`vwrap`、`filter` | 普通 patch | 直接属性赋值 |
| `video-node` | `file` | 重建 | 构造资源 |
| `video-node` | `looped` | 普通 patch | 当前不触发重建 |
| `tic80-node` | `file` | 重建 | 构造资源 |
| `audio-source` | `file` | 重建 | 构造资源 |
| `audio-source` | `autoRemove`、`bus`、`delayTime` | 普通 patch | 动态阶段不会重新构造音源 |
| `audio-source` | `volume`、`pan`、`looping` | 普通 patch | 直接属性赋值 |
| `audio-source` | `playMode`、`delayTime` | 特殊 patch | `playMode` 存在且 `playMode` 或 `delayTime` 变化时调用 `play()` / `playBackground()` / `play3D()` |
| `audio-source` | `protected`、`loopPoint`、`velocity`、`minMaxDistance`、`attenuation`、`dopplerFactor` | 普通 patch | 动态阶段不会调用对应 setter helper |
| `label` | `fontName`、`fontSize`、`sdf` | 重建 | 字体构造参数 |
| `label` | `text` 和 primitive children | 特殊 patch | 每次 patch 后执行 `label.text = getPrimitiveLabelText(newElement)` |
| `label` | `smoothLower`、`smoothUpper`、`outlineColor` | 特殊 patch | 通用转换 patch |
| `label` | `alphaRef`、`textWidth`、`lineGap`、`spacing`、`outlineWidth`、`blendFunc`、`depthWrite`、`batched`、`effect`、`alignment` | 普通 patch | 直接属性赋值 |
| `line` | `verts`、`lineColor` | 特殊 patch | `verts` 存在且 `verts` 或 `lineColor` 变化时调用 `line.set(verts, Color(lineColor ?? 0xffffffff))` |
| `line` | `depthWrite`、`blendFunc` | 普通 patch | 直接属性赋值 |
| `particle` | `file` | 重建 | 构造资源 |
| `particle` | `emit` | 特殊 patch | `emit` 变化为 truthy 时调用 `start()`；变化为 falsy 时调用 `stop()` |
| `particle` | `onFinished` | slot patch | 见 Slot 事件表 |
| `menu` | `enabled` | 普通 patch | 直接属性赋值 |
| `physics-world` | `<contact>` children | 特殊 patch | 见 `<contact>` 表 |
| `body` | `type`、`world`、`fixedRotation`、`bullet`、`linearAcceleration` | 重建 | BodyDef 结构参数 |
| `body` | fixture children | 结构变化重建 | 见 fixture 表 |
| `body` | `velocityX`、`velocityY`、`angularRate`、`group`、`linearDamping`、`angularDamping`、`owner`、`receivingContact` | 普通 patch | 直接属性赋值 |
| `body` | `onBodyEnter`、`onBodyLeave`、`onContactStart`、`onContactEnd` | slot patch | 见 Slot 事件表 |
| `body` | `onContactFilter` | singlecast patch | 见 Singlecast 表 |
| `custom-node` | `onCreate` | 重建 | 创建函数变化必须重建 |
| `align-node` | `windowRoot` | 重建 | 构造参数 |
| `align-node` | `style` | 特殊 patch | `style` 变化时重新生成 CSS 字符串并调用 `css(styleStr)` |
| `align-node` | `onLayout` | slot patch | `Slot.AlignLayout` |
| `effek-node` | 普通节点属性 | 普通 patch | 无元素专用动态 patch |
| `tile-node` | `file` | 重建 | 构造资源 |
| `tile-node` | `layers` | 普通 patch | 当前不触发重建 |
| `tile-node` | `depthWrite`、`blendFunc`、`effect`、`filter` | 普通 patch | 直接属性赋值 |

## 特殊子节点

| 子节点类型 | 父元素 | 动态更新模式 | 额外行为 |
| --- | --- | --- | --- |
| `dot-shape`、`segment-shape`、`rect-shape`、`polygon-shape`、`verts-shape` | `draw-node` | 父 `draw-node` 总是重建 | 重新执行 draw 命令 |
| `rect-fixture`、`polygon-fixture`、`multi-fixture`、`disk-fixture`、`chain-fixture` | `body` | 结构变化重建 body | 比较 fixture 子节点数量、类型和浅层 props；不相等则重建 |
| `contact` | `physics-world` | 特殊 patch | 新增或 `enabled` 变化调用 `world.setShouldContact(groupA, groupB, enabled)`；删除时调用 `setShouldContact(groupA, groupB, true)` 恢复默认 |
| action 子节点 | 普通 node | 命令型 patch | `<move-x>`、`<sequence>`、`<loop>` 等可运行 action 子树变化时，重新构造 ActionDef 并对宿主节点再次执行；默认使用 `runAction()`，带 `exclusive` 的 action 使用 `perform()` 替换节点上当前动作；宿主节点不重建；action 子树删除时不主动停止已运行 action |

### action 子节点的 `exclusive` 规则

| 场景 | 行为 |
| --- | --- |
| action 子节点未设置 `exclusive` | 使用 `node.runAction(action, loop)`，保留非独占、可并行动作语义 |
| 一个或多个非 `<loop>` action 设置 `exclusive` | 先把这些独占 action 合成为一个 action；多个时用 `Spawn(...)`；再调用 `node.perform(action, false)` |
| 一个或多个 `<loop>` 设置 `exclusive` | 先把这些独占 loop action 合成为一个 action；多个时用 `Spawn(...)`；再调用 `node.perform(action, true)` |
| 同一宿主节点同一轮中同时出现 `<loop exclusive>` 和非 `<loop exclusive>` | 按源码顺序选择先出现的独占类型执行；另一类独占 action 被忽略并输出 warning |
| 同一轮中同时有独占和非独占 action | 先执行选中的独占组，再启动非独占 action，避免 `perform()` 误停同轮新启动的非独占 action |

## 待确认点

暂无。
