// @preview-file off
// One update task per engine, independent of launcher scenes and open panels.
import { App, Content, Director, Path, PlatformType, thread } from "Dora";
import { compareVersions, updatePlatformForApp, isWindowsUpdatePlatform, type UpdatePlatform } from "Tools/SelfUpdater/Manifest";
import { checkGitHubRelease, prepareUpdatePackage, syncUpdateManifest, updateSourcesForLocale, type UpdateSnapshot, type UpdateSource, type UpdateProgress, type PreparedUpdate, type UpdateOperationOptions } from "Tools/SelfUpdater/UpdateSync";

export type UpdatePhase = "idle" | "checking" | "available" | "current" | "error" | "downloading" | "canceling" | "ready" | "installing";
const zh = string.match(App.locale, "^zh")[0] !== undefined;
const [major, minor, patch, revision] = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)");
const currentVersion = `v${major}.${minor}.${patch}`;
const currentRevision = tonumber(revision) ?? 0;
let source: UpdateSource = updateSourcesForLocale(App.locale)[0];
let phase: UpdatePhase = "idle";
let snapshot: UpdateSnapshot | undefined;
let progress: UpdateProgress | undefined;
let message = "";
let checkedAt = 0;
let usedCache = false;
let canceled = false;
let serial = 0;
let extractedPath = "";
interface PreparedInstallation { snapshot: UpdateSnapshot; platform: UpdatePlatform; update: PreparedUpdate; installPath?: string }
let prepared: PreparedInstallation | undefined;
let ignoredVersion: string | undefined;
// Entry owns the public state; the service only performs the update task.
let readEntryState: ((this: void) => ReturnType<typeof buildState>) | undefined;
let publishEntryState: ((this: void, state: ReturnType<typeof buildState>) => void) | undefined;
export const bindEntryState = (read: (this: void) => ReturnType<typeof buildState>, publish: (this: void, state: ReturnType<typeof buildState>) => void, ignored?: string) => {
 readEntryState = read; publishEntryState = publish;
 ignoredVersion = ignored;
};
const changed = () => { serial++; publishEntryState?.(buildState()); Director.postNode.emit("EngineUpdateChanged"); };
const fail = (title: string, detail: string) => { phase = "error"; message = `${title}: ${detail}`; progress = undefined; changed(); };
const snapshotVersion = (value: UpdateSnapshot) => value.source === "AtomGit" ? value.manifest.version : value.version;
const snapshotDisplayVersion = (value: UpdateSnapshot) => value.source === "AtomGit" ? `${value.manifest.version}-${value.manifest.revision}` : value.version;
export const compareSnapshotWithCurrent = (value: UpdateSnapshot) => {
 const base = compareVersions(currentVersion, snapshotVersion(value));
 if (base !== 0 || value.source === "GitHub") return base;
 return currentRevision === value.manifest.revision ? 0 : currentRevision < value.manifest.revision ? -1 : 1;
};
const busy = () => phase === "checking" || phase === "downloading" || phase === "canceling" || phase === "installing";
const packageFor = (value: UpdateSnapshot, platform: UpdatePlatform) => value.source === "AtomGit" ? value.manifest.packages[platform] : value.packages[platform];
const buildState = () => {
 const platform = updatePlatformForApp();
 const item = snapshot && platform ? packageFor(snapshot, platform) : undefined;
 const comparison = snapshot ? compareSnapshotWithCurrent(snapshot) : undefined;
 const ignored = snapshot !== undefined && snapshotDisplayVersion(snapshot) === ignoredVersion;
 const newer = checkedAt > 0 && !usedCache && comparison === -1 && (!platform || item !== undefined);
 return {
  serial, phase, source, currentVersion: `${currentVersion}-${currentRevision}`,
  targetVersion: snapshot ? snapshotDisplayVersion(snapshot) : undefined,
  publishedAt: snapshot ? snapshot.source === "AtomGit" ? snapshot.manifest.publishedAt : snapshot.publishedAt : undefined,
  releaseUrl: snapshot ? `https://github.com/IppClub/Dora-SSR/releases/tag/${snapshotVersion(snapshot)}` : undefined,
  available: newer && !ignored && phase !== "checking" && phase !== "error" && phase !== "canceling",
  ignored, ignoredVersion, canIgnore: newer && !ignored && !busy() && !prepared,
  comparison, platform: App.platform, packagePlatform: platform, packageSize: item?.size,
  installSupported: item !== undefined && App.platform !== PlatformType.Linux,
  canDownload: item !== undefined && comparison !== undefined && comparison <= 0 && !busy() && !prepared,
  windows: platform !== undefined && isWindowsUpdatePlatform(platform),
  prepared: prepared !== undefined, checkedAt, usedCache, message, progress,
 };
};
export const getState = () => readEntryState ? readEntryState() : buildState();
export const ignoreUpdate = () => {
 if (!buildState().canIgnore || !snapshot) return false;
 ignoredVersion = snapshotDisplayVersion(snapshot); changed(); return true;
};
export const checkForUpdates = (selected: UpdateSource = source) => {
 if (busy() || prepared) return false;
 source = selected; snapshot = undefined; checkedAt = 0; usedCache = false; message = ""; canceled = false; phase = "checking"; progress = undefined; changed();
 (async () => {
  try {
   const options: UpdateOperationOptions = {isCanceled: () => canceled, onProgress: (value: UpdateProgress) => { progress = value; changed(); }};
   const result = await (source === "AtomGit" ? syncUpdateManifest(options) : checkGitHubRelease(options));
   progress = undefined;
   if (canceled) { phase = "idle"; message = zh ? "检查已取消。" : "Check canceled."; changed(); return; }
   if (!result.success || !result.snapshot) { fail(zh ? "检查失败" : "Check failed", result.message ?? "Unable to read update metadata"); return; }
   snapshot = result.snapshot; usedCache = result.usedCache === true; checkedAt = os.time();
   message = result.message ?? ""; phase = compareSnapshotWithCurrent(snapshot) < 0 ? "available" : "current"; changed();
  } catch (err) { fail(zh ? "检查失败" : "Check failed", tostring(err)); }
 })();
 return true;
};
export const cancelOperation = () => {
 if (phase !== "checking" && phase !== "downloading") return false;
 canceled = true; phase = "canceling"; changed(); return true;
};
const installPreparedPackage = (pending: PreparedInstallation) => {
	const { snapshot: valueSnapshot, platform, update: value } = pending;
	const version = snapshotVersion(valueSnapshot);
	const packageInfo = valueSnapshot.source === "AtomGit"
		? valueSnapshot.manifest.packages[platform]
		: valueSnapshot.packages[platform];
	if (!packageInfo) { prepared = undefined; return; }
	phase = "installing"; changed();
	if (pending.installPath && Content.exist(pending.installPath)) {
		progress = { progress: 1, message: zh ? "正在启动安装程序…" : "Starting installer…", source: value.source };
		App.install(pending.installPath);
		phase = "ready"; progress = undefined; changed();
		return;
	}
    if (platform.endsWith("-msi")) {
        pending.installPath = value.file;
        App.install(value.file);
        phase = "ready"; progress = undefined; changed();
        return;
    }
	progress = { progress: 0.94, message: zh ? "正在解压更新…" : "Extracting update…", source: value.source };
	thread(() => {
		const unzipPath = Path(Path.getPath(value.file), "unpacked");
		if (Content.exist(unzipPath)) Content.remove(unzipPath);
		extractedPath = unzipPath;
		const success = Content.unzipAsync(value.file, unzipPath);
		if (!success) {
			phase = "ready"; changed();
			progress = undefined;
			Content.remove(value.cleanupPath);
			prepared = undefined;
			extractedPath = "";
			fail(
				zh ? "解压失败" : "Failed to extract update",
				zh ? `无法解压文件：${packageInfo.file}` : `Failed to extract: ${packageInfo.file}`,
			);
			return;
		}
		progress = { progress: 1, message: zh ? "正在启动安装程序…" : "Starting installer…", source: value.source };
		const installPath = platform === "android"
			? Path(unzipPath, `dora-ssr-${version}-android.apk`)
			: (platform === "macos-universal" || platform === "macos-arm64")
				? Path(unzipPath, "Dora.app")
				: unzipPath;
		if (!Content.exist(installPath)) {
			phase = "ready"; changed();
			progress = undefined;
			Content.remove(value.cleanupPath);
			prepared = undefined;
			extractedPath = "";
			fail(
				zh ? "安装包无效" : "Invalid update package",
				zh ? "更新包缺少预期的安装入口。" : "The update package does not contain the expected installer.",
			);
			return;
		}
		pending.installPath = installPath;
		App.install(installPath);
		phase = "ready"; progress = undefined; changed();
	});
};

