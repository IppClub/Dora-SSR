import { spawn } from "node:child_process";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const baseUrl = process.env.DORA_PERF_BASE_URL ?? "http://127.0.0.1:8866";
const chromePath = process.env.DORA_PERF_CHROME ?? [
	"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
	"/Applications/Chromium.app/Contents/MacOS/Chromium",
	"/usr/bin/google-chrome",
	"/usr/bin/chromium",
].find(existsSync);
const runs = Number(process.env.DORA_PERF_RUNS ?? 3);
const sampleFile = process.env.DORA_PERF_SAMPLE_FILE
	?? "/Users/Jin/Workspace/Dora/Vomfy/init.tsx";
const projectPaths = (
	process.env.DORA_PERF_PROJECT_PATHS
	?? "/Users/Jin/Workspace/Dora/AgentArcade,/Users/Jin/Workspace/Dora/RandomTest"
).split(",").map(value => value.trim()).filter(Boolean);
const agentProjectPath = process.env.DORA_PERF_AGENT_PROJECT
	?? "/Users/Jin/Workspace/Dora/AgentArcade/20260722-05-Abyssal-Tether";
const listenerGrowthBudget = Number(process.env.DORA_PERF_LISTENER_GROWTH ?? 5);
const heapGrowthBudget = Number(process.env.DORA_PERF_HEAP_GROWTH_MIB ?? 10) * 1024 * 1024;
const agentMode = process.argv.includes("--agent");
const mobileMode = process.argv.includes("--mobile");
const agentDurationMs = Number(process.env.DORA_PERF_AGENT_DURATION_MS ?? 30_000);
const agentPatchIntervalMs = Number(process.env.DORA_PERF_AGENT_PATCH_INTERVAL_MS ?? 25);

if (!chromePath) {
	throw new Error("Chrome not found. Set DORA_PERF_CHROME to a Chrome/Chromium executable.");
}
if (!Number.isInteger(runs) || runs < 1) {
	throw new Error("DORA_PERF_RUNS must be a positive integer.");
}
if (projectPaths.length < 2) {
	throw new Error("DORA_PERF_PROJECT_PATHS must contain at least two comma-separated project paths.");
}
if (!Number.isFinite(agentDurationMs) || agentDurationMs < 1000) {
	throw new Error("DORA_PERF_AGENT_DURATION_MS must be at least 1000.");
}
if (!Number.isFinite(agentPatchIntervalMs) || agentPatchIntervalMs < 10) {
	throw new Error("DORA_PERF_AGENT_PATCH_INTERVAL_MS must be at least 10.");
}

const delay = milliseconds => new Promise(resolve => setTimeout(resolve, milliseconds));
const percentile = (values, ratio) => {
	const sorted = [...values].sort((left, right) => left - right);
	return sorted[Math.min(sorted.length - 1, Math.ceil(sorted.length * ratio) - 1)] ?? 0;
};

class CdpClient {
	constructor(webSocketUrl) {
		this.nextId = 1;
		this.pending = new Map();
		this.consoleErrors = [];
		this.socket = new WebSocket(webSocketUrl);
		this.ready = new Promise((resolve, reject) => {
			this.socket.addEventListener("open", resolve, { once: true });
			this.socket.addEventListener("error", reject, { once: true });
		});
		this.socket.addEventListener("message", event => {
			const message = JSON.parse(event.data);
			if (message.method === "Runtime.consoleAPICalled"
				&& message.params?.type === "error") {
				this.consoleErrors.push(message.params.args
					.map(argument => argument.value ?? argument.description ?? "")
					.join(" "));
			}
			if (message.method === "Log.entryAdded"
				&& message.params?.entry?.level === "error") {
				this.consoleErrors.push(message.params.entry.text);
			}
			if (message.id === undefined) return;
			const pending = this.pending.get(message.id);
			if (!pending) return;
			this.pending.delete(message.id);
			if (message.error) {
				pending.reject(new Error(`${message.error.message} (${message.error.code})`));
			} else {
				pending.resolve(message.result);
			}
		});
	}

	async send(method, params = {}) {
		await this.ready;
		const id = this.nextId++;
		const result = new Promise((resolve, reject) => {
			this.pending.set(id, { resolve, reject });
		});
		this.socket.send(JSON.stringify({ id, method, params }));
		return result;
	}

	async evaluate(expression) {
		const result = await this.send("Runtime.evaluate", {
			expression,
			awaitPromise: true,
			returnByValue: true,
		});
		if (result.exceptionDetails) {
			throw new Error(result.exceptionDetails.exception?.description
				?? result.exceptionDetails.text
				?? "Runtime.evaluate failed");
		}
		return result.result.value;
	}

	close() {
		this.socket.close();
	}
}

async function waitForFile(path, timeoutMs = 10000) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		if (existsSync(path)) return;
		await delay(50);
	}
	throw new Error(`Timed out waiting for ${path}`);
}

async function waitFor(client, expression, timeoutMs = 15000) {
	const deadline = Date.now() + timeoutMs;
	while (Date.now() < deadline) {
		if (await client.evaluate(`Boolean(${expression})`)) return;
		await delay(50);
	}
	throw new Error(`Timed out waiting for: ${expression}`);
}

