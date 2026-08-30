import { Content, Path, sleep, thread } from "Dora";
import type { ResourceInfo } from "Tools/ResourceDownloader/Catalog";
import { isMobileResourceReady, prepareMobileResource } from "Dev/Mobile/Lifecycle";

const resultPath = "/tmp/dora-mobile-catalog-install-integration.result";
const testWritablePath = "/tmp/dora-mobile-catalog-install-integration";
const originalWritablePath = Content.writablePath;
const resource: ResourceInfo = {
	schemaVersion: 1,
	id: "dora-demo-mobile-integration",
	status: "active",
	title: { "zh-Hans": "Dora 演示", en: "Dora Demo" },
	description: { "zh-Hans": "真实 Catalog 安装集成测试", en: "Real Catalog installation integration test" },
	categories: ["Dora"],
	tags: ["mobile-feed"],
	license: { status: "pending" },
	runnable: true,
	entrypoints: [{ name: "AI Fighter", path: "AI Fighter/init" }],
	versions: [{
		name: "latest",
		publishedAt: "2026-07-27T00:00:00.000Z",
		sources: [{ role: "upstream", url: "https://gitcode.com/ippclub/dora-demo" }],
	}],
	projectPath: "dora-demo",
	selectedVersion: 1,
};

thread(() => {
	Content.save(resultPath, "running");
	try {
		if (Content.exist(testWritablePath)) Content.remove(testWritablePath);
		Content.mkdir(testWritablePath);
		Content.writablePath = testWritablePath;
		let completed = false;
		let progressEvents = 0;
		let failure = "";
		prepareMobileResource(resource, "live-catalog-integration", () => { progressEvents++; }, result => {
			if (!result.success || !result.entry) failure = result.message ?? "installation failed";
			else if (!isMobileResourceReady(resource)) failure = "installed Catalog resource is not ready";
			else if (!Content.exist(Path(result.entry.workDir, ".dora", "resource-state.json"))) failure = "resource state metadata is missing";
			completed = true;
		});
		for (let i = 0; i < 3600 && !completed; i++) sleep(0.05);
		if (!completed) throw new Error("real Catalog installation timed out");
		if (failure !== "") throw new Error(failure);
		if (progressEvents < 3) throw new Error("installation progress did not report enough stages");
		Content.save(resultPath, `passed: source=gitcode progressEvents=${progressEvents}`);
	} catch (error) {
		Content.save(resultPath, `failed: ${error}`);
	}
	Content.writablePath = originalWritablePath;
	if (Content.exist(testWritablePath)) Content.remove(testWritablePath);
});
