// @preview-file off clear
import { Content, Path, Director, once } from 'Dora';
import {
	ensureSafeSearchGlobs,
	isValidWorkspacePath,
	readFile,
	splitSearchPatterns,
	splitWhitespaceSearchPatterns,
	AGENT_DORA_DOC_PREFIX,
	getDoraDocSearchTarget,
	getDoraDocResultBaseRoot,
	isDoraDocFileInScope,
	toDocRelativePath,
} from 'Agent/Tool/Workspace';
import type {
	DoraDocLanguage,
	DoraDocSearchType,
	DoraDocProgrammingLanguage,
	DoraDocSearchHit,
	DoraDocSearchResult,
	DoraDocReadResult,
} from 'Agent/Tool/Workspace';
export type {
	DoraDocLanguage,
	DoraDocSearchType,
	DoraDocProgrammingLanguage,
	DoraDocSearchHit,
	DoraDocSearchResult,
	DoraDocReadResult,
} from 'Agent/Tool/Workspace';

function mergeDoraDocSearchHitsUnique(resultsList: DoraDocSearchHit[][]): DoraDocSearchHit[] {
	const merged: DoraDocSearchHit[] = [];
	const seen = new Set<string>();
	let index = 0;
	let advanced = true;
	while (advanced) {
		advanced = false;
		for (let i = 0; i < resultsList.length; i++) {
			const list = resultsList[i];
			if (index >= list.length) continue;
			advanced = true;
			const row = list[index];
			const key = `${row.file}:${tostring(row.line ?? "")}:${tostring(row.content ?? "")}`;
			if (seen.has(key)) continue;
			seen.add(key);
			merged.push(row);
		}
		index += 1;
	}
	return merged;
}

function getDoraDocFilePriority(file: string, docType: DoraDocSearchType, programmingLanguage: DoraDocProgrammingLanguage): number {
	if (docType !== "dora-api") return 100;
	if (programmingLanguage !== "tsx") return 100;
	switch (Path.getFilename(file).toLowerCase()) {
		case "jsx.d.ts": return 0;
		case "dorax.d.ts": return 1;
		case "dora.d.ts": return 2;
		default: return 100;
	}
}

function sortDoraDocSearchHits(
	hits: DoraDocSearchHit[],
	docType: DoraDocSearchType,
	programmingLanguage: DoraDocProgrammingLanguage
): DoraDocSearchHit[] {
	const sorted = hits.slice();
	sorted.sort((a, b) => {
		const pa = getDoraDocFilePriority(a.file, docType, programmingLanguage);
		const pb = getDoraDocFilePriority(b.file, docType, programmingLanguage);
		if (pa !== pb) return pa - pb;
		const fa = a.file.toLowerCase();
		const fb = b.file.toLowerCase();
		if (fa !== fb) return fa < fb ? -1 : 1;
		return (a.line ?? 0) - (b.line ?? 0);
	});
	return sorted;
}

export async function searchDoraDoc(req: {
	pattern: string;
	docLanguage: DoraDocLanguage;
	programmingLanguage: DoraDocProgrammingLanguage;
	docType?: DoraDocSearchType;
	limit?: number;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
}): Promise<DoraDocSearchResult> {
	const pattern = (req.pattern ?? "").trim();
	if (pattern === "") return { success: false, message: "empty pattern" };
	const patterns = splitSearchPatterns(pattern);
	if (patterns.length === 0) return { success: false, message: "empty pattern" };
	const docType = req.docType ?? "dora-api";
	const target = getDoraDocSearchTarget(docType, req.docLanguage, req.programmingLanguage);
	const docRoot = target.root;
	const resultBaseRoot = getDoraDocResultBaseRoot(docType, req.docLanguage);
	if (!Content.exist(docRoot) || !Content.isdir(docRoot)) {
		return { success: false, message: `doc root not found: ${docRoot}` };
	}
	const exts = target.exts;
	const dotExts = exts.map(ext => ext.startsWith(".") ? ext : `.${ext}`);
	const globs = target.globs;
	const limit = math.max(1, math.floor(req.limit ?? 10));

	return new Promise(resolve => {
		Director.systemScheduler.schedule(once(() => {
			try {
				const allHits: DoraDocSearchHit[][] = [];
				for (let p = 0; p < patterns.length; p++) {
					const raw = Content.searchFilesAsync(
						docRoot,
						dotExts,
						{},
						ensureSafeSearchGlobs(globs),
						patterns[p],
						req.useRegex ?? false,
						req.caseSensitive ?? false,
						req.includeContent ?? true,
						req.contentWindow ?? 80
					);
					const hits: DoraDocSearchHit[] = [];
					for (let i = 0; i < raw.length; i++) {
						const row = raw[i];
						const file = toDocRelativePath(resultBaseRoot, row.file, docType);
						if (file === "") continue;
						hits.push({
							file,
							line: typeof row.line === "number" ? row.line : undefined,
							content: typeof row.content === "string" ? row.content : undefined,
						});
					}
					allHits.push(sortDoraDocSearchHits(hits, docType, req.programmingLanguage).slice(0, limit));
				}
				let hits = mergeDoraDocSearchHitsUnique(allHits);
				let fallbackPatterns: string[] | undefined;
				// Preserve phrase search first. If a model sends a space-separated
				// keyword list instead of the documented `|` form and gets no hits,
				// retry the individual terms inside the same tool call.
				if (hits.length === 0 && patterns.length === 1 && req.useRegex !== true && pattern.indexOf("|") < 0) {
					const terms = splitWhitespaceSearchPatterns(pattern);
					if (terms.length > 1) {
						fallbackPatterns = terms;
						const fallbackHits: DoraDocSearchHit[][] = [];
						for (let p = 0; p < terms.length; p++) {
							const raw = Content.searchFilesAsync(
								docRoot,
								dotExts,
								{},
								ensureSafeSearchGlobs(globs),
								terms[p],
								false,
								req.caseSensitive ?? false,
								req.includeContent ?? true,
								req.contentWindow ?? 80
							);
							const termHits: DoraDocSearchHit[] = [];
							for (let i = 0; i < raw.length; i++) {
								const row = raw[i];
								const file = toDocRelativePath(resultBaseRoot, row.file, docType);
								if (file === "") continue;
								termHits.push({
									file,
									line: typeof row.line === "number" ? row.line : undefined,
									content: typeof row.content === "string" ? row.content : undefined,
								});
							}
							fallbackHits.push(sortDoraDocSearchHits(termHits, docType, req.programmingLanguage).slice(0, limit));
						}
						hits = mergeDoraDocSearchHitsUnique(fallbackHits);
					}
				}
				resolve({
					success: true,
					docType,
					docLanguage: req.docLanguage,
					programmingLanguage: req.programmingLanguage,
					exts,
					results: hits,
				hint: "Use read_file with a namespaced result to view it, or grep_files with that exact @dora-doc path to search within the document.",
					totalResults: hits.length,
					truncated: false,
					limit,
					fallbackPatterns,
				});
			} catch (e) {
				resolve({ success: false, message: tostring(e) });
			}
		}));
	});
}

