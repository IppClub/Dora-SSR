/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

import { App, Content, Node, Path, PlatformType, thread, threadLoop, Vec2 } from "Dora";
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from "ImGui";
import {
	compareVersions,
	updatePlatformForApp,
	type UpdatePlatform,
} from "Script/Tools/SelfUpdater/Manifest";
import {
	checkGitHubRelease,
	loadCachedUpdateManifest,
	prepareUpdatePackage,
	syncUpdateManifest,
	updateSourcesForLocale,
	type PreparedUpdate,
	type UpdateProgress,
	type UpdateSource,
	type UpdateSnapshot,
} from "Script/Tools/SelfUpdater/UpdateSync";

let zh = false;
{
	const [matched] = string.match(App.locale, "^zh");
	zh = matched !== undefined;
}

const [major, minor, patch, revision] = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)");
const currentVersion = `v${major}.${minor}.${patch}`;
const currentRevision = tonumber(revision) ?? 0;
const currentDisplayVersion = `${currentVersion}-${currentRevision}`;
const { themeColor } = App;
const sources: UpdateSource[] = updateSourcesForLocale(App.locale);
let currentSource = 1;
const selectedSource = () => sources[currentSource - 1];

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoMove,
];
const messagePopupFlags = [
	WindowFlag.NoSavedSettings,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoTitleBar,
];

let snapshot: UpdateSnapshot | undefined;
let checking = false;
let preparing = false;
let installing = false;
let canceled = false;
let progress: UpdateProgress | undefined;
let prepared: PreparedUpdate | undefined;
let extractedPath = "";
let popupTitle = "";
let popupMessage = "";
let popupShow = false;

const showPopup = (title: string, message: string) => {
	popupTitle = title;
	popupMessage = message;
	popupShow = true;
};

const applySnapshot = (value: UpdateSnapshot) => {
	snapshot = value;
};

const cached = loadCachedUpdateManifest();
if (selectedSource() === "AtomGit" && cached.success && cached.snapshot) applySnapshot(cached.snapshot);

const loadSnapshotForSelectedSource = () => {
	snapshot = undefined;
	if (selectedSource() !== "AtomGit") return;
	const result = loadCachedUpdateManifest();
	if (result.success && result.snapshot) applySnapshot(result.snapshot);
};

const snapshotVersion = (value: UpdateSnapshot) => value.source === "AtomGit"
	? value.manifest.version
	: value.version;

const snapshotRevision = (value: UpdateSnapshot) => value.source === "AtomGit"
	? value.manifest.revision
	: undefined;

const snapshotDisplayVersion = (value: UpdateSnapshot) => {
	const version = snapshotVersion(value);
	const revision = snapshotRevision(value);
	return revision === undefined ? version : `${version}-${revision}`;
};

const compareSnapshotWithCurrent = (value: UpdateSnapshot) => {
	const base = compareVersions(currentVersion, snapshotVersion(value));
	if (base !== 0 || value.source === "GitHub") return base;
	return currentRevision === value.manifest.revision
		? 0
		: currentRevision < value.manifest.revision ? -1 : 1;
};

const checkForUpdates = () => {
	if (checking || preparing || installing) return;
	checking = true;
	canceled = false;
	const source = selectedSource();
	progress = {
		progress: 0,
		message: source === "AtomGit"
			? (zh ? "正在连接 AtomGit 更新仓库…" : "Connecting to the AtomGit update repository…")
			: (zh ? "正在查询 GitHub Release…" : "Checking GitHub Releases…"),
		source,
	};
	(async () => {
		const result = await (source === "AtomGit" ? syncUpdateManifest({
			isCanceled: () => canceled,
			onProgress: status => {
				progress = status;
			},
		}) : checkGitHubRelease({
			isCanceled: () => canceled,
			onProgress: status => {
				progress = status;
			},
		}));
		checking = false;
		progress = undefined;
		if (result.success && result.snapshot) {
			applySnapshot(result.snapshot);
			if (source === "AtomGit" && result.usedCache && result.message) {
				showPopup(
					zh ? "正在使用已验证缓存" : "Using verified cache",
					result.message,
				);
			}
			return;
		}
		showPopup(
			zh ? "检查更新失败" : "Failed to check for updates",
			result.message ?? (zh ? "无法读取可信更新清单。" : "Unable to read trusted update metadata."),
		);
	})();
};

