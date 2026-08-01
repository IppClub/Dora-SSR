import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { spawnSync } from "node:child_process";

const toolsDir = process.cwd();
const repoDir = path.resolve(toolsDir, "../..");
const readRepoFile = (file) => readFile(path.join(repoDir, file), "utf8");

const header = await readRepoFile("Source/Http/XrtNetwork.h");
const implementation = await readRepoFile("Source/Http/XrtNetwork.c");
const httpServer = await readRepoFile("Source/Http/HttpServer.cpp");

assert.match(httpServer, /#include "Http\/XrtNetwork\.h"/);
assert.doesNotMatch(httpServer, /#include [<"]xrt\/xrt\.h[>"]/);
assert.doesNotMatch(httpServer, /\b(?:xhttpd|xws|xnetengine|xnet_result|xrtNet|xrtHttpd|xrtWs)/);

assert.doesNotMatch(header, /#include [<"]xrt\/xrt\.h[>"]/);
assert.doesNotMatch(header, /\b(?:xhttpd|xws|xnetengine|xnet_result|xrtNet|xrtHttpd|xrtWs)/);
assert.match(header, /typedef struct DoraXrtHttpServer DoraXrtHttpServer;/);
assert.match(header, /typedef struct DoraXrtWebSocketServer DoraXrtWebSocketServer;/);
assert.match(implementation, /#define XRT_IMPLEMENTATION/);
assert.match(implementation, /#include "xrt\/xrt\.h"/);

const projectFiles = [
	"Projects/Linux/CMakeLists.txt",
	"Projects/Android/Dora/app/CMakeLists.txt",
	"Projects/Windows/Dora/Dora.vcxproj",
	"Projects/Windows/Dora/Dora.vcxproj.filters",
	"Projects/macOS/Dora.xcodeproj/project.pbxproj",
	"Projects/iOS/Dora.xcodeproj/project.pbxproj",
];
for (const projectFile of projectFiles) {
	const source = await readRepoFile(projectFile);
	assert.match(source, /XrtNetwork\.(?:c|h)/, `${projectFile} must include the renamed wrapper`);
	assert.doesNotMatch(source, /XrtHttpClient\.(?:c|h)/, `${projectFile} still references the old wrapper name`);
}

const compile = (command, args, options = {}) => {
	const result = spawnSync(command, args, {
		cwd: repoDir,
		encoding: "utf8",
		...options,
	});
	assert.equal(
		result.status,
		0,
		`${command} ${args.join(" ")} failed:\n${result.stdout}${result.stderr}`,
	);
};

compile("clang", [
	"-std=c11",
	"-fsyntax-only",
	"-ISource",
	"-ISource/3rdParty",
	"Source/Http/XrtNetwork.c",
]);

compile("clang++", [
	"-std=c++20",
	"-fsyntax-only",
	"-ISource",
	"-x",
	"c++",
	"-",
], {
	input: `
#include <stdint.h>
typedef uint64_t u64;
typedef int64_t i64;
#include "Http/XrtNetwork.h"

int main() {
	DoraXrtHttpServer* httpServer = nullptr;
	DoraXrtWebSocketServer* webSocketServer = nullptr;
	return httpServer == nullptr && webSocketServer == nullptr ? 0 : 1;
}
`,
});

console.log("XRT network wrapper isolation tests passed.");