async function openTarget(port, url, emulation) {
	const response = await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, { method: "PUT" });
	if (!response.ok) throw new Error(`Could not create Chrome target: ${response.status}`);
	const target = await response.json();
	const client = new CdpClient(target.webSocketDebuggerUrl);
	await Promise.all([
		client.send("Page.enable"),
		client.send("Runtime.enable"),
		client.send("Network.enable"),
		client.send("HeapProfiler.enable"),
		client.send("Log.enable"),
	]);
	if (emulation) {
		await client.send("Emulation.setDeviceMetricsOverride", {
			width: emulation.width,
			height: emulation.height,
			deviceScaleFactor: emulation.deviceScaleFactor,
			mobile: true,
		});
		await client.send("Emulation.setTouchEmulationEnabled", {
			enabled: true,
			maxTouchPoints: 5,
		});
	}
	await client.send("Network.clearBrowserCache");
	await client.send("Page.navigate", { url });
	await waitFor(client, "document.readyState === 'complete'");
	await waitFor(client, "document.querySelector('[data-dora-perf-diagnostics]') !== null");
	return {
		client,
		close: async () => {
			client.close();
			await fetch(`http://127.0.0.1:${port}/json/close/${target.id}`);
		},
	};
}

async function sampleSearch(port, run) {
	const url = new URL(baseUrl);
	url.searchParams.set("doraPerf", "1");
	url.searchParams.set("browserPerfRun", String(run));
	const target = await openTarget(port, url.toString());
	const { client } = target;
	try {
		await waitFor(client, "document.querySelectorAll('[role=treeitem]').length > 5");
		const cold = await client.evaluate(`(() => {
			const navigation = performance.getEntriesByType("navigation")[0];
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			return {
				navigationMs: navigation?.duration ?? 0,
				dom: document.querySelectorAll("*").length,
				listeners: Number(diagnostics?.dataset.doraPerfListeners ?? 0),
				heap: Number(diagnostics?.dataset.doraPerfHeap ?? 0),
				monacoLoaded: diagnostics?.dataset.doraPerfMonacoLoaded === "true",
				typeScriptWorkerLoaded: diagnostics?.dataset.doraPerfTypeScriptWorkerLoaded === "true",
			};
		})()`);
		const opened = await client.evaluate(`(() => {
			const labels = new Set(["跳转到文件", "Go to File"]);
			const button = [...document.querySelectorAll("button")]
				.find(element => labels.has(element.getAttribute("aria-label") ?? "")
					|| labels.has(element.getAttribute("title") ?? "")
					|| labels.has(element.textContent?.trim() ?? ""));
			button?.click();
			return Boolean(button);
		})()`);
		if (!opened) throw new Error("Could not find the Go to File button.");
		await waitFor(client, "document.querySelector('input[data-file-filter-input]') !== null");
		await client.evaluate(`(() => {
			const input = document.querySelector("input[data-file-filter-input]");
			if (!input) throw new Error("Jump-to-file input not found");
			input.focus();
			return true;
		})()`);
		for (let index = 0; index < 50; index += 1) {
			const value = index % 2 === 0 ? "ini" : "init";
			await client.evaluate(`document.querySelector("input[data-file-filter-input]")?.select()`);
			await client.send("Input.insertText", { text: value });
			await client.evaluate(`new Promise(resolve => requestAnimationFrame(resolve))`);
		}
		try {
			await waitFor(client, "document.querySelector('[role=option]') !== null");
		} catch (error) {
			const state = await client.evaluate(`(() => ({
				input: document.querySelector("input[data-file-filter-input]")?.value,
				options: document.querySelector("input[data-file-filter-input]")?.dataset.fileFilterOptionCount,
				results: document.querySelector("input[data-file-filter-input]")?.dataset.fileFilterResultCount,
				dialog: document.querySelector('[data-file-filter-dialog="true"]')?.textContent,
				progress: document.querySelectorAll('[data-file-filter-dialog="true"] [role=progressbar]').length,
				diagnostics: document.querySelector("[data-dora-perf-diagnostics]")?.dataset,
			}))()`);
			throw new Error(`${error.message}; searchState=${JSON.stringify(state)}`);
		}
		const search = await client.evaluate(`(() => {
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			return {
				count: Number(diagnostics?.dataset.doraPerfSearchInputCount ?? 0),
				p50: Number(diagnostics?.dataset.doraPerfSearchInputP50 ?? 0),
				p95: Number(diagnostics?.dataset.doraPerfSearchInputP95 ?? 0),
				max: Number(diagnostics?.dataset.doraPerfSearchInputMax ?? 0),
				results: document.querySelectorAll("[role=option]").length,
			};
		})()`);
		return { cold, search };
	} finally {
		await target.close();
	}
}

