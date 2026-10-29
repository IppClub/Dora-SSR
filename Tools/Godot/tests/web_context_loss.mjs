#!/usr/bin/env node
import {spawn} from "node:child_process";
import {createHash} from "node:crypto";
import {createServer} from "node:http";
import {mkdir, mkdtemp, readFile, rm, stat, writeFile} from "node:fs/promises";
import {tmpdir} from "node:os";
import {extname, join, normalize, resolve, sep} from "node:path";

const player = resolve(process.argv[2] || "build/godot-web/node-controller-teardown/player-3");
const output = resolve(process.argv[3] || "build/godot-web/context-loss-results");
const chromePath = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const timeLimit = Number(process.env.DORA_CONTEXT_LOSS_TIMEOUT_MS || 120000);
const verifyReloadRecovery = process.argv.includes("--reload-recovery");
const observeCabi = process.argv.includes("--cabi-observer");
if (observeCabi && !verifyReloadRecovery) throw new Error("C ABI drain observation requires --reload-recovery");
const mime = new Map([
	[".html", "text/html; charset=utf-8"], [".js", "text/javascript; charset=utf-8"],
	[".mjs", "text/javascript; charset=utf-8"], [".json", "application/json"],
	[".wasm", "application/wasm"], [".data", "application/octet-stream"],
	[".lua", "text/plain; charset=utf-8"], [".png", "image/png"],
]);
const sleep = milliseconds => new Promise(resolvePromise => setTimeout(resolvePromise, milliseconds));
async function digest(path) { return createHash("sha256").update(await readFile(path)).digest("hex"); }

async function waitFor(predicate, label, timeout = timeLimit) {
	const started = Date.now();
	let last;
	while (Date.now() - started < timeout) {
		try { last = await predicate(); if (last) return last; } catch (error) { last = String(error); }
		await sleep(100);
	}
	throw new Error(`Timed out waiting for ${label}; last result: ${JSON.stringify(last)}`);
}

await stat(join(player, "index.html"));
await mkdir(output, {recursive: true});
const server = createServer(async (request, response) => {
	try {
		const pathname = decodeURIComponent(new URL(request.url, "http://localhost").pathname);
		const relative = normalize(pathname === "/" ? "index.html" : pathname.slice(1));
		const file = resolve(player, relative);
		if (file !== player && !file.startsWith(player + sep)) throw new Error("path outside player");
		const body = await readFile(file);
		response.writeHead(200, {
			"Content-Type": mime.get(extname(file)) || "application/octet-stream",
			"Cache-Control": "no-store",
			"Cross-Origin-Opener-Policy": "same-origin",
			"Cross-Origin-Embedder-Policy": "require-corp",
			"Cross-Origin-Resource-Policy": "same-origin",
		});
		response.end(body);
	} catch (error) {
		response.writeHead(404, {"Content-Type": "text/plain"}); response.end(String(error));
	}
});
await new Promise((resolvePromise, reject) => server.listen(0, "127.0.0.1", error => error ? reject(error) : resolvePromise()));
const serverAddress = server.address();
const pageURL = `http://127.0.0.1:${serverAddress.port}/`;
const profile = await mkdtemp(join(tmpdir(), "dora-context-loss-"));
const chrome = spawn(chromePath, [
	"--headless=new", "--no-first-run", "--no-default-browser-check", "--disable-background-networking",
	"--autoplay-policy=no-user-gesture-required", "--remote-debugging-port=0", `--user-data-dir=${profile}`, "about:blank",
], {stdio: ["ignore", "pipe", "pipe"]});
let chromeOutput = "";
chrome.stdout.on("data", data => { chromeOutput += data; });
chrome.stderr.on("data", data => { chromeOutput += data; });

