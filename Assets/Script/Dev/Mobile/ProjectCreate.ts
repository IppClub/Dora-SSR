import { Content, Path } from "Dora";

export const mobileTypeScriptProjectTemplate = "// @preview-file on clear\nimport {} from 'Dora';\n\n";
export const mobileTypeScriptProjectLuaTemplate = "-- [ts]: init.ts\nlocal ____exports = {}\nreturn ____exports\n";

export type MobileProjectCreateError = "invalid-name" | "target-existed" | "create-folder-failed" | "create-entry-failed";

export type MobileProjectCreateResult =
	| { success: true; name: string; workDir: string; fileName: string }
	| { success: false; error: MobileProjectCreateError };

export interface MobileProjectStorage {
	workspace: string;
	getDirs(this: void, path: string): string[];
	getFiles(this: void, path: string): string[];
	exist(this: void, path: string): boolean;
	mkdir(this: void, path: string): boolean;
	save(this: void, path: string, content: string): boolean;
	remove(this: void, path: string): boolean;
}

const defaultStorage = (): MobileProjectStorage => ({
	workspace: Content.writablePath,
	getDirs: path => Content.getDirs(path),
	getFiles: path => Content.getFiles(path),
	exist: path => Content.exist(path),
	mkdir: path => Content.mkdir(path),
	save: (path, content) => Content.save(path, content),
	remove: path => Content.remove(path),
});

export const normalizeMobileProjectName = (name: string) => {
	const normalized = name.trim();
	if (normalized === "" || normalized === "." || normalized === "..") return undefined;
	if (normalized.indexOf("/") >= 0 || normalized.indexOf("\\") >= 0) return undefined;
	return normalized;
};

export function createMobileTypeScriptProject(name: string, storage = defaultStorage()): MobileProjectCreateResult {
	const normalized = normalizeMobileProjectName(name);
	if (!normalized) return { success: false, error: "invalid-name" };

	const targetName = normalized.toLowerCase();
	const collision = [...storage.getDirs(storage.workspace), ...storage.getFiles(storage.workspace)]
		.some(item => item.toLowerCase() === targetName);
	const workDir = Path(storage.workspace, normalized);
	if (collision || storage.exist(workDir)) return { success: false, error: "target-existed" };
	if (!storage.mkdir(workDir)) return { success: false, error: "create-folder-failed" };

	const entryFile = Path(workDir, "init.ts");
	if (!storage.save(entryFile, mobileTypeScriptProjectTemplate)) {
		storage.remove(workDir);
		return { success: false, error: "create-entry-failed" };
	}
	if (!storage.save(Path(workDir, "init.lua"), mobileTypeScriptProjectLuaTemplate)) {
		storage.remove(workDir);
		return { success: false, error: "create-entry-failed" };
	}
	return { success: true, name: normalized, workDir, fileName: Path(workDir, "init") };
}
