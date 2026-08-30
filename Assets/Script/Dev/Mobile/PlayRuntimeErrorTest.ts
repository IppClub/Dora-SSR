import { Content, Director, Node, Path, sleep, thread } from "Dora";
import { startMobilePlayOverlay } from "Dev/Mobile/PlayOverlay";

const resultPath = Path(Content.writablePath, "dora-mobile-play-runtime-error.result");
let exitCount = 0;
let errorCount = 0;
let errorMessage = "";

thread(() => {
	const overlay = startMobilePlayOverlay({
		onExit: () => { exitCount++; },
		onRuntimeError: message => {
			errorCount++;
			errorMessage = message;
		},
	});
	const crashingNode = Node().addTo(Director.ui);
	crashingNode.schedule(() => {
		throw new Error("mobile runtime failure injection");
	});
	sleep(0.8);

	if (errorCount !== 1) throw new Error(`runtime error callback count mismatch: ${errorCount}`);
	if (exitCount !== 0) throw new Error("runtime failure incorrectly used the normal exit callback");
	if (errorMessage.indexOf("mobile runtime failure injection") < 0) throw new Error("runtime traceback was not forwarded");
	if (overlay.parent !== undefined) throw new Error("play overlay was not removed after runtime failure");
	Content.save(resultPath, "passed runtimeError=1 overlayRemoved=1\n");
	crashingNode.removeFromParent(true);
});
