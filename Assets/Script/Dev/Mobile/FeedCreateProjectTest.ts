import { App, Content, Director, emit, Node, Path, sleep, thread } from "Dora";
import { startMobileFeed } from "Dev/Mobile/Feed";
import type { FeedEntry } from "Dev/Mobile/FeedModel";

const resultPath = Path(Content.writablePath, "dora-feed-create-project.result");
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
	const local: FeedEntry[] = [];
	let attempts = 0;
	let remixCount = 0;
	let remixed: FeedEntry | undefined;
	let host: Node.Type;
	host = startMobileFeed({
		getDiscoverEntries: () => [],
		getLocalEntries: () => local,
		onPlay: () => undefined,
		onRemix: entry => { remixCount++; remixed = entry; },
		prepare: () => undefined,
		createProject: name => {
			attempts++;
			find(host, "mobile-project-create-submit")?.emit("Tapped");
			if (attempts === 1) return { success: false, error: "target-existed" };
			const entry = { id: "new-game", title: name, description: "Local", kind: "local" as const, fileName: "/workspace/New Game/init", workDir: "/workspace/New Game" };
			local.push(entry);
			return { success: true, entry };
		},
	});

	expect(find(host, "mobile-feed-create") === undefined, "create button leaked into Discover");
	find(host, "mobile-feed-local-tab")?.emit("Tapped");
	expect(find(host, "mobile-feed-create") !== undefined, "empty Local feed has no create button");

	find(host, "mobile-feed-create")?.emit("Tapped");
	expect(find(host, "mobile-project-create-sheet") !== undefined, "create sheet did not open");
	find(host, "mobile-project-create-cancel")?.emit("Tapped");
	expect(find(host, "mobile-project-create-sheet") === undefined, "cancel did not close create sheet");

	find(host, "mobile-feed-create")?.emit("Tapped");
	find(host, "mobile-project-create-input")?.emit("TextInput", "New Game");
	find(host, "mobile-project-create-submit")?.emit("Tapped");
	expect(attempts === 1, "create allowed a reentrant duplicate submission");
	expect(find(host, "mobile-project-create-sheet") !== undefined, "recoverable failure closed the sheet");
	expect(find(host, "mobile-project-create-error") !== undefined, "recoverable failure has no error message");

	find(host, "mobile-project-create-submit")?.emit("Tapped");
	expect(attempts === 2 && remixCount === 1, "successful create did not enter Remix exactly once");
	expect(remixed?.workDir === "/workspace/New Game", "successful create selected the wrong project");
	expect(find(host, "mobile-feed-card-new-game") !== undefined, "new local project was not selected before Remix");

	host.emit("RestoreFeedEntry", remixed);
	host.visible = true;
	host.emit("ResumeLocalUI");
	expect(find(host, "mobile-feed-card-new-game") !== undefined, "return from Remix lost the new project card");
	expect(find(host, "mobile-feed-index") !== undefined, "refined Feed card has no compact index badge");

	find(host, "mobile-feed-create")?.emit("Tapped");
	expect(find(host, "mobile-project-create-sheet") !== undefined, "create sheet did not reopen over an existing project");
	sleep(0.35);
	expect(App.saveScreenshot("/tmp/dora-mobile-feed-create-sheet") !== "", "create sheet screenshot failed");
	sleep(0.3);
	// Back is a global AppEvent, not a node-local signal. Isolate the fixture
	// from the user's shell so this test cannot navigate another open screen.
	const muted: { enabled: boolean }[] = [];
	const muteOtherBackHandlers = (node: Node.Type) => {
		if (node !== host) (node.gslot("AppEvent") ?? []).forEach(slot => {
			if (slot.enabled) { slot.enabled = false; muted.push(slot); }
		});
		node.eachChild(child => { muteOtherBackHandlers(child); return false; });
	};
	muteOtherBackHandlers(Director.systemUI);
	muteOtherBackHandlers(Director.entry);
	emit("AppEvent", "BackButton");
	muted.forEach(slot => { slot.enabled = true; });
	expect(find(host, "mobile-project-create-sheet") === undefined, "Back did not close create sheet");

	host.removeFromParent(true);
	sleep(0.05);
	Content.save(resultPath, "passed empty=1 cancel=1 reentry=1 recovery=1 success=1 restore=1 back=1\n");
});
