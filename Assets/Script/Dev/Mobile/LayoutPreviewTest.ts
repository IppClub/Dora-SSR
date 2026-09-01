import { App, Content, Size, sleep, thread } from "Dora";
import { startMobileFeed } from "Dev/Mobile/Feed";

const entries = [
	{ id: "wide-orbit", title: "轨道花园", description: "横屏与平板布局验证作品。", kind: "discover" as const },
	{ id: "wide-runner", title: "霓虹跑者", description: "验证三卡窗口和宽屏信息区。", kind: "discover" as const },
	{ id: "wide-puzzle", title: "像素谜城", description: "验证下一张预加载边界。", kind: "discover" as const },
];

thread(() => {
	App.winSize = Size(844, 390);
	sleep(0.5);
	const host = startMobileFeed({
		getDiscoverEntries: () => entries,
		getLocalEntries: () => [],
		onPlay: () => undefined,
		onRemix: () => undefined,
		prepare: (_entry, _repairIncomplete, _onProgress, onDone) => onDone(false, undefined, "preview only"),
	});
	sleep(0.8);
	const landscape = App.saveScreenshot("/tmp/dora-mobile-feed-landscape");
	App.winSize = Size(1024, 768);
	sleep(0.8);
	const tablet = App.saveScreenshot("/tmp/dora-mobile-feed-tablet");
	App.winSize = Size(390, 640);
	sleep(0.8);
	const shortPortrait = App.saveScreenshot("/tmp/dora-mobile-feed-short");
	sleep(0.3);
	Content.save("/tmp/dora-mobile-layout-preview.result", `passed\nlandscape=${landscape}\ntablet=${tablet}\nshort=${shortPortrait}\nhostScale=${host.scaleX},${host.scaleY}`);
});
