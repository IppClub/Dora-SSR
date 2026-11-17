// @preview-file off clear
import { Content, Path } from 'Dora';
import { safeJsonDecode, safeJsonEncode } from 'Agent/Utils';
import { readFile, inspectWorkspaceTextTarget } from 'Agent/Tool/Workspace';
import { createCommandContent } from 'Agent/Tool/CommandContent';
import { executeRegisteredAgentTool } from 'Agent/Tool/Executor';
import { sanitizeReadResultForHistory } from 'Agent/Runtime/HistoryProjection';
import type { AgentToolExecutionContext } from 'Agent/Tool/Types';

export async function runTests(workDir: string): Promise<string> {
	Content.addSearchPath(Path(workDir, "packed.zip"));
	const failures: string[] = [];
	let checks = 0;
	const check = (condition: boolean, message: string) => {
		checks++;
		if (!condition && failures.length < 12) failures.push(message);
	};
	const [cases] = safeJsonDecode(Content.load(Path(workDir, "cases.json")));
	for (const item of cases as {path: string; expected?: Record<string, unknown>; absent?: string[]}[]) {
		const result = readFile(workDir, item.path);
		check(result.success === false, `${item.path}: remains a refused read`);
		const record = result as unknown as Record<string, unknown>;
		check(record.isBinary === true && record.content === undefined, `${item.path}: no binary content`);
		const metadata = record.metadata as Record<string, unknown> | undefined;
		if (item.expected !== undefined) {
			check(metadata !== undefined, `${item.path}: metadata exists`);
			for (const key of Object.keys(item.expected)) {
				const actual = metadata?.[key], expected = item.expected[key];
				check(typeof actual === "number" && typeof expected === "number"
					? math.abs(actual - expected) < 0.001 : actual === expected, `${item.path}: ${key}`);
			}
			check(metadata?.source === "header", `${item.path}: header provenance`);
		} else {
			check(metadata === undefined && typeof record.metadataMessage === "string", `${item.path}: unknown metadata is explicit`);
		}
		for (const key of item.absent ?? []) check(metadata?.[key] === undefined, `${item.path}: ${key} is unknown`);
		const [encoded] = safeJsonEncode(record);
		check(encoded !== undefined && encoded.indexOf("DO_NOT_RETURN_BINARY_PAYLOAD") < 0, `${item.path}: payload never returned`);
		check(encoded !== undefined && encoded.length < 1400, `${item.path}: bounded structured result`);
	}
	const text = readFile(workDir, "plain.txt", 2, 2);
	check(text.success && text.content.indexOf("second line") >= 0 && text.startLine === 2, "text line reads preserved");
	const missing = readFile(workDir, "missing.png") as unknown as Record<string, unknown>;
	check(missing.success === false && missing.metadata === undefined, "missing file has no fabricated metadata");
	const escaped = readFile(workDir, "../outside.png") as unknown as Record<string, unknown>;
	check(escaped.success === false && escaped.metadata === undefined, "workspace path boundary preserved");
	check(inspectWorkspaceTextTarget(workDir, "image.png").success === false, "binary editing remains refused");
	const commandContent = createCommandContent(workDir) as {load(this: void, path: string): string; read?: unknown};
	const [loadAllowed] = pcall(() => commandContent.load("image.png"));
	check(!loadAllowed && commandContent.read === undefined, "execute_command binary load and range read remain unavailable");
	const context: AgentToolExecutionContext = {
		sessionId: 10, taskId: 1, step: 1, workingDir: workDir, role: "main", workMode: "code",
		useChineseResponse: false, disabledAgentTools: [],
		cancellation: {stopToken: {stopped: false}, isCancelled: () => false, reason: () => undefined},
		emitProgress: () => {}, services: {}, workflow: {},
	};
	const batch = await executeRegisteredAgentTool({tool: "read_file", input: {reads: [
		{path: "plain.txt"}, {path: "image.png"}, {path: "tone.ogg"}, {path: "unknown.bin"},
	]}, context, schemaContext: {searchDoraDocLimitMax: 20}});
	check(batch.output.success === false && batch.output.partial === true && batch.output.succeededReadCount === 1,
		"mixed batch keeps binary refusals distinct from text success");
	const results = batch.output.results as Record<string, unknown>[];
	check((results[1].metadata as Record<string, unknown>)?.width === 17 && results[1].content === undefined, "handler preserves image metadata without bytes");
	check((results[2].metadata as Record<string, unknown>)?.codec === "vorbis" && results[2].content === undefined, "handler preserves audio metadata without bytes");
	const history = sanitizeReadResultForHistory("read_file", batch.output);
	const retained = (history.results as Record<string, unknown>[])[1];
	check((retained.metadata as Record<string, unknown>)?.width === 17 && retained.content === undefined, "history keeps metadata and binary refusal");
	Content.removeSearchPath(Path(workDir, "packed.zip"));
	return `${failures.length === 0 ? "passed" : "failed"}: ${checks} checks\n${failures.join("\n")}`;
}
