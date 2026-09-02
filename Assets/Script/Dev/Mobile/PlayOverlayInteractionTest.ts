import { Content, Node, Path, sleep, thread } from "Dora";
import { resolvePlayHandleY, startMobilePlayOverlay } from "Dev/Mobile/PlayOverlay";

const resultPath = Path(Content.writablePath, "dora-mobile-play-overlay.result");

function find(node: Node.Type, tag: string): Node.Type | undefined {
	if (node.tag === tag) return node;
	let result: Node.Type | undefined;
	node.eachChild(child => { result = find(child, tag); return result !== undefined; });
	return result;
}

thread(() => {
	let exits = 0;
	const overlay = startMobilePlayOverlay({ onExit: () => { exits++; } });
	const [ok, err] = xpcall(() => {
		if (!find(overlay, "mobile-play-handle") || find(overlay, "mobile-play-exit")) throw new Error("overlay did not start as an edge handle");
		const firstY = resolvePlayHandleY(100, 300, 310, 600);
		const laterY = resolvePlayHandleY(100, 300, 350, 600);
		if (firstY !== 110 || laterY !== 150) throw new Error("dragging does not track the absolute pointer path");
		const handle = find(overlay, "mobile-play-handle") as Node.Type;
		handle.emit("Tapped");
		if (!find(overlay, "mobile-play-exit")) throw new Error("edge handle did not expand");
		sleep(3.2);
		const collapsed = find(overlay, "mobile-play-handle");
		if (!collapsed || find(overlay, "mobile-play-exit")) throw new Error("exit control did not auto-hide");
		collapsed.emit("Tapped");
		const exit = find(overlay, "mobile-play-exit");
		if (!exit) throw new Error("collapsed handle did not expand");
		exit.emit("Tapped");
		if (exits !== 1 || overlay.parent !== undefined) throw new Error("expanded exit control did not exit once");
	}, debug.traceback);
	overlay.removeFromParent(true);
	Content.save(resultPath, ok ? "passed handle=1 absoluteDrag=1 expanded=1 autoHidden=1 reopened=1 exit=1\n" : `failed: ${err}`);
});
