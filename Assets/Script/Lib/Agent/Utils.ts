// @preview-file off clear
import { json } from 'Dora';

type OnJSON = (this: void, obj: any, raw: string) => void;
type OnDone = (this: void, text: string) => void;
type OnError = (this: void, err: unknown, context?: { raw?: string }) => void;

export function createSSEJSONParser(opts: {
	onJSON: OnJSON; // 每解析出一个完整 data JSON 调用
	onDone?: OnDone; // 遇到非 JSON 的 data（比如 [DONE]）调用
	onError?: OnError; // JSON 解析失败等
}) {
	let buffer = ""; // 原始字节拼接后的文本
	let eventDataLines: string[] = []; // 当前事件累积的 data 行（去掉 "data:" 前缀）

	function flushEventIfAny() {
		if (eventDataLines.length === 0) return;

		// 按 SSE 规范：多行 data 用 \n 拼接
		const dataPayload = eventDataLines.join("\n");
		eventDataLines = [];

		// 一些实现会发 data: [DONE]
		if (dataPayload === "[DONE]") {
			opts.onDone?.(dataPayload);
			return;
		}

		// 尝试按 JSON 解析
		const [obj, err] = json.decode(dataPayload);
		if (err === null) {
			opts.onJSON(obj, dataPayload);
		} else {
			opts.onError?.(err, { raw: dataPayload });
		}
	}

	/**
	 * 你的底层每收到一个 string chunk 就调用 feed(chunk)
	 */
	function feed(chunk: string) {
		buffer += chunk;

		// 只按 \n 做增量行解析（\r\n 也兼容）
		while (true) {
			const nl = buffer.indexOf("\n");
			if (nl < 0) break; // 没有完整行，继续等下一包

			let line = buffer.slice(0, nl);
			buffer = buffer.slice(nl + 1);

			// 兼容 CRLF
			if (line.endsWith("\r")) line = line.slice(0, -1);

			// 空行：一个 SSE 事件结束
			if (line === "") {
				flushEventIfAny();
				continue;
			}

			// 注释行（:xxx）直接忽略
			if (line.startsWith(":")) continue;

			// 只关心 data 字段（你给的例子就是 data: {...}）
			if (line.startsWith("data:")) {
				// data: 后面允许有一个空格
				let v = line.slice(5);
				if (v.startsWith(" ")) v = v.slice(1);
				eventDataLines.push(v);
				continue;
			}

			// 其他 SSE 字段（event:, id:, retry:）按需处理；不需要就忽略
			// if (line.startsWith("id:")) ...
		}
	}

	/**
	 * 流结束时可调用，避免最后一个事件没有以空行收尾导致丢失
	 */
	function end() {
		// 先尝试把 buffer 里最后一行也当作行（如果没有 \n）
		if (buffer.length > 0) {
			// 注意：这一步可能把“半行”当完整行；但 end() 说明不会再有数据了
			let line = buffer;
			buffer = "";
			if (line.endsWith("\r")) line = line.slice(0, -1);

			if (line.startsWith("data:")) {
				let v = line.slice(5);
				if (v.startsWith(" ")) v = v.slice(1);
				eventDataLines.push(v);
			}
		}
		flushEventIfAny();
	}

	return { feed, end };
}

export interface LLMStreamData {
	id: string;
	created: number;
	object: string;
	model: string;
	choices: Choice[];
}

interface Choice {
	index: number;
	delta: Delta;
}

interface Delta {
	role: string;
	reasoning_content?: string;
	content?: string;
}