export function searchDoraDocHttp(req: {
	pattern: string;
	docLanguage: DoraDocLanguage;
	programmingLanguage: DoraDocProgrammingLanguage;
	docType?: DoraDocSearchType;
	limit?: number;
	useRegex?: boolean;
	caseSensitive?: boolean;
	includeContent?: boolean;
	contentWindow?: number;
}, callback: (result: DoraDocSearchResult) => void) {
	searchDoraDoc(req).then(result => callback(result));
}

export function readDoraDoc(req: {
	docLanguage: DoraDocLanguage;
	file: string;
	startLine?: number;
	endLine?: number;
}): DoraDocReadResult {
	const requestedFile = (req.file ?? "").split("\\").join("/");
	let file = requestedFile;
	let namespacedType: DoraDocSearchType | undefined = undefined;
	if (requestedFile.startsWith(AGENT_DORA_DOC_PREFIX)) {
		const namespaced = requestedFile.slice(AGENT_DORA_DOC_PREFIX.length);
		if (namespaced.startsWith("dora-api/")) {
			namespacedType = "dora-api";
			file = namespaced.slice(9);
		} else if (namespaced.startsWith("love-api/")) {
			namespacedType = "love-api";
			file = namespaced.slice(9);
		} else if (namespaced.startsWith("tic80-api/")) {
			namespacedType = "tic80-api";
			file = namespaced.slice(10);
		} else if (namespaced.startsWith("dora-tutorial/")) {
			namespacedType = "dora-tutorial";
			file = namespaced.slice(14);
		} else if (namespaced.startsWith("api/")) {
			namespacedType = "dora-api";
			file = namespaced.slice(4);
		} else if (namespaced.startsWith("tutorial/")) {
			namespacedType = "dora-tutorial";
			file = namespaced.slice(9);
		} else {
			return { success: false, message: "invalid Dora doc namespace" };
		}
	}
	if (!isValidWorkspacePath(file) || file === ".") {
		return { success: false, message: "invalid file" };
	}
	const lowerFile = file.toLowerCase();
	const isTutorialDoc = lowerFile.endsWith(".md");
	const isAPIDoc = lowerFile.endsWith(".ts") || lowerFile.endsWith(".tl");
	if (!isTutorialDoc && !isAPIDoc) return { success: false, message: "unsupported doc file type" };
	const docType: DoraDocSearchType = namespacedType ?? (isTutorialDoc ? "dora-tutorial" : "dora-api");
	if (!isDoraDocFileInScope(docType, file)) {
		return { success: false, message: "document is outside the requested search type" };
	}
	const root = getDoraDocResultBaseRoot(docType, req.docLanguage);
	const fullPath = Path(root, file);
	const relative = Path.getRelative(fullPath, root);
	if (relative === ".." || relative.startsWith("../") || relative.startsWith("..\\")) {
		return { success: false, message: "invalid file" };
	}
	const readResult = readFile(root, file, req.startLine ?? 1, req.endLine ?? -1);
	if (!readResult.success) return readResult;
	return {
		success: true,
		docLanguage: req.docLanguage,
		file,
		content: readResult.content,
		startLine: readResult.startLine,
		endLine: readResult.endLine,
	};
}