async function sampleTabs(port, run) {
	const url = new URL(baseUrl);
	url.searchParams.set("doraPerf", "1");
	url.searchParams.set("browserPerfRun", String(run));
	url.searchParams.set("file", sampleFile);
	const target = await openTarget(port, url.toString());
	const { client } = target;
	const tabPaths = [sampleFile, ...projectPaths.slice(0, 2)];
	try {
		await waitFor(client, "document.querySelector('.monaco-editor') !== null");
		for (const projectPath of projectPaths.slice(0, 2)) {
			const label = projectPath.split(/[\\\\/]/).filter(Boolean).at(-1);
			const clicked = await client.evaluate(`(() => {
				const label = ${JSON.stringify(label)};
				const item = [...document.querySelectorAll("[role=treeitem]")]
					.find(element => element.textContent?.trim() === label);
				const target = item?.querySelector(".ant-tree-node-content-wrapper");
				target?.click();
				return Boolean(target);
			})()`);
			if (!clicked) throw new Error(`Could not find project tree item ${label}.`);
			await delay(500);
		}
		try {
			await waitFor(client, "document.querySelectorAll('[role=tab][data-file-key]').length >= 3");
		} catch (error) {
			const tabs = await client.evaluate(`[...document.querySelectorAll("[role=tab]")]
				.map(element => ({
					text: element.textContent,
					fileKey: element.getAttribute("data-file-key"),
					ariaLabel: element.getAttribute("aria-label"),
				}))`);
			throw new Error(`${error.message}; tabs=${JSON.stringify(tabs)}`);
		}
		const switchExpression = iterations => `(async () => {
			const paths = ${JSON.stringify(tabPaths)};
			const timings = [];
			let maxMainCount = 0;
			for (let index = 0; index < ${iterations}; index += 1) {
				const path = paths[index % paths.length];
				const tab = document.querySelector('[role=tab][data-file-key="' + CSS.escape(path) + '"]');
				if (!tab) throw new Error("Missing top tab: " + path);
				const startedAt = performance.now();
				tab.click();
				while (tab.getAttribute("aria-selected") !== "true") {
					await new Promise(resolve => requestAnimationFrame(resolve));
				}
				timings.push(performance.now() - startedAt);
				await new Promise(resolve => requestAnimationFrame(resolve));
				maxMainCount = Math.max(maxMainCount, document.querySelectorAll("main").length);
			}
			return { timings, maxMainCount };
		})()`;
		await client.evaluate(switchExpression(15));
		await delay(5000);
		await client.send("HeapProfiler.collectGarbage");
		await delay(600);
		const before = await client.evaluate(`(() => {
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			return {
				dom: document.querySelectorAll("*").length,
				listeners: Number(diagnostics?.dataset.doraPerfListeners ?? 0),
				listenerTypes: JSON.parse(diagnostics?.dataset.doraPerfListenerTypes ?? "{}"),
				heap: Number(diagnostics?.dataset.doraPerfHeap ?? 0),
			};
		})()`);
		const switches = await client.evaluate(switchExpression(21));
		await delay(15000);
		await client.send("HeapProfiler.collectGarbage");
		await delay(600);
		const after = await client.evaluate(`(() => {
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			return {
				dom: document.querySelectorAll("*").length,
				listeners: Number(diagnostics?.dataset.doraPerfListeners ?? 0),
				listenerTypes: JSON.parse(diagnostics?.dataset.doraPerfListenerTypes ?? "{}"),
				heap: Number(diagnostics?.dataset.doraPerfHeap ?? 0),
				mains: document.querySelectorAll("main").length,
				editors: document.querySelectorAll(".monaco-editor").length,
			};
		})()`);
		const listenerTypes = Object.fromEntries(
			[...new Set([
				...Object.keys(before.listenerTypes),
				...Object.keys(after.listenerTypes),
			])]
				.map(type => [type, (after.listenerTypes[type] ?? 0) - (before.listenerTypes[type] ?? 0)])
				.filter(([, delta]) => delta !== 0)
		);
		delete before.listenerTypes;
		delete after.listenerTypes;
		return {
			switchP50: percentile(switches.timings, 0.5),
			switchP95: percentile(switches.timings, 0.95),
			switchMax: Math.max(...switches.timings),
			maxMainCount: switches.maxMainCount,
			before,
			after,
			delta: {
				dom: after.dom - before.dom,
				listeners: after.listeners - before.listeners,
				listenerTypes,
				heap: after.heap - before.heap,
			},
		};
	} finally {
		await target.close();
	}
}