export const downloadUpdate = (target?: UpdatePlatform) => {
 const platform = target ?? updatePlatformForApp();
 if (busy() || prepared || !snapshot || !platform || !packageFor(snapshot, platform)) return false;
 // A cached/older stable manifest must never turn the primary action into a downgrade.
 if (compareSnapshotWithCurrent(snapshot) > 0) return false;
 const installed = updatePlatformForApp();
 if (target && target !== installed && (!installed || !isWindowsUpdatePlatform(installed) || !isWindowsUpdatePlatform(target) || installed.endsWith("-msi") !== target.endsWith("-msi"))) return false;
 const valueSnapshot = snapshot;
 phase = "downloading"; canceled = false; message = ""; progress = undefined; changed();
 (async () => {
  try {
   const update = await prepareUpdatePackage(valueSnapshot, platform, {isCanceled: () => canceled, onProgress: value => { progress = value; changed(); }});
   progress = undefined;
   if (canceled) { if (update) Content.remove(update.cleanupPath); phase = compareSnapshotWithCurrent(valueSnapshot) < 0 ? "available" : "current"; message = zh ? "下载已取消。" : "Download canceled."; changed(); return; }
   if (!update) { fail(zh ? "下载失败" : "Download failed", zh ? "更新源不可用，或安装包未通过校验。可重试或切换更新源。" : "Source unavailable or package verification failed. Retry or switch sources."); return; }
   prepared = {snapshot: valueSnapshot, platform, update}; phase = "ready"; changed();
  } catch (err) { fail(zh ? "下载失败" : "Download failed", tostring(err)); }
 })();
 return true;
};
export const installUpdate = (confirmed: boolean) => {
 if (!confirmed || phase !== "ready" || !prepared) return false;
 installPreparedPackage(prepared); return true;
};
export const discardPrepared = () => {
 if (busy() || !prepared) return false;
 Content.remove(prepared.update.cleanupPath); prepared = undefined; extractedPath = ""; phase = "idle"; changed(); return true;
};
