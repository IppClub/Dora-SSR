# TSTL 代码编写注意事项

## 1. 目的

本项目大量 TypeScript 最终会经由 TypeScriptToLua 转成 Lua 运行。因此代码虽然写在 `.ts` 文件里，但不能按普通 Node.js / 浏览器 TypeScript 的直觉来写。

对大模型来说，最容易犯的错误是：

- 写出“TypeScript 语法成立，但 TSTL 不支持”的代码
- 忘记 Lua 的运行时语义与 JavaScript 不同
- 把 Lua 多返回值当成单返回值处理
- 使用标准库 API 时默认按现代 TypeScript 目标来假设能力

本文整理高频混淆点，以及在本项目里更稳妥的推荐写法。

## 2. 总原则

- 先按 “TypeScript 语法 + Lua 语义 + TSTL 子集” 来思考，不要按现代 JavaScript 运行时思考。
- 优先使用简单、直接、可映射到 Lua 的写法。
- 遇到字符串处理、数组判断、模式匹配、可选返回值时，优先怀疑是否存在 TSTL 差异。
- 对外部库返回值，优先查当前项目里已有调用方式，不要凭 JavaScript 经验猜。

## 3. 常见混淆点

### 3.1 Lua 多返回值不能按普通 TypeScript 单返回值处理

Lua 里很多函数天然会返回多个值。TSTL 会保留这套语义。

错误示例：

```ts
const match = string.match(line, "^##[ \t]+(.+)$");
if (match !== undefined) {
	const heading = tostring(match).trim();
}
```

这类代码在 TSTL 下很容易拿到一个多返回值结果容器，而不是你以为的单个字符串，最终日志里可能出现 `table: 0x...`。

正确写法：

```ts
const [matchedHeading] = string.match(line, "^##[ \t]+(.+)$");
if (matchedHeading !== undefined) {
	const heading = tostring(matchedHeading).trim();
}
```

另一个常见例子：

```ts
const [result, err] = yaml.parse(text);
if (err !== undefined) {
	Log("Error", tostring(err));
}
```

结论：

- 只要底层来自 Lua 风格 API，就优先写成解构接收
- 不要假设只有一个返回值

### 3.2 不要默认现代 TypeScript 字符串 / 数组 API 都可用

TSTL 的目标不是现代浏览器或 Node.js。很多你熟悉的方法并不一定可用，或者会直接编译报错。

高风险 API：

- `trimEnd()`
- `trimStart()`
- `includes()`
- `flat()`
- `flatMap()`
- 正则相关现代用法

错误示例：

```ts
const normalized = text.trimEnd();
if (keys.includes(name)) {
	// ...
}
```

更稳妥的写法：

```ts
const normalized = text.trim();

let found = false;
for (const key of keys) {
	if (key === name) {
		found = true;
		break;
	}
}
```

如果只是做尾部清理，可以直接重组内容并整体 `trim()`：

```ts
return lines.join("\n").trim() + "\n";
```

结论：

- 能不用现代 API 就不用
- 优先 `for` 循环、显式判断、简单字符串拼接

### 3.3 正则表达式不是默认安全选择

TSTL 对 `RegExp` 支持有限，部分场景会直接报：

- `Unsupported node kind RegularExpressionLiteral`

错误示例：

```ts
const cleaned = text.replace(/\s+$/, "");
```

更稳妥的方向有两个。

如果只是普通清理，改成简单字符串流程：

```ts
const cleaned = text.trim();
```

如果要做模式匹配，优先使用 Lua pattern 兼容写法：

```ts
const [name] = string.match(line, "^##[ \t]+(.+)$");
```

结论：

- 能不用正则就不用
- 优先 Lua pattern 或更直接的字符串处理

### 3.4 Lua 的 truthy / falsy 规则和 JavaScript 不一样

Lua 里只有 `false` 和 `nil` 是假值。下面这些都是真值：

- `0`
- `""`
- `{}`

因此下面这种 JavaScript 风格判断容易出错。

错误示例：

```ts
if (text) {
	// 在 JS 里空字符串会进不来
}
```

在 Lua 语义下，空字符串也会进入分支。

更稳妥的写法：

```ts
if (text !== "") {
	// 明确只接受非空字符串
}
```

或者：

```ts
if (value !== undefined) {
	// 明确判断是否存在
}
```

结论：

- 不要偷懒写 “if (value)”
- 对字符串、数字、对象、数组都尽量显式比较

### 3.5 带索引访问的类型推断比普通 TypeScript 更容易出问题

当一个对象字段类型不完全一致时，`pack[key]` 往往会被推成联合类型。再去赋值时，很容易出现 `never`、`string | number` 之类的问题。

错误示例：

```ts
interface AgentPromptPack {
	version: number;
	agentIdentityPrompt: string;
}

for (const key of keys) {
	pack[key] = other[key];
}
```

这里 `pack[key]` 可能被推成 `string | number`，后续赋 `string` 时就会报错。

更稳妥的写法有两种。

第一种，避免混合字段类型：

```ts
interface AgentPromptPack {
	agentIdentityPrompt: string;
	finalSummaryPrompt: string;
}
```

第二种，明确用桥接类型处理动态赋值：

```ts
((merged as unknown) as Record<string, unknown>)[key] = value[key] as string;
```

但这类写法只适合非常确定结构时使用。更推荐的仍然是：减少异构字段，降低动态索引赋值。

### 3.6 结构化对象不能随手当成 `Record<string, unknown>`

普通 TypeScript 里很多人会把强类型对象随手塞进 `Record<string, unknown>`。在更严格的检查下，这未必成立。

