---
sidebar_position: 2
---

# Choose Your Game Programming Language

## Introduction

Welcome to the world of Dora SSR! If you're new to game development, you might be wondering how to choose the right programming language. Don't worry, Dora SSR offers a variety of language options to suit your interests and project needs. This article will help you understand the characteristics of different programming languages so you can make the best choice for your journey in Dora SSR.

## Exploring Your Options

Dora SSR supports a range of programming languages, including Lua, Yuescript, Teal, TypeScript, TSX, and Rust, each with its unique features and advantages.

### 1. Lua: Lightweight and Fast

<div style={{marginLeft: '30px', width: '120px'}}>
![Lua](@site/static/img/lua.png)
</div>

Lua is a lightweight scripting language known for its simplicity, efficiency, and ease of learning. It's a great choice if you're new to programming or prefer straightforward code.

----

### 2. Yuescript: A Modern Alternative to Lua

<div style={{marginLeft: '30px', width: '120px'}}>
![Lua](@site/static/img/yuescript.png)
</div>

Yuescript, a dialect of Lua, inherits Lua's features while introducing syntax sugar and a Python-like coding style found in modern programming languages. If you're interested in dynamic (weakly-typed) programming like Lua but want a more modern syntax, Yuescript is ideal.

----

### 3. Teal: A Typed Lua

<div style={{marginLeft: '30px', width: '100px'}}>
![Lua](@site/static/img/teal.png)
</div>

Teal is a statically-typed language that compiles to Lua. It's perfect if you want the efficiency of native Lua execution and Lua-like syntax, with the added safety of static type checks.

----

### 4. TypeScript: A Better Typed Language

<div style={{marginLeft: '30px', width: '100px'}}>
![Lua](@site/static/img/typescript.png)
</div>

TypeScript, a superset of JavaScript, adds optional static types and modern programming features like classes. It's a good choice if you're familiar with JavaScript or want to develop complex game logic with enhanced coding assistance.

----

### 5. TSX: Modern Interface Development

TSX (TypeScript XML) extends TypeScript, allowing JSX tags in TypeScript code, similar to JSX in JavaScript. This combination brings unparalleled flexibility and expressiveness to game UI design. With TSX, you can build game interfaces declaratively, like modern web apps, benefiting from TypeScript's robust type checking.

----

### 6. Rust: Performance and Safety

<div style={{marginLeft: '30px', width: '120px'}}>
![Lua](@site/static/img/rust.png)
</div>

Rust is a systems programming language emphasizing safety and performance. It's highly suitable for low-level systems or performance-intensive tasks, such as complex game functionalities.

----

## Making Your Choice

Consider the following factors when choosing a programming language:

1. **Project Requirements**: What specific functionalities does your game need? Do you require high performance or particular language features?
2. **Personal Experience**: Are you already familiar with a language? Choosing a comfortable language can enhance your learning efficiency.
3. **Learning Curve**: How much time do you have to learn a new language? Beginners might prefer an easy-to-learn language.
4. **Community and Resources**: Consider the community support and resources available for each language. An active community and rich learning materials can significantly aid your learning process.

## How is Multi-language Support Achieved?

1. **The Magic of Transpilers**   
Dora SSR uses a technique known as "transpiling" to automatically convert code written in Yuescript, Teal, TypeScript, etc., into Lua. It's like a multi-language translator, allowing different programming languages to coexist harmoniously in the same game engine.

2. **WebAssembly (WASM): The Cross-Language Bridge**  
For lower-level languages like Rust, C/C++, or Go, Dora SSR employs WebAssembly (WASM). By compiling these languages into WASM bytecode and running it in a built-in WASM virtual machine, Dora SSR supports these languages. It's like creating a universal platform within the game engine, where any WASM-compilable language can run.

3. **Seamless Integration Experience**  
Most importantly, Dora SSR hides these complex technical details behind its Web IDE (Integrated Development Environment). Developers simply code in a friendly interface, with the IDE handling all transpiling and compilation. It's like driving an automatic car, where you focus on the journey and destination, and the engine seamlessly shifts gears for you.

Choosing a programming language in Dora SSR is an exciting and significant decision. Each language has its unique strengths and use cases. Your final choice should be based on your personal needs, experience, and project goals. Remember, there's no "best" language, only the one that's best for you. Here's to discovering your programming language in Dora SSR and creating exciting game projects!