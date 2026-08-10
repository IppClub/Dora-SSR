import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const repo = path.resolve("../..");
const read = relative => readFile(path.join(repo, relative), "utf8");

const service = await read("Tools/dora-dora/src/Service.ts");
const webServer = await read("Assets/Script/Dev/WebServer.yue");
const tools = await read("Assets/Script/Lib/Agent/Tools.ts");
const codingAgent = await read("Assets/Script/Lib/Agent/CodingAgent.ts");
const generated = await Promise.all([
	read("Assets/Script/Dev/WebServer.lua"),
	read("Assets/Script/Lib/Agent/Tools.lua"),
	read("Assets/Script/Lib/Agent/CodingAgent.lua"),
]);

const authoritative = [service, webServer, tools, codingAgent];
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

assert.match(tools, /payload\.id !== requestId/);
assert.match(tools, /payload\.name === "TranspileTSProbe"/);
assert.match(tools, /payload\.name !== "TranspileTS"/);
assert.match(tools, /App\.runningTime >= readyDeadline/);
assert.match(tools, /App\.runningTime >= buildDeadline/);
assert.match(tools, /isCancelled\?\.\(\) === true/);
assert.match(tools, /interrupted: true/);
assert.doesNotMatch(tools, /wait\(\(\) => done\);/);

assert.match(codingAgent, /isCancelled: \(\) => shared\.stopToken\.stopped/);
assert.match(codingAgent, /isCancelled: input\.isCancelled/);

console.log("TypeScript transpile protocol tests passed.");
