import { React, reference, toNode } from "DoraX";
import { App, DB, Director, HttpServer, Node, TextAlign } from "Dora";
import { mobileFontScale } from "Dev/Mobile/Accessibility";
import { MobileButton, MobilePanelSurface } from "Dev/Mobile/Controls";
import { createTextInput } from "Dev/Mobile/TextInput";
import { RoundedSurface } from "Dev/Mobile/Visual";

export interface MobileLLMPreset {
	id: string;
	name: string;
	url: string;
	model: string;
	contextWindow: number;
	maxTokens: number;
	customOptions: string;
}

interface MobileLLMSetupOptions {
	onSaved(this: void, id: number): void;
	onClose?(this: void): void;
	coveredNode?: Node.Type;
}

export interface MobileLLMManagerOptions {
	selectedId: number;
	taskRunning?: boolean;
	runningId?: number;
	onSelected(this: void, id: number): void;
	onClose?(this: void): void;
	coveredNode?: Node.Type;
}

const auxiliary = (body: string) => `{"auxiliaryOptions":${body}}`;
export const mobileLLMPresets: MobileLLMPreset[] = [
	{ id: "deepseek", name: "DeepSeek", url: "https://api.deepseek.com/v1/chat/completions", model: "deepseek-v4-pro", contextWindow: 1000000, maxTokens: 64000, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "moonshot", name: "Moonshot", url: "https://api.moonshot.cn/v1/chat/completions", model: "kimi-k3", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":"low"}') },
	{ id: "qwen", name: "Qwen", url: "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions", model: "qwen3.7-max", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"enable_thinking":false}') },
	{ id: "openrouter", name: "OpenRouter", url: "https://openrouter.ai/api/v1/chat/completions", model: "~anthropic/claude-sonnet-latest", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"reasoning":{"effort":"none"}}') },
	{ id: "openai", name: "OpenAI", url: "https://api.openai.com/v1/chat/completions", model: "gpt-5.6", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":null,"max_completion_tokens":8192,"reasoning_effort":"none"}') },
	{ id: "aihubmix", name: "AiHubMix", url: "https://aihubmix.com/v1/chat/completions", model: "gpt-5.6-luna", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":null,"max_completion_tokens":8192,"reasoning_effort":"none"}') },
	{ id: "siliconflow", name: "SiliconFlow", url: "https://api.siliconflow.cn/v1/chat/completions", model: "deepseek-ai/DeepSeek-V4-Pro", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"enable_thinking":false}') },
	{ id: "volcengine", name: "VolcEngine", url: "https://ark.cn-beijing.volces.com/api/v3/chat/completions", model: "doubao-seed-2-0-pro-260215", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "volcengine-coding-plan", name: "VolcEngine Coding Plan", url: "https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions", model: "ark-code-latest", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "byteplus", name: "BytePlus", url: "https://ark.ap-southeast.bytepluses.com/api/v3/chat/completions", model: "dola-seed-2-1-turbo-260628", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "byteplus-coding-plan", name: "BytePlus Coding Plan", url: "https://ark.ap-southeast.bytepluses.com/api/coding/v3/chat/completions", model: "ark-code-latest", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "minimax", name: "MiniMax", url: "https://api.minimax.io/v1/chat/completions", model: "MiniMax-M2.7", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null}') },
	{ id: "minimax-cn", name: "MiniMax (CN)", url: "https://api.minimaxi.com/v1/chat/completions", model: "MiniMax-M2.7", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null}') },
	{ id: "mimo", name: "Xiaomi MiMo", url: "https://api.xiaomimimo.com/v1/chat/completions", model: "mimo-v2.5-pro", contextWindow: 128000, maxTokens: 8192, customOptions: '{"max_tokens":null,"max_completion_tokens":8192,"top_p":0.95,"auxiliaryOptions":{"max_tokens":null,"max_completion_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}}' },
	{ id: "zai", name: "ZAI", url: "https://open.bigmodel.cn/api/paas/v4/chat/completions", model: "glm-5.2", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "zai-coding-plan", name: "ZAI Coding Plan", url: "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions", model: "glm-5.2", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":null,"thinking":{"type":"disabled"}}') },
	{ id: "ollama", name: "Ollama", url: "http://localhost:11434/v1/chat/completions", model: "llama3.2", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":"none"}') },
	{ id: "vllm", name: "vLLM", url: "http://localhost:8000/v1/chat/completions", model: "meta-llama/Llama-3.1-8B-Instruct", contextWindow: 128000, maxTokens: 8192, customOptions: auxiliary('{"max_tokens":8192,"reasoning_effort":"none","chat_template_kwargs":{"enable_thinking":false}}') },
];

const fontName = "sarasa-mono-sc-regular";
const trim = (value: string) => string.match(value, "^%s*(.-)%s*$")[0] ?? "";
let activeSetup: Node.Type | undefined;

function ensureLLMConfigTable() {
	DB.exec(`CREATE TABLE IF NOT EXISTS LLMConfig(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL, url TEXT NOT NULL, model TEXT NOT NULL, api_key TEXT NOT NULL,
		context_window INTEGER NOT NULL DEFAULT 64000, temperature REAL NOT NULL DEFAULT 0.1,
		max_tokens INTEGER NOT NULL DEFAULT 8192, reasoning_effort TEXT NOT NULL DEFAULT '',
		custom_options TEXT NOT NULL DEFAULT '', supports_function_calling INTEGER NOT NULL DEFAULT 1,
		active INTEGER NOT NULL DEFAULT 1, created_at INTEGER, updated_at INTEGER
	)`);
}

function uniqueConfigName(base: string) {
	const rows = DB.query("select name from LLMConfig") as unknown[][] | undefined;
	const names = (rows ?? []).map(row => tostring(row[0]));
	if (names.indexOf(base) < 0) return base;
	let suffix = 2;
	while (names.indexOf(`${base} ${suffix}`) >= 0) suffix++;
	return `${base} ${suffix}`;
}

export function hasMobileLLMConfig() {
	ensureLLMConfigTable();
	const rows = DB.query("select id from LLMConfig limit 1") as unknown[][] | undefined;
	return rows !== undefined && rows.length > 0;
}

export function startMobileLLMSetup(options: MobileLLMSetupOptions) {
	activeSetup?.removeFromParent(true);
	const coveredNode = options.coveredNode;
	if (coveredNode) coveredNode.visible = false;
	let coveredRestored = false;
	const restoreCovered = () => {
		if (coveredRestored) return;
		coveredRestored = true;
		if (coveredNode?.parent) coveredNode.visible = true;
	};
	let zh = string.match(App.locale, "^zh")[0] !== undefined;
	const host = Node();
	host.tag = "mobile-llm-setup";
	host.order = 10000;
	host.renderGroup = true;
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	activeSetup = host;
	let presetIndex = 0;
	let apiKey = "";
	let error = "";
	let disposed = false;
	let keyRef = reference<Node.Type>();
	const canEdit = () => !disposed && host.parent !== undefined && host.visible && HttpServer.wsConnectionCount === 0;
	const keyInput = createTextInput({
		fontSize: math.floor(15 * mobileFontScale), singleLine: true, isSecure: () => true,
		getText: () => apiKey, setText: value => { apiKey = value; error = ""; },
		getPlaceholder: () => "sk-…", isEnabled: canEdit,
		onReturn: () => true,
	});
	const blurInputs = () => keyInput.blur();
	const close = () => {
		if (disposed) return;
		disposed = true;
		blurInputs();
		restoreCovered();
		host.removeFromParent(true);
		if (activeSetup === host) activeSetup = undefined;
		options.onClose?.();
	};
	const choose = (delta: number) => {
		presetIndex = (presetIndex + delta + mobileLLMPresets.length) % mobileLLMPresets.length;
		error = "";
		blurInputs(); render();
	};
	const save = () => {
		if (!canEdit()) return;
		const preset = mobileLLMPresets[presetIndex];
		const key = trim(apiKey);
		if (key === "") { error = zh ? "请粘贴 API Key" : "Paste an API key"; render(); return; }
		ensureLLMConfigTable();
		const now = os.time();
		const name = uniqueConfigName(preset.name);
		const affected = DB.exec(`insert into LLMConfig(
			name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort,
			custom_options, supports_function_calling, active, created_at, updated_at
		) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [
			name, preset.url, preset.model, key, preset.contextWindow, 0.1, preset.maxTokens, "",
			preset.customOptions, 1, 1, now, now,
		]);
		if (affected < 0) { error = zh ? "配置保存失败，请重试" : "Could not save the configuration"; render(); return; }
		const rows = DB.query("select last_insert_rowid()") as unknown[][] | undefined;
		const id = rows && rows.length > 0 ? tonumber(rows[0][0]) : undefined;
		if (!id) { error = zh ? "无法读取新配置" : "Could not read the new configuration"; render(); return; }
		DB.exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", [id]);
		options.onSaved(id);
		close();
	};
	const render = () => {
		if (disposed) return;
		keyInput.unmount();
		keyRef = reference<Node.Type>();
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio; host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = App.safeArea;
		const shortLandscape = safe.width >= 760 && safe.height < 500;
		const sheetWidth = shortLandscape ? math.min(720, safe.width - 24) : safe.width;
		const sheetHeight = shortLandscape ? math.min(240, safe.height - 16) : math.min(300, safe.height - 20);
		const left = safe.x + (safe.width - sheetWidth) / 2;
		const bottom = safe.y;
		const contentWidth = sheetWidth - 40;
		const fieldGap = 12;
		const fieldWidth = shortLandscape ? math.floor((contentWidth - fieldGap) / 2) : contentWidth;
		const keyButtonWidth = 92;
		const keyX = shortLandscape ? 20 + fieldWidth + fieldGap : 20;
		const keyWidth = fieldWidth - keyButtonWidth - fieldGap;
		const providerLabelY = sheetHeight - 66;
		const providerY = sheetHeight - 126;
		const keyLabelY = shortLandscape ? providerLabelY : sheetHeight - 150;
		const keyY = shortLandscape ? providerY : sheetHeight - 204;
		const actionGap = 12;
		const cancelWidth = math.floor((contentWidth - actionGap) * (shortLandscape ? 0.34 : 0.38));
		const preset = mobileLLMPresets[presetIndex];
		const scene = toNode(<node order={10000} x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0}>
			<node tag="mobile-llm-setup-backdrop" width={width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={close}>
				<RoundedSurface width={width} height={height} radius={0} fillColor={0x8c000000} renderOrder={0} />
			</node>
			<node order={10} x={left} y={bottom} width={sheetWidth} height={sheetHeight} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
				<MobilePanelSurface width={sheetWidth} height={sheetHeight} renderOrder={10} />
				<label x={20} y={sheetHeight - 24} anchorX={0} anchorY={1} fontName={fontName} fontSize={22} text={zh ? "从模板新增配置" : "Add from template"} color3={0xf4f1e8} />
				<label x={sheetWidth - 20} y={sheetHeight - 24} anchorX={1} anchorY={1} fontName={fontName} fontSize={12} text={compactText(preset.model, shortLandscape ? 42 : 24)} color3={0xa8afbd} />
				<label x={20} y={providerLabelY} anchorX={0} anchorY={1} fontName={fontName} fontSize={14} text={zh ? "配置模板" : "Template"} color3={0xa8afbd} />
				<MobileButton tag="mobile-llm-provider-prev" x={20} y={providerY} width={48} text="‹" renderOrder={10} onTapped={() => choose(-1)} />
				<MobileButton tag="mobile-llm-provider" x={80} y={providerY} width={fieldWidth - 120} text={preset.name} renderOrder={10} onTapped={() => choose(1)} />
				<MobileButton tag="mobile-llm-provider-next" x={20 + fieldWidth - 48} y={providerY} width={48} text="›" renderOrder={10} onTapped={() => choose(1)} />
				<label x={keyX} y={keyLabelY} anchorX={0} anchorY={1} fontName={fontName} fontSize={14} text="API Key" color3={0xa8afbd} />
				<node tag="mobile-llm-key" ref={keyRef} renderOrder={10} x={keyX} y={keyY} width={keyWidth} height={44} anchorX={0} anchorY={0} onMount={keyInput.mount} />
				<MobileButton tag="mobile-llm-paste" x={keyX + keyWidth + fieldGap} y={keyY - 2} width={keyButtonWidth} text={zh ? "粘贴" : "Paste"} renderOrder={10} onTapped={() => {
					if (!keyInput.pasteFromClipboard(true)) error = zh ? "剪贴板为空" : "Clipboard is empty";
					else error = "";
					keyInput.refresh();
				}} />
				<label tag="mobile-llm-error" x={20} y={78} anchorX={0} fontName={fontName} fontSize={12} text={error} textWidth={contentWidth} alignment={TextAlign.Left} color3={0xff6b6b} />
				<MobileButton tag="mobile-llm-cancel" x={20} y={20} width={cancelWidth} text={zh ? "返回" : "Back"} renderOrder={10} onTapped={close} />
				<MobileButton tag="mobile-llm-save" x={20 + cancelWidth + actionGap} y={20} width={contentWidth - cancelWidth - actionGap} text={zh ? "新增并使用" : "Add and use"} primary={true} renderOrder={10} onTapped={save} />
			</node>
		</node>);
		if (scene) host.addChild(scene);
	};
	host.onAppChange(setting => {
		if (setting === "Locale") zh = string.match(App.locale, "^zh")[0] !== undefined;
		if (setting === "Size" || setting === "Locale") render();
	});
	host.onAppEvent(event => { if (event === "BackButton") close(); });
	host.onCleanup(() => { disposed = true; restoreCovered(); if (activeSetup === host) activeSetup = undefined; });
	render();
	return host;
}

interface MobileLLMConfigItem {
	id: number;
	name: string;
	url: string;
	model: string;
	contextWindow: number;
	supportsFunctionCalling: boolean;
}

function getMobileLLMConfigs(): MobileLLMConfigItem[] {
	ensureLLMConfigTable();
	const rows = DB.query(`select id, name, url, model, context_window, supports_function_calling
		from LLMConfig order by id asc`) as unknown[][] | undefined;
	return (rows ?? []).flatMap(row => {
		const id = tonumber(row[0]);
		if (!id) return [];
		return [{
			id,
			name: tostring(row[1]),
			url: tostring(row[2]),
			model: tostring(row[3]),
			contextWindow: tonumber(row[4]) ?? 128000,
			supportsFunctionCalling: tonumber(row[5]) !== 0,
		}];
	});
}

function compactText(value: string, limit: number) {
	const length = utf8.len(value)[0] ?? 0;
	if (length <= limit) return value;
	const stop = utf8.offset(value, limit) ?? value.length;
	return string.sub(value, 1, stop - 1) + "…";
}

export function startMobileLLMManager(options: MobileLLMManagerOptions) {
	let configs = getMobileLLMConfigs();
	if (configs.length === 0) {
		return startMobileLLMSetup({
			coveredNode: options.coveredNode,
			onSaved: options.onSelected,
			onClose: options.onClose,
		});
	}
	activeSetup?.removeFromParent(true);
	const coveredNode = options.coveredNode;
	if (coveredNode) coveredNode.visible = false;
	let coveredRestored = false;
	const restoreCovered = () => {
		if (coveredRestored) return;
		coveredRestored = true;
		if (coveredNode?.parent) coveredNode.visible = true;
	};
	let zh = string.match(App.locale, "^zh")[0] !== undefined;
	const host = Node();
	host.tag = "mobile-llm-manager";
	host.order = 10000;
	host.renderGroup = true;
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	activeSetup = host;
	let page = -1;
	let detailId = 0;
	let detailMode: "view" | "key" | "delete" = "view";
	let detailKey = "";
	let detailError = "";
	let selectedId = options.selectedId;
	let disposed = false;
	let detailKeyRef = reference<Node.Type>();
	const canEdit = () => !disposed && host.parent !== undefined && host.visible && HttpServer.wsConnectionCount === 0;
	const detailKeyInput = createTextInput({
		fontSize: math.floor(15 * mobileFontScale), singleLine: true, isSecure: () => true,
		getText: () => detailKey, setText: value => { detailKey = value; detailError = ""; },
		getPlaceholder: () => zh ? "粘贴新的 API Key" : "Paste a new API key", isEnabled: canEdit,
		onReturn: () => true,
	});
	const close = (notify = true) => {
		if (disposed) return;
		disposed = true;
		detailKeyInput.blur();
		restoreCovered();
		host.removeFromParent(true);
		if (activeSetup === host) activeSetup = undefined;
		if (notify) options.onClose?.();
	};
	const select = (id: number) => {
		DB.exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", [id]);
		options.onSelected(id);
		close();
	};
	const openDetail = (id: number) => {
		detailId = id;
		detailMode = "view";
		detailKey = "";
		detailError = "";
		render();
	};
	const saveDetailKey = () => {
		if (!canEdit() || detailId <= 0) return;
		const key = trim(detailKey);
		if (key === "") { detailError = zh ? "请粘贴新的 API Key" : "Paste a new API key"; render(); return; }
		const affected = DB.exec("update LLMConfig set api_key = ?, updated_at = ? where id = ?", [key, os.time(), detailId]);
		if (affected <= 0) { detailError = zh ? "API Key 保存失败" : "Could not save the API key"; render(); return; }
		detailKeyInput.blur();
		detailKey = "";
		detailError = zh ? "API Key 已更新" : "API key updated";
		detailMode = "view";
		render();
	};
	const deleteDetail = () => {
		if (!canEdit() || detailId <= 0) return;
		const deletingId = detailId;
		const affected = DB.exec("delete from LLMConfig where id = ?", [deletingId]);
		if (affected <= 0) { detailError = zh ? "删除失败，请重试" : "Could not delete the configuration"; render(); return; }
		configs = getMobileLLMConfigs();
		if (selectedId === deletingId) {
			selectedId = configs[0]?.id ?? 0;
			if (selectedId > 0) DB.exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", [selectedId]);
			else DB.exec("delete from Config where name = 'mobileRemixLLMConfigId'");
			options.onSelected(selectedId);
		}
		detailId = 0;
		detailMode = "view";
		detailKey = "";
		detailError = "";
		page = -1;
		if (configs.length > 0) render();
		else {
			close(false);
			startMobileLLMSetup({ coveredNode, onSaved: options.onSelected, onClose: options.onClose });
		}
	};
	const add = () => {
		close(false);
		let saved = false;
		startMobileLLMSetup({
			coveredNode,
			onSaved: id => { saved = true; options.onSelected(id); },
			onClose: () => {
				if (saved) options.onClose?.();
				else startMobileLLMManager(options);
			},
		});
	};
	const render = () => {
		if (disposed) return;
		detailKeyInput.unmount();
		detailKeyRef = reference<Node.Type>();
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = App.safeArea;
		const shortLandscape = safe.width >= 760 && safe.height < 500;
		const rowsPerPage = shortLandscape ? 3 : 5;
		const desiredHeight = detailId > 0 ? 410 : math.max(260, 160 + math.min(configs.length, rowsPerPage) * 68);
		const sheetWidth = shortLandscape ? math.min(720, safe.width - 24) : safe.width;
		const sheetHeight = math.min(desiredHeight, safe.height - (shortLandscape ? 16 : 20));
		const left = safe.x + (safe.width - sheetWidth) / 2;
		const bottom = safe.y;
		const contentWidth = sheetWidth - 40;
		const pageCount = math.max(1, math.ceil(configs.length / rowsPerPage));
		if (page < 0) {
			const selectedIndex = configs.findIndex(item => item.id === selectedId);
			page = selectedIndex < 0 ? 0 : math.floor(selectedIndex / rowsPerPage);
		}
		page = math.max(0, math.min(pageCount - 1, page));
		const pageItems = configs.slice(page * rowsPerPage, (page + 1) * rowsPerPage);
		const detail = configs.find(item => item.id === detailId);
		const switchPending = options.taskRunning && (options.runningId ?? selectedId) !== selectedId;
		const scene = toNode(<node order={10000} x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0}>
			<node tag="mobile-llm-manager-backdrop" width={width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={() => close()}>
				<RoundedSurface width={width} height={height} radius={0} fillColor={0x8c000000} renderOrder={0} />
			</node>
			<node order={10} x={left} y={bottom} width={sheetWidth} height={sheetHeight} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
				<MobilePanelSurface width={sheetWidth} height={sheetHeight} renderOrder={10} />
				{detail ? detailMode === "key" ? <node tag="mobile-llm-detail-key">
					<label x={20} y={sheetHeight - 24} anchorX={0} anchorY={1} fontName={fontName} fontSize={22} text={zh ? "修改 API Key" : "Update API key"} color3={0xf4f1e8} />
					<label x={20} y={sheetHeight - 66} anchorX={0} anchorY={1} fontName={fontName} fontSize={13} text={compactText(detail.name, shortLandscape ? 44 : 28)} color3={0xa8afbd} />
					<label x={20} y={sheetHeight - 104} anchorX={0} anchorY={1} fontName={fontName} fontSize={13} text={zh ? "原 Key 不会显示，保存后立即替换" : "The current key stays hidden and will be replaced"} color3={0xa8afbd} />
					<node tag="mobile-llm-detail-key-input" ref={detailKeyRef} renderOrder={10} x={20} y={sheetHeight - 166} width={contentWidth - 104} height={44} anchorX={0} anchorY={0} onMount={detailKeyInput.mount} />
					<MobileButton tag="mobile-llm-detail-key-paste" x={contentWidth - 72} y={sheetHeight - 168} width={92} text={zh ? "粘贴" : "Paste"} renderOrder={10} onTapped={() => {
						if (!detailKeyInput.pasteFromClipboard(true)) detailError = zh ? "剪贴板为空" : "Clipboard is empty";
						else detailError = "";
						detailKeyInput.refresh();
					}} />
					<label x={20} y={82} anchorX={0} fontName={fontName} fontSize={12} text={detailError} textWidth={contentWidth} alignment={TextAlign.Left} color3={0xff6b6b} />
					<MobileButton tag="mobile-llm-detail-key-cancel" x={20} y={20} width={math.floor((contentWidth - 12) * 0.36)} text={zh ? "取消" : "Cancel"} renderOrder={10} onTapped={() => { detailKeyInput.blur(); detailMode = "view"; detailKey = ""; detailError = ""; render(); }} />
					<MobileButton tag="mobile-llm-detail-key-save" x={32 + math.floor((contentWidth - 12) * 0.36)} y={20} width={contentWidth - 12 - math.floor((contentWidth - 12) * 0.36)} text={zh ? "保存新 Key" : "Save new key"} primary={true} renderOrder={10} onTapped={saveDetailKey} />
				</node> : detailMode === "delete" ? <node tag="mobile-llm-detail-delete">
					<label x={20} y={sheetHeight - 24} anchorX={0} anchorY={1} fontName={fontName} fontSize={22} text={zh ? "删除这个配置？" : "Delete this configuration?"} color3={0xf4f1e8} />
					<label x={20} y={sheetHeight - 78} anchorX={0} anchorY={1} fontName={fontName} fontSize={16} text={compactText(detail.name, shortLandscape ? 52 : 32)} color3={0xffff8585} />
					<label x={20} y={sheetHeight - 120} anchorX={0} anchorY={1} fontName={fontName} fontSize={13} text={zh ? "删除后无法恢复；若它是当前配置，将自动切换到下一项。" : "This cannot be undone. The next configuration will become active."} textWidth={contentWidth} alignment={TextAlign.Left} color3={0xa8afbd} />
					<label x={20} y={82} anchorX={0} fontName={fontName} fontSize={12} text={detailError} textWidth={contentWidth} alignment={TextAlign.Left} color3={0xff6b6b} />
					<MobileButton tag="mobile-llm-detail-delete-cancel" x={20} y={20} width={math.floor((contentWidth - 12) * 0.42)} text={zh ? "保留配置" : "Keep it"} renderOrder={10} onTapped={() => { detailMode = "view"; detailError = ""; render(); }} />
					<MobileButton tag="mobile-llm-detail-delete-confirm" x={32 + math.floor((contentWidth - 12) * 0.42)} y={20} width={contentWidth - 12 - math.floor((contentWidth - 12) * 0.42)} text={zh ? "确认删除" : "Delete"} danger={true} renderOrder={10} onTapped={deleteDetail} />
				</node> : <node tag="mobile-llm-detail">
					<label x={20} y={sheetHeight - 24} anchorX={0} anchorY={1} fontName={fontName} fontSize={22} text={compactText(detail.name, 28)} color3={0xf4f1e8} />
					{detailError !== "" ? <label x={sheetWidth - 20} y={sheetHeight - 25} anchorX={1} anchorY={1} fontName={fontName} fontSize={12} text={detailError} color3={0xff7ee2a8} /> : undefined}
					<label x={20} y={sheetHeight - 68} anchorX={0} anchorY={1} fontName={fontName} fontSize={13} text={zh ? "模型" : "Model"} color3={0xa8afbd} />
					<label x={20} y={sheetHeight - 94} anchorX={0} anchorY={1} fontName={fontName} fontSize={15} text={compactText(detail.model, shortLandscape ? 56 : 38)} color3={0xf4f1e8} />
					<label x={20} y={sheetHeight - 132} anchorX={0} anchorY={1} fontName={fontName} fontSize={13} text="API URL" color3={0xa8afbd} />
					<label x={20} y={sheetHeight - 158} anchorX={0} anchorY={1} fontName={fontName} fontSize={13} text={compactText(detail.url, shortLandscape ? 72 : 42)} color3={0xf4f1e8} />
					<label x={20} y={sheetHeight - 200} anchorX={0} anchorY={1} fontName={fontName} fontSize={13}
						text={`${zh ? "上下文" : "Context"}  ${detail.contextWindow}   ·   Function Call  ${detail.supportsFunctionCalling ? (zh ? "支持" : "On") : (zh ? "不支持" : "Off")}`} color3={0xa8afbd} />
					<MobileButton tag="mobile-llm-detail-key-edit" x={20} y={76} width={math.floor((contentWidth - 12) * 0.62)} text={zh ? "修改 API Key" : "Update API key"} renderOrder={10} onTapped={() => { detailMode = "key"; detailKey = ""; detailError = ""; render(); }} />
					<MobileButton tag="mobile-llm-detail-delete" x={32 + math.floor((contentWidth - 12) * 0.62)} y={76} width={contentWidth - 12 - math.floor((contentWidth - 12) * 0.62)} text={zh ? "删除" : "Delete"} danger={true} renderOrder={10} onTapped={() => { detailMode = "delete"; detailError = ""; render(); }} />
					<MobileButton tag="mobile-llm-detail-back" x={20} y={20} width={math.floor((contentWidth - 12) * 0.36)} text={zh ? "返回列表" : "Back"} renderOrder={10} onTapped={() => { detailId = 0; render(); }} />
					<MobileButton tag="mobile-llm-detail-select" x={32 + math.floor((contentWidth - 12) * 0.36)} y={20} width={contentWidth - 12 - math.floor((contentWidth - 12) * 0.36)}
						text={detail.id === selectedId ? (switchPending ? (zh ? "下一轮使用" : "Use next") : options.taskRunning ? (zh ? "本轮使用" : "In this run") : (zh ? "当前使用" : "In use")) : (zh ? "切换到此配置" : "Use this config")}
						primary={detail.id !== selectedId} renderOrder={10} onTapped={() => select(detail.id)} />
				</node> : <node tag="mobile-llm-list">
					<label x={20} y={sheetHeight - 24} anchorX={0} anchorY={1} fontName={fontName} fontSize={22} text={zh ? "模型配置" : "Model configurations"} color3={0xf4f1e8} />
					<label x={20} y={sheetHeight - 58} anchorX={0} anchorY={1} fontName={fontName} fontSize={13}
						text={options.taskRunning ? (zh ? "切换将在下一轮生效" : "Changes apply to the next run") : (zh ? "选择当前 Remix 使用的配置" : "Choose the configuration for Remix")} color3={0xa8afbd} />
					{pageCount > 1 ? <label x={sheetWidth - 20} y={sheetHeight - 58} anchorX={1} anchorY={1} fontName={fontName} fontSize={12} text={`${page + 1} / ${pageCount}`} color3={0xa8afbd} /> : undefined}
					{pageItems.map((item, index) => {
						const y = sheetHeight - 126 - index * 68;
						const selected = item.id === selectedId;
						return <node key={`${item.id}`} tag={`mobile-llm-config-${item.id}`} x={20} y={y} width={contentWidth} height={54} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={() => select(item.id)}>
							<RoundedSurface width={contentWidth} height={54} radius={14} topColor={selected ? 0xff3a3420 : 0xff252c39} bottomColor={selected ? 0xff211d12 : 0xff171c25} borderWidth={1} borderColor={selected ? 0xffffcc33 : 0xff343b48} />
							<draw-node x={20} y={27}><dot-shape radius={8} color={selected ? 0xffffcc33 : 0xff6f7888} /><dot-shape radius={selected ? 3 : 5} color={selected ? 0xff17130a : 0xff171c25} /></draw-node>
							<label x={38} y={34} anchorX={0} fontName={fontName} fontSize={15} text={compactText(item.name, shortLandscape ? 34 : 22)} color3={0xf4f1e8} />
							<label x={38} y={15} anchorX={0} fontName={fontName} fontSize={11} text={compactText(item.model, shortLandscape ? 52 : 30)} color3={0xa8afbd} />
							{selected ? <label x={contentWidth - 54} y={27} anchorX={1} fontName={fontName} fontSize={11} text={switchPending ? (zh ? "下一轮" : "Next") : options.taskRunning ? (zh ? "本轮" : "Running") : (zh ? "当前" : "Current")} color3={0xffcc33} /> : undefined}
							<node tag={`mobile-llm-detail-${item.id}`} x={contentWidth - 44} y={0} width={44} height={54} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={() => openDetail(item.id)}>
								<label x={26} y={27} fontName={fontName} fontSize={18} text="›" color3={0xa8afbd} />
							</node>
						</node>;
					})}
					{pageCount > 1 ? <node>
						<MobileButton tag="mobile-llm-page-prev" x={20} y={20} width={54} text="‹" renderOrder={10} onTapped={() => { page = (page - 1 + pageCount) % pageCount; render(); }} />
						<MobileButton tag="mobile-llm-page-next" x={86} y={20} width={54} text="›" renderOrder={10} onTapped={() => { page = (page + 1) % pageCount; render(); }} />
					</node> : <MobileButton tag="mobile-llm-close" x={20} y={20} width={math.floor(contentWidth * 0.28)} text={zh ? "关闭" : "Close"} renderOrder={10} onTapped={() => close()} />}
					<MobileButton tag="mobile-llm-add" x={pageCount > 1 ? 152 : 32 + math.floor(contentWidth * 0.28)} y={20}
						width={pageCount > 1 ? contentWidth - 132 : contentWidth - 12 - math.floor(contentWidth * 0.28)} text={zh ? "＋ 从模板新增" : "+ Add from template"} primary={true} renderOrder={10} onTapped={add} />
				</node>}
			</node>
		</node>);
		if (scene) host.addChild(scene);
	};
	host.onAppChange(setting => {
		if (setting === "Locale") zh = string.match(App.locale, "^zh")[0] !== undefined;
		if (setting === "Size" || setting === "Locale") render();
	});
	host.onAppEvent(event => { if (event === "BackButton") { if (detailId > 0) { detailId = 0; render(); } else close(); } });
	host.onCleanup(() => { disposed = true; restoreCovered(); if (activeSetup === host) activeSetup = undefined; });
	render();
	return host;
}
