import { App, Content, Director, Node, Path, Vec2, sleep, thread } from "Dora";

const resultPath = Path(Content.writablePath, "dora-mobile-system-ui-coordinate.result");
Content.save(resultPath, "running\n");
thread(() => {
	const ui = Node().addTo(Director.ui);
	const system = Node().addTo(Director.systemUI);
	const point = Vec2(20, -App.bufferSize.height * 0.3);
	let uiPoint: { x: number; y: number } | undefined;
	let systemPoint: { x: number; y: number } | undefined;
	ui.convertToWindowSpace(point, pos => { uiPoint = { x: pos.x, y: pos.y }; });
	system.convertToWindowSpace(point, pos => { systemPoint = { x: pos.x, y: pos.y }; });
	sleep(0.3);
	ui.removeFromParent(true);
	system.removeFromParent(true);
	const expectedX = App.winSize.width * (0.5 + 20 / App.bufferSize.width);
	const expectedY = App.winSize.height * 0.8;
	if (!uiPoint || !systemPoint || math.abs(uiPoint.x - systemPoint.x) > 1 || math.abs(uiPoint.y - systemPoint.y) > 1
		|| math.abs(systemPoint.x - expectedX) > 1 || math.abs(systemPoint.y - expectedY) > 1) {
		Content.save(resultPath, `failed UI y=${uiPoint?.y} SystemUI y=${systemPoint?.y}\n`);
		throw new Error("UI/SystemUI window coordinates differ");
	}
	Content.save(resultPath, `passed x=${systemPoint.x} y=${systemPoint.y}\n`);
});
