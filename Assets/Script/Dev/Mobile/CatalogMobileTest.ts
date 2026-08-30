import { Content } from "Dora";
import type { ResourceInfo } from "Tools/ResourceDownloader/Catalog";
import { getMobileFeedResources } from "Tools/ResourceDownloader/Catalog";

const resultPath = "/tmp/dora-mobile-catalog-model.result";
const makeResource = (id: string, tags: string[], mobileOrder?: number): ResourceInfo => ({
	schemaVersion: 1,
	id,
	status: "active",
	title: { "zh-Hans": id, en: id },
	description: { "zh-Hans": id, en: id },
	categories: ["Game"],
	tags,
	license: { status: "pending" },
	runnable: true,
	entrypoints: [{ name: "main", path: "init" }],
	versions: [{ name: "latest", publishedAt: "2026-08-29", sources: [] }],
	projectPath: id,
	selectedVersion: 1,
	mobileOrder,
});
const expect = (condition: boolean, message: string) => { if (!condition) throw new Error(message); };

try {
	const tagged = getMobileFeedResources([
		makeResource("desktop", []),
		makeResource("mobile-b", ["mobile-feed"], 20),
		makeResource("mobile-a", ["mobile-feed"], 10),
	]);
	expect(tagged.length === 2, "tagged mobile resources must exclude untagged fallback entries");
	expect(tagged[0].id === "mobile-a" && tagged[1].id === "mobile-b", "tagged mobile ordering mismatch");

	const fallback = getMobileFeedResources([makeResource("dora-demo", []), makeResource("z-game", [])]);
	expect(fallback.length === 2, "runnable Catalog fallback is missing");
	expect(fallback[0].id === "dora-demo" && fallback[1].id === "z-game", "fallback ordering mismatch");
	const unavailable = makeResource("unavailable", []);
	unavailable.status = "unavailable";
	const noEntry = makeResource("no-entry", []);
	noEntry.entrypoints = [];
	expect(getMobileFeedResources([unavailable, noEntry]).length === 0, "fallback must reject unavailable or entryless resources");
	Content.save(resultPath, "passed");
} catch (error) {
	Content.save(resultPath, `failed: ${error}`);
}
