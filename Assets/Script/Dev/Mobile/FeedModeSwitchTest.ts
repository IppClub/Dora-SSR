import { Content, Node, Path, sleep, thread } from "Dora";
import { startMobileFeed } from "Dev/Mobile/Feed";

const resultPath = Path(Content.writablePath, "dora-feed-mode-switch.result");
Content.save(resultPath, "running\n");
function expect(condition: boolean, message: string) {
	if (condition) return;
	Content.save(resultPath, `failed ${message}\n`);
	throw new Error(message);
}
function find(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let result: Node.Type | undefined;
	root.eachChild(child => { result = find(child, tag); return result !== undefined; });
	return result;
}
thread(() => {
	let switched = 0;
	let played = 0;
	let progress: ((this: void, progress: number, message: string) => void) | undefined;
	let done: ((this: void, success: boolean, ready?: { fileName: string; workDir: string }) => void) | undefined;
	let synced: ((this: void, success: boolean, message?: string) => void) | undefined;
	const host = startMobileFeed({
		getDiscoverEntries: () => [{ id: "test", title: "Mode test", description: "Test", kind: "discover" }],
		getLocalEntries: () => [],
		onPlay: () => { played++; },
		onRemix: () => undefined,
		onSwitchMode: () => { switched++; },
		prepare: (_entry, _repair, onProgress, onDone) => { progress = onProgress; done = onDone; },
		syncDiscover: (_progress, onDone) => { synced = onDone; },
	});
	expect(find(host, "mobile-ui-mode-switch") !== undefined, "mode button missing");
	find(host, "mobile-feed-play")?.emit("Tapped");
	expect(done !== undefined, "install was not started");
	host.emit("SwitchUIMode");
	find(host, "mobile-ui-mode-switch")?.emit("Tapped");
	expect(switched === 0, "switch allowed during installation");
	host.removeFromParent(true);
	const childCount = host.children?.count ?? 0;
	progress?.(0.5, "late progress");
	done?.(true, { fileName: "test/init", workDir: "test" });
	synced?.(true);
	host.emit("SwitchUIMode");
	sleep(0.05);
	expect(played === 0 && switched === 0, "late callback activated a disposed Feed");
	expect((host.children?.count ?? 0) === childCount, "late callback rebuilt a disposed Feed");
	const idle = startMobileFeed({
		getDiscoverEntries: () => [],
		getLocalEntries: () => [{ id: "local", title: "Local", description: "Test", kind: "local", fileName: "test/init" }],
		onPlay: () => { played++; },
		onRemix: () => { played++; },
		onSwitchMode: () => { switched++; },
		prepare: () => undefined,
	});
	find(idle, "mobile-ui-mode-switch")?.emit("Tapped");
	idle.emit("SwitchUIMode");
	find(idle, "mobile-feed-play")?.emit("Tapped");
	find(idle, "mobile-feed-remix")?.emit("Tapped");
	expect(switched === 1 && played === 0, "same-frame double click reopened a leaving Feed");
	idle.removeFromParent(true);
	Content.save(resultPath, "passed installGuard=1 lateCallbacks=1 disposedHost=1 reentryGuard=1\n");
});
