import { App, Content, Label, Node, Vec2, sleep, thread, tolua, TypeName } from "Dora";
import { startMobileRemix, MobileRemixServices } from "Dev/Mobile/Remix";
import type { AgentSessionDetailResult, AgentSessionItem, AgentSessionMessageItem, AgentSessionStepItem } from "Agent/Session";

const result = "/tmp/dora-remix-transcript-test.result";
const session: AgentSessionItem = { id: 99158, projectRoot: Content.writablePath, title: "Transcript test",
	kind: "main", rootSessionId: 99158, memoryScope: "main", status: "RUNNING", workMode: "code", currentTaskId: 99200, createdAt: 1, updatedAt: 1 };
const messages: AgentSessionMessageItem[] = [];
for (let i = 1; i <= 8; i++) messages.push({ id: i, sessionId: session.id, role: i % 2 === 0 ? "assistant" : "user",
	content: `## 消息 ${i}\n` + "这是完整长消息，用于验证换行、动态高度和历史滚动。\n".repeat(8), createdAt: 1, updatedAt: 1 });
const step: AgentSessionStepItem = { id: 99001, sessionId: session.id, taskId: 99200, step: 1, tool: "build", status: "RUNNING", reason: "原始进度", reasoningContent: "DO_NOT_DISPLAY_PRIVATE_REASONING", createdAt: 1, updatedAt: 1 };
const detail = (): AgentSessionDetailResult => ({ success: true, session, messages, steps: [step], checkpoints: [], relatedSessions: [], hasActivePlan: false });
const unavailable = () => ({ success: false as const, message: "Test does not use a model" });
const services: MobileRemixServices = {
	createSession: () => ({ success: true, session }), getSession: detail, setWorkMode: () => ({ success: true }),
	sendPrompt: unavailable, respondQuestionnaire: unavailable, stopSessionTask: () => undefined,
	getActiveLLMConfig: unavailable, getLLMConfig: unavailable, getLLMConfigSummaries: () => [],
};
function find(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let found: Node.Type | undefined;
	root.eachChild(n => { found = find(n, tag); return found !== undefined; }); return found;
}
function text(root: Node.Type): string {
	let value = tolua.cast(root, TypeName.Label)?.text ?? "";
	root.eachChild(n => { value += text(n); return false; }); return value;
}
function expect(ok: boolean, message: string) { if (!ok) { Content.save(result, `failed ${message}`); throw new Error(message); } }
type Scroll = Node.Type & { offset: Vec2.Type; viewSize: {height: number}; area: Node.Type; };

thread(() => {
	const host = startMobileRemix({ entry: { id: "transcript-test", title: "工作展示回归", workDir: Content.writablePath }, onBack: () => undefined, onPlay: () => undefined, services });
	host.tag = "remix-transcript-test";
	sleep(0.4);
	const input = find(host, "remix-input")!;
	const inputLabel = find(host, "remix-input-text") as Label.Type;
	const scroll = find(host, "remix-scroll") as Scroll;
	expect(scroll !== undefined && scroll.viewSize.height > scroll.area.height, "missing scrollable history");
	expect(text(host).includes("消息 1"), "old messages truncated");
	expect(!text(host).includes("DO_NOT_DISPLAY_PRIVATE_REASONING"), "private reasoning exposed");
	expect(math.abs(scroll.offset.y - (scroll.viewSize.height - scroll.area.height)) < 2, "initial list not at latest");
	input.emit("TextInput", "草稿"); input.emit("TextEditing", "ni");
	step.reason = "同一步骤更新了进度"; step.result = { progress: 0.5, message: "验证进行中" };
	sleep(0.4);
	expect(text(host).includes("同一步骤更新了进度") && text(host).includes("50%"), "same-count progress did not update");
	expect(find(host, "remix-input") === input && inputLabel.text === "草稿ni", "progress reset input/composition");
	expect(math.abs(scroll.offset.y - (scroll.viewSize.height - scroll.area.height)) < 2, "update failed to follow latest");
	scroll.area.emit("MouseWheel", Vec2(0, 12));
	const offset = scroll.offset.y;
	messages.push({ id: 9, sessionId: session.id, role: "assistant", content: "新的追加消息\n".repeat(8), createdAt: 2, updatedAt: 2 });
	sleep(0.4);
	expect(math.abs(scroll.offset.y - offset) < 2, "new message stole reading position");
	expect(find(host, "remix-latest")!.visible, "new-content hint missing");
	find(host, "remix-latest")!.emit("Tapped");
	expect(math.abs(scroll.offset.y - (scroll.viewSize.height - scroll.area.height)) < 2, "latest action did not reach bottom");
	messages[8].content = "消息原位变更，不增加数量";
	step.status = "DONE"; session.status = "DONE";
	sleep(0.4);
	expect(text(host).includes("消息原位变更，不增加数量"), "same-count message change stale");
	expect(find(host, "remix-play") !== undefined, "completion action missing");
	expect(find(host, "remix-input") === input && inputLabel.text === "草稿ni", "completion reset input/composition");
	input.emit("TextInput", "你好");
	expect(inputLabel.text === "草稿你好", "composition commit incorrect after update");
	host.slot("TestAfterRun", () => { messages[8].content = "运行之后仍持续更新"; });
	App.saveScreenshot("/tmp/dora-remix-transcript-fixed");
	Content.save(result, "passed sameStep=1 messageMutation=1 autoScroll=1 readingAnchor=1 inputIdentity=1 composition=1 privateReasoningHidden=1\n");
});
