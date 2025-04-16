# 使用 Yarn 来编写游戏剧本

&emsp;&emsp;在本教程中，我们将创作一个叙事剧本，玩家将扮演 Alex，一个在未来社会的反叛者。在这个社会里，一个大型的公司已经开发出先进的赛博技术，用来控制民众。

&emsp;&emsp;我们将使用一门叫做 [Yarn](https://docs.yarnspinner.dev/beginners-guide/syntax-basics) 的语言来编写我们的故事。Yarn 是一门易于阅读和编写的语言，即使对于非程序员也是如此。该语言允许编写者创建分支对话. 设置和检查变量以及运行与游戏交互的命令。

## 1. 进行准备

&emsp;&emsp;首先，请确保你已经准备并打开 Dora SSR 的 Web IDE 环境。如果你还没有准备好可以参看[这里](/docs/tutorial/quick-start)的步骤。然后在 Web IDE 左侧的文件资源目录中选择新建一个 Yarn 语言类型的文件。

## 2. 理解 Yarn 的结构

&emsp;&emsp;用 Yarn 编写的游戏对话是一系列结构化的 '节点'。每一个节点包含故事的一部分。我们可以打开刚才创建的 Yarn 语言文件，默认应该可以看到已经创建好了一个名叫`Start`初始节点，然后我们就从这个初始节点开始编写：

```html title="节点：Start"
Alex，你终于决定加入反对 Cybertech Corp 的反叛军。人类的未来岌岌可危！

-> 继续

<<jump Decision>>
```

&emsp;&emsp;由箭头`->`开始的语句代表一个暂停等待玩家交互的选项。`<<jump Decision>>`是一个命令语句，表示跳转到下一个名叫`Decision`的故事节点。其它的语句则为普通的文本段落。记得在编写对话的过程中，你随时可以通过Web IDE中，对话文本编辑界面右上角的播放按钮进行测试，并发现一些脚本编写的语法错误。

## 3. 添加选择

&emsp;&emsp;选择是分支叙事中的关键。让我们给 Alex 一个决定：

```html title="节点：Decision"
你想要：
-> 渗透到 Cybertech Corp 总部。
	<<jump Infiltrate>>

-> 散布反对赛博技术的宣传。
	<<jump Propaganda>>
```

&emsp;&emsp;在这个故事节点里我们提供了两个选项，跟随每个选项，我们通过编写增加缩进的文本表示这部分文本属于对应选项的分支内容。

## 4. 添加变量

&emsp;&emsp;变量允许我们记住玩家做出的选择或发生的某些事件。

```html title="节点：Infiltrate"
你决定渗透到 Cybertech Corp。这是有风险的，一旦成功，可能会结束他们的统治。

<<set $infiltrate = true>>

-> 继续

<<jump Outcome>>
```

```html title="节点：Propaganda"
你选择散播关于 Cybertech 的赛博技术的危险的消息。信息就是力量。

<<set $infiltrate = false>>

-> 继续

<<jump Outcome>>
```

使用变量的格式为`<<set $变量名 = 表达式>>`。

## 5. 检查变量

&emsp;&emsp;现在，让我们看看基于 Alex 的决定如何展开故事。

```html title="节点：Outcome"
<<if $infiltrate>>

你悄悄地进入 Cybertech Corp 的主要设施。这里是令人毛骨悚然的安静。
-> 尝试黑入他们的主机。
-> 寻找机密文件。

<<else>>

你开始在整个城市播放消息，警告公民。反抗军每天都变得更强大。
-> 组织一个抗议。
-> 不动声色地做下一步计划。

<<endif>>

行动中……

-> 未完待续
```

## 6. 进一步编写分支和结尾

&emsp;&emsp;你可以继续这种模式，为 "黑客". "搜索". "抗议" 和 "计划" 创建节点，每个节点都有其后果. 选择和结果。最终，你会希望结束故事，总结叙事。

## 7. 使用标记

&emsp;&emsp;标记是 Yarn 语言中的一种特殊语法，用于在对话中添加额外的信息。它们可以在程序中读取，并用来控制对话的显示方式、添加视觉效果或触发特定的游戏事件。

* 人物标记

	```html
	[Character name=Alex] 我是一名反叛者。
	```

	&emsp;&emsp;在对话中，`[Character name=Alex]` 是一个显示标记，用于指定对话的说话者是 Alex。作为标记，它不会出现在对话文本中。你也可以等效的简写这个特殊的人物标记为：

	```html
	Alex: 我是一名反叛者。
	```

* 常规标记

	```html
	Alex: 我是一名[color=red]反叛者[/color]。
	```

	&emsp;&emsp;在对话中，`[color=red]反叛者[/color]` 是一个普通标记，用于指定对话的文本颜色为红色。同样作为标记，它也不会出现在对话文本中。只有通过程序可以读取到这个标记，并根据标记的指令在程序中进行相应的操作。

## 8. 在单个文件中编写多个对话节点

&emsp;&emsp;在 Yarn 中，你可以在单个文件（`.yarn` 结尾的文件）中编写多个对话节点。每个节点由 `===` 标记分隔，每个节点以 `---` 标记分割节点的元数据。以下是如何构建你的完整 Yarn 文件的示例：

```html title="文件：tutorial.yarn"
title: Start
---
Alex，你终于决定加入反对 Cybertech Corp 的反叛军。人类的未来岌岌可危！
-> 继续
<<jump Decision>>
===

title: Decision
---
你想要：
-> 渗透到 Cybertech Corp 总部。
	<<jump Infiltrate>>
-> 散布反对赛博技术的宣传。
	<<jump Propaganda>>
===

title: Propaganda
---
……
===

title: Infiltrate
---
……
===
```

关键点：
1. 节点之间由单行 `===` 标记分隔。
2. 每个节点中在 `---` 之前放置元数据。
3. 实际的对话内容跟随元数据之后。
4. 你可以使用 `<<jump XXX>>` 命令在节点之间跳转。

&emsp;&emsp;这样的文件结构允许你人工创建复杂分支对话树，同时将所有内容有序的组织在单个文件中。

## 9. 结论

&emsp;&emsp;这就是使用 Yarn 语言编写分支叙事的基本结构！有了这些工具，你可以创造出充满选择. 后果. 多种结局的，甚至是巨大. 复杂的故事。那么在这里就祝你写作愉快啦，也愿你的反抗成功！
