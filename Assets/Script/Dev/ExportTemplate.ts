// @preview-file off
import {App, Content, Path, thread} from "Dora";
import {preparePinnedUpdatePackage} from "Script/Tools/SelfUpdater/UpdateSync";

type Template = "android" | "windows-x64";
type Result = {folder?: string; message?: string};
const pending: Partial<Record<Template, Promise<Result>>> = {};

function usable(folder: string, target: Template, apk: string) {
	return target === "android"
		? Content.exist(Path(folder, apk))
		: Content.exist(Path(folder, "Dora.exe")) && Content.isdir(Path(folder, "Script", "Lib"));
}

async function download(target: Template, version: string, revision: number, folder: string, apk: string): Promise<Result> {
	const zh = App.locale.startsWith("zh");
	const prepared = await preparePinnedUpdatePackage(version, revision, target);
	if (!prepared) return {message: zh
		? `无法下载与 Dora ${App.version} 匹配的 ${target} 模板`
		: `Could not download the ${target} template matching Dora ${App.version}`};
	return new Promise(resolve => thread(() => {
		const stage = `${folder}.stage-${os.time()}-${App.rand}`;
		Content.mkdir(Path.getPath(folder));
		const unpacked = Content.unzipAsync(prepared.file, stage, undefined, 2 * 1024 * 1024 * 1024, 30000);
		let success = false;
		if (unpacked && usable(stage, target, apk)) {
			if (Content.exist(folder)) Content.remove(folder);
			success = Content.move(stage, folder);
		}
		if (Content.exist(stage)) Content.remove(stage);
		Content.remove(prepared.cleanupPath);
		resolve(success ? {folder} : {message: zh ? "无法缓存导出模板" : "Could not cache the export template"});
	}));
}

export function resolveExportTemplate(target: Template, done: (this: void, result: Result) => void) {
	const [version, revision] = string.match(App.version, "^(%d+%.%d+%.%d+)%.(%d+)$");
	if (version === undefined || revision === undefined) {
		done({message: "Could not determine the Dora engine version"});
		return;
	}
	const folder = Path(Content.appPath, ".cache", "export-templates", App.version, target);
	const tag = `v${version}`;
	const apk = `dora-ssr-${tag}-android.apk`;
	if (usable(folder, target, apk)) {
		done({folder});
		return;
	}
	const operation = pending[target] ?? download(target, tag, tonumber(revision)!, folder, apk);
	pending[target] = operation;
	operation.then(result => {
		pending[target] = undefined;
		done(result);
	}, error => {
		pending[target] = undefined;
		done({message: tostring(error)});
	});
}
