// @preview-file on clear
import { HttpClient, json, thread, Buffer, Vec2, Node as DNode, Log, DB, Path, Content, Director, emit, GSlot, Node as DoraNode, App, HttpServer } from 'Dora';
import * as ImGui from "ImGui";
import { InputTextFlag, SetCond, WindowFlag } from "ImGui";
import { Node, Flow } from 'Agent/flow';
import * as Config from 'Config';

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null;
}

interface LLM {
	url: string;
	model: string;
	apiKey: string;
	output: string;
}

let running = true;

if (!DB.existDB('llm')) {
	const dbPath = Path(Content.writablePath, "llm.db");
	DB.exec(`ATTACH DATABASE '${dbPath}' AS llm`);
	Director.entry.onCleanup(() => {
		DB.exec("DETACH DATABASE llm");
		running = false;
	});
}

const config = Config<LLM>('llm', 'url', 'model', 'apiKey', 'output');
config.load();

const url = Buffer(512);
if (typeof config.url === "string") {
	url.text = config.url;
} else {
	url.text = config.url = "https://api.deepseek.com/chat/completions";
}
const apiKey = Buffer(256);
if (typeof config.apiKey === "string") {
	apiKey.text = config.apiKey;
}
const model = Buffer(128);
if (typeof config.model === "string") {
	model.text = config.model;
} else {
	model.text = config.model = "deepseek-chat";
}
const outputFile = Buffer(512);
if (typeof config.output === "string") {
	outputFile.text = config.output;
} else {
	outputFile.text = config.output = Path("Blockly", "Output.bl");
}

interface Message {
	role: string;
	content: string;
}

const callLLM = (messages: Message[], url: string, apiKey: string, model: string, receiver: (this: void, data: string) => boolean) => {
	const data = {
		model,
		messages,
		temperature: 0,
		stream: true,
	};
	return new Promise<string>((resolve, reject) => {
		thread(() => {
			const [jsonStr] = json.dump(data);
			if (jsonStr !== null) {
				const res = HttpClient.postAsync(url, [
					`Authorization: Bearer ${apiKey}`,
				], jsonStr, 10, receiver);
				if (res !== null) {
					resolve(res);
				} else {
					reject("failed to get http response");
				}
			}
		});
	});
};

const extractTSBlocks = (text: string) => {
	const blocks: string[] = [];
	for (let [code] of string.gmatch(text, "```%s*[tT][sS%w-]*%s*\n(.-)\n()```")) {
		blocks.push(code);
	}
	return blocks.length === 0 ? text : blocks.join('\n');
}

const root = DNode();

interface ChatInfo {
	messages: Message[];
}

let llmWorking = false;

const getSystemPrompt = () => {
	const filename = Path(Content.writablePath, outputFile.text);
	return `
你有一个 TypeScript 的 DSL 框架，用来模拟编写 Blockly 的积木编程代码。

DSL 框架模块的 API 定义和用法示例如下：

${Content.load(Path(Content.assetPath, 'Script', 'Lib', 'Agent', 'BlocklyGen.d.ts'))}

编写出的 Blockly 积木代码需遵守以下事项：
- 数组下标从1开始
- 对变量名对大小写不敏感，勿用大小写区分变量
- 导入 DSL 模块请使用代码 \`import Gen from 'Agent/BlocklyGen';\`
- 确保最后给我的回答只包含纯粹的 TypeScript 代码，不要包含任何非代码的说明
- 坐标计算均使用左手系坐标，包括所有绘图 API 中的坐标
- 程序块请放在\`const root\`变量中，函数定义放在\`const funcs\`变量中
- 最后输出的 jsonCode 变量请原样补充如下的处理代码：
import * as Dora from 'Dora';
Dora.Content.save("${filename}"), jsonCode);
`;
};

class ChatNode extends Node {
	async prep(shared: ChatInfo) {
		return new Promise((resolve) => {
			root.slot('Input', (message: string) => {
				const systemContent = getSystemPrompt();
				const userContent = `
你是一名经验丰富的 TypeScript 代码专家。

任务目标：
1. 阅读「Blockly DSL 框架 API 与示例用法」以及需求描述。
2. 将需求拆分为具体的积木块功能，并规划对应的 TypeScript 代码结构。
3. 编写完整的积木块实现代码，使其符合需求并能够正确运行。

回答格式必须分两部分：

1.思考过程
逐步阐述你的推理：先研读 API 与示例 → 拆解需求 → 规划积木块功能 → 制定代码结构 → 编写实现代码。
用条目或小节清晰列出，不要省略中间推理步骤。

2.最终答案
完整的 TypeScript 积木块实现代码（用 \`\`\`typescript\`\`\` 代码块包裹）。
期望的功能行为或输出结果，用简要文字或示例说明。
注意：先完整写出思考过程，再给出最终代码；不要在思考过程中提前透露最终代码或结果。

需求如下：

${message}
`;
				shared.messages = [
					{role: 'system', content: systemContent},
					{role: 'user', content: userContent}
				];
				resolve(undefined);
			});
		});
	}
}

