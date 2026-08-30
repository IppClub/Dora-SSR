import { App, Content, KeyName, Label, Node, Path, sleep, thread } from "Dora";
import { createSession, deleteSessionsByProjectRoot, getSession, setWorkMode } from "Agent/Session";
import { startMobileRemix } from "Dev/Mobile/Remix";

// Use the real service adapter: mocks alone cannot detect an extra Lua self argument.
const projectRoot = Path(Content.writablePath, `mobile-remix-service-test-${App.runningTime}`);
const resultPath = Path(Content.writablePath, "dora-mobile-remix-service.result");
function expect(condition: boolean, message: string) {
	if (!condition) throw new Error(message);
}
function findTagged(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let found: Node.Type | undefined;
	root.eachChild(child => { found = findTagged(child, tag); return found !== undefined; });
	return found;
}
thread(() => {
	if (!Content.mkdir(projectRoot)) throw new Error("Cannot create test project");
	const created = createSession(projectRoot, "Manual mode service test");
	if (!created.success) throw new Error(created.message);
	const sessionId = created.session.id;
	expect(created.session.workMode === "code", "New session must use the Web IDE default code mode");
	const host = startMobileRemix({
		entry: { id: "remix-service-test", title: "Service regression", workDir: projectRoot },
		onBack: () => undefined,
		onPlay: () => undefined,
	});
	sleep(0.5);
	if (!findTagged(host, "remix-scene")) throw new Error("Real service Remix scene did not render");
	const input = findTagged(host, "remix-input");
	if (input) {
		findTagged(host, "remix-mode-plan")?.emit("Tapped");
		let shared = getSession(sessionId);
		expect(shared.success && shared.session.workMode === "plan", "Mobile mode did not reach the shared Web IDE session");
		expect(setWorkMode(sessionId, "code").success, "Shared service could not select code");
		sleep(0.35);
		expect(findTagged(host, "remix-input") === input, "External mode change replaced input");
		findTagged(host, "remix-mode-plan")?.emit("Tapped");
		shared = getSession(sessionId);
		expect(shared.success && shared.session.workMode === "plan" && shared.messages.length === 0, "Mode change sent a prompt or diverged from shared session");
		for (const text of ["a", "b", "c", "中文", "🙂"]) input.emit("TextInput", text);
		if (findTagged(host, "remix-input") !== input) throw new Error("Typing replaced the IME node");
		const label = findTagged(host, "remix-input-text") as Label.Type;
		expect(label.text === "abc中文🙂", "Continuous text input lost characters");
		input.emit("KeyDown", KeyName.BackSpace);
		expect(label.text === "abc中文", "Backspace broke UTF-8 text");
		input.emit("TextEditing", "ni");
		expect(label.text === "abc中文ni", "Composition preview missing");
		input.emit("TextEditing", "nihao");
		expect(label.text === "abc中文nihao", "Composition preview duplicated");
		input.emit("TextInput", "你好");
		expect(label.text === "abc中文你好", "Composition commit duplicated preview");
		input.emit("TextEditing", "cancel");
		input.emit("TextEditing", "");
		expect(label.text === "abc中文你好", "Composition cancellation lost committed text");
		input.emit("TextEditing", "pending");
		host.emit("SuspendLocalUI");
		host.visible = false;
		input.emit("TextInput", "blocked");
		host.visible = true;
		host.emit("ResumeLocalUI");
		const resumedLabel = findTagged(host, "remix-input-text") as Label.Type;
		expect(resumedLabel.text === "abc中文你好", "UI takeover lost draft or retained unfinished composition");
	}
	host.removeFromParent(true);
	const reopened = startMobileRemix({ entry: { id: "remix-service-test", title: "Service regression", workDir: projectRoot }, onBack: () => undefined, onPlay: () => undefined });
	const saved = getSession(sessionId);
	expect(saved.success && saved.session.workMode === "plan", "Reopening changed saved mode");
	reopened.removeFromParent(true);
	deleteSessionsByProjectRoot(projectRoot);
	Content.remove(projectRoot);
	Content.save(resultPath, `passed realServices=1 scene=1 polling=1 input=${input ? 1 : 0} suspendResumeDraft=1 sharedManualMode=1 savedMode=1 noPrompts=1\n`);
});
