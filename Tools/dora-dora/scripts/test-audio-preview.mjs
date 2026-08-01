import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";

const appSource = await readFile(path.resolve("src/App.tsx"), "utf8");
const cardSource = await readFile(path.resolve("src/AudioPreviewCard.tsx"), "utf8");
const treeSource = await readFile(path.resolve("src/FileTree.tsx"), "utf8");

assert.match(appSource, /const audioFileExts = new Set\(\["\.wav", "\.ogg", "\.mp3"\]\)/);
assert.match(appSource, /if \(!folder && isAudioFile\(key\)\)[\s\S]*openAudioPreview\(key, title\)[\s\S]*return/);
assert.match(appSource, /if \(!exists && isChildFolder\(current\.file, file\)\) return null/);
assert.match(appSource, /if \(exists && path\.relative\(current\.file, file\) === ""\)[\s\S]*version: current\.version \+ 1/);
assert.match(appSource, /<AudioPreviewCard[\s\S]*playRequest=\{audioPreview\.playRequest\}/);
assert.match(appSource, /moveAudioPreviewPath\(oldFile, newFile\)/);
assert.match(appSource, /closeAudioPreviewPath\(data\.key\)/);

assert.match(cardSource, /<audio[\s\S]*preload="metadata"/);
assert.match(cardSource, /const sourceChanged = lastSrcRef\.current !== src[\s\S]*audio\.load\(\);[\s\S]*play\(\);/);
assert.match(cardSource, /else if \(playRequested && audio\.paused\)[\s\S]*else if \(playRequested\)[\s\S]*audio\.pause\(\)/);
const playHandler = cardSource.match(/const play = useCallback\(\(\) => \{([\s\S]*?)\n\t\}, \[\]\);/)?.[1] ?? "";
assert.doesNotMatch(playHandler, /setFailed/, "a rejected play request must not be reported as a media load failure");
assert.match(cardSource, /document\.addEventListener\("visibilitychange", pauseWhenHidden\)/);
assert.match(cardSource, /audio\.removeAttribute\("src"\)/);
assert.match(cardSource, /type="range"[\s\S]*audioRef\.current\.currentTime = next/);
assert.match(cardSource, /onError=\{\(\) =>/);

for (const extension of [".wav", ".ogg", ".mp3"]) {
	assert.match(treeSource, new RegExp(`case "\\${extension}"`));
}
assert.match(treeSource, /return <TbMusic/);

console.log("Audio preview integration tests passed.");
