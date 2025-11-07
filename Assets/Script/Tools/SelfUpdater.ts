/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import {HttpClient, json, thread, App, threadLoop, Vec2, Buffer, Path, Content, PlatformType, Node} from 'Dora';
import { InputTextFlag, SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null;
}

const [major, minor, patch, _revision] = string.match(App.version, "(%d+)%.(%d+)%.(%d+)%.(%d+)");
const currentVersion = `v${major}.${minor}.${patch}`;

let currentProxy = 1;
const proxies = zh ? [
	"OpenAtom",
	"github.com"
] : [
	"github.com",
	"OpenAtom",
];

interface VersionInfo {
	tag_name: string;
}

let popupMessageTitle = "";
let popupMessage = "";
let popupShow = false;

function showPopup(title: string, msg: string) {
	popupMessageTitle = title;
	popupMessage = msg;
	popupShow = true;
}

let latestVersion = "";
let checking = false;
function getLatestVersion() {
	checking = true;
	latestVersion = "";
	thread(() => {
		let url = `https://api.github.com/repos/IppClub/Dora-SSR/releases/latest`;
		const res = HttpClient.getAsync(url);
		let success = false;
		if (res) {
			const info = json.decode(res)[0] as VersionInfo | null;
			if (info) {
				latestVersion = info.tag_name;
				success = true;
			}
		}
		if (!success) {
			showPopup(zh ? "获取更新失败" : "Failed to check", zh ? "无法读取仓库地址，请检查网络情况。" : "Unable to read the repo URL, please check the network status.");
		}
		checking = false;
	});
}

function getDownloadURL() {
	switch (App.platform) {
		case PlatformType.Android: {
			const filename = `dora-ssr-${latestVersion}-android.zip`;
			const proxy = proxies[currentProxy - 1];
			if (proxy === 'OpenAtom') {
				return [`http://39.155.148.157:8866/zips/${filename}`, filename]
			}
			return [`https://${proxy}/IppClub/Dora-SSR/releases/download/${latestVersion}/${filename}`, filename];
		}
		case PlatformType.Windows: {
			const filename = `dora-ssr-${latestVersion}-windows-x86.zip`;
			const proxy = proxies[currentProxy - 1];
			if (proxy === 'OpenAtom') {
				return [`http://39.155.148.157:8866/zips/${filename}`, filename]
			}
			return [`https://${proxy}/IppClub/Dora-SSR/releases/download/${latestVersion}/${filename}`, filename];
		}
		default: {
			error("invalid platform");
		}
	}
}

let cancelDownload = false;
let downloadTitle = "";
let progress = 0;
let downloadTargetFile = "";
let targetUnzipPath = "";
let unzipDone = false

function download() {
	thread(() => {
		progress = 0;
		const [url, filename] = getDownloadURL();
		const targetFile = Path(Content.writablePath, ".download", filename);
		downloadTargetFile = targetFile;
		Content.mkdir(Path(Content.writablePath, ".download"));
		downloadTitle = (zh ? "正在下载：" : "Downloading: ") + filename;
		const success = HttpClient.downloadAsync(
			url,
			targetFile,
			30,
			(current, total) => {
				if (cancelDownload) {
					return true;
				}
				progress = current / total;
				return false;
			}
		);
		if (success) {
			downloadTitle = zh ? `解压中：${filename}` : `Unziping: ${filename}`;
			const unzipPath = Path(Path.getPath(targetFile), Path.getName(targetFile));
			Content.remove(unzipPath);
			unzipDone = false;
			targetUnzipPath = unzipPath;
			if (!Content.unzipAsync(targetFile, unzipPath)) {
				Content.remove(unzipPath);
				targetUnzipPath = "";
				showPopup(zh ? "解压失败" : "Failed to unzip ", zh ? `无法解压文件：${filename}` : `Failed to unzip: ${filename}`);
			} else {
				Content.remove(targetFile);
				unzipDone = true;
				const pathForInstall = App.platform === PlatformType.Windows ? unzipPath : Path(unzipPath, `dora-ssr-${latestVersion}-android.apk`)
				App.install(pathForInstall);
			}
		} else {
			Content.remove(targetFile);
			downloadTitle = "";
			showPopup(zh ? "下载失败" : "Download failed", zh ? `无法从该地址下载：${url}` : `Failed to download from: ${url}`);
		}
	});
}

const {themeColor} = App;

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
const messagePopupFlags = [
	WindowFlag.NoSavedSettings,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoTitleBar
];
const inputTextFlags = [InputTextFlag.AutoSelectAll];
const proxyBuf = Buffer(100);

