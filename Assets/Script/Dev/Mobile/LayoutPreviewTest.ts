import { App, Content, Director, Node, Size, sleep, thread } from "Dora";
import { startMobileFeed } from "Dev/Mobile/Feed";

const entries = [
	{ id: "wide-orbit", title: "轨道花园", description: "横屏与平板布局验证作品。", kind: "discover" as const },
	{ id: "wide-runner", title: "霓虹跑者", description: "验证三卡窗口和宽屏信息区。", kind: "discover" as const },
	{ id: "wide-puzzle", title: "像素谜城", description: "验证下一张预加载边界。", kind: "discover" as const },
];

const englishEntries = [
	{ id: "wide-orbit", title: "Orbital Garden", description: "A mobile layout preview with a deliberately longer English description.", kind: "discover" as const },
	{ id: "wide-runner", title: "Neon Runner", description: "Checks the wide information panel and reusable card window.", kind: "discover" as const },
	{ id: "wide-puzzle", title: "Pixel Maze", description: "Checks the preload boundary for the next card.", kind: "discover" as const },
];

thread(() => {
	let previousFeed: Node.Type | undefined;
	const originalLocale = App.locale;
	let previewEntries = entries;
	Director.systemUI.eachChild(child => {
		if (child.tag === "mobile-feed" && child.visible) { previousFeed = child; child.visible = false; }
		return false;
	});
	App.winSize = Size(844, 390);
	sleep(0.5);
	const host = startMobileFeed({
		getDiscoverEntries: () => previewEntries,
		getLocalEntries: () => [],
		onPlay: () => undefined,
		onRemix: () => undefined,
		prepare: (_entry, _repairIncomplete, _onProgress, onDone) => onDone(false, undefined, "preview only"),
	});
	sleep(0.8);
	const landscape = App.saveScreenshot("/tmp/dora-mobile-feed-landscape");
	App.winSize = Size(640, 480);
	sleep(0.8);
	const compactLandscape = App.saveScreenshot("/tmp/dora-mobile-feed-640x480");
	App.winSize = Size(1024, 768);
	sleep(0.8);
	const tablet = App.saveScreenshot("/tmp/dora-mobile-feed-tablet");
	App.winSize = Size(390, 640);
	sleep(0.8);
	const shortPortrait = App.saveScreenshot("/tmp/dora-mobile-feed-short");
	previewEntries = englishEntries;
	App.locale = "en";
	App.winSize = Size(640, 480);
	sleep(1.5);
	const english = App.saveScreenshot("/tmp/dora-mobile-feed-640x480-en");
	sleep(0.3);
	Content.save("/tmp/dora-mobile-layout-preview.result", `passed\nlandscape=${landscape}\ncompactLandscape=${compactLandscape}\ntablet=${tablet}\nshort=${shortPortrait}\nenglish=${english}\nhostScale=${host.scaleX},${host.scaleY}`);
	host.removeFromParent(true);
	App.locale = originalLocale;
	if (previousFeed?.parent) previousFeed.visible = true;
});
