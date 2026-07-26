import { performance } from "node:perf_hooks";
import { resolve } from "node:path";
import { matchSorter } from "match-sorter";

const baseUrl = process.env.DORA_PERF_BASE_URL ?? "http://127.0.0.1:8866";
const repoPath = process.env.DORA_PERF_REPO ?? resolve(process.cwd(), "../..");

async function post(path, body) {
	const startedAt = performance.now();
	const response = await fetch(new URL(path, baseUrl), {
		method: "POST",
		headers: { "content-type": "application/json" },
		body: body === undefined ? undefined : JSON.stringify(body),
	});
	const text = await response.text();
	const elapsedMs = performance.now() - startedAt;
	let data;
	try {
		data = JSON.parse(text);
	} catch {
		data = null;
	}
	return {
		ok: response.ok,
		status: response.status,
		elapsedMs,
		decodedBytes: Buffer.byteLength(text),
		contentLength: Number(response.headers.get("content-length")) || undefined,
		data,
	};
}

function median(values) {
	const sorted = [...values].sort((left, right) => left - right);
	const middle = Math.floor(sorted.length / 2);
	return sorted.length % 2 === 0
		? (sorted[middle - 1] + sorted[middle]) / 2
		: sorted[middle];
}

function countTreeNodes(value) {
	if (Array.isArray(value)) {
		return value.reduce((count, item) => count + countTreeNodes(item), 0);
	}
	if (!value || typeof value !== "object") return 0;
	return 1 + countTreeNodes(value.children);
}

const assets = await post("/assets");
const workspacePath = process.env.DORA_PERF_WORKSPACE
	?? (typeof assets.data?.key === "string" ? assets.data.key : resolve(process.cwd(), "../.."));
const assetFiles = await post("/assets/files", { path: workspacePath });
const files = assetFiles.data?.success && Array.isArray(assetFiles.data.files)
	? assetFiles.data.files
	: [];

const searchSamples = {};
for (const query of ["s", "sk", "ske", "agent"]) {
	const timings = [];
	for (let run = 0; run < 5; run += 1) {
		const startedAt = performance.now();
		matchSorter(files, query);
		timings.push(performance.now() - startedAt);
	}
	searchSamples[query] = {
		medianMs: median(timings),
		minMs: Math.min(...timings),
		maxMs: Math.max(...timings),
	};
}

const gitHistory = await post("/git/history", { repoPath, limit: 1000 });
const historyCommits = Array.isArray(gitHistory.data?.status?.data?.commits)
	? gitHistory.data.status.data.commits
	: [];
const report = {
	generatedAt: new Date().toISOString(),
	environment: {
		baseUrl,
		workspacePath,
		repoPath,
	},
	assets: {
		ok: assets.ok,
		status: assets.status,
		elapsedMs: assets.elapsedMs,
		decodedBytes: assets.decodedBytes,
		contentLength: assets.contentLength,
		nodeCount: countTreeNodes(assets.data),
	},
	assetFiles: {
		ok: assetFiles.ok,
		status: assetFiles.status,
		elapsedMs: assetFiles.elapsedMs,
		decodedBytes: assetFiles.decodedBytes,
		contentLength: assetFiles.contentLength,
		fileCount: files.length,
	},
	searchSamples,
	gitHistory: {
		ok: gitHistory.ok,
		status: gitHistory.status,
		elapsedMs: gitHistory.elapsedMs,
		decodedBytes: gitHistory.decodedBytes,
		contentLength: gitHistory.contentLength,
		success: gitHistory.data?.success,
		jobId: gitHistory.data?.jobId,
		commitCount: historyCommits.length,
		includesChangedFiles: historyCommits.some((commit) => Array.isArray(commit?.files)),
	},
};

console.log(JSON.stringify(report, null, 2));