async function sampleAgent(port) {
	const url = new URL(baseUrl);
	url.searchParams.set("doraPerf", "1");
	url.searchParams.set("browserPerfScenario", "agent");
	const target = await openTarget(port, url.toString());
	const { client } = target;
	const projectPath = agentProjectPath;
	const projectLabel = projectPath.split(/[\\/]/).filter(Boolean).at(-1);
	try {
		await waitFor(client, "document.querySelectorAll('[role=treeitem]').length > 5");
		const parentLabels = projectPath.split(/[\\/]/).filter(Boolean).slice(-2, -1);
		for (const label of parentLabels) {
			const expanded = await client.evaluate(`(() => {
				const label = ${JSON.stringify(label)};
				const item = [...document.querySelectorAll("[role=treeitem]")]
					.find(element => element.textContent?.trim() === label);
				if (!item) return false;
				if (item.getAttribute("aria-expanded") !== "true") {
					item.querySelector(".ant-tree-switcher")?.click();
				}
				return true;
			})()`);
			if (!expanded) throw new Error(`Could not find Agent project parent ${label}.`);
			await waitFor(client, `[...document.querySelectorAll("[role=treeitem]")]
				.some(element => element.textContent?.trim() === ${JSON.stringify(projectLabel)})`);
		}
		const clicked = await client.evaluate(`(() => {
			const label = ${JSON.stringify(projectLabel)};
			const item = [...document.querySelectorAll("[role=treeitem]")]
				.find(element => element.textContent?.trim() === label);
			const target = item?.querySelector(".ant-tree-node-content-wrapper");
			target?.click();
			return Boolean(target);
		})()`);
		if (!clicked) throw new Error(`Could not find Agent project tree item ${projectLabel}.`);
		await waitFor(client, "document.querySelector('[data-agent-session-id]')?.getAttribute('data-agent-session-id')");
		await waitFor(client, "typeof window.__doraPerfEmitAgentSessionPatch === 'function'");
		await delay(1000);
		await client.send("HeapProfiler.collectGarbage");
		await delay(600);
		const before = await client.evaluate(`(async () => {
			const root = document.querySelector("[data-agent-session-id]");
			const sessionId = Number(root?.getAttribute("data-agent-session-id"));
			const response = await fetch("/agent/session/get", {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({ sessionId }),
			});
			const detail = await response.json();
			if (!detail.success) throw new Error(detail.message ?? "Could not load Agent session");
			window.__doraPerfAgentOriginalSession = detail.session;
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			return {
				sessionId,
				session: detail.session,
				dom: document.querySelectorAll("*").length,
				listeners: Number(diagnostics?.dataset.doraPerfListeners ?? 0),
				heap: Number(diagnostics?.dataset.doraPerfHeap ?? 0),
				messageRenders: Object.fromEntries(
					[...document.querySelectorAll("[data-agent-message-id]")]
						.map(element => [
							element.getAttribute("data-agent-message-id"),
							Number(element.getAttribute("data-agent-message-render-count") ?? 0),
						])
				),
				stepRenders: Object.fromEntries(
					[...document.querySelectorAll("[data-agent-step-row-id]")]
						.map(element => [
							element.getAttribute("data-agent-step-row-id"),
							Number(element.getAttribute("data-agent-step-render-count") ?? 0),
						])
				),
			};
		})()`);
		const probeId = 8_900_000_001;
		const taskId = 8_900_000_002;
		await client.evaluate(`(() => {
			const probeId = ${probeId};
			const taskId = ${taskId};
			const originalSession = window.__doraPerfAgentOriginalSession;
			const emit = window.__doraPerfEmitAgentSessionPatch;
			const sessionId = Number(document.querySelector("[data-agent-session-id]")
				?.getAttribute("data-agent-session-id"));
			if (!originalSession || typeof emit !== "function" || !sessionId) {
				throw new Error("Agent diagnostics harness is unavailable");
			}
			const now = Date.now();
			emit({
				name: "AgentSessionPatch",
				sessionId,
				session: {
					...originalSession,
					status: "RUNNING",
					currentTaskId: taskId,
					currentTaskStatus: "RUNNING",
					updatedAt: now,
				},
				message: {
					id: probeId,
					sessionId,
					taskId,
					role: "assistant",
					content: "stream-0000 性能采样内容\\n",
					createdAt: now,
					updatedAt: now,
				},
			});
			const scroll = document.querySelector("[data-agent-scroll-container]");
			if (scroll) {
				scroll.scrollTop = scroll.scrollHeight;
				scroll.dispatchEvent(new Event("scroll"));
			}
			return true;
		})()`);
		await delay(250);
		const stableBefore = await client.evaluate(`(() => ({
			messageRenders: Object.fromEntries(
				[...document.querySelectorAll("[data-agent-message-id]")]
					.filter(element => element.getAttribute("data-agent-message-id") !== "${probeId}")
					.map(element => [
						element.getAttribute("data-agent-message-id"),
						Number(element.getAttribute("data-agent-message-render-count") ?? 0),
					])
			),
			stepRenders: Object.fromEntries(
				[...document.querySelectorAll("[data-agent-step-row-id]")]
					.map(element => [
						element.getAttribute("data-agent-step-row-id"),
						Number(element.getAttribute("data-agent-step-render-count") ?? 0),
					])
			),
		}))()`);
		const stream = await client.evaluate(`new Promise(resolve => {
			const durationMs = ${agentDurationMs};
			const patchIntervalMs = ${agentPatchIntervalMs};
			const probeId = ${probeId};
			const taskId = ${taskId};
			const originalSession = window.__doraPerfAgentOriginalSession;
			const emit = window.__doraPerfEmitAgentSessionPatch;
			const sessionId = Number(document.querySelector("[data-agent-session-id]")
				?.getAttribute("data-agent-session-id"));
			if (!originalSession || typeof emit !== "function" || !sessionId) {
				throw new Error("Agent diagnostics harness is unavailable");
			}
			const startedAt = performance.now();
			const frameIntervals = [];
			const longTasks = [];
			let previousFrame = startedAt;
			let animationFrame = 0;
			let patches = 1;
			let stepPatches = 0;
			let currentStepIndex = 0;
			let content = "stream-0000 性能采样内容\\n";
			let previousThinkingTop = null;
			const thinkingPositionDeltas = [];
			const bottomDistances = [];
			const observer = typeof PerformanceObserver === "undefined"
				? null
				: new PerformanceObserver(list => {
					for (const entry of list.getEntries()) longTasks.push(entry.duration);
				});
			try {
				observer?.observe({ type: "longtask", buffered: false });
			} catch {
				observer?.disconnect();
			}
			const trackFrame = timestamp => {
				frameIntervals.push(timestamp - previousFrame);
				previousFrame = timestamp;
				const thinking = document.querySelector("[data-agent-thinking]");
				if (thinking) {
					const thinkingTop = thinking.getBoundingClientRect().top;
					if (previousThinkingTop !== null) {
						thinkingPositionDeltas.push(Math.abs(thinkingTop - previousThinkingTop));
					}
					previousThinkingTop = thinkingTop;
				}
				const scroll = document.querySelector("[data-agent-scroll-container]");
				if (scroll) {
					bottomDistances.push(Math.max(
						0,
						scroll.scrollHeight - scroll.scrollTop - scroll.clientHeight
					));
				}
				animationFrame = requestAnimationFrame(trackFrame);
			};
			animationFrame = requestAnimationFrame(trackFrame);
			const interval = setInterval(() => {
				patches += 1;
				content += "stream-" + String(patches).padStart(4, "0") + " 性能采样内容\\n";
				const now = Date.now();
				emit({
					name: "AgentSessionPatch",
					sessionId,
					message: {
						id: probeId,
						sessionId,
						taskId,
						role: "assistant",
						content,
						createdAt: now,
						updatedAt: now,
					},
				});
				// Real Agent output alternates between streamed messages and
				// tool rows whose Markdown height changes asynchronously.
				// Exercise that path as well as the plain text stream.
				if (patches % 20 === 0) {
					currentStepIndex += 1;
					stepPatches += 1;
					emit({
						name: "AgentSessionPatch",
						sessionId,
						step: {
							id: 8_910_000_000 + currentStepIndex,
							sessionId,
							taskId,
							step: currentStepIndex,
							tool: "read_file",
							status: "RUNNING",
							reason: "正在检查第 " + currentStepIndex + " 个文件。\\n\\n- 读取内容\\n- 分析依赖",
							reasoningContent: "",
							params: { path: "src/stream-" + currentStepIndex + ".ts" },
							createdAt: now,
							updatedAt: now,
						},
					});
				} else if (currentStepIndex > 0 && patches % 20 === 10) {
					stepPatches += 1;
					emit({
						name: "AgentSessionPatch",
						sessionId,
						step: {
							id: 8_910_000_000 + currentStepIndex,
							sessionId,
							taskId,
							step: currentStepIndex,
							tool: "read_file",
							status: "DONE",
							reason: "已检查第 " + currentStepIndex + " 个文件。\\n\\n- 读取内容完成\\n- 依赖分析完成\\n- 记录后续修改点",
							reasoningContent: "",
							params: { path: "src/stream-" + currentStepIndex + ".ts" },
							result: { success: true },
							createdAt: now,
							updatedAt: now,
						},
					});
				}
			}, patchIntervalMs);
			setTimeout(() => {
				clearInterval(interval);
				cancelAnimationFrame(animationFrame);
				observer?.disconnect();
				const streamDurationMs = performance.now() - startedAt;
				const now = Date.now();
				emit({
					name: "AgentSessionPatch",
					sessionId,
					message: {
						id: probeId,
						sessionId,
						taskId,
						role: "assistant",
						content,
						createdAt: now,
						updatedAt: now,
					},
					session: {
						...originalSession,
						status: "DONE",
						currentTaskId: taskId,
						currentTaskStatus: "DONE",
						updatedAt: now,
					},
				});
				setTimeout(() => resolve({
					durationMs: streamDurationMs,
					patches,
					stepPatches,
					contentLength: content.length,
					frameIntervals,
					longTasks,
					thinkingPositionDeltas,
					bottomDistances,
				}), 500);
			}, durationMs);
		})`);
		await delay(1000);
		await client.send("HeapProfiler.collectGarbage");
		await delay(600);
		const after = await client.evaluate(`(() => {
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			const scroll = document.querySelector("[data-agent-scroll-container]");
			return {
				dom: document.querySelectorAll("*").length,
				listeners: Number(diagnostics?.dataset.doraPerfListeners ?? 0),
				heap: Number(diagnostics?.dataset.doraPerfHeap ?? 0),
				probeRenderCount: Number(document.querySelector(
					'[data-agent-message-id="${probeId}"]'
				)?.getAttribute("data-agent-message-render-count") ?? 0),
				messageRenders: Object.fromEntries(
					[...document.querySelectorAll("[data-agent-message-id]")]
						.filter(element => element.getAttribute("data-agent-message-id") !== "${probeId}")
						.map(element => [
							element.getAttribute("data-agent-message-id"),
							Number(element.getAttribute("data-agent-message-render-count") ?? 0),
						])
				),
				stepRenders: Object.fromEntries(
					[...document.querySelectorAll("[data-agent-step-row-id]")]
						.map(element => [
							element.getAttribute("data-agent-step-row-id"),
							Number(element.getAttribute("data-agent-step-render-count") ?? 0),
						])
				),
				scrollDistanceToBottom: scroll
					? Math.max(0, scroll.scrollHeight - scroll.scrollTop - scroll.clientHeight)
					: null,
			};
		})()`);
		const stableRenderGrowth = (beforeCounts, afterCounts) => Object.entries(beforeCounts)
			.reduce((total, [id, count]) => total + Math.max(0, (afterCounts[id] ?? 0) - count), 0);
		return {
			projectPath,
			sessionId: before.sessionId,
			durationMs: stream.durationMs,
			patches: stream.patches,
			stepPatches: stream.stepPatches,
			contentLength: stream.contentLength,
			frameP50: percentile(stream.frameIntervals, 0.5),
			frameP95: percentile(stream.frameIntervals, 0.95),
			frameMax: Math.max(...stream.frameIntervals),
			thinkingPositionP95: percentile(stream.thinkingPositionDeltas, 0.95),
			thinkingPositionMax: Math.max(0, ...stream.thinkingPositionDeltas),
			bottomDistanceP95: percentile(stream.bottomDistances, 0.95),
			bottomDistanceMax: Math.max(0, ...stream.bottomDistances),
			longTaskCount: stream.longTasks.length,
			longTaskMax: Math.max(0, ...stream.longTasks),
			probeRenderCount: after.probeRenderCount,
			renderBudget: Math.ceil(agentDurationMs / 50) + 5,
			stableMessageRenderGrowth: stableRenderGrowth(stableBefore.messageRenders, after.messageRenders),
			stableStepRenderGrowth: stableRenderGrowth(stableBefore.stepRenders, after.stepRenders),
			scrollDistanceToBottom: after.scrollDistanceToBottom,
			delta: {
				dom: after.dom - before.dom,
				listeners: after.listeners - before.listeners,
				heap: after.heap - before.heap,
			},
		};
	} finally {
		await target.close();
	}
}

