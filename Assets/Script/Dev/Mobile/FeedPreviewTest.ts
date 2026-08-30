import { App, Content, Size, sleep, thread } from "Dora";
import { startMobileFeed } from "Dev/Mobile/Feed";

const resultPath = "/tmp/dora-mobile-feed-preview.result";

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
	prepare: (_entry, _repairIncomplete, _onProgress, onDone) => onDone(false, undefined, "preview only"),
	});
	sleep(0.8);
	const screenshot = App.saveScreenshot("/tmp/dora-mobile-feed-preview");
	sleep(0.3);
	Content.save(resultPath, `${screenshot}\nvisual=${App.visualSize.width}x${App.visualSize.height} buffer=${App.bufferSize.width}x${App.bufferSize.height} dpr=${App.devicePixelRatio} hostScale=${host.scaleX},${host.scaleY} safe=${App.safeArea.x},${App.safeArea.y},${App.safeArea.width},${App.safeArea.height}`);
});
