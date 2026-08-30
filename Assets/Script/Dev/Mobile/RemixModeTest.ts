import { App, Content, Label, Node, sleep, thread } from "Dora";
import type { AgentSessionItem } from "Agent/Session";
import type { LLMConfig } from "Agent/Utils";
import { startMobileRemix, type MobileRemixServices } from "Dev/Mobile/Remix";

const expect = (condition: boolean, message: string) => { if (!condition) throw new Error(message); };
function find(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let found: Node.Type | undefined;
	root.eachChild(child => { found = find(child, tag); return found !== undefined; });
	return found;
}
const session: AgentSessionItem = {
	id: 91901, projectRoot: Content.assetPath, title: "Manual modes", kind: "main", rootSessionId: 91901,
	memoryScope: "main", workMode: "code", status: "IDLE", createdAt: 1, updatedAt: 1,
};
const config: LLMConfig = { url: "https://example.invalid", model: "test", apiKey: "test", contextWindow: 64000, temperature: 0.1, maxTokens: 1024, supportsFunctionCalling: true };
let changes = 0;
let rejectMode = false;
let rejectSend = false;
const sent: { text: string; mode: string }[] = [];
const services: MobileRemixServices = {
	createSession: () => ({ success: true, session }),
	getSession: () => ({ success: true, session, messages: [], steps: [], checkpoints: [], relatedSessions: [], hasActivePlan: false }),
	setWorkMode: (_id, mode) => {
		changes++;
		if (rejectMode) return { success: false, message: "Mode rejected" };
		session.workMode = mode;
		return { success: true };
	},
	sendPrompt: (_id, text, _tools, mode) => {
		if (rejectSend) return { success: false, message: "Send rejected" };
		sent.push({ text, mode });
		session.status = "DONE";
		return { success: true, sessionId: session.id, taskId: 92901 };
	},
	respondQuestionnaire: () => ({ success: false, message: "Not expected" }),
	stopSessionTask: () => undefined,
	getActiveLLMConfig: () => ({ success: true, id: 94901, config }),
	getLLMConfig: () => ({ success: true, id: 94901, config }),
	getLLMConfigSummaries: () => [{ id: 94901, name: "Test", model: "test", active: true }],
};
thread(() => {
	let host = startMobileRemix({ entry: { id: "mode-test", title: "手动模式回归", workDir: Content.assetPath }, services, onBack: () => undefined, onPlay: () => undefined });
	try {
		const tap = (tag: string) => { const node = find(host, tag); expect(node !== undefined, `Missing ${tag}`); node?.emit("Tapped"); };
		const input = find(host, "remix-input")!;
		const label = () => find(host, "remix-input-text") as Label.Type;
		expect(changes === 0 && session.workMode === "code", "Opening changed the saved mode");
		input.emit("TextInput", "直接执行"); tap("remix-send");
		input.emit("TextInput", "继续执行"); tap("remix-send");
		expect(sent.length === 2 && sent[0].mode === "code" && sent[1].mode === "code", "Code requests forced planning");
		input.emit("TextInput", "保留草稿"); input.emit("TextEditing", "ni");
		tap("remix-mode-plan");
		expect(sent.length === 2 && session.workMode === "plan", "Switching must not send a request");
		expect(find(host, "remix-input") === input && label().text === "保留草稿ni", "Mode switch lost input/composition");
		tap("remix-send"); expect(sent.length === 2, "Uncommitted composition was sent");
		input.emit("TextInput", "你"); tap("remix-send");
		expect(sent[2].mode === "plan" && sent[2].text === "保留草稿你", `Plan send changed mode or prompt: ${sent[2].mode} / ${sent[2].text}`);
		expect(find(host, "remix-start") === undefined, "Mandatory start gate remains");
		input.emit("TextInput", "继续讨论"); tap("remix-send");
		expect(sent[3].mode === "plan", "Plan mode reset after a reply");
		input.emit("TextInput", "失败后保留"); rejectMode = true; tap("remix-mode-code");
		expect(session.workMode === "plan" && label().text === "失败后保留", "Rejected mode switch changed mode/draft");
		rejectMode = false; rejectSend = true; tap("remix-send");
		expect(sent.length === 4 && label().text === "失败后保留", "Rejected send lost draft"); rejectSend = false;
		const before = changes;
		for (const status of ["RUNNING", "WAITING_USER"] as const) {
			session.status = status; sleep(0.3);
			expect(!find(host, "remix-mode-code")?.touchEnabled, "Busy mode control was enabled");
			tap("remix-mode-code"); find(host, "remix-send")?.emit("Tapped");
		}
		session.status = "DONE"; session.currentTaskFinalizing = true; sleep(0.3);
		tap("remix-mode-code"); find(host, "remix-send")?.emit("Tapped");
		session.currentTaskFinalizing = false; session.currentTaskStatus = "RUNNING";
		tap("remix-mode-code"); find(host, "remix-send")?.emit("Tapped"); session.currentTaskStatus = "DONE";
		host.visible = false; tap("remix-mode-code"); find(host, "remix-send")?.emit("Tapped"); host.visible = true;
		expect(changes === before && sent.length === 4, "Busy/hidden controls changed state");
		host.removeFromParent(true);
		host = startMobileRemix({ entry: { id: "mode-test", title: "手动模式回归", workDir: Content.assetPath }, services, onBack: () => undefined, onPlay: () => undefined });
		expect(changes === before && session.workMode === "plan", "Reopening did not preserve plan mode");
		tap("remix-mode-code"); find(host, "remix-input")?.emit("TextInput", "手动执行"); tap("remix-send");
		expect(sent[4].mode === "code" && sent[4].text === "手动执行", "Manual code mode requires plan files or injected prompt");
		sleep(0.3); App.saveScreenshot("/tmp/dora-remix-manual-mode"); sleep(0.3);
		Content.save("/tmp/dora-remix-mode.result", "passed defaultCode=1 repeatedCode=1 repeatedPlan=1 manualSwitch=1 exactPrompt=1 savedMode=1 draftIME=1 rejectedActions=1 busyFinalizingHidden=1 noStartGate=1\n");
	} catch (error) { Content.save("/tmp/dora-remix-mode.result", `failed: ${error}`); }
	host.removeFromParent(true);
});