const messagePopup = () => {
	ImGui.Text(popupMessageTitle);
	ImGui.Separator();
	ImGui.PushTextWrapPos(300, () => {
		ImGui.TextWrapped(popupMessage);
	});
	if (ImGui.Button(zh ? "确认" : "OK", Vec2(300, 30))) {
		ImGui.CloseCurrentPopup();
	}
};

threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(400, 0), SetCond.Always);
	ImGui.Begin("Dora Updater", windowFlags, () => {
		ImGui.Text(zh ? "Dora SSR 自更新工具" : "Dora SSR Self Updater");
		ImGui.SameLine();
		ImGui.TextDisabled("(?)");
		if (ImGui.IsItemHovered()) {
			ImGui.BeginTooltip(() => {
				ImGui.PushTextWrapPos(300, () => {
					ImGui.Text(zh ? "使用该工具来检测和安装 Dora SSR 新版本的软件。" : "Use this tool to detect and install new versions of Dora SSR software.");
				});
			});
		}
		ImGui.Separator();
		switch (App.platform) {
			case PlatformType.Linux:
				ImGui.TextWrapped(zh ? "请通过 Dora SSR PPA，使用 apt-get 工具进行更新管理。详见官网的安装教程。" : "Please use apt-get to manage updates via the Dora SSR PPA. See the installation tutorial on the official website for details.");
				return false;
			case PlatformType.macOS:
				ImGui.TextWrapped(zh ? "请通过 Homebrew 工具进行更新管理。详见官网的安装教程。" : "Please use the Homebrew tool to manage updates. See the installation tutorial on the official website for details.");
				return false;
		}
		let _ = false;
		[_, currentProxy] = ImGui.Combo(zh ? "选择代理" : "Proxy Site", currentProxy, proxies);
		if (latestVersion === "") {
			ImGui.InputText("##NewProxy", proxyBuf, inputTextFlags);
			ImGui.SameLine();
			if (ImGui.Button(zh ? "添加代理" : "Add Proxy")) {
				const proxyText = proxyBuf.text;
				if (proxyText !== "") {
					proxies.push(proxyText);
					proxyBuf.text = "";
					currentProxy = proxies.length;
				}
			}
		}
		ImGui.Separator();
		ImGui.TextColored(themeColor, zh ? "当前版：" : "Current Version:");
		ImGui.SameLine();
		ImGui.Text(currentVersion);
		if (latestVersion !== "") {
			ImGui.TextColored(themeColor, zh ? "最新版：" : "Latest Version:");
			ImGui.SameLine();
			ImGui.Text(latestVersion);
			if (latestVersion !== currentVersion) {
				ImGui.TextColored(themeColor, zh ? "有可用更新！" : "Update Available!");
				if (downloadTitle === "") {
					if (ImGui.Button(zh ? "进行更新" : "Update")) {
						download();
					}
				}
			} else {
				ImGui.TextColored(themeColor, zh ? "已是最新版！" : "Already the latest version!");
				if (downloadTitle === "") {
					if (ImGui.Button(zh ? "重新安装" : "Reinstall")) {
						download();
					}
				}
			}
		} else {
			if (checking) {
				ImGui.BeginDisabled(() => {
					ImGui.Button(zh ? "检查更新" : "Check Update");
				});
			} else {
				if (ImGui.Button(zh ? "检查更新" : "Check Update")) {
					getLatestVersion();
				}
			}
		}
		if (unzipDone) {
			if (App.platform === "Android") {
				if (ImGui.Button(zh ? "进行安装" : "Install")) {
					const pathForInstall = Path(targetUnzipPath, `dora-ssr-${latestVersion}-android.apk`);
					App.install(pathForInstall);
				}
			}
		} else if (downloadTitle !== "") {
			ImGui.Separator();
			ImGui.Text(downloadTitle);
			ImGui.ProgressBar(progress, Vec2(-1, 30));
		}
		if (popupShow) {
			popupShow = false;
			ImGui.OpenPopup("MessagePopup");
		}
		ImGui.BeginPopupModal("MessagePopup", messagePopupFlags, messagePopup);
	});
	return false;
});

const node = Node();
node.onCleanup(() => {
	if (0 < progress && progress < 1 && downloadTargetFile !== "") {
		cancelDownload = true;
		Content.remove(downloadTargetFile);
	}
	if (targetUnzipPath !== "") {
		Content.remove(targetUnzipPath);
	}
});
