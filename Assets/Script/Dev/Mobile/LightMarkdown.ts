export type LightBlockKind = "heading1" | "heading2" | "paragraph" | "list" | "task" | "code";

export interface LightBlock {
	kind: LightBlockKind;
	text: string;
}

const cleanInline = (text: string) => {
	let result = string.gsub(text, "%*%*", "")[0];
	result = string.gsub(result, "__", "")[0];
	result = string.gsub(result, "`", "")[0];
	return result;
};

export function parseLightMarkdown(source: string): LightBlock[] {
	const blocks: LightBlock[] = [];
	const lines = source.split("\n");
	let code = false;
	for (let i = 0; i < lines.length; i++) {
		const raw = lines[i].trim();
		if (raw.slice(0, 3) === "```") { code = !code; continue; }
		if (raw === "") continue;
		if (code) { blocks.push({ kind: "code", text: raw }); continue; }
		if (raw.slice(0, 3) === "## ") { blocks.push({ kind: "heading2", text: cleanInline(raw.slice(3)) }); continue; }
		if (raw.slice(0, 2) === "# ") { blocks.push({ kind: "heading1", text: cleanInline(raw.slice(2)) }); continue; }
		if (raw.slice(0, 6) === "- [ ] ") { blocks.push({ kind: "task", text: `□ ${cleanInline(raw.slice(6))}` }); continue; }
		if (raw.slice(0, 6) === "- [x] " || raw.slice(0, 6) === "- [X] ") { blocks.push({ kind: "task", text: `■ ${cleanInline(raw.slice(6))}` }); continue; }
		if (raw.slice(0, 2) === "- " || raw.slice(0, 2) === "* ") { blocks.push({ kind: "list", text: `• ${cleanInline(raw.slice(2))}` }); continue; }
		blocks.push({ kind: "paragraph", text: cleanInline(raw) });
	}
	return blocks;
}
