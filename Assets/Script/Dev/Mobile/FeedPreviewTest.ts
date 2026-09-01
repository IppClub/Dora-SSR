import { App, Content, Node, Size, Vec2, sleep, thread } from "Dora";
import { startMobileFeed } from "Dev/Mobile/Feed";

const resultPath = "/tmp/dora-mobile-feed-preview.result";

function find(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let result: Node.Type | undefined;
	root.eachChild(child => { result = find(child, tag); return result !== undefined; });
	return result;
}

function findPrefix(root: Node.Type, prefix: string): Node.Type | undefined {
	if (string.sub(root.tag, 1, prefix.length) === prefix) return root;
	let result: Node.Type | undefined;
	root.eachChild(child => { result = findPrefix(child, prefix); return result !== undefined; });
	return result;
}

function expect(condition: boolean, message: string) {
	if (!condition) throw new Error(message);
}

App.winSize = Size(390, 844);
thread(() => {
	sleep(0.4);
	const host = startMobileFeed({
		getDiscoverEntries: () => [
			{
				id: "orbital-garden",
				title: "轨道花园",
				description: "守护漂浮花园，在星轨之间培育新的生态。",
				kind: "discover",
			},
			{
				id: "neon-runner",
				title: "霓虹跑者",
				description: "一段可以立即试玩和 Remix 的节奏动作原型。",
				kind: "discover",
			},
		],
		getLocalEntries: () => [
			{
				id: "local-sample",
				title: "我的 Dora 游戏",
				description: "保存在当前设备上的可运行作品。",
				kind: "local",
				fileName: "Game/init",
			},
		],
		onPlay: () => undefined,
		onRemix: () => undefined,
		onSwitchMode: () => undefined,
		createProject: () => ({ success: false, error: "preview only" }),
		prepare: (_entry, _repairIncomplete, _onProgress, onDone) => onDone(false, undefined, "preview only"),
	});
	sleep(0.8);
	const screenshot = App.saveScreenshot("/tmp/dora-mobile-feed-preview");
	sleep(0.3);
	const scene = find(host, "mobile-feed-scene")!;
	const header = find(host, "mobile-feed-header")!;
	const card = findPrefix(host, "mobile-feed-card-")!;
	const indexBadge = find(host, "mobile-feed-index")!;
	expect(header.order > card.order, "dragging card can cover the fixed header");
	scene.emit("TapBegan");
	scene.emit("TapMoved", { delta: Vec2(0, 720) });
	expect(card.position.y > 0, "vertical drag preview did not move the card");
	expect(indexBadge.opacity === 0, "dragging index remained visible inside the fixed header");
	sleep(0.2);
	const dragScreenshot = App.saveScreenshot("/tmp/dora-mobile-feed-drag-layer");
	sleep(0.3);
	Content.save(resultPath, `${screenshot}\n${dragScreenshot}\nvisual=${App.visualSize.width}x${App.visualSize.height} buffer=${App.bufferSize.width}x${App.bufferSize.height} dpr=${App.devicePixelRatio} hostScale=${host.scaleX},${host.scaleY} safe=${App.safeArea.x},${App.safeArea.y},${App.safeArea.width},${App.safeArea.height}\nheaderOrder=${header.order} cardOrder=${card.order} cardY=${card.position.y}`);
});
