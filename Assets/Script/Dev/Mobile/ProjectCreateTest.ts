import { Content, Path } from "Dora";
import { createMobileTypeScriptProject, mobileTypeScriptProjectLuaTemplate, mobileTypeScriptProjectTemplate, type MobileProjectStorage } from "Dev/Mobile/ProjectCreate";

const resultPath = Path(Content.writablePath, "dora-mobile-project-create.result");
Content.save(resultPath, "running\n");

function expect(condition: boolean, message: string) {
	if (condition) return;
	Content.save(resultPath, `failed ${message}\n`);
	throw new Error(message);
}

function storage(options?: { dirs?: string[]; files?: string[]; mkdir?: boolean; save?: boolean; failSaveAt?: number }) {
	const dirs = [...(options?.dirs ?? [])];
	const files = [...(options?.files ?? [])];
	const saved: Record<string, string> = {};
	const removed: string[] = [];
	let saveCount = 0;
	const value: MobileProjectStorage = {
		workspace: "/workspace",
		getDirs: () => dirs,
		getFiles: () => files,
		exist: path => dirs.some(item => Path("/workspace", item) === path) || files.some(item => Path("/workspace", item) === path),
		mkdir: path => {
			if (options?.mkdir === false) return false;
			dirs.push(Path.getFilename(path));
			return true;
		},
		save: (path, content) => {
			saveCount++;
			if (options?.save === false || options?.failSaveAt === saveCount) return false;
			saved[path] = content;
			return true;
		},
		remove: path => {
			removed.push(path);
			const name = Path.getFilename(path);
			const index = dirs.indexOf(name);
			if (index >= 0) dirs.splice(index, 1);
			return true;
		},
	};
	return { value, dirs, saved, removed };
}

["", "   ", ".", "..", "a/b", "a\\b"].forEach(name => {
	const fake = storage();
	const result = createMobileTypeScriptProject(name, fake.value);
	expect(!result.success && result.error === "invalid-name", `invalid name accepted: ${name}`);
	expect(fake.dirs.length === 0, `invalid name created a folder: ${name}`);
});

for (const fake of [storage({ dirs: ["Existing"] }), storage({ files: ["Existing"] })]) {
	const result = createMobileTypeScriptProject("existing", fake.value);
	expect(!result.success && result.error === "target-existed", "case-insensitive collision was not rejected");
}

{
	const fake = storage({ mkdir: false });
	const result = createMobileTypeScriptProject("Game", fake.value);
	expect(!result.success && result.error === "create-folder-failed", "folder failure mismatch");
	expect(fake.removed.length === 0, "folder failure removed an existing path");
}

{
	const fake = storage({ save: false });
	const result = createMobileTypeScriptProject("Game", fake.value);
	expect(!result.success && result.error === "create-entry-failed", "entry failure mismatch");
	expect(fake.removed.length === 1 && fake.removed[0] === "/workspace/Game", "entry failure did not roll back only the new folder");
}

{
	const fake = storage({ failSaveAt: 2 });
	const result = createMobileTypeScriptProject("Game", fake.value);
	expect(!result.success && result.error === "create-entry-failed", "runnable entry failure mismatch");
	expect(fake.removed.length === 1 && fake.removed[0] === "/workspace/Game", "runnable entry failure did not roll back only the new folder");
}

{
	const fake = storage();
	const result = createMobileTypeScriptProject("  Star Garden  ", fake.value);
	expect(result.success, "valid project was not created");
	if (result.success) {
		expect(result.name === "Star Garden" && result.workDir === "/workspace/Star Garden", "project normalization mismatch");
		expect(result.fileName === "/workspace/Star Garden/init", "entry path mismatch");
		expect(fake.saved["/workspace/Star Garden/init.ts"] === mobileTypeScriptProjectTemplate, "TypeScript template mismatch");
		expect(fake.saved["/workspace/Star Garden/init.lua"] === mobileTypeScriptProjectLuaTemplate, "runnable Lua template mismatch");
		expect(fake.removed.length === 0, "successful project was rolled back");
	}
}

Content.save(resultPath, "passed invalid=6 collision=2 folderFailure=1 rollback=2 success=1\n");
