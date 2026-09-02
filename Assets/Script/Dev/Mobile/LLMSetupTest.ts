import { Content, DB, Node, Path, thread } from "Dora";
import { mobileLLMPresets, startMobileLLMManager, startMobileLLMSetup } from "Dev/Mobile/LLMSetup";

const resultPath = Path(Content.writablePath, "dora-mobile-llm-setup.result");

function find(node: Node.Type, tag: string): Node.Type | undefined {
	if (node.tag === tag) return node;
	let result: Node.Type | undefined;
	node.eachChild(child => { result = find(child, tag); return result !== undefined; });
	return result;
}

thread(() => {
	let host: Node.Type | undefined;
	let savedId = 0;
	let backupId = 0;
	let selectedId = 0;
	const selectedRows = DB.query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") as unknown[][] | undefined;
	const previousSelected = selectedRows && selectedRows.length > 0 ? tonumber(selectedRows[0][0]) : undefined;
	const key = "dora-mobile-test-key";
	const cleanup = () => {
		host?.removeFromParent(true);
		if (savedId > 0) DB.exec("delete from LLMConfig where id = ?", [savedId]);
		if (backupId > 0) DB.exec("delete from LLMConfig where id = ?", [backupId]);
		if (previousSelected !== undefined) {
			DB.exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", [previousSelected]);
		} else {
			DB.exec("delete from Config where name = 'mobileRemixLLMConfigId'");
		}
	};
	const [ok, err] = xpcall(() => {
		host = startMobileLLMSetup({ onSaved: id => { savedId = id; } });
		const get = (tag: string) => {
			const node = find(host as Node.Type, tag);
			if (!node) throw new Error(`missing ${tag}`);
			return node;
		};
		if (mobileLLMPresets.some(preset => preset.id === "custom")) throw new Error("custom provider remains in quick setup");
		const expectedTemplates = ["deepseek", "moonshot", "qwen", "openrouter", "openai", "aihubmix", "siliconflow", "volcengine", "volcengine-coding-plan", "byteplus", "byteplus-coding-plan", "minimax", "minimax-cn", "mimo", "zai", "zai-coding-plan", "ollama", "vllm"];
		if (mobileLLMPresets.map(item => item.id).join(",") !== expectedTemplates.join(",")) throw new Error("mobile templates do not match Web IDE");
		if (find(host, "mobile-llm-advanced") || find(host, "mobile-llm-url") || find(host, "mobile-llm-model") || find(host, "mobile-llm-key-visibility")) {
			throw new Error("advanced controls remain in quick setup");
		}
		get("mobile-llm-key-border");
		get("mobile-llm-paste");
		get("mobile-llm-key").emit("TextInput", key);
		const keyLabel = get("remix-input-text") as Node.Type & { text: string };
		if (keyLabel.text === key || keyLabel.text.indexOf("•") < 0) throw new Error("API key was not masked by the shared input");
		get("mobile-llm-save").emit("Tapped");
		if (savedId <= 0) throw new Error("save callback did not return an id");
		const rows = DB.query("select name, api_key from LLMConfig where id = ?", [savedId]) as unknown[][] | undefined;
		if (!rows || rows.length !== 1 || tostring(rows[0][0]).indexOf("DeepSeek") !== 0 || rows[0][1] !== key) throw new Error("saved LLM configuration mismatch");
		DB.exec(`insert into LLMConfig(name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at)
			select name || ' Test Backup', url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at from LLMConfig where id = ?`, [savedId]);
		const backupRows = DB.query("select last_insert_rowid()") as unknown[][] | undefined;
		backupId = backupRows && backupRows.length > 0 ? tonumber(backupRows[0][0]) ?? 0 : 0;
		if (backupId <= 0) throw new Error("could not create deletion fallback");
		if (host.parent !== undefined) throw new Error("setup panel remained mounted after save");
		host = startMobileLLMManager({ selectedId: savedId, onSelected: id => { selectedId = id; } });
		get(`mobile-llm-config-${savedId}`);
		get(`mobile-llm-detail-${savedId}`).emit("Tapped");
		get("mobile-llm-detail-key-edit").emit("Tapped");
		const updatedKey = "dora-mobile-updated-key";
		get("mobile-llm-detail-key-input").emit("TextInput", updatedKey);
		const updatedKeyLabel = get("remix-input-text") as Node.Type & { text: string };
		if (updatedKeyLabel.text === updatedKey || updatedKeyLabel.text.indexOf("•") < 0) throw new Error("updated API key was not masked");
		get("mobile-llm-detail-key-save").emit("Tapped");
		const updatedRows = DB.query("select api_key from LLMConfig where id = ?", [savedId]) as unknown[][] | undefined;
		if (!updatedRows || updatedRows.length !== 1 || updatedRows[0][0] !== updatedKey) throw new Error("API key update failed");
		get("mobile-llm-detail-delete").emit("Tapped");
		get("mobile-llm-detail-delete-cancel").emit("Tapped");
		get("mobile-llm-detail-delete").emit("Tapped");
		get("mobile-llm-detail-delete-confirm").emit("Tapped");
		const deletedRows = DB.query("select id from LLMConfig where id = ?", [savedId]) as unknown[][] | undefined;
		if (deletedRows && deletedRows.length > 0) throw new Error("configuration deletion failed");
		if (selectedId <= 0 || selectedId === savedId || host.parent === undefined) throw new Error("selection fallback after deletion failed");
		savedId = 0;
	}, debug.traceback);
	cleanup();
	Content.save(resultPath, ok ? "passed templates=18 sharedInput=1 pasteButton=1 masked=1 persisted=1 listed=1 keyUpdated=1 deleteConfirmed=1 fallback=1 cleanup=1\n" : `failed: ${err}`);
});
