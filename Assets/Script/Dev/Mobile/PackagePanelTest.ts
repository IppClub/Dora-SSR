import { App, Content, Director, Label, Node, Path, sleep, thread } from "Dora";
import { startPackagePanel } from "Dev/Mobile/PackagePanel";

// Verify the async export cannot replace or resize an already visible sheet.
thread(() => {
	const marker = Path(Content.appPath, "mobile-package-panel-test.result");
	const root = Path(Content.writablePath, `.package-panel-test-${App.rand}`);
	let host: Node.Type | undefined;
	Content.save(marker, "running");
	try {
		assert(Content.mkdir(root));
		Content.save(Path(root, "init.lua"), "return true");
		host = startPackagePanel({ mode: "share", entry: { title: "Panel test", workDir: root }, onClosed: () => {} });
		const sheet = () => {
			let found: Node.Type | undefined;
			host!.traverse(node => { if (node.tag === "mobile-package-sheet") found = node; return false; });
			return found!;
		};
		const sceneChildren = Director.entry.children?.count ?? 0;
		const initial = sheet();
		assert(initial);
		const height = initial.height;
		let ready = false;
		for (let frame = 0; frame < 180; frame++) {
			sleep();
			assert((Director.entry.children?.count ?? 0) === sceneChildren, "measurement labels leaked into the scene");
			assert(sheet() === initial, "export replaced the visible sheet");
			assert(sheet().height === height, "export changed the sheet height");
			host.traverse(node => {
				const text = node.tag === "mobile-package-detail" ? (node as Label.Type).text : undefined;
				if (typeof text === "string" && text.indexOf(" MB") >= 0) ready = true;
				return false;
			});
			if (ready && frame >= 30) break;
		}
		assert(ready, "export never completed");
		host.removeFromParent(true);
		host = undefined;
		sleep();
		assert((Director.entry.children?.count ?? 0) === sceneChildren, "closing the sheet left scene nodes behind");
		Content.save(marker, "passed: stable sheet and no measurement nodes during export or after close");
	} catch (e) { Content.save(marker, `failed: ${tostring(e)}`); }
	finally { host?.removeFromParent(true); Content.remove(root); }
});