async function touchElement(client, expression, scrollIntoView = true) {
	const point = await client.evaluate(`(() => {
		const element = ${expression};
		if (!element) return null;
		if (${scrollIntoView}) {
			element.scrollIntoView({ block: "center", inline: "center" });
		}
		const rect = element.getBoundingClientRect();
		return {
			x: Math.max(1, Math.min(innerWidth - 1, rect.left + rect.width / 2)),
			y: Math.max(1, Math.min(innerHeight - 1, rect.top + rect.height / 2)),
		};
	})()`);
	if (!point) return false;
	await client.send("Input.synthesizeTapGesture", {
		x: point.x,
		y: point.y,
		duration: 50,
		gestureSourceType: "touch",
	});
	await delay(50);
	return true;
}

async function sampleMobilePortrait(port) {
	const url = new URL(baseUrl);
	url.searchParams.set("doraPerf", "1");
	url.searchParams.set("browserPerfScenario", "mobile-portrait");
	const target = await openTarget(port, url.toString(), {
		width: 390,
		height: 844,
		deviceScaleFactor: 3,
	});
	const { client } = target;
	try {
		await waitFor(client, "document.querySelector('.dora-content-panel') !== null");
		const initial = await client.evaluate(`(() => ({
			resourceWidth: document.querySelector(".dora-resource-panel")
				?.getBoundingClientRect().width ?? -1,
			contentWidth: document.querySelector(".dora-content-panel")
				?.getBoundingClientRect().width ?? -1,
			drawerButtonVisible: Boolean(document.querySelector(
				'button[aria-label="open drawer"]'
			)),
		}))()`);
		const opened = await touchElement(
			client,
			`document.querySelector('button[aria-label="open drawer"]')`,
			false
		);
		if (!opened) throw new Error("Could not touch the portrait drawer toggle.");
		await waitFor(client, `document.querySelector(".dora-resource-panel")
			?.getBoundingClientRect().width > 100`);
		const overlay = await client.evaluate(`(() => ({
			resourceWidth: document.querySelector(".dora-resource-panel")
				?.getBoundingClientRect().width ?? -1,
			contentWidth: document.querySelector(".dora-content-panel")
				?.getBoundingClientRect().width ?? -1,
			closeButtonVisible: Boolean(document.querySelector(
				'button[aria-label="close drawer"]'
			)),
		}))()`);
		const closed = await touchElement(
			client,
			`document.querySelector('button[aria-label="close drawer"]')`,
			false
		);
		if (!closed) throw new Error("Could not touch the portrait drawer close button.");
		await waitFor(client, `document.querySelector(".dora-resource-panel")
			?.getBoundingClientRect().width < 1`);
		return {
			device: await client.evaluate(`({
				width: innerWidth,
				height: innerHeight,
				devicePixelRatio,
				maxTouchPoints: navigator.maxTouchPoints,
			})`),
			initial,
			overlay,
			closed: true,
			consoleErrors: [...new Set(client.consoleErrors)],
		};
	} finally {
		await target.close();
	}
}

