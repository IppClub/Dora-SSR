const baseUrl = process.env.DORA_PERF_BASE_URL ?? "http://127.0.0.1:8866";
const durationSeconds = Number(process.env.DORA_LOG_DURATION ?? 30);
const linesPerSecond = Number(process.env.DORA_LOG_LINES_PER_SECOND ?? 400);

if (!Number.isFinite(durationSeconds) || durationSeconds <= 0) {
	throw new Error("DORA_LOG_DURATION must be a positive number.");
}
if (!Number.isFinite(linesPerSecond) || linesPerSecond <= 0) {
	throw new Error("DORA_LOG_LINES_PER_SECOND must be a positive number.");
}

const startedAt = performance.now();
let emittedLines = 0;
for (let second = 0; second < durationSeconds; second += 1) {
	const start = second * linesPerSecond + 1;
	const end = start + linesPerSecond - 1;
	const response = await fetch(`${baseUrl}/command`, {
		method: "POST",
		headers: { "content-type": "application/json" },
		body: JSON.stringify({
			code: `for i = ${start}, ${end}\n\tprint "perf-log-#{i}"`,
			log: true,
		}),
	});
	const result = await response.json();
	if (!response.ok || result.success !== true) {
		throw new Error(`Log pressure command failed at second ${second + 1}: ${JSON.stringify(result)}`);
	}
	emittedLines += linesPerSecond;
	if (second + 1 < durationSeconds) {
		await new Promise(resolve => setTimeout(resolve, 1000));
	}
}

console.log(JSON.stringify({
	durationSeconds,
	linesPerSecond,
	emittedLines,
	elapsedMs: Math.round(performance.now() - startedAt),
}, null, 2));
