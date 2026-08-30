import { Content, Path, sleep, thread } from "Dora";
import type { ResourceInfo } from "Tools/ResourceDownloader/Catalog";
import { isMobileResourceReady, prepareMobileResource, resolveMobileLaunchEntry } from "Dev/Mobile/Lifecycle";

const originalWritablePath = Content.writablePath;
const testWritablePath = "/tmp/dora-mobile-lifecycle-test";
const makeResource = (id: string, versions: ResourceInfo["versions"]): ResourceInfo => ({
	schemaVersion: 1,
	id,
	status: "active",
	title: { "zh-Hans": "已安装作品", en: "Installed Game" },
	description: { "zh-Hans": "测试", en: "Test" },
	categories: ["game"],
	tags: ["mobile-feed"],
	license: { status: "confirmed", spdx: "MIT" },
	runnable: true,
	entrypoints: [{ name: "main", path: "init.lua" }],
	versions,
	projectPath: id,
	selectedVersion: 1,
});
const resource = makeResource("installed-game", [{ name: "test", publishedAt: "2026-08-29", sources: [] }]);
const moduleResource = makeResource("module-game", [{ name: "test", publishedAt: "2026-08-29", sources: [] }]);
moduleResource.entrypoints[0].path = "Game/init";
const unavailableResource = makeResource("unavailable-game", []);
const incompleteResource = makeResource("incomplete-game", [{ name: "test", publishedAt: "2026-08-29", sources: [] }]);

thread(() => {
	Content.save("/tmp/dora-mobile-lifecycle.result", "running");
	try {
		if (Content.exist(testWritablePath)) Content.remove(testWritablePath);
		Content.mkdir(testWritablePath);
		Content.writablePath = testWritablePath;
		const downloadPath = Path(testWritablePath, "Download");
		const installPath = Path(downloadPath, resource.id);
		Content.mkdir(downloadPath);
		Content.mkdir(installPath);
		Content.save(Path(installPath, "init.lua"), "return function() end\n");
		if (!isMobileResourceReady(resource)) throw new Error("installed resource readiness mismatch");
		let completed = false;
		prepareMobileResource(resource, "test-commit", () => undefined, result => {
			if (!result.success || !result.entry) throw new Error(result.message ?? "installed resource was not resolved");
			if (result.entry.workDir !== installPath) throw new Error("installed workDir mismatch");
			if (result.entry.fileName !== Path(installPath, "init")) throw new Error("installed entrypoint mismatch");
			completed = true;
		});
		if (!completed) throw new Error("installed callback did not complete synchronously");

		const modulePath = Path(downloadPath, moduleResource.id);
		Content.mkdir(modulePath);
		Content.mkdir(Path(modulePath, "Game"));
		Content.save(Path(modulePath, "Game", "init.lua"), "return function() end\n");
		if (!isMobileResourceReady(moduleResource)) throw new Error("extensionless module entrypoint was not resolved");
		let moduleCompleted = false;
		prepareMobileResource(moduleResource, "test-commit", () => undefined, result => {
			if (!result.success || result.entry?.fileName !== Path(modulePath, "Game", "init")) {
				throw new Error("extensionless installed entrypoint mismatch");
			}
			moduleCompleted = true;
		});
		if (!moduleCompleted) throw new Error("extensionless module callback did not complete synchronously");
		const launchEntry = resolveMobileLaunchEntry({ fileName: Path(modulePath, "Game", "init"), workDir: modulePath });
		if (launchEntry.fileName !== Path(modulePath, "Game", "init") || launchEntry.workDir !== Path(modulePath, "Game")) {
			throw new Error("play launch workDir must resolve from the selected entrypoint");
		}

		let unavailableCompleted = false;
		prepareMobileResource(unavailableResource, "test-commit", () => undefined, result => {
			if (result.success || result.message !== "resource version is unavailable") throw new Error("unavailable version mismatch");
			unavailableCompleted = true;
		});
		if (!unavailableCompleted) throw new Error("unavailable callback did not complete synchronously");

		const incompletePath = Path(downloadPath, incompleteResource.id);
		Content.mkdir(incompletePath);
		Content.save(Path(incompletePath, "user-note.txt"), "preserve me\n");
		if (isMobileResourceReady(incompleteResource)) throw new Error("incomplete resource must not be ready");
		let repairPrompted = false;
		prepareMobileResource(incompleteResource, "test-commit", () => undefined, result => {
			if (result.success || !result.repairable) throw new Error("incomplete resource must request repair confirmation");
			repairPrompted = true;
		});
		if (!repairPrompted) throw new Error("repair prompt did not complete synchronously");

		let repairCompleted = false;
		prepareMobileResource(incompleteResource, "test-commit", () => undefined, result => {
			if (result.success || string.match(result.message ?? "", "previous installation restored")[0] === undefined) {
				throw new Error(`repair rollback mismatch: ${result.message}`);
			}
			repairCompleted = true;
		}, true);
		for (let i = 0; i < 100 && !repairCompleted; i++) sleep(0.01);
		if (!repairCompleted) throw new Error("repair callback timed out");
		if (!Content.exist(Path(incompletePath, "user-note.txt"))) throw new Error("failed repair did not restore user data");
		Content.save("/tmp/dora-mobile-lifecycle.result", "passed");
	} catch (error) {
		Content.save("/tmp/dora-mobile-lifecycle.result", `failed: ${error}`);
	}
	Content.writablePath = originalWritablePath;
});
