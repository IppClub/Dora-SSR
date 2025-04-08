// @preview-file on clear
import { HttpClient, json, thread, Buffer, Vec2, Node as DNode, Log } from 'Dora';
import * as ImGui from "ImGui";
import { InputTextFlag, SetCond } from "ImGui";
import { Node, Flow } from 'flow';

interface Message {
	role: string;
	content: string;
}

const url = Buffer(512);
url.text = "https://api.deepseek.com/chat/completions";
const apiKey = Buffer(256);
const model = Buffer(128);
model.text = "deepseek-chat";

const callLLM = (messages: Message[], url: string, apiKey: string, model: string, receiver: (this: void, data: string) => void) => {
	const data = {
		model,
		messages,
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

const root = DNode();

interface ChatInfo {
	messages: Message[];
}

let llmWorking = false;

class ChatNode extends Node {
	async prep(shared: ChatInfo) {
		return new Promise<Message[]>((resolve) => {
			root.slot('Input', (message: string) => {
				shared.messages.push({role: 'user', content: message});
				resolve(shared.messages.slice(-10));
			});
		});
	}
	async exec(messages: Message[]) {
		return new Promise<string>(async (resolve, reject) => {
			let str = '';
			root.emit('Output', 'LLM: ');
			llmWorking = true;
			try {
				await callLLM(messages, url.text, apiKey.text, model.text, (data) => {
					const [done] = string.match(data, 'data:%s*(%b[])');
					if (done === '[DONE]') {
						resolve(str);
						return;
					}
					for (let [item] of string.gmatch(data, 'data:%s*(%b{})')) {
						const [res] = json.load(item);
						if (res) {
							str += (res as any)['choices'][1]['delta']['content'] as string;
						}
					}
					root.emit('Update', `LLM: ${str}`);
				});
				llmWorking = false;
			} catch (e) {
				llmWorking = false;
				reject(e);
			}
		});
	}
	async post(shared: ChatInfo, _prepRes: Message[], execRes: string) {
		if (execRes !== "") {
			shared.messages.push({role: 'system', content: execRes});
		}
		return undefined;
	}
}

const chatNode = new ChatNode(2, 1);
chatNode.next(chatNode);

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

const logs: string[] = [];
const inputBuffer = Buffer(500);

const ChatButton = () => {
	if (ImGui.InputText("Chat", inputBuffer, [InputTextFlag.EnterReturnsTrue])) {
		const command = inputBuffer.text;
		if (command !== '') {
			logs.push(`User: ${command}`);
			root.emit('Input', command);
		}
		inputBuffer.text = "";
	}
};

root.loop(() => {
	ImGui.SetNextWindowSize(Vec2(400, 300), SetCond.FirstUseEver);
	ImGui.Begin("LLM Chat", () => {
		ImGui.InputText("URL", url);
		ImGui.InputText("API Key", apiKey);
		ImGui.InputText("Model", model);
		ImGui.Separator();
		ImGui.BeginChild("LogArea", Vec2(0, -40), () => {
			for (const log of logs) {
				ImGui.TextWrapped(log);
			}
			if (ImGui.GetScrollY() >= ImGui.GetScrollMaxY()) {
				ImGui.SetScrollHereY(1.0);
			}
		});
		if (llmWorking) {
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
