import assert from "node:assert/strict";
import fs from "node:fs";

const matrix = JSON.parse(fs.readFileSync("Projects/Web/love-capabilities.json", "utf8"));
assert.equal(matrix.format, "dora-web-love-capabilities");
assert.equal(matrix.version, 1);
assert.equal(matrix.loveVersion, "11.5");
assert.equal(matrix.available, false, "Love Web must remain unavailable until runtime fixtures pass");
assert.equal(matrix.profile, "web-player-full");
assert.equal(matrix.profiles["web-player-full"].available, false);
assert.equal(matrix.profiles["love-pthread-player"].available, true);
assert.equal(matrix.profiles["love-pthread-player"].threads, true);
assert.deepEqual(matrix.profiles["love-pthread-player"].requires,
	["Cross-Origin-Opener-Policy: same-origin", "Cross-Origin-Embedder-Policy: require-corp"]);
assert.equal(matrix.validation.runtimeObjectCompile, "passed");
assert.equal(matrix.validation.runtimeLink, "passed");
assert.equal(matrix.validation.browserFixture, "passed");
assert.equal(matrix.validation.nonBlockingLoad, "passed");
assert.equal(matrix.validation.graphicsFixture, "passed");
assert.equal(matrix.validation.shaderFixture, "passed");
assert.equal(matrix.validation.shaderFailureFixture, "passed");
assert.equal(matrix.validation.audioLifecycleFixture, "passed");
assert.equal(matrix.validation.complexProjectInput, "passed");
assert.equal(matrix.validation.lovePthreadPlayerBuild, "passed");
assert.equal(matrix.validation.lovePthreadPlayerBrowserFixture, "passed");
assert.equal(matrix.validation.releaseProfile, "excluded");
assert.equal(matrix.execution.startup, "incremental-instruction-budget-with-explicit-yield");
assert.equal(matrix.execution.nativeLoveWindow, false);
assert.equal(matrix.execution.nativeLoveMainLoop, false);

const expectedModules = ["graphics", "image", "font", "sound", "math", "data", "window", "event", "filesystem", "keyboard", "mouse", "touch", "joystick", "timer", "audio", "video", "system", "thread", "physics"];
assert.deepEqual(Object.keys(matrix.modules).sort(), expectedModules.sort(), "Love Web module matrix is incomplete");
const allowedStatuses = new Set(["candidate", "limited", "deferred", "unsupported"]);
for (const [name, capability] of Object.entries(matrix.modules)) {
	assert.ok(allowedStatuses.has(capability.status), `invalid Love Web status: ${name}`);
	assert.match(capability.milestone, /P\d/, `Love Web milestone is missing: ${name}`);
	assert.ok(Array.isArray(capability.requires) && capability.requires.length > 0, `Love Web requirements are missing: ${name}`);
	if (capability.status === "deferred" || capability.status === "unsupported") assert.ok(capability.reason, `Love Web deferral reason is missing: ${name}`);
}
assert.equal(matrix.modules.thread.status, "unsupported");
assert.equal(matrix.modules.video.status, "deferred");
assert.equal(matrix.graphicsGroups.shaderTranslation.status, "passed");
assert.equal(matrix.graphicsGroups.shaderTranslation.milestone, "P5-05/P5-06");
assert.equal(matrix.graphicsGroups.shaderTranslation.failurePolicy.defaultAction, "explicit-error");
assert.equal(matrix.graphicsGroups.shaderTranslation.failurePolicy.silentFallback, false);
assert.equal(matrix.graphicsGroups.shaderTranslation.failurePolicy.optionalFallback.available, false);
assert.equal(matrix.graphicsGroups.shaderTranslation.failurePolicy.optionalFallback.packageDeclarationRequired, true);
assert.equal(matrix.graphicsGroups.canvasMeshSpriteBatchParticleSystem.status, "passed");
assert.equal(matrix.acceptance.lifecycleSoak.status, "passed");
assert.equal(matrix.acceptance.lifecycleSoak.milestone, "P5-07");
assert.equal(matrix.acceptance.complexProject.status, "input-locked");
assert.equal(matrix.acceptance.complexProject.milestone, "P5-08");
assert.equal(matrix.acceptance.complexProject.runtimeValidation, "P5-09");
assert.deepEqual(matrix.acceptance.formalPlayer,
	{status: "passed", milestone: "P5-10", artifact: "love-pthread-player", bundlesProject: false});
assert.deepEqual(matrix.acceptance.browserMatrix, ["Chrome", "Edge", "Firefox", "Safari"]);

