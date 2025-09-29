# 第二章：场景与节点：构建游戏世界

&emsp;&emsp;在本章节中，我们将深入了解 **Dora** 中的场景和节点，构建一个简单的游戏世界，并初步设置游戏窗口。这些知识将为你后续开发奠定基础。

&emsp;&emsp;在一切开始之前，让我们先准备一个新的游戏项目。

* 1. 在 Dora 的 Web IDE 中，创建一个名为 `dodge_the_creeps` 的项目，并在项目文件夹中创建一个名为 `init` 的 TSX 文件作为游戏程序入口。
* 2. 在将游戏需要的资源文件（如图片、音频等），通过右键点击 `dodge_the_creeps` 目录，使用上传功能放入项目文件夹中。本教程用到的资源文件可以在[这里](https://github.com/IppClub/Dora-Demo/tree/main/Dodge%20the%20Creeps)下载。

&emsp;&emsp;一切准备好后，你应该可以看到如下的项目结构：

```plaintext
dodge_the_creeps
├── Audio
│   ├── House In a Forest Loop.ogg
│   └── gameover.wav
├── Font
│   └── Xolonium-Regular.ttf
├── Image
│   ├── art.clip
│   └── art.png
└── init.tsx
```

&emsp;&emsp;接下来，我们将正式开始一步步构建游戏世界，让游戏开始动起来。

:::tip 提示
&emsp;&emsp;在这个系列教程中出现的示例代码，会用 `示例代码` 和 `dodge_the_creeps/init.tsx` 两种方式展示。前者表示只是一些说明性的代码片段，而后者则是可以直接复制到项目中执行的完整代码。
:::

---

## 1. 场景与节点的基本概念

&emsp;&emsp;在游戏开发中，“场景”是游戏的一部分，例如主菜单场景、游戏场景和结束场景。场景中包含的元素被称为“节点”，它们可以是精灵、物理物体、标签等。

&emsp;&emsp;在 **Dora** 中：

- **Scene（场景）**：是节点的容器。可以理解为游戏中某个特定的画面或部分，承载着显示在屏幕上的各种内容。
- **Node（节点）**：是游戏元素的最小组成单位，可以嵌套和组合。

&emsp;&emsp;场景和节点结构通常类似树状结构，所有节点由根节点（Root Node）组织管理。

---

## 2. 创建游戏窗口和基本场景

&emsp;&emsp;让我们从创建一个游戏窗口开始，并设置基本的场景内容。以下是初始化游戏窗口的代码示例：

```tsx title="dodge_the_creeps/init.tsx"
import { Director, View, Camera2D, Vec2 } from 'Dora';

const width = 480; // 设计窗口的宽度
const height = 700; // 设计窗口的高度

const DesignSceneHeight = height;
const updateViewSize = () => {
	const camera = Director.currentCamera as Camera2D.Type;
	camera.zoom = View.size.height / DesignSceneHeight;
};

updateViewSize();
// 监听窗口大小变化做自适应
Director.entry.onAppChange(settingName => {
	if (settingName === 'Size') {
		updateViewSize();
	}
});
```

#### 代码解释：

1. **导入模块**：`Director` 是管理场景的控制器，而 `View` 提供游戏窗口信息。
2. **设置窗口尺寸**：我们定义了窗口宽度 `width` 和高度 `height`，并通过 `updateViewSize` 函数调整场景的缩放比例，以适应不同设备屏幕大小。
3. **响应窗口大小变化**：使用 `Director.entry.onAppChange` 监听窗口变化并更新视角，保证窗口始终符合设计尺寸。

---

## 3. 创建背景节点

&emsp;&emsp;在游戏窗口设置好之后，我们可以创建一个简单的背景节点，为后续添加玩家角色和敌人提供场地。

```tsx title="dodge_the_creeps/init.tsx"
import { React, toNode } from 'DoraX';

const Rect = () => (
	<draw-node>
		<rect-shape width={width} height={height} fillColor={0xff4b6b6c}/>
	</draw-node>
);

toNode(<Rect/>);
```

#### 代码解释：

1. **`Rect`组件**：使用 `draw-node` 创建绘制节点，利用 `rect-shape` 指定背景矩形的宽度、高度和颜色。
2. **渲染背景**：通过 `toNode(<Rect/>)` 将背景节点添加到场景中。

> 提示：`fillColor` 属性接受 16 进制颜色值，0xff4b6b6c 表示一种灰绿色背景。

---

## 4. 使用 `Director` 管理场景

&emsp;&emsp;`Director` 是场景管理的核心模块。它可以用来：

- 加载、切换和删除场景；
- 添加 UI 节点，如按钮和得分显示。

&emsp;&emsp;让我们为游戏添加一个开始界面，供玩家启动游戏：

```tsx title="dodge_the_creeps/init.tsx"
import { emit } from 'Dora';

const StartUp = () => {
	return (
		<>
			<Rect/>
			<label fontName='Xolonium-Regular' fontSize={80} text='Dodge the Creeps!' textWidth={400}/>
			<draw-node y={-150}>
				<rect-shape width={250} height={80} fillColor={0xff3a3a3a}/>
				<label fontName='Xolonium-Regular' fontSize={60} text='Start'/>
				<node width={250} height={80} onTapped={() => emit('Input.Start')}/>
			</draw-node>
		</>
	);
};

toNode(<StartUp/>)?.addTo(Director.ui);
```

#### 代码解释：

1. **标题和开始按钮**：`<label>` 显示游戏名称，而 `<draw-node>` 创建了一个按钮。`onTapped` 事件监听玩家点击，触发事件 `Input.Start`。
2. **游戏启动**：通过 `emit('Input.Start')` 发送输入信号，后续章节将用这个信号开始游戏。
3. **添加到场景**：使用 `addTo(Director.ui)` 将开始界面添加到 UI 场景中。

---

## 5. 通过 `toNode` 创建并添加节点

&emsp;&emsp;`toNode` 是一个重要的工具函数，用于将 JSX 元素转为游戏中的节点。这可以让你像在 React 中一样，通过 JSX 语法来定义游戏界面和结构。下面展示如何将一个节点添加到场景中：

```tsx
toNode(<Rect/>); // 添加背景
toNode(<StartUp/>); // 添加开始界面
```

## 6. 章节总结

&emsp;&emsp;在本章节中，你学习了如何：

- 设置游戏窗口的尺寸和缩放比例；
- 创建简单的背景节点；
- 使用 `Director` 管理游戏场景；
- 创建开始界面并响应玩家的点击事件。

&emsp;&emsp;下一章节将进一步探讨 **精灵与动画**，让我们的场景和角色“动”起来。