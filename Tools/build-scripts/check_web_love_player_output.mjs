import fs from "node:fs";
import path from "node:path";

const outputDir = path.resolve(process.argv[2] || "result/love-pthread-player");
const artifacts = ["index.html", "love-pthread-player.html", "love-pthread-player.js",
	"love-pthread-player.wasm", "love-pthread-player.data"];
for (const artifact of artifacts) {
	const file = path.join(outputDir, artifact);
	if (!fs.statSync(file, {throwIfNoEntry: false})?.isFile() || fs.statSync(file).size === 0)
		throw new Error(`missing or empty Love pthread Player artifact: ${file}`);
}

const html = fs.readFileSync(path.join(outputDir, "index.html"), "utf8");
for (const contract of ["package-picker", "recent-projects", "stop-project", ".dora", "doraStop"])
	if (!html.includes(contract)) throw new Error(`Love pthread Player shell is missing ${contract}`);

const glue = fs.readFileSync(path.join(outputDir, "love-pthread-player.js"), "utf8");
for (const contract of ["dora_web_love_player_start", "dora_web_love_player_stop", "inspectLovePackage",
	"installPackage", "crossOriginIsolated", "SharedArrayBuffer", "doraSyncUserStorage", "ENVIRONMENT_IS_PTHREAD"])
	if (!glue.includes(contract)) throw new Error(`Love pthread Player glue is missing ${contract}`);
if (/balatro|love-complex-stage/i.test(glue) || fs.readdirSync(outputDir).some((name) => name.endsWith(".dora")))
	throw new Error("Love pthread Player must not bundle the Balatro acceptance input");

const wasm = fs.readFileSync(path.join(outputDir, "love-pthread-player.wasm"));
if (!WebAssembly.validate(wasm)) throw new Error("Love pthread Player WASM is invalid");

console.log(`[INFO] Love pthread Player output validated: ${outputDir}`);
