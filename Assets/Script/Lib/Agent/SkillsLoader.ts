// @preview-file off clear
import { Content, Path } from 'Dora';
import { Log } from 'Agent/Utils';

export interface SkillMetadata {
	name: string;
	description: string;
	always?: boolean;
}

export interface Skill extends SkillMetadata {
	location: string;
	body?: string;
}

export interface SkillsLoaderConfig {
	projectDir: string;
}

enum SkillPriority {
	BuiltIn = 0,
	User = 1,
	Project = 2,
}

interface SkillEntry {
	skill: Skill;
	priority: SkillPriority;
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== undefined;
}

function isArray(value: unknown): value is unknown[] {
	return Array.isArray(value);
}

function stripWrappingQuotes(value: string): string {
	let [result] = string.gsub(value, '^"(.*)"$', "%1");
	[result] = string.gsub(result, "^'(.*)'$", "%1");
	return result;
}

function escapeXMLText(text: string): string {
	let [result] = string.gsub(text, "&", "&amp;");
	[result] = string.gsub(result, "<", "&lt;");
	[result] = string.gsub(result, ">", "&gt;");
	[result] = string.gsub(result, '"', "&quot;");
	[result] = string.gsub(result, "'", "&apos;");
	return result;
}

function parseYAMLFrontmatter(content: string): {
	metadata: Record<string, unknown> | undefined;
	body: string;
	error?: string;
} {
	if (!content || content.trim() === "") {
		return { metadata: undefined, body: "", error: "empty content" };
	}

	const trimmed = content.trim();
	if (!trimmed.startsWith("---")) {
		return { metadata: undefined, body: content };
	}

	const lines = trimmed.split("\n");
	let endLine = -1;
	for (let i = 1; i < lines.length; i++) {
		if (lines[i].trim() === "---") {
			endLine = i;
			break;
		}
	}

	if (endLine < 0) {
		return { metadata: undefined, body: content, error: "missing closing ---" };
	}

	const frontmatterLines = lines.slice(1, endLine);
	const frontmatterText = frontmatterLines.join("\n").trim();

	const metadata = parseSimpleYAML(frontmatterText);

	const bodyLines = lines.slice(endLine + 1);
	const body = bodyLines.join("\n").trim();

	return { metadata, body };
}

function parseSimpleYAML(text: string): Record<string, unknown> | undefined {
	if (!text || text.trim() === "") {
		return undefined;
	}

	const result: Record<string, unknown> = {};
	const lines = text.split("\n");
	let currentKey = "";
	let currentArray: string[] | undefined = undefined;

	for (let i = 0; i < lines.length; i++) {
		const line = lines[i];
		const trimmed = line.trim();

		if (trimmed === "" || trimmed.startsWith("#")) {
			continue;
		}

		if (trimmed.startsWith("- ")) {
			if (currentArray !== undefined && currentKey !== "") {
				const value = trimmed.substring(2).trim();
				const cleaned = stripWrappingQuotes(value);
				currentArray.push(cleaned);
			}
			continue;
		}

		const colonIndex = trimmed.indexOf(":");
		if (colonIndex > 0) {
			if (currentArray !== undefined && currentKey !== "") {
				result[currentKey] = currentArray;
				currentArray = undefined;
			}

			const key = trimmed.substring(0, colonIndex).trim();
			let value = trimmed.substring(colonIndex + 1).trim();

			if (value.startsWith("[") && value.endsWith("]")) {
				const arrayText = value.substring(1, value.length - 1);
				const items = arrayText.split(",").map(item => {
					const cleaned = stripWrappingQuotes(item.trim());
					return cleaned;
				});
				result[key] = items;
				continue;
			}

			if (value === "true") {
				result[key] = true;
				continue;
			}
			if (value === "false") {
				result[key] = false;
				continue;
			}

			if (value === "") {
				currentKey = key;
				currentArray = [];
				if (i + 1 < lines.length) {
					const nextLine = lines[i + 1].trim();
					if (!nextLine.startsWith("- ")) {
						currentArray = undefined;
						result[key] = "";
					}
				} else {
					currentArray = undefined;
					result[key] = "";
				}
				continue;
			}

			const cleaned = stripWrappingQuotes(value);
			result[key] = cleaned;
			currentKey = "";
			currentArray = undefined;
		}
	}

	if (currentArray !== undefined && currentKey !== "") {
		result[currentKey] = currentArray;
	}

	return result;
}

function validateSkillMetadata(
	metadata?: Record<string, unknown>
): { metadata: SkillMetadata; error?: string } {
	if (!metadata) {
		return {
			metadata: {
				name: "",
				description: "",
			},
			error: "missing frontmatter",
		};
	}

	const name = typeof metadata.name === "string" ? metadata.name.trim() : "";
	if (name === "") {
		return {
			metadata: {
				name: "",
				description: "",
			},
			error: "missing name in frontmatter",
		};
	}

	const description = typeof metadata.description === "string"
		? metadata.description.trim()
		: "";

	const always = metadata.always === true;

	return {
		metadata: {
			name,
			description,
			always
		},
	};
}

export class SkillsLoader {
	private config: SkillsLoaderConfig;
	private skills: Map<string, SkillEntry> = new Map();
	private loaded = false;

	constructor(config: SkillsLoaderConfig) {
		this.config = config;
	}