const installPreparedPackage = (
	valueSnapshot: UpdateSnapshot,
	platform: UpdatePlatform,
	value: PreparedUpdate,
) => {
	const version = snapshotVersion(valueSnapshot);
	const packageInfo = valueSnapshot.source === "AtomGit"
		? valueSnapshot.manifest.packages[platform]
		: valueSnapshot.packages[platform];
	installing = true;
	progress = { progress: 0.94, message: zh ? "正在解压更新…" : "Extracting update…", source: value.source };
	thread(() => {
		const unzipPath = Path(Path.getPath(value.file), "unpacked");
		if (Content.exist(unzipPath)) Content.remove(unzipPath);
		extractedPath = unzipPath;
		const success = Content.unzipAsync(value.file, unzipPath);
		if (!success) {
			installing = false;
			progress = undefined;
			Content.remove(value.cleanupPath);
			prepared = undefined;
			extractedPath = "";
			showPopup(
				zh ? "解压失败" : "Failed to extract update",
				zh ? `无法解压文件：${packageInfo.file}` : `Failed to extract: ${packageInfo.file}`,
			);
			return;
		}
		progress = { progress: 1, message: zh ? "正在启动安装程序…" : "Starting installer…", source: value.source };
		const installPath = platform === "android"
			? Path(unzipPath, `dora-ssr-${version}-android.apk`)
			: platform === "macos-universal"
				? Path(unzipPath, "Dora.app")
				: unzipPath;
		if (!Content.exist(installPath)) {
			installing = false;
			progress = undefined;
			Content.remove(value.cleanupPath);
			prepared = undefined;
			extractedPath = "";
			showPopup(
				zh ? "安装包无效" : "Invalid update package",
				zh ? "更新包缺少预期的安装入口。" : "The update package does not contain the expected installer.",
			);
			return;
		}
		App.install(installPath);
		installing = false;
		progress = undefined;
	});
};

const beginUpdate = () => {
	if (!snapshot || preparing || installing) return;
	const platform = updatePlatformForApp();
	if (!platform) return;
	preparing = true;
	canceled = false;
	progress = { progress: 0, message: zh ? "正在准备下载…" : "Preparing download…" };
	(async () => {
		const valueSnapshot = snapshot!;
		const value = await prepareUpdatePackage(valueSnapshot, platform, {
			isCanceled: () => canceled,
			onProgress: status => {
				progress = status;
			},
		});
		preparing = false;
		if (!value) {
			progress = undefined;
			if (!canceled) {
				showPopup(
					zh ? "下载更新失败" : "Failed to download update",
					zh ? `${valueSnapshot.source} 下载不可用，或安装包校验失败。` : `${valueSnapshot.source} is unavailable, or the package did not pass verification.`,
				);
			}
			return;
		}
		prepared = value;
		installPreparedPackage(valueSnapshot, platform, value);
	})();
};

const cancelCurrentOperation = () => {
	canceled = true;
	progress = undefined;
};

const drawMessagePopup = () => {
	ImGui.Text(popupTitle);
	ImGui.Separator();
	ImGui.PushTextWrapPos(360, () => ImGui.TextWrapped(popupMessage));
	if (ImGui.Button(zh ? "确认" : "OK", Vec2(360, 30))) {
		ImGui.CloseCurrentPopup();
	}
};

const drawPlatformMessage = () => {
	switch (App.platform) {
		case PlatformType.Linux:
			ImGui.TextWrapped(
				zh
					? "请通过 Dora SSR PPA，使用 apt 工具管理更新。"
					: "Use the Dora SSR PPA and apt to manage updates.",
			);
			return true;
		case PlatformType.macOS:
			ImGui.TextWrapped(
				zh
					? "可直接在应用内更新 Dora SSR；如果当前安装由 Homebrew 管理，也可以继续使用 brew upgrade。"
					: "Dora SSR can update itself in the app. If this installation is managed by Homebrew, you can continue to use brew upgrade.",
			);
			return false;
		default:
			return false;
	}
};

