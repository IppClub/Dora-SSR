// @preview-file off clear
import { Content, Path } from "Dora";

const xml = (require("Dora") as { xml?: { isDoraTag(this: void, name: string): boolean } }).xml;

function isBuildSource(file: string): boolean {
	if (Path.getExt(file) !== "xml" || !xml?.isDoraTag) return true;
	const content = Content.load(file);
	if (content === undefined) return true;
	const [withoutBom] = string.gsub(content, "^\ufeff", "");
	let source = withoutBom;
	while (true) {
		const [rest] = string.match(source, "^%s*<!%-%-.-%-%->(.*)$");
		const [afterInstruction] = string.match(source, "^%s*<%?.-%?>(.*)$");
		const remaining = rest ?? afterInstruction;
		if (remaining === undefined) break;
		source = remaining;
	}
	const [tag] = string.match(source, "^%s*<([%w_:%.%-]+)");
	return tag === undefined || xml.isDoraTag(tag);
}

export type DirectoryBuildUnit = {
	projectRoot?: string;
	godot?: string;
	files: string[];
};

type BuildContent = Pick<typeof Content, "glob" | "exist" | "load" | "read" | "isAbsolutePath">;
type BuildPath = typeof Path;

/** Index directories in one traversal, then assign each source to its nearest project. */
export function createDirectoryBuildPlanner(
	Content: BuildContent,
	Path: BuildPath,
	isBuildSource: (file: string) => boolean = () => true,
) {
	const luaSourceExtensions = new Set(["ts", "tsx", "tl", "yue", "xml"]);
	return function planDirectoryBuild(
		directory: string,
		enclosingProject?: string,
		exclusions: string[] = [],
		extensionLevels?: Record<string, number>,
	): DirectoryBuildUnit[] {
		// A directory resolved from "." can end in a separator, while its children's parent paths do not.
		directory = Path.getPath(Path(directory, "_"));
		const entries = Content.glob(directory, [
			"**", "!**/.agent/**", "!**/.git/**", "!**/.godot/**", "!**/.cache/**",
			"!**/.build/**", "!**/.www/**", "!**/.upload/**", "!**/.download/**",
			"!**/.native-export/**", "!**/node_modules/**",
			"!**/CMakeFiles/**",
			...exclusions,
		], extensionLevels, false).map(file => Path(directory, file));
		const excluded = new Set<string>();
		for (const file of entries) {
			if (Path.getFilename(file) !== ".dora-no-build") continue;
			const folder = Path.getPath(file);
			let hasTargets = false;
			for (const line of (Content.load(file) ?? "").split("\r").join("\n").split("\n")) {
				const target = line.trim();
				if (target === "" || target.startsWith("#")) continue;
				hasTargets = true;
				if (Content.isAbsolutePath(target)) continue;
				const relative = Path.getRelative(Path(folder, target), folder);
				if (relative === "." || relative === ".." || relative.startsWith("../") || relative.startsWith("..\\")) continue;
				excluded.add(Path(folder, relative));
			}
			if (!hasTargets) excluded.add(folder);
		}
		const included = new Map<string, boolean>();
		function isIncluded(dir: string): boolean {
			const cached = included.get(dir);
			if (cached !== undefined) return cached;
			const parent = Path.getPath(dir);
			const result = !excluded.has(dir) && (dir === directory || (parent !== "" && parent !== dir && isIncluded(parent)));
			included.set(dir, result);
			return result;
		}
		const files = entries.filter(file => !excluded.has(file) && isIncluded(Path.getPath(file)) && isBuildSource(file));
		files.sort();
		const sourceFiles = new Set(files);
		const luaOutputs = new Set<string>();
		for (const file of files) {
			if (luaSourceExtensions.has(Path.getExt(file)) && Path.getExt(Path.getName(file)) !== "d") {
				luaOutputs.add(Path.replaceExt(file, "lua"));
			}
		}
		const projects = new Map<string, DirectoryBuildUnit>();
		const explicitRoots = new Set<string>();
		for (const file of files) {
			const dir = Path.getPath(file);
			const name = Path.getFilename(file);
			if (Path.getName(file).toLowerCase() !== "init" && name !== "wa.mod" && name !== "project.godot") continue;
			let project = projects.get(dir);
			if (!project) {
				project = { projectRoot: dir, files: [] };
				projects.set(dir, project);
			}
			if (name === "wa.mod" || name === "project.godot") explicitRoots.add(dir);
			if (name === "project.godot") project.godot = dir;
		}
		// init.lua also names a Lua package entry. Script and Lib are module roots
		// within a project, and a sibling declaration identifies a typed Lua package.
		const roots = [...projects.keys()].sort((a, b) => a.length - b.length);
		for (const dir of roots) {
			if (explicitRoots.has(dir) || dir === directory) continue;
			let parent = Path.getPath(dir);
			while (parent !== "" && parent !== dir && !projects.has(parent) && parent !== enclosingProject) {
				const next = Path.getPath(parent);
				if (next === parent) break;
				parent = next;
			}
			const moduleRoot = projects.has(parent) || parent === enclosingProject
				? Path.getRelative(dir, parent).split("\\").join("/").split("/")[0]
				: undefined;
			if (moduleRoot === "Script" || moduleRoot === "Lib" || Content.exist(dir + ".d.ts")) {
				projects.delete(dir);
			}
		}
		const remainder: DirectoryBuildUnit = { projectRoot: enclosingProject, files: [] };
		const ownerByDirectory = new Map<string, DirectoryBuildUnit>();
		function owner(dir: string): DirectoryBuildUnit {
			const existing = projects.get(dir) ?? ownerByDirectory.get(dir);
			if (existing) return existing;
			const parent = Path.getPath(dir);
			const project = dir === directory || parent === dir || parent === "" ? remainder : owner(parent);
			ownerByDirectory.set(dir, project);
			return project;
		}
		for (const file of files) {
			if (luaOutputs.has(file)) {
				const lines = (Content.read(file, 0, 256) ?? "").split("\n", 2);
				const header = lines[0].trimEnd() === "-- tic80" ? lines[1] ?? "" : lines[0];
				const sourceExt = header.startsWith("-- [") && header.includes("]:") ? header.split("]:", 2)[0].slice(4) : "";
				// Keep handwritten Lua and generated Lua shipped without its source.
				if (luaSourceExtensions.has(sourceExt) && sourceFiles.has(Path.replaceExt(file, sourceExt))) continue;
			}
			owner(Path.getPath(file)).files.push(file);
		}
		const units = [...projects.values()];
		if (remainder.files.length > 0) units.unshift(remainder);
		return units;
	};
}

export const planDirectoryBuild = createDirectoryBuildPlanner(Content, Path, isBuildSource);
