import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repo = path.resolve("../..");
const read = relative => readFile(path.join(repo, relative), "utf8");

const service = await read("Tools/dora-dora/src/Service.ts");
const webServer = await read("Assets/Script/Dev/WebServer.yue");
const buildTool = await read("Assets/Script/Lib/Agent/Tool/Build.ts");
const toolHandlers = await read("Assets/Script/Lib/Agent/Tool/Handlers.ts");
const doraAgent = await read("Assets/Script/Lib/Agent/DoraAgent.ts");
const generated = await Promise.all([
	read("Assets/Script/Dev/WebServer.lua"),
	read("Assets/Script/Lib/Agent/Tool/Build.lua"),
	read("Assets/Script/Lib/Agent/Tool/Handlers.lua"),
	read("Assets/Script/Lib/Agent/DoraAgent.lua"),
]);

const authoritative = [service, webServer, buildTool, toolHandlers, doraAgent];
for (const source of [...authoritative, ...generated]) {
	assert.ok(!source.includes("TranspileTSProbeV3"), "legacy probe name must be removed");
	assert.ok(!source.includes("TranspileTSReadyV3"), "legacy ready name must be removed");
	assert.ok(!source.includes("TranspileTSV3"), "legacy transpile name must be removed");
}

assert.match(service, /TranspileTSProbe = "TranspileTSProbe"/);
assert.match(service, /case WsEvent\.TranspileTSProbe:[\s\S]*name: WsEvent\.TranspileTSProbe, id: result\.id/);
assert.match(service, /case WsEvent\.TranspileTS:[\s\S]*void handleTranspileTS/);
assert.match(service, /sendTranspileTSResponse\(item, \{ name: WsEvent\.TranspileTS,/);

assert.match(webServer, /res\.name == "TranspileTSProbe" and res\.id == requestId/);
assert.match(webServer, /res\.name == "TranspileTS" and res\.id == requestId/);
assert.match(webServer, /if entry := seen\[targetFile\][\s\S]*entry\.moduleName = moduleName/);
assert.match(webServer, /seen\[targetFile\] = entry/);
assert.match(webServer, /App\.runningTime >= readyDeadline/);
assert.match(webServer, /App\.runningTime >= deadline/);

assert.match(buildTool, /payload\.id !== requestId/);
assert.match(buildTool, /payload\.name === "TranspileTSProbe"/);
assert.match(buildTool, /payload\.name !== "TranspileTS"/);
assert.match(buildTool, /App\.runningTime >= readyDeadline/);
assert.match(buildTool, /App\.runningTime >= buildDeadline/);
assert.match(buildTool, /isCancelled\?\.\(\) === true/);
assert.match(buildTool, /interrupted: true/);
assert.doesNotMatch(buildTool, /wait\(\(\) => done\);/);

assert.match(doraAgent, /isCancelled: \(\) => shared\.stopToken\.stopped/);
assert.match(toolHandlers, /isCancelled: \(\) => context\.cancellation\.isCancelled\(\)/);
assert.match(buildTool, /runSingleTsTranspile\(target, content, req\.workDir, req\.isCancelled\)/);

console.log("TypeScript transpile protocol tests passed.");