let socket;
const pending = new Map();
const consoleMessages = [];
let nextId = 1;
try {
	const portFile = join(profile, "DevToolsActivePort");
	const port = await waitFor(async () => {
		const value = await readFile(portFile, "utf8");
		return Number(value.split(/\r?\n/, 1)[0]) || false;
	}, "Chrome DevTools port", 30000);
	const target = await fetch(`http://127.0.0.1:${port}/json/new?${encodeURIComponent(pageURL)}`, {method: "PUT"}).then(response => response.json());
	socket = new WebSocket(target.webSocketDebuggerUrl);
	await new Promise((resolvePromise, reject) => { socket.onopen = resolvePromise; socket.onerror = reject; });
	socket.onmessage = event => {
		const message = JSON.parse(event.data);
		if (message.id) {
			const callback = pending.get(message.id); pending.delete(message.id);
			if (message.error) callback?.reject(new Error(JSON.stringify(message.error))); else callback?.resolve(message.result);
		} else if (message.method === "Runtime.consoleAPICalled") {
			consoleMessages.push({type: message.params.type, text: message.params.args.map(argument => argument.value ?? argument.description ?? "").join(" ")});
		} else if (message.method === "Runtime.exceptionThrown") {
			consoleMessages.push({type: "exception", text: message.params.exceptionDetails.text});
		}
	};
	const send = (method, params = {}) => new Promise((resolvePromise, reject) => {
		const id = nextId++; pending.set(id, {resolve: resolvePromise, reject}); socket.send(JSON.stringify({id, method, params}));
	});
	const evaluate = async expression => {
		const result = await send("Runtime.evaluate", {expression, awaitPromise: true, returnByValue: true});
		if (result.exceptionDetails) throw new Error(result.exceptionDetails.text);
		return result.result.value;
	};
	await send("Runtime.enable");
	await send("Page.enable");
	if (observeCabi) {
		await send("Page.addScriptToEvaluateOnNewDocument", {source: await readFile(new URL("./web/acceptance_init.js", import.meta.url), "utf8")});
		consoleMessages.length = 0;
		await send("Page.reload", {ignoreCache: true});
	}
	await waitFor(async () => await evaluate("document.documentElement.dataset.doraState") === "running", "Dora Web running");
	await waitFor(() => consoleMessages.some(message => message.text.includes("DORA_WEB_NODE_CAPTURE animated")), "animated Godot frame before context loss");
	const before = await evaluate(`({
		state: document.documentElement.dataset.doraState,
		platform: DoraWebPlatform?.state,
		contextLost: Boolean(Module.doraWebContextLost),
		imePresent: Boolean(document.getElementById('dora-ime-input'))
	})`);
	const trigger = await evaluate(`(() => {
		try {
			const gl = Module.canvas.getContext('webgl2');
			const extension = gl?.getExtension('WEBGL_lose_context');
			if (!gl || !extension) return {requested: false, reason: !gl ? 'WebGL2 context unavailable' : 'WEBGL_lose_context unavailable'};
			extension.loseContext();
			return {requested: true, actualContextLost: gl.isContextLost()};
		} catch (error) { return {requested: false, reason: String(error)}; }
	})()`);
	if (!trigger.requested) throw new Error(`Could not force a real WebGL context loss: ${trigger.reason}`);
	await waitFor(async () => await evaluate("document.documentElement.dataset.doraState") === "faulted", "Dora Web faulted state");
	await sleep(300);
	const after = await evaluate(`({
		state: document.documentElement.dataset.doraState,
		message: document.getElementById('status-message')?.textContent || '',
		platform: DoraWebPlatform?.state,
		contextLost: Boolean(Module.doraWebContextLost),
		startupFailed: Boolean(Module.doraStartupFailed),
		engineFrameAfterResumeAttempt: DoraWebPlatform?.setSuspended(false)?.engineFrame,
		disposeAgain: DoraWebPlatform?.dispose(),
		imePresent: Boolean(document.getElementById('dora-ime-input'))
	})`);
	const screenshot = await send("Page.captureScreenshot", {format: "png"});
	await writeFile(join(output, "faulted.png"), Buffer.from(screenshot.data, "base64"));
	let reloadRecovery = null;
	if (verifyReloadRecovery) {
		const animatedBefore = consoleMessages.filter(message => message.text.includes("DORA_WEB_NODE_CAPTURE animated")).length;
		await send("Page.reload", {ignoreCache: true});
		await waitFor(async () => await evaluate("document.documentElement.dataset.doraState") === "running", "Dora Web running after reload");
		await waitFor(() => consoleMessages.filter(message => message.text.includes("DORA_WEB_NODE_CAPTURE animated")).length > animatedBefore, "animated Godot frame after reload");
		await waitFor(() => consoleMessages.some(message => message.text.includes("DORA_WEB_NODE_DONE frames=620")), "complete Godot lifetime after reload");
		const running = await evaluate(`({state:document.documentElement.dataset.doraState,contextLost:Boolean(Module.doraWebContextLost),platform:DoraWebPlatform?.state})`);
		await evaluate("Module.ccall('dora_web_stop','number',[],[])");
		await waitFor(async () => await evaluate("document.documentElement.dataset.doraState") === "stopped", "Dora Web stopped after recovered lifetime", 30000);
		const stopped = await evaluate(`({state:document.documentElement.dataset.doraState,platform:DoraWebPlatform?.state,disposeAgain:DoraWebPlatform?.dispose({notifyEngine:false}),imePresent:Boolean(document.getElementById('dora-ime-input'))})`);
		reloadRecovery = {
			passed: running.state === "running" && running.contextLost === false && running.platform?.active === true
				&& stopped.state === "stopped" && stopped.platform?.active === false && stopped.platform?.audioState === "closed"
				&& stopped.disposeAgain === false && stopped.imePresent === false,
			running,
			stopped,
		};
	}
	const expectedMessage = "WebGL context lost; restart the runtime";
	const consoleText = consoleMessages.map(message => message.text);
	const unexpectedGraphicsErrors = consoleText.filter(value => /TypeError|incomplete shared texture framebuffer|WebGL transport error|gpuErrors=[1-9]/.test(value));
	const readerMatch = consoleText.map(value => /GodotRuntime readers: buffers=(\d+), frames=(\d+), .*pending=0, completed=(\d+), gpuErrors=0/.exec(value)).find(Boolean);
	const clientMatch = consoleText.map(value => /GodotRuntime client closed: produced=(\d+), completed=(\d+), gpuErrors=0/.exec(value)).find(Boolean);
	let gpuDrain = readerMatch && clientMatch ? {
		buffers: Number(readerMatch[1]), readerFrames: Number(readerMatch[2]), readerCompleted: Number(readerMatch[3]),
		produced: Number(clientMatch[1]), completed: Number(clientMatch[2]),
	} : null;
	let cabiSessions = null;
	if (observeCabi) {
		const metrics = await evaluate("Module.doraTestAudioMetrics");
		if (metrics.protocol_errors.length || metrics.sessions.length !== 2) throw new Error("Invalid observed recovered C ABI lifecycle");
		cabiSessions = metrics.sessions;
		for (const session of cabiSessions) {
			const [produced, completed, errors] = session.close_stats;
			if (!(produced > 0 && produced === completed && errors === 0 && session.pending_at_close === 0
				&& session.begins > 0 && session.begins + session.empty_ends === session.ends && session.ends % session.buffers === 0))
				throw new Error("Recovered native C ABI did not drain");
		}
		const session = cabiSessions[0];
		gpuDrain = {buffers: session.buffers, readerFrames: session.ends / session.buffers,
			readerCompleted: session.ends / session.buffers, produced: session.close_stats[0], completed: session.close_stats[1]};
	}
	const drainedWithoutGpuErrors = Boolean(gpuDrain && gpuDrain.readerFrames >= 30
		&& gpuDrain.readerCompleted === gpuDrain.readerFrames && gpuDrain.completed === gpuDrain.produced);
	const passed = trigger.actualContextLost === true && after.state === "faulted" && after.contextLost === true
		&& after.message.includes(expectedMessage) && after.platform?.active === false
		&& after.platform?.audioState === "closed" && after.platform?.pressedKeys === 0
		&& after.platform?.activePointers === 0 && after.disposeAgain === false && after.imePresent === false
		&& unexpectedGraphicsErrors.length === 0 && drainedWithoutGpuErrors
		&& (!verifyReloadRecovery || reloadRecovery?.passed === true);
	const report = {
		passed,
		scope: "Actual Chrome WEBGL_lose_context event while the current Dora Web player and embedded Godot runtime are running",
		artifacts: {
			dora_host_wasm_sha256: await digest(join(player, "dora-player-runtime.wasm")),
			godot_runtime_wasm_sha256: await digest(join(player, "godot/dora-godot.wasm")),
			shared_gl_sha256: await digest(join(player, "godot/shared_gl.mjs")),
			runtime_bridge_sha256: await digest(join(player, "godot/runtime_bridge.mjs")),
		},
		before,
		trigger,
		after,
		reloadRecovery,
		cabiSessions,
		statsEvidence: observeCabi ? "Observed production C ABI after reload" : "Native diagnostic logs",
		gpuDrain,
		drainedWithoutGpuErrors,
		unexpectedGraphicsErrors,
		console: consoleMessages,
	};
	await writeFile(join(output, "verification.json"), JSON.stringify(report, null, 2) + "\n");
	if (!passed) throw new Error(`Context-loss contract failed: ${JSON.stringify(report)}`);
	console.log(JSON.stringify(report, null, 2));
} finally {
	try { socket?.close(); } catch {}
	chrome.kill("SIGTERM");
	await Promise.race([new Promise(resolvePromise => chrome.once("exit", resolvePromise)), sleep(3000)]);
	if (chrome.exitCode === null) chrome.kill("SIGKILL");
	server.close();
	await rm(profile, {recursive: true, force: true});
	if (chromeOutput) await writeFile(join(output, "chrome.log"), chromeOutput);
}