async function sampleMobileLandscape(port) {
	const url = new URL(baseUrl);
	url.searchParams.set("doraPerf", "1");
	url.searchParams.set("browserPerfScenario", "mobile");
	const target = await openTarget(port, url.toString(), {
		width: 844,
		height: 390,
		deviceScaleFactor: 3,
	});
	const { client } = target;
	const projectPath = agentProjectPath;
	const projectLabel = projectPath.split(/[\\/]/).filter(Boolean).at(-1);
	try {
		await waitFor(client, "document.querySelectorAll('[role=treeitem]').length > 5");
		const device = await client.evaluate(`({
			width: innerWidth,
			height: innerHeight,
			devicePixelRatio,
			maxTouchPoints: navigator.maxTouchPoints,
		})`);

		const splitter = await client.evaluate(`(() => {
			const dragger = document.querySelector(".dora-splitter-dragger");
			const panel = document.querySelector(".ant-splitter-panel");
			if (!dragger || !panel) return null;
			const rect = dragger.getBoundingClientRect();
			return {
				x: rect.left + rect.width / 2,
				y: Math.min(innerHeight - 80, Math.max(80, rect.top + rect.height / 2)),
				before: panel.getBoundingClientRect().width,
			};
		})()`);
		if (!splitter) throw new Error("Could not find the mobile splitter dragger.");
		await client.send("Input.dispatchTouchEvent", {
			type: "touchStart",
			touchPoints: [{
				x: splitter.x,
				y: splitter.y,
				radiusX: 12,
				radiusY: 12,
				force: 1,
			}],
		});
		for (let step = 1; step <= 8; step += 1) {
			await client.send("Input.dispatchTouchEvent", {
				type: "touchMove",
				touchPoints: [{
					x: splitter.x + step * 5,
					y: splitter.y,
					radiusX: 12,
					radiusY: 12,
					force: 1,
				}],
			});
			await delay(30);
		}
		await client.send("Input.dispatchTouchEvent", {
			type: "touchEnd",
			touchPoints: [],
		});
		await delay(300);
		const splitterAfter = await client.evaluate(
			`document.querySelector(".ant-splitter-panel")?.getBoundingClientRect().width ?? 0`
		);

		const labels = ["跳转到文件", "Go to File"];
		const openedSearch = await touchElement(client, `[...document.querySelectorAll("button")]
			.find(element => ${JSON.stringify(labels)}.includes(
				element.getAttribute("aria-label")
					?? element.getAttribute("title")
					?? element.textContent?.trim()
			))`);
		if (!openedSearch) throw new Error("Could not touch the Go to File button.");
		await waitFor(client, "document.querySelector('input[data-file-filter-input]') !== null");
		const focused = await touchElement(client, `document.querySelector(
			"input[data-file-filter-input]"
		)`);
		if (!focused) throw new Error("Could not touch the jump-to-file input.");
		await client.send("Input.insertText", { text: "init" });
		await waitFor(client, `Number(document.querySelector(
			"input[data-file-filter-input]"
		)?.dataset.fileFilterResultCount ?? 0) > 0`);
		const search = await client.evaluate(`(() => {
			const input = document.querySelector("input[data-file-filter-input]");
			const diagnostics = document.querySelector("[data-dora-perf-diagnostics]");
			return {
				value: input?.value ?? "",
				candidates: Number(input?.dataset.fileFilterOptionCount ?? 0),
				matches: Number(input?.dataset.fileFilterResultCount ?? 0),
				results: document.querySelectorAll("[role=option]").length,
				p95: Number(diagnostics?.dataset.doraPerfSearchInputP95 ?? 0),
			};
		})()`);
		await client.send("Input.dispatchKeyEvent", {
			type: "keyDown",
			key: "Escape",
			code: "Escape",
			windowsVirtualKeyCode: 27,
			nativeVirtualKeyCode: 27,
		});
		await client.send("Input.dispatchKeyEvent", {
			type: "keyUp",
			key: "Escape",
			code: "Escape",
			windowsVirtualKeyCode: 27,
			nativeVirtualKeyCode: 27,
		});
		await waitFor(client, "document.querySelector('input[data-file-filter-input]') === null");

		const parentLabel = projectPath.split(/[\\/]/).filter(Boolean).at(-2);
		const parentExpanded = await client.evaluate(`(() => {
			const item = [...document.querySelectorAll("[role=treeitem]")]
				.find(element => element.textContent?.trim() === ${JSON.stringify(parentLabel)});
			return item?.getAttribute("aria-expanded") === "true";
		})()`);
		if (!parentExpanded) {
			const parentTouched = await touchElement(client, `[...document.querySelectorAll(
				"[role=treeitem]"
			)].find(element => element.textContent?.trim() === ${JSON.stringify(parentLabel)})
				?.querySelector(".ant-tree-switcher")`);
			if (!parentTouched) throw new Error(`Could not touch Agent project parent ${parentLabel}.`);
		}
		let projectTouched = false;
		for (let index = 0; index < 80 && !projectTouched; index += 1) {
			projectTouched = await touchElement(client, `[...document.querySelectorAll(
				"[role=treeitem]"
			)].find(element => element.textContent?.trim() === ${JSON.stringify(projectLabel)})
				?.querySelector(".ant-tree-node-content-wrapper")`);
			if (projectTouched) break;
			await client.evaluate(`(() => {
				const holder = document.querySelector(".ant-tree-list-holder");
				if (!holder) return;
				const next = holder.scrollTop + Math.max(160, holder.clientHeight * 0.6);
				holder.scrollTop = next >= holder.scrollHeight - holder.clientHeight ? 0 : next;
				holder.dispatchEvent(new Event("scroll"));
			})()`);
			await delay(100);
		}
		if (!projectTouched) throw new Error(`Could not touch Agent project ${projectLabel}.`);
		await waitFor(client, `document.querySelector(
			'[data-workspace-view="agent"][aria-pressed="true"]'
		) !== null`);

		const rotationBefore = await client.evaluate(`(() => ({
			resourceWidth: document.querySelector(".dora-resource-panel")
				?.getBoundingClientRect().width ?? -1,
			contentWidth: document.querySelector(".dora-content-panel")
				?.getBoundingClientRect().width ?? -1,
		}))()`);
		await client.send("Emulation.setDeviceMetricsOverride", {
			width: 390,
			height: 844,
			deviceScaleFactor: 3,
			mobile: true,
		});
		await waitFor(client, "innerWidth === 390 && innerHeight === 844");
		await waitFor(client, `document.querySelector(".dora-resource-panel")
			?.getBoundingClientRect().width < 1`);
		const rotationAfter = await client.evaluate(`(() => ({
			width: innerWidth,
			height: innerHeight,
			resourceWidth: document.querySelector(".dora-resource-panel")
				?.getBoundingClientRect().width ?? -1,
			contentWidth: document.querySelector(".dora-content-panel")
				?.getBoundingClientRect().width ?? -1,
			drawerButtonVisible: Boolean(document.querySelector(
				'button[aria-label="open drawer"]'
			)),
		}))()`);
		await delay(500);

		return {
			device,
			splitter: {
				before: splitter.before,
				after: splitterAfter,
				delta: splitterAfter - splitter.before,
			},
			search,
			searchClosedWithEscape: true,
			projectOpened: true,
			rotation: {
				before: rotationBefore,
				after: rotationAfter,
			},
			drawerClosed: true,
			consoleErrors: [...new Set(client.consoleErrors)],
		};
	} finally {
		await target.close();
	}
}

