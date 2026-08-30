import { App, Content, Size, sleep, thread } from "Dora";
import { startMobileRemix } from "Dev/Mobile/Remix";

const resultPath = "/tmp/dora-mobile-remix-preview.result";

App.winSize = Size(390, 844);
thread(() => {
	sleep(0.4);
	const host = startMobileRemix({
		entry: {
			id: "mobile-remix-preview",
			title: "轨道花园",
			workDir: Content.assetPath,
			fileName: "Script/Dev/Mobile/FeedPreviewTest",
		},
		onBack: () => undefined,
		onPlay: () => undefined,
	});
	sleep(0.8);
	const screenshot = App.saveScreenshot("/tmp/dora-mobile-remix-preview");
	sleep(0.3);
	Content.save(resultPath, `${screenshot}\nvisual=${App.visualSize.width}x${App.visualSize.height} dpr=${App.devicePixelRatio} hostScale=${host.scaleX},${host.scaleY}`);
});