threadLoop(() => {
	const { width } = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(430, 0), SetCond.Always);
	ImGui.Begin("Dora Updater", windowFlags, () => {
		ImGui.Text(zh ? "Dora SSR 自更新工具" : "Dora SSR Self Updater");
		ImGui.SameLine();
		ImGui.TextDisabled("(?)");
		if (ImGui.IsItemHovered()) {
			ImGui.BeginTooltip(() => {
				ImGui.PushTextWrapPos(340, () => {
					ImGui.Text(
						zh
							? "可手动切换 GitHub 和 AtomGit 两种完整更新模式。中文环境默认使用 AtomGit，其它语言默认使用 GitHub；两种模式都会核对安装包大小和 SHA-256。"
							: "Choose either the complete GitHub or AtomGit update mode. Chinese locales default to AtomGit; other locales default to GitHub. Both modes verify package size and SHA-256.",
					);
				});
			});
		}
		ImGui.Separator();
		drawPlatformMessage();

		ImGui.TextColored(themeColor, zh ? "更新模式：" : "Update mode:");
		ImGui.SameLine();
		const [sourceChanged, sourceIndex] = ImGui.Combo("##update-source", currentSource, sources);
		if (sourceChanged && !checking && !preparing && !installing) {
			currentSource = sourceIndex;
			loadSnapshotForSelectedSource();
		}

		ImGui.TextColored(themeColor, zh ? "当前版本：" : "Current version:");
		ImGui.SameLine();
		ImGui.Text(currentDisplayVersion);
		if (snapshot) {
			const visibleSnapshot = snapshot;
			ImGui.TextColored(themeColor, zh ? "稳定版本：" : "Stable version:");
			ImGui.SameLine();
			ImGui.Text(snapshotDisplayVersion(visibleSnapshot));
			ImGui.TextColored(themeColor, zh ? "更新来源：" : "Update source:");
			ImGui.SameLine();
			ImGui.Text(visibleSnapshot.source);
			if (ImGui.IsItemHovered()) {
				ImGui.BeginTooltip(() => {
					ImGui.PushTextWrapPos(390, () => {
						if (visibleSnapshot.source === "AtomGit") {
							ImGui.Text(`${zh ? "清单提交" : "Manifest commit"}: ${visibleSnapshot.commit}`);
							ImGui.Text(`${zh ? "签名者" : "Signer"}: ${visibleSnapshot.signer}`);
							ImGui.Text(`${zh ? "验证时间" : "Verified"}: ${visibleSnapshot.verifiedAt}`);
						} else {
							ImGui.Text(`${zh ? "发布时间" : "Published"}: ${visibleSnapshot.publishedAt}`);
							ImGui.TextWrapped(
								zh
									? "GitHub API 只提供 Release 版本号，无法判断同版本安装包的 revision；需要时可直接重新下载。"
									: "The GitHub API exposes only the Release version, so it cannot identify package revisions within the same version. You can redownload when needed.",
							);
						}
					});
				});
			}
			const comparison = compareSnapshotWithCurrent(visibleSnapshot);
			ImGui.PushTextWrapPos(410, () => {
				if (comparison < 0) {
					ImGui.TextColored(themeColor, zh ? "有可用更新！" : "Update available!");
				} else if (comparison === 0) {
					ImGui.TextColored(
						themeColor,
						visibleSnapshot.source === "GitHub"
							? (zh ? "Release 版本相同，可重新下载以获取可能更新的 revision。" : "The Release version matches; redownload to get a possible newer revision.")
							: (zh ? "已是最新版，可按需重新下载。" : "Already up to date; you can redownload when needed."),
					);
				} else {
					ImGui.TextColored(themeColor, zh ? "当前版本高于稳定版本。" : "Current version is newer than stable.");
				}
			});
		}

		if (progress) {
			ImGui.Separator();
			ImGui.TextWrapped(
				`${progress.source ? `${progress.source} · ` : ""}${progress.message}`,
			);
			ImGui.ProgressBar(progress.progress, Vec2(-1, 28));
			if (!installing && ImGui.Button(zh ? "取消" : "Cancel", Vec2(-1, 30))) {
				cancelCurrentOperation();
			}
		} else {
			if (ImGui.Button(zh ? "检查更新" : "Check for updates", Vec2(-1, 30))) {
				checkForUpdates();
			}
			const platform = updatePlatformForApp();
			const installSupported = platform === "android"
				|| platform === "windows-x86"
				|| platform === "macos-universal";
			if (snapshot && installSupported) {
				const comparison = compareSnapshotWithCurrent(snapshot);
				if (ImGui.Button(
					comparison < 0
						? (zh ? "下载并安装" : "Download and install")
						: (zh ? "重新下载并安装" : "Redownload and install"),
					Vec2(-1, 30),
				)) {
					beginUpdate();
				}
			}
		}

		if (popupShow) {
			popupShow = false;
			ImGui.OpenPopup("SelfUpdaterMessage");
		}
		ImGui.BeginPopupModal("SelfUpdaterMessage", messagePopupFlags, drawMessagePopup);
	});
	return false;
});

const node = Node();
node.onCleanup(() => {
	canceled = true;
	if (prepared) Content.remove(prepared.cleanupPath);
	if (extractedPath !== "") Content.remove(extractedPath);
});