async function sampleMobile(port) {
	return {
		portrait: await sampleMobilePortrait(port),
		landscape: await sampleMobileLandscape(port),
	};
}

const userDataDir = await mkdtemp(join(tmpdir(), "dora-web-perf-"));
const chrome = spawn(chromePath, [
	"--headless=new",
	"--remote-debugging-port=0",
	`--user-data-dir=${userDataDir}`,
	"--no-first-run",
	"--disable-default-apps",
	"--disable-background-networking",
	"--disable-component-update",
	"--disable-sync",
	"about:blank",
], { stdio: "ignore" });

let report;
try {
	const portFile = join(userDataDir, "DevToolsActivePort");
	await waitForFile(portFile);
	const [portText] = (await readFile(portFile, "utf8")).trim().split("\n");
	const port = Number(portText);
	if (mobileMode) {
		const sample = await sampleMobile(port);
		const { landscape, portrait } = sample;
		const failures = [];
		if (portrait.device.maxTouchPoints < 1 || landscape.device.maxTouchPoints < 1) {
			failures.push("touch emulation is unavailable");
		}
		if (portrait.initial.resourceWidth >= 1
			|| portrait.initial.contentWidth < portrait.device.width - 1) {
			failures.push("portrait layout did not start with a full-width content panel");
		}
		if (portrait.overlay.resourceWidth < 100
			|| portrait.overlay.contentWidth < portrait.device.width - 1
			|| !portrait.overlay.closeButtonVisible) {
			failures.push("portrait resource drawer did not behave as an overlay");
		}
		if (Math.abs(landscape.splitter.delta) < 20) {
			failures.push(`splitter moved only ${landscape.splitter.delta.toFixed(2)} px`);
		}
		if (landscape.rotation.before.resourceWidth < 100
			|| landscape.rotation.after.resourceWidth >= 1
			|| landscape.rotation.after.contentWidth < landscape.rotation.after.width - 1
			|| !landscape.rotation.after.drawerButtonVisible) {
			failures.push("landscape-to-portrait rotation did not close the drawer");
		}
		if (landscape.search.results < 1 || landscape.search.results > 100) {
			failures.push(`mobile search returned ${landscape.search.results} items`);
		}
		if (landscape.search.p95 >= 16) {
			failures.push(`mobile search P95 ${landscape.search.p95.toFixed(2)} ms exceeds 16 ms`);
		}
		const consoleErrors = [...portrait.consoleErrors, ...landscape.consoleErrors];
		if (consoleErrors.length > 0) {
			failures.push(`browser console reported ${consoleErrors.length} errors`);
		}
		report = {
			generatedAt: new Date().toISOString(),
			environment: {
				baseUrl,
				chromePath,
				viewports: ["390x844", "844x390"],
				deviceScaleFactor: 3,
				projectPath: agentProjectPath,
			},
			budgets: {
				portraitContentWidth: "full viewport",
				portraitDrawer: "overlay with close control",
				rotation: "landscape drawer closes on portrait transition",
				splitterMovementPx: ">= 20",
				searchP95Ms: 16,
				searchResults: "1..100",
				consoleErrors: 0,
			},
			sample,
			pass: failures.length === 0,
			failures,
		};
		console.log(JSON.stringify(report, null, 2));
		if (failures.length > 0) process.exitCode = 1;
	} else if (agentMode) {
		const sample = await sampleAgent(port);
		const failures = [];
		if (sample.frameP95 >= 25) {
			failures.push(`Agent frame P95 ${sample.frameP95.toFixed(2)} ms exceeds 25 ms`);
		}
		if (sample.longTaskMax >= 100) {
			failures.push(`Agent long task max ${sample.longTaskMax.toFixed(2)} ms exceeds 100 ms`);
		}
		if (sample.thinkingPositionP95 > 1) {
			failures.push(`Agent thinking position P95 ${sample.thinkingPositionP95.toFixed(2)} px exceeds 1 px`);
		}
		if (sample.stableMessageRenderGrowth > 0 || sample.stableStepRenderGrowth > 0) {
			failures.push("stable Agent history rows rendered during the synthetic stream");
		}
		if (sample.probeRenderCount > sample.renderBudget) {
			failures.push(`Agent probe rendered ${sample.probeRenderCount} times, budget ${sample.renderBudget}`);
		}
		if (sample.delta.listeners > listenerGrowthBudget) {
			failures.push(`Agent listeners grew by ${sample.delta.listeners}`);
		}
		if (sample.delta.heap > heapGrowthBudget) {
			failures.push(`Agent heap grew by ${(sample.delta.heap / 1024 / 1024).toFixed(2)} MiB`);
		}
		report = {
			generatedAt: new Date().toISOString(),
			environment: {
				baseUrl,
				chromePath,
				projectPath: agentProjectPath,
				durationMs: agentDurationMs,
				patchIntervalMs: agentPatchIntervalMs,
			},
			budgets: {
				frameP95Ms: 25,
				longTaskMaxMs: 100,
				thinkingPositionP95Px: 1,
				stableRenderGrowth: 0,
				probeRenderCommits: `<= ${sample.renderBudget}`,
				listenerGrowth: listenerGrowthBudget,
				heapGrowthMiB: heapGrowthBudget / 1024 / 1024,
			},
			sample,
			pass: failures.length === 0,
			failures,
		};
		console.log(JSON.stringify(report, null, 2));
		if (failures.length > 0) process.exitCode = 1;
	} else {
	const samples = [];
	for (let run = 1; run <= runs; run += 1) {
		samples.push({
			run,
			search: await sampleSearch(port, run),
			tabs: await sampleTabs(port, run),
		});
	}
	const failures = [];
	for (const sample of samples) {
		if (sample.search.search.count !== 50) {
			failures.push(`run ${sample.run}: expected 50 search samples, got ${sample.search.search.count}`);
		}
		if (sample.search.search.p95 >= 16) {
			failures.push(`run ${sample.run}: search P95 ${sample.search.search.p95} ms exceeds 16 ms`);
		}
		if (sample.search.search.results > 100) {
			failures.push(`run ${sample.run}: search returned ${sample.search.search.results} items`);
		}
		if (sample.tabs.switchP95 >= 100) {
			failures.push(`run ${sample.run}: tab switch P95 ${sample.tabs.switchP95.toFixed(2)} ms exceeds 100 ms`);
		}
		if (sample.tabs.maxMainCount > 2) {
			failures.push(`run ${sample.run}: mounted main count reached ${sample.tabs.maxMainCount}`);
		}
		if (sample.tabs.delta.listeners > listenerGrowthBudget) {
			failures.push(`run ${sample.run}: listeners grew by ${sample.tabs.delta.listeners}`);
		}
		if (sample.tabs.delta.heap > heapGrowthBudget) {
			failures.push(`run ${sample.run}: heap grew by ${(sample.tabs.delta.heap / 1024 / 1024).toFixed(2)} MiB`);
		}
	}
	report = {
		generatedAt: new Date().toISOString(),
		environment: {
			baseUrl,
			chromePath,
			runs,
			sampleFile,
			projectPaths: projectPaths.slice(0, 2),
		},
		budgets: {
			searchP95Ms: 16,
			tabSwitchP95Ms: 100,
			maxMountedMains: 2,
			listenerGrowth: listenerGrowthBudget,
			heapGrowthMiB: heapGrowthBudget / 1024 / 1024,
		},
		samples,
		pass: failures.length === 0,
		failures,
	};
	console.log(JSON.stringify(report, null, 2));
	if (failures.length > 0) process.exitCode = 1;
	}
} finally {
	chrome.kill("SIGTERM");
	await delay(200);
	await rm(userDataDir, { recursive: true, force: true });
}