错误示例：

```ts
const record = pack as Record<string, unknown>;
```

更稳妥的写法：

```ts
const record = (pack as unknown) as Record<string, unknown>;
```

或者根本不要走泛型字典，直接显式处理字段。

更推荐：

```ts
const next = {
	agentIdentityPrompt: pack.agentIdentityPrompt,
	finalSummaryPrompt: pack.finalSummaryPrompt,
};
```

结论：

- 能显式列字段，就不要偷懒转 `Record`
- 若必须转换，先过 `unknown`

### 3.7 `undefined` 判断要做全

TSTL 项目里很多 API 返回值都可能缺失。只靠“应该有”来写，最后往往会撞上编译错误或运行期空值。

错误示例：

```ts
const [heading] = string.match(line, "^##[ \t]+(.+)$");
const normalized = heading.trim();
```

正确写法：

```ts
const [heading] = string.match(line, "^##[ \t]+(.+)$");
if (heading === undefined) {
	return;
}
const normalized = heading.trim();
```

对数组访问也是一样：

```ts
const item = list[index];
if (item === undefined) {
	return;
}
useItem(item);
```

### 3.8 日志、枚举值、字面量参数要以项目现有定义为准

不要凭自然语言直觉写参数值。

错误示例：

```ts
Log("Warning", "config parse failed");
```

如果项目定义的是 `"Info" | "Warn" | "Error"`，这里就会直接报错。

正确写法：

```ts
Log("Warn", "config parse failed");
```

结论：

- 先看项目已有类型定义
- 不要自创看起来“更自然”的字符串字面量

### 3.9 永远优先使用 `undefined`，不要依赖 `null`

在这个项目里，推荐约定是：

- 永远只用 `undefined`
- 永远不要主动引入 `null`

原因是：

- `undefined` 在 TSTL/Lua 语义里会映射到 `nil`
- Lua 里没有和 JavaScript `null` 完全对等的独立语义
- 一旦同时混用 `undefined | null`，判空逻辑会变复杂，代码生成后的语义也更难统一

错误示例：

```ts
let currentSection: string | null = null;
if (currentSection !== null) {
	// ...
}
```

推荐写法：

```ts
let currentSection: string | undefined = undefined;
if (currentSection !== undefined) {
	// ...
}
```

再比如函数返回值也应统一：

```ts
function findSection(name: string): string | undefined {
	if (name === "") {
		return undefined;
	}
	return name;
}
```

不推荐：

```ts
function findSection(name: string): string | null {
	if (name === "") {
		return null;
	}
	return name;
}
```

结论：

- 缺失值统一表达为 `undefined`
- 判空统一写 `=== undefined` 或 `!== undefined`
- 不要同时维护 `null` 和 `undefined` 两套空值语义

### 3.10 配置解析不要只靠“看到标题就切 section”

如果正文本身也包含 Markdown 标题，按普通 Markdown 思路切分会误伤正文。

错误示例：

```ts
const [heading] = string.match(line, "^##[ \t]+(.+)$");
if (heading !== undefined) {
	currentSection = heading;
}
```

如果正文里也有 `## Output Format`，解析会被打断。

更稳妥的写法：

```ts
const [heading] = string.match(line, "^##[ \t]+(.+)$");
if (heading !== undefined) {
	const name = tostring(heading).trim();
	let isKnown = false;
	for (const key of PROMPT_PACK_KEYS) {
		if (key === name) {
			isKnown = true;
			break;
		}
	}

	if (isKnown) {
		currentSection = name;
	} else if (currentSection !== undefined) {
		sections[currentSection].push(line);
	} else {
		unknown.push(name);
	}
}
```

同时，正文里的内部标题尽量降级成 `###`，避免和外层配置段冲突。

## 4. 推荐写法风格

### 4.1 优先显式、直接、低魔法

推荐：

```ts
let found = false;
for (const item of items) {
	if (item === target) {
		found = true;
		break;
	}
}
```

不推荐：

```ts
const found = items.includes(target);
```

### 4.2 优先小函数拆分，而不是复杂链式调用

推荐：

```ts
function isKnownPromptKey(name: string): boolean {
	for (const key of PROMPT_PACK_KEYS) {
		if (key === name) {
			return true;
		}
	}
	return false;
}
```

不推荐：

```ts
const isKnown = PROMPT_PACK_KEYS.filter((it) => it === name).length > 0;
```

### 4.3 优先写成 Lua 也容易读懂的代码

推荐：

```ts
if (text === undefined || text === "") {
	return defaultValue;
}
return text;
```

不推荐：

```ts
return text || defaultValue;
```

后者在 Lua 语义下很容易和你的 JavaScript 直觉不一致。

## 5. 编写前自检清单

提交 TSTL 相关代码前，建议至少快速过一遍这些问题：

- 是否用了现代字符串 / 数组 API？
- 是否用了正则字面量？
- 是否把 Lua 多返回值当成单返回值？
- 是否写了依赖 JavaScript falsy 语义的判断？
- 是否对可选值做了完整 `undefined` 检查？
- 是否把强类型对象粗暴转成 `Record<string, unknown>`？
- 是否使用了项目里不存在的字符串字面量参数？
- 是否正文里的 Markdown 标题会干扰配置解析？

## 6. 一条经验原则

当你不确定某种 TypeScript 写法在 TSTL 下是否安全时，优先选：

- 更短的控制流
- 更少的语法糖
- 更显式的判空
- 更直接的字符串处理
- 更接近 Lua 运行模型的写法

在这个项目里，“朴素但稳定”通常比“现代 TypeScript 风格”更正确。