const complexProject = JSON.parse(fs.readFileSync("Projects/Web/love-complex-project.json", "utf8"));
assert.equal(complexProject.format, "dora-web-love-complex-package");
assert.equal(complexProject.version, 2);
assert.equal(complexProject.milestone, "P5-08");
assert.equal(complexProject.project.edition, complexProject.expected.gameVersion);
assert.equal(complexProject.project.sourceOrigin, "not-recorded");
assert.equal(complexProject.runtime.entry, "main.lua");
assert.equal(complexProject.runtime.backend, "love");
assert.equal(complexProject.runtime.usesDoraExtensions, false);
assert.equal(complexProject.runtime.distribution, "local-only-not-bundled");
assert.equal(complexProject.modifications.sourceChanged, true);
assert.equal(complexProject.modifications.vanillaCompatibilityClaim, false);
assert.equal(complexProject.acceptancePlan.milestone, "P5-09");
assert.ok(complexProject.acceptancePlan.minimumRunSeconds >= 1800);
assert.ok(complexProject.acceptancePlan.flows.length >= 7);
assert.match(complexProject.expected.archiveSha256, /^[0-9a-f]{64}$/);
assert.ok(complexProject.expected.archiveBytes > 0);
assert.ok(complexProject.expected.entryCount > 0);
const complexInputChecker = fs.readFileSync("Tools/build-scripts/check_web_love_complex_input.mjs", "utf8");
for (const evidence of ["archiveSha256", "entryCount", "entry escapes its root", "unzip", "LoveNode", "local-only-not-bundled"]) {
	assert.ok(complexInputChecker.includes(evidence), `Love Web complex input verifier evidence is missing: ${evidence}`);
}
const complexRunner = fs.readFileSync("Tools/build-scripts/check_web_love_complex.mjs", "utf8");
for (const evidence of ["Cross-Origin-Opener-Policy", "Cross-Origin-Embedder-Policy",
	"crossOriginIsolated", "sharedArrayBuffer", "Emulation.setDeviceMetricsOverride"]) {
	assert.ok(complexRunner.includes(evidence), `Love Web pthread browser evidence is missing: ${evidence}`);
}

const runtime = fs.readFileSync("Source/Love/LoveRuntimeAdapters.inc", "utf8");
for (const module of expectedModules) {
	const functionName = `openLove${module[0].toUpperCase()}${module.slice(1)}Module`;
	assert.ok(runtime.includes(functionName), `Love runtime module registration is missing: ${module}`);
}
assert.match(runtime, /std::thread\s*\(/, "Love thread capability evidence changed");
assert.match(runtime, /openLoveVideoModule/, "Love video capability evidence changed");
assert.match(runtime, /runtimeBootYield/, "Love Web explicit boot yield is missing");
assert.match(runtime, /math\.log10\s*=\s*math\.log10\s*or/, "Love LuaJIT math.log10 compatibility is missing");
const runtimeCore = fs.readFileSync("Source/Love/LoveRuntime.cpp", "utf8");
assert.match(runtimeCore, /incrementalStartHook/, "Love Web instruction-budget yield is missing");
assert.match(runtimeCore, /LoveRuntime::resumeStart/, "Love Web incremental start state machine is missing");
const loveNode = fs.readFileSync("Source/Love/LoveNode.cpp", "utf8");
assert.match(loveNode, /WebLoadInstructionBudget/, "LoveNode Web does not drive incremental load slices");
assert.match(loveNode, /platform == "Web"_slice\) return "Web"/, "LoveNode Web platform mapping is missing");
const application = fs.readFileSync("Source/Basic/Application.cpp", "utf8");
assert.match(application, /defined\(DORA_EMSCRIPTEN\).*BX_PLATFORM_EMSCRIPTEN/,
	"Dora Web platform selection does not prefer the explicit Web build macro");
const touchDispatcher = fs.readFileSync("Source/Input/TouchDispather.cpp", "utf8");
assert.match(touchDispatcher, /BX_PLATFORM_EMSCRIPTEN[\s\S]*Touch::FromMouseAndTouch/,
	"Dora Web input source does not enable both mouse and touch");

