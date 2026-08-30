import { Content } from "Dora";
import {
	getReusableCardIndices,
	getCoverScales,
	normalizeFeedIndex,
	resolveDiscoverRefreshTab,
	resolveFeedGesture,
	resolveFeedLocation,
	stableCoverColor,
} from "Dev/Mobile/FeedModel";

const resultPath = "/tmp/dora-mobile-feed-model.result";

const expect = (condition: boolean, message: string) => {
	if (!condition) throw new Error(message);
};

try {
	expect(normalizeFeedIndex(-4, 5) === 0, "negative index should clamp to zero");
	expect(normalizeFeedIndex(8, 5) === 4, "large index should clamp to the last card");
	expect(normalizeFeedIndex(2.8, 5) === 2, "fractional index should be floored");
	expect(getReusableCardIndices(0, 8).join(",") === "0,1", "first card pool mismatch");
	expect(getReusableCardIndices(4, 8).join(",") === "3,4,5", "middle card pool mismatch");
	expect(getReusableCardIndices(7, 8).join(",") === "6,7", "last card pool mismatch");
	expect(getReusableCardIndices(50, 100).join(",") === "49,50,51", "long-list pool must stay capped at three cards");
	for (let i = 0; i < 10000; i++) {
		const pool = getReusableCardIndices(i % 1000, 1000);
		expect(pool.length <= 3, "rapid long-list paging exceeded the three-card window");
	}
	expect(resolveFeedGesture(220, 10, 400, 800) === "remix", "right swipe should open Remix");
	expect(resolveFeedGesture(-220, 10, 400, 800) === "play", "left swipe should start Play");
	expect(resolveFeedGesture(4, 160, 400, 800) === "next", "vertical swipe should advance");
	expect(resolveFeedGesture(220, 10, 400, 800, true) === "none", "captured control should suppress gestures");
	expect(stableCoverColor("same-id") === stableCoverColor("same-id"), "cover color should be stable");
	expect(resolveDiscoverRefreshTab("local", false, 0, 1) === "discover", "first Catalog result should open Discover");
	expect(resolveDiscoverRefreshTab("local", true, 0, 1) === "local", "user-selected Local tab must be preserved");
	expect(resolveDiscoverRefreshTab("discover", true, 1, 2) === "discover", "Discover refresh must preserve active tab");
	expect(resolveDiscoverRefreshTab("local", false, 0, 0) === "local", "empty Catalog refresh must not switch tabs");
	expect(resolveDiscoverRefreshTab("local", false, 0, 2, 3) === "local", "Catalog sync stole Local with existing projects");
	const locals = ["A", "B", "C"].map(id => ({ id, title: id, description: "", kind: "local" as const, fileName: `${id}/init`, workDir: id }));
	const discover = [{ ...locals[1], id: "catalog-B", kind: "discover" as const }];
	expect(resolveFeedLocation(locals, discover).tab === "local", "Local must be the default");
	expect(resolveFeedLocation([], discover).tab === "discover", "Empty Local must show Discover");
	expect(resolveFeedLocation([locals[2], locals[0], locals[1]], discover, locals[1]).index === 2, "Return must follow reordered project");
	expect(resolveFeedLocation(locals, discover, discover[0]).tab === "discover", "Return should retain origin tab");
	expect(resolveFeedLocation(locals, [], discover[0]).index === 1, "Installed Catalog project should match local path");
	expect(resolveFeedLocation([{ ...locals[1], id: "renamed" }], [], locals[1]).index === 0, "Rename must retain project identity");
	const landscapeScales = getCoverScales(1920, 1080, 390, 390);
	expect(math.abs(landscapeScales.contain - 390 / 1920) < 0.0001, "landscape cover contain scale mismatch");
	expect(math.abs(landscapeScales.cover - 390 / 1080) < 0.0001, "landscape cover fill scale mismatch");
	const portraitScales = getCoverScales(600, 900, 400, 240);
	expect(math.abs(portraitScales.contain - 240 / 900) < 0.0001, "portrait cover contain scale mismatch");
	expect(math.abs(portraitScales.cover - 400 / 600) < 0.0001, "portrait cover fill scale mismatch");
	Content.save(resultPath, "passed");
} catch (error) {
	Content.save(resultPath, `failed: ${error}`);
}