	load(): void {
		this.skills.clear();

		const builtInDir = Path(Content.assetPath, "Doc", "skills");
		const builtInParent = Content.assetPath;
		this.loadSkillsFromDir(builtInDir, builtInParent, SkillPriority.BuiltIn);

		const userDir = Path(Content.writablePath, ".agent", "skills");
		const userParent = Content.writablePath;
		this.loadSkillsFromDir(userDir, userParent, SkillPriority.User);

		const projectDir = Path(this.config.projectDir, ".agent", "skills");
		const projectParent = this.config.projectDir;
		this.loadSkillsFromDir(projectDir, projectParent, SkillPriority.Project);

		this.loaded = true;
		Log("Info", `[SkillsLoader] Loaded ${this.skills.size} skills`);
	}

	private loadSkillsFromDir(dir: string, parent: string, priority: SkillPriority): void {
		if (!Content.exist(dir) || !Content.isdir(dir)) {
			return;
		}

		const subdirs = Content.getDirs(dir);
		if (!subdirs || subdirs.length === 0) {
			return;
		}

		for (const subdir of subdirs) {
			const skillPath = Path(dir, subdir, "SKILL.md");
			if (!Content.exist(skillPath)) {
				continue;
			}

			const skill = this.loadSkillFile(skillPath);
			if (!skill) {
				continue;
			}

			skill.location = Path.getRelative(skillPath, parent);

			const existing = this.skills.get(skill.name);
			if (existing && existing.priority >= priority) {
				continue;
			}

			this.skills.set(skill.name, { skill, priority });
		}
	}

	private loadSkillFile(skillPath: string): Skill | undefined {
		const content = Content.load(skillPath);
		if (!content) {
			Log("Warn", `[SkillsLoader] Failed to read ${skillPath}`);
			return undefined;
		}

		const parsed = parseYAMLFrontmatter(content);
		const validated = validateSkillMetadata(parsed.metadata);

		if (validated.error) {
			Log("Warn", `[SkillsLoader] Invalid SKILL.md at ${skillPath}: ${validated.error}`);
			return undefined;
		}

		let displayLocation = skillPath;
		if (skillPath.startsWith(this.config.projectDir)) {
			displayLocation = Path.getRelative(skillPath, this.config.projectDir);
		}

		const skill: Skill = {
			...validated.metadata,
			location: displayLocation,
			body: parsed.body,
		};

		return skill;
	}

	getAllSkills(): Skill[] {
		if (!this.loaded) {
			this.load();
		}

		const result: Skill[] = [];
		for (const entry of this.skills.values()) {
			result.push(entry.skill);
		}

		result.sort();

		return result;
	}

	getSkill(name: string): Skill | undefined {
		if (!this.loaded) {
			this.load();
		}

		return this.skills.get(name)?.skill;
	}

	getAlwaysSkills(): Skill[] {
		const all = this.getAllSkills();
		return all.filter(skill => skill.always === true);
	}

	getSummarySkills(): Skill[] {
		const all = this.getAllSkills();
		return all.filter(skill => skill.always !== true);
	}

	buildLevel1Summary(): string {
		const skills = this.getSummarySkills();

		if (skills.length === 0) {
			return "";
		}

		const parts: string[] = [];

		for (const skill of skills) {
			let skillXML = `<skill>\n`;
			skillXML += `	<name>${this.escapeXML(skill.name)}</name>\n`;
			skillXML += `	<description>${this.escapeXML(skill.description)}</description>\n`;
			skillXML += `	<location>${this.escapeXML(skill.location)}</location>\n`;
			skillXML += `</skill>`;
			parts.push(skillXML);
		}

		return parts.join("\n\n");
	}

	buildActiveSkillsContent(): string {
		const skills = this.getAlwaysSkills();

		if (skills.length === 0) {
			return "";
		}

		const parts: string[] = [];

		for (const skill of skills) {
			parts.push(`## Skill: ${skill.name}\n`);
			if (skill.description !== undefined) {
				parts.push(`${skill.description}\n`);
			}
			if (skill.body && skill.body.trim() !== "") {
				parts.push(`\n${skill.body}`);
			}
			parts.push("");
		}

		return parts.join("\n");
	}

	loadSkillContent(name: string): string | undefined {
		const skill = this.getSkill(name);
		if (!skill) {
			return undefined;
		}

		if (skill.body && skill.body.trim() !== "") {
			return skill.body;
		}

		const content = Content.load(skill.location);
		if (!content) {
			return undefined;
		}

		const parsed = parseYAMLFrontmatter(content);
		return parsed.body || undefined;
	}

	buildSkillsPromptSection(): string {
		if (!this.loaded) {
			this.load();
		}

		const sections: string[] = [];

		const activeContent = this.buildActiveSkillsContent();
		sections.push(`# Active Skills\n\n${activeContent}`);

		const summary = this.buildLevel1Summary();
		sections.push(`# Skills\n\nRead a skill's SKILL.md with \`read_file\` for full instructions.\n\n${summary}`);

		return sections.join("\n\n---\n\n");
	}

	private escapeXML(text: string): string {
		return escapeXMLText(text);
	}

	reload(): void {
		this.loaded = false;
		this.load();
	}

	getSkillCount(): number {
		if (!this.loaded) {
			this.load();
		}
		return this.skills.size;
	}
}

export function createSkillsLoader(config: SkillsLoaderConfig): SkillsLoader {
	return new SkillsLoader(config);
}
