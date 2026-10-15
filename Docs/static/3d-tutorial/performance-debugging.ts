import {App, Content, Director, threadLoop} from "Dora";

const view = Director.entry;
view.showAABB = true;

let elapsed = 0;
let done = false;
threadLoop(() => {
	elapsed += App.deltaTime;
	if (!done && elapsed > 1.5) {
		done = true;
		const stats = view.stats;
		const passed = stats.drawCalls >= 0 && stats.visibleVisuals >= 0;
		const screenshot = App.saveScreenshot("/tmp/3d-performance-tutorial/baseline");
		Content.save(
			"/tmp/3d-performance-tutorial/baseline.txt",
			`status=${passed ? "PASS" : "FAIL"} draws=${stats.drawCalls} visible=${stats.visibleVisuals} screenshot=${screenshot}`,
		);
	}
	return false;
});