class LLMCode extends Node {
	async prep(shared: ChatInfo) {
		return shared.messages;
	}
	async exec(messages: Message[]) {
		return new Promise<string>(async (resolve, reject) => {
			let str = '';
			root.emit('Output', 'Coder: ');
			llmWorking = true;
			try {
				await callLLM(messages, url.text, apiKey.text, model.text, (data) => {
					if (!running) {
						return true;
					}
					const [done] = string.match(data, 'data:%s*(%b[])');
					if (done === '[DONE]') {
						resolve(str);
						return false;
					}
					for (let [item] of string.gmatch(data, 'data:%s*(%b{})')) {
						const [res] = json.load(item);
						if (res) {
							const part = (res as any)['choices'][1]['delta']['content'];
							if (typeof part === 'string') {
								str += part;
							}
						}
					}
					root.emit('Update', `Coder: ${str}`);
					return false;
				});
			} catch (e) {
				llmWorking = false;
				reject(e);
			}
		});
	}
	async post(shared: ChatInfo, _prepRes: Message[], execRes: string) {
		const code = extractTSBlocks(execRes);
		shared.messages.push({role: 'system', content: code});
		return undefined;
	}
}

interface CompileResult {
	success: boolean,
	result: string
}

const compileTS = (file: string, content: string) => {
	const data = {name: "TranspileTS", file, content};
	return new Promise<CompileResult>((resolve) => {
		if (HttpServer.wsConnectionCount == 0) {
			resolve({success: false, result: "Web IDE not connected"});
			return;
		}
		const node = DoraNode();
		node.gslot(GSlot.AppWS, (eventType, msg) => {
			if (eventType === "Receive") {
				node.removeFromParent();
				const [res] = json.load(msg);
				if (res && res.name == "TranspileTS") {
					if (res.success) {
						resolve({success: true, result: res.luaCode});
					} else {
						resolve({success: false, result: res.message});
					}
				}
			}
		});
		const [str] = json.dump(data);
		if (str) {
			emit(GSlot.AppWS, "Send", str);
		}
	});
}

class CompileNode extends Node {
	async prep(shared: ChatInfo) {
		return shared.messages[shared.messages.length - 1].content;
	}
	async exec(code: string) {
		return await compileTS(Path(Content.writablePath, Path.getPath(outputFile.text), "__code__.ts"), code);
	}
	async post(shared: ChatInfo, prepRes: string, execRes: CompileResult) {
		if (execRes.success) {
			shared.messages.push({role: 'user', content: prepRes});
			logs.push("代码编译成功！");
			return "Success";
		} else {
			shared.messages.push({role: 'user', content: prepRes + '\n\n编译错误信息如下：\n' + execRes.result});
			logs.push("代码编译失败！");
			logs.push(execRes.result);
			return "Failed";
		}
	}
}

class FixNode extends Node {
	async prep(shared: ChatInfo) {
		const codeAndError = shared.messages[shared.messages.length - 1].content;
		const systemContent = getSystemPrompt();
		const userContent = `
你是一名经验丰富的 TypeScript 代码专家。

任务目标：
1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。
2. 找出导致编译失败的根本原因，并给出修正后的完整代码。
3. 展示修正后代码运行的正确输出结果或关键行为。

回答格式必须分两部分：
1. 思考过程
逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。
用条目或小节清晰列出，不要省略中间推理步骤。

2. 最终答案
修正后的完整代码（用 \`\`\`typescript\`\`\` 代码块包裹）。
期望输出或结果说明，用简要文字或示例输出展示。
注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。

原始代码及编译错误信息：

${codeAndError}
`;
		shared.messages = [
			{role: 'system', content: systemContent},
			{role: 'user', content: userContent}
		];
	}
	async exec() {
		logs.push("开始修复代码！");
	}
}

