import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const appSource = await readFile(path.resolve("src/App.tsx"), "utf8");
const serviceSource = await readFile(path.resolve("src/Service.ts"), "utf8");
const entrySource = await readFile(path.resolve("../../Assets/Script/Dev/Entry.yue"), "utf8");
const serverSource = await readFile(path.resolve("../../Assets/Script/Dev/WebServer.yue"), "utf8");

assert.doesNotMatch(
	appSource,
	/Promise\.all\(\[\s*loadAssets\(\),\s*loadEntries\(\)/,
	"startup should not request the entry list",
);
assert.match(appSource, /void loadEntries\(\);/, "opening the entries panel should load cached entries");
assert.match(appSource, /void loadEntries\(true\)/, "the reload button should force an entry rescan");
assert.match(appSource, /entriesLoadedRef\.current/, "entry loading should be deduplicated after success");
assert.match(
	appSource,
	/if \(!refresh && entryLoadPromiseRef\.current !== null\)/,
	"forced refreshes should not be swallowed by ordinary request deduplication",
);
assert.match(serviceSource, /entryList = \(refresh = false\)/);
assert.match(serviceSource, /post<EntryListResponse>\("\/entry\/list", \{ refresh \}\)/);
assert.match(entrySource, /getLaunchEntries = \(refresh = false\)/);
assert.match(entrySource, /updateEntries! if refresh/);
assert.doesNotMatch(entrySource, /getLaunchEntries = ->\s*\n\s*updateEntries!/);
assert.match(serverSource, /Entry\.getLaunchEntries \(req and req\.body and req\.body\.refresh == true\)/);

console.log("Entry list lazy-load and cache regression tests passed.");
