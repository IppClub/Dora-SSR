---
sidebar_position: 2
---

# 选择你的游戏编程语言

## 引言

&emsp;&emsp;欢迎来到 Dora SSR 的世界！如果你是一名游戏开发的新手，你可能对如何选择合适的编程语言感到困惑。别担心，Dora SSR 提供了多种语言选择，让你可以根据自己的兴趣和项目需求来挑选。本文将帮助你了解不同编程语言的特点，以便在 Dora SSR 中做出适合自己的选择。

## 了解你的可选项

&emsp;&emsp;Dora SSR 支持多种编程语言，目前包括 Lua、Yuescript、Teal、TypeScript、TSX、Rust 等。每种语言都有其独特的特点和优势。

### 1. Lua：轻量级且快速

<div style={{marginLeft: '30px', width: '120px'}}>
![Lua](@site/static/img/lua.png)
</div>

&emsp;&emsp;Lua 是一种轻量级的脚本语言，以其语言特性精简，高效和易学而闻名。如果你是编程新手，或者喜欢简单明了的代码，Lua 是一个很好的选择。

----

### 2. Yuescript：Lua 的现代替代品

<div style={{marginLeft: '30px', width: '120px'}}>
![Lua](@site/static/img/yuescript.png)
</div>

&emsp;&emsp;Yuescript 是 Lua 的一种方言，它继承了 Lua 的语言特性，同时引入了一些现代编程语言的语法糖和类Python的简洁的编码风格。如果你对 Lua 这样动态类型（弱类型）的编程方式感兴趣，但想要更现代化的语法，Yuescript 将是理想之选。

----

### 3. Teal：增加了类型标注的 Lua

<div style={{marginLeft: '30px', width: '100px'}}>
![Lua](@site/static/img/teal.png)
</div>

&emsp;&emsp;Teal 是一个编译到 Lua 的静态类型语言。如果你想要确保代码有原生 Lua 的执行效率，以及和原 Lua 语言基本一致的编程语法，同时又希望引入一定程度静态类型检查的安全性，Teal 是一个不错的选择。

----

### 4. TypeScript：更强大的类型系统

<div style={{marginLeft: '30px', width: '100px'}}>
![Lua](@site/static/img/typescript.png)
</div>

&emsp;&emsp;TypeScript 是 JavaScript 的一个超集，它添加了可选的静态类型和类等现代编程特性。如果你已经熟悉 JavaScript，或者想要开发复杂的游戏逻辑，并同时获得更好的编码辅助提示的体验，TypeScript 是一个好选择。

----

### 5. TSX：现代化的界面开发

&emsp;&emsp;TSX（TypeScript XML）是 TypeScript 的一种扩展，允许你在 TypeScript 代码中嵌入 JSX 标签，类似于在 JavaScript 中使用 JSX。这种结合为游戏开发带来了前所未有的界面设计灵活性和表达力。使用 TSX，你可以以声明式方式构建游戏界面，类似于构建现代化的 Web 应用。这不仅使得界面组件的编写更直观、更易于管理，同时也能利用 TypeScript 强大的类型检查。

----

### 6. Rust：性能和安全

<div style={{marginLeft: '30px', width: '120px'}}>
![Lua](@site/static/img/rust.png)
</div>

&emsp;&emsp;Rust 是一种强调安全和性能的系统编程语言。如果你需要处理底层系统或性能密集型任务，比如涉及复杂算法的游戏功能，那么 Rust 将非常适合。

----

## 如何做出选择

&emsp;&emsp;在选择编程语言时，考虑以下几个因素：

1. **项目需求**：你的游戏需要哪些特定功能？是否需要高性能或特定的编程语言特性？
2. **个人经验**：你是否已经熟悉某种语言？选择一种你舒适的语言可以提高学习效率。
3. **学习曲线**：你有多少时间来学习新语言？选择一种易于学习和上手的语言可能更适合初学者。
4. **社区和资源**：考虑每种语言的社区支持和可用资源。一个活跃的社区和丰富的学习资料可以大大帮助你的学习过程。

## 多样的编程语言支持是怎么做到的？

1. **转译器的魔法**   
&emsp;&emsp;Dora SSR 使用了一种被称为“转译（transpiling）”的技术。简单来说，就是将你用 Yuescript、Teal、Typescript 等语言编写的代码，自动地转换成 Lua 代码。这就像是一个多语言的翻译机，让不同的编程语言可以在同一个游戏引擎下和谐共存。

2. **WebAssembly（WASM）：跨语言的桥梁**  
&emsp;&emsp;对于更加底层的编程语言，比如 Rust、C/C++ 或 Go，Dora SSR 采用了 WebAssembly（WASM）技术。通过将这些语言编译成 WASM 字节码，再在内置的 WASM 虚拟机中运行，Dora SSR 实现了对这些语言的支持。这就像是在游戏引擎中建立了一个万能运行平台，任何可以编译到WASM的语言写的程序都可以在这里运行。

3. **无缝的集成体验**  
&emsp;&emsp;最重要的是，在使用转译类的语言做开发时，Dora SSR 把这些复杂的技术细节隐藏在了其 Web IDE（集成开发环境）之后。对于开发者来说，他们只需在这个友好的界面中编写代码，剩下的转译和编译工作都由 IDE 自动完成。这就像是在驾驶一辆自动挡汽车，你只需要关注路线和目的地，引擎会在不知不觉中自动帮你换挡。

&emsp;&emsp;在 Dora SSR 中选择编程语言是一个既激动人心又重要的决定。每种语言都有其独特的优势和应用场景，最终的选择应基于你的个人需求、经验和项目目标。记住，没有绝对的“最佳”语言，只有最适合你的语言。祝你在 Dora SSR 的旅程中发现属于你的编程语言，并创造出令人兴奋的游戏作品！