class SaveNode extends Node {
	async prep(shared: ChatInfo) {
		return shared.messages[shared.messages.length - 1].content;
	}
	async exec(code: string) {
		llmWorking = false;
		const filename = Path(Content.writablePath, Path.getPath(outputFile.text), Path.getFilename(Path.replaceExt(outputFile.text, "")) + "Gen.ts");
		if (Content.save(filename, code)) {
			logs.push(`保存代码成功！${filename}`);
		} else {
			logs.push(`保存代码失败！${filename}`);
		}
		const res = await compileTS(filename, code);
		if (res.success) {
			const luaFile = Path.replaceExt(filename, 'lua');
			if (Content.save(luaFile, res.result)) {
				logs.push(`保存代码成功！${luaFile}`);
			} else {
				logs.push(`保存代码失败！${luaFile}`);
			}
			try {
				const [func] = load(res.result, luaFile);
				if (func) func();
				logs.push('生成代码成功！');
			} catch (e) {
				logs.push('生成代码失败！');
				Log("Error", tostring(e));
			}
		}
	}
}

const chatNode = new ChatNode();
const llmCode = new LLMCode(2, 1);
const compileNode = new CompileNode();
const saveNode = new SaveNode();
const fixNode = new FixNode();
chatNode.next(llmCode);
llmCode.next(compileNode);
compileNode.on('Success', saveNode);
compileNode.on('Failed', fixNode);
fixNode.next(llmCode);
saveNode.next(chatNode);

const flow = new Flow(chatNode);
const runFlow = async () => {
	const chatInfo: ChatInfo = {
		messages: []
	};
	try {
		await flow.run(chatInfo);
	} catch (err: any) {
		Log("Error", err);
		runFlow();
	}
};
runFlow();

let logs: string[] = [];
const inputBuffer = Buffer(5000);

const ChatButton = () => {
	ImGui.PushItemWidth(-80, () => {
		if (ImGui.InputText(zh ? "描述需求" : "Desc", inputBuffer, [InputTextFlag.EnterReturnsTrue])) {
			const command = inputBuffer.text;
			if (command !== '') {
				logs = [];
				logs.push(`User: ${command}`);
				root.emit('Input', command);
			}
			inputBuffer.text = "";
		}
	});
};

const inputFlags = [InputTextFlag.Password];
const windowsFlags = [
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoResize,
	WindowFlag.NoDecoration,
	WindowFlag.NoNav,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoBringToFrontOnFocus,
	WindowFlag.NoFocusOnAppearing,
];
root.loop(() => {
	const {width, height} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2.zero, SetCond.Always, Vec2.zero);
	ImGui.SetNextWindowSize(Vec2(width, height - 40), SetCond.Always);
	ImGui.Begin("Blockly Coder", windowsFlags, () => {
		ImGui.Text(zh ? "Blockly 编程家" : "Blockly Coder");
		ImGui.SameLine();
		ImGui.TextDisabled("(?)");
		if (ImGui.IsItemHovered()) {
			ImGui.BeginTooltip(() => {
				ImGui.PushTextWrapPos(400, () => {
					ImGui.Text(zh ? "请先配置大模型 API 密钥，然后输入自然语言需求，Agent 将自动生成 TypeScript 积木代码，编译成 Blockly 积木并翻译为 Lua 脚本运行。遇到编译失败会自动修正，无需手动干预。" : "First, configure the API key for the large language model. Then, input your natural language requirements. The Agent will automatically generate TypeScript building block code, compile it into Blockly blocks, and translate it into Lua scripts for execution. If any compilation errors occur, they will be automatically corrected without requiring manual intervention.");
				});
			});
		}
		
		ImGui.SameLine();
		ImGui.Dummy(Vec2(width - 290, 0));
		ImGui.SameLine();
		if (ImGui.CollapsingHeader(zh ? "配置" : "Config")) {
			if (ImGui.InputText(zh ? "API 地址" : "API URL", url)) {
				config.url = url.text;
			}
			if (ImGui.InputText(zh ? "API 密钥" : "API Key", apiKey, inputFlags)) {
				config.apiKey = apiKey.text;
			}
			if (ImGui.InputText(zh ? "模型" : "Model", model)) {
				config.model = model.text;
			}
			if (ImGui.InputText(zh ? "输出文件" : "Output File", outputFile)) {
				config.output = outputFile.text;
			}
		}
		ImGui.Separator();
		ImGui.BeginChild("LogArea", Vec2(0, -40), () => {
			for (const log of logs) {
				ImGui.TextWrapped(log);
			}
			if (ImGui.GetScrollY() >= ImGui.GetScrollMaxY()) {
				ImGui.SetScrollHereY(1.0);
			}
		});
		if (llmWorking || config.output === '') {
			ImGui.BeginDisabled(() => {
				ChatButton();
			});
		} else {
			ChatButton();
		}
	});
	return false;
});

root.slot('Output', (message) => {
	logs.push(message);
});

root.slot('Update', (message) => {
	logs[logs.length - 1] = message;
});