const webCMake = fs.readFileSync("Projects/Web/CMakeLists.txt", "utf8");
assert.ok(webCMake.includes('list(FILTER DORA_WEB_ENGINE_SOURCES EXCLUDE REGEX "/Love/[^/]+\\\\.cpp$")'), "Web minimal no longer explicitly excludes Love sources");
assert.match(webCMake, /DORA_WEB_BUILD_LOVE_PROBE/, "Love Web compile probe option is missing");
assert.match(webCMake, /dora-web-love-compile-probe/, "Love Web compile probe target is missing");
assert.match(webCMake, /dora-web-love-node-compile-probe/, "LoveNode Web host compile probe target is missing");
assert.match(webCMake, /dora-web-love-support/, "Love Web support source target is missing");
assert.match(webCMake, /dora-web-love-link-probe/, "Love Web link probe target is missing");
assert.match(webCMake, /dora-web-love-graphics-probe/, "Love Web graphics probe target is missing");
assert.match(webCMake, /dora-web-love-shader-probe/, "Love Web shader probe target is missing");
assert.match(webCMake, /dora-web-love-audio-probe/, "Love Web audio probe target is missing");
assert.match(webCMake, /dora-web-love-complex-probe/, "Love Web opt-in complex-project probe target is missing");
assert.match(webCMake, /dora-web-love-pthread-player/, "Love Web formal pthread Player target is missing");
assert.match(webCMake, /DORA_WEB_LOVE_COMPLEX_PACKAGE/, "Love Web complex-package path gate is missing");
assert.match(webCMake, /option\(DORA_WEB_PTHREADS/, "Love Web opt-in pthread profile is missing");
assert.match(webCMake, /USE_PTHREADS=1/, "Love Web pthread profile does not enable Emscripten threads");
assert.match(webCMake, /USE_PTHREADS=0/, "Love Web default profile no longer explicitly disables pthreads");
assert.match(webCMake, /DoraLoveSources\.cmake/, "Love Web support source manifest is missing");
const buildScript = fs.readFileSync("Tools/build-scripts/build_web.sh", "utf8");
assert.match(buildScript, /BUILD_LOVE_PROBE=.*BUILD_ENGINE/, "Love Web compile probe is not enabled with engine CI builds");
assert.match(buildScript, /BUILD_TARGETS\+=\(dora-web-love-support dora-web-love-compile-probe dora-web-love-node-compile-probe\)/, "Love Web support and compile probes are not part of the build target set");
assert.match(buildScript, /BUILD_TARGETS\+=\(dora-web-love-link-probe dora-web-love-graphics-probe dora-web-love-shader-probe dora-web-love-audio-probe\)/,
	"Love Web link, graphics, shader and audio probes are not part of linked Player builds");
assert.match(buildScript, /BUILD_TARGETS\+=\(dora-web-love-complex-probe\)/,
	"Love Web complex-project probe is not connected to the opt-in build");
assert.match(buildScript, /DORA_WEB_PTHREADS/, "Love Web build script does not forward the pthread profile");
assert.match(buildScript, /LOVE_PLAYER_PACKAGE_DIR/, "Love Web formal Player is not packaged independently");
const formalPlayerRunner = fs.readFileSync("Projects/Web/love-pthread-player.js", "utf8");
for (const evidence of ["inspectLovePackage", "installPackage", "dora_web_love_player_start", "doraSyncUserStorage", "crossOriginIsolated"]) {
	assert.ok(formalPlayerRunner.includes(evidence), `Love Web formal Player evidence is missing: ${evidence}`);
}
const graphicsChecker = fs.readFileSync("Tools/build-scripts/check_web_love_graphics.mjs", "utf8");
assert.match(graphicsChecker, /Canvas render and readback/, "Love Web Canvas readback evidence is missing");
assert.match(graphicsChecker, /ParticleSystem/, "Love Web ParticleSystem evidence is missing");
const shaderChecker = fs.readFileSync("Tools/build-scripts/check_web_love_shader.mjs", "utf8");
assert.match(shaderChecker, /DORA_WEB_LOVE_VISUAL_KIND/, "Love Web shader browser fixture selector is missing");
const shaderFixture = fs.readFileSync("Projects/Web/love-shader-fixture/main.lua", "utf8");
for (const evidence of ["ProbeUV", "ProbeTint", "DrawOffset", "Tint", "Mask", "highp", "mediump", "LOVE_TEST_PRECISION", "LOVE_WEB_SHADER_COMBINED_STAGE_PASS", "screen.x", "newImageData", "[love-shader/translation]", "[love-shader/driver/pixel]", "[love-shader/driver/link]"]) {
	assert.ok(shaderFixture.includes(evidence), `Love Web shader fixture evidence is missing: ${evidence}`);
}
const audioChecker = fs.readFileSync("Tools/build-scripts/check_web_love_audio.mjs", "utf8");
for (const evidence of ["WAV static Source", "OGG streaming Source", "SoundData Source", "two concurrent LoveNode instances", "AudioFile and SoLoud voice cleanup", "configurable long-run soak"]) {
	assert.ok(audioChecker.includes(evidence), `Love Web audio lifecycle evidence is missing: ${evidence}`);
}
const audioFixture = fs.readFileSync("Projects/Web/love-audio-fixture/main.lua", "utf8");
for (const evidence of ["fixture.wav", "fixture.ogg", "newSoundData", "setLooping", "pause", "seek", "LOVE_WEB_AUDIO_READY"]) {
	assert.ok(audioFixture.includes(evidence), `Love Web audio fixture behavior is missing: ${evidence}`);
}
const loveConfig = fs.readFileSync("Source/3rdParty/Love/src/common/config.h", "utf8");
assert.match(loveConfig, /defined\(__EMSCRIPTEN__\)/, "Love does not recognize Emscripten as a target platform");
const webFeatures = fs.readFileSync("Projects/Web/web-features.json.in", "utf8");
assert.match(webFeatures, /"loveNode": false/, "Web feature profile exposed unvalidated LoveNode support");
assert.match(loveNode, /validateLoveWebGLProgram/, "Love Web shader driver preflight is missing");
assert.match(loveNode, /Shader source line/, "Love Web shader source-line diagnostic is missing");
assert.match(graphicsChecker, /no silent fallback/, "Love Web shader failure fixture is missing its fallback assertion");
console.log("[INFO] Love Web capability matrix covers 19 modules; full remains excluded and love-pthread-player passed its P5-10 gates");
