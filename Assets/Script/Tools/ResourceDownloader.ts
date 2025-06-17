// @preview-file on clear
import { HttpClient, json, thread, App, Vec2, Path, Content, Node, Texture2D, Job, Cache, Buffer, Director } from 'Dora';
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';

const url = "http://39.155.148.157:8866";

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null && ImGui.IsFontLoaded();
}

interface PackageListVersion {
	version: number;
	updatedAt: number;
}

interface PackageVersion {
	file: string;
	size: number;
	tag: string;
	commit: string;
	download: string;
	updatedAt: number;
}

interface PackageInfo {
	name: string;
	url: string;
	versions: PackageVersion[];
	currentVersion?: number;
	versionNames?: string[];
}

interface RepoInfo {
	name: string;
	title: {
		zh: string;
		en: string;
	};
	desc: {
		zh: string;
		en: string;
	};
}


const windowsNoScrollFlags = [
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoResize,
	WindowFlag.NoDecoration,
	WindowFlag.NoNav,
	WindowFlag.NoBringToFrontOnFocus,
];

const windowsFlags = [
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoResize,
	WindowFlag.NoDecoration,
	WindowFlag.NoNav,
	WindowFlag.AlwaysVerticalScrollbar,
	WindowFlag.NoBringToFrontOnFocus,
];

const themeColor = App.themeColor;

const sep = () => ImGui.SeparatorText("");
const thinSep = () => ImGui.PushStyleVar(ImGui.StyleVarNum.SeparatorTextBorderSize, 1, sep);

class ResourceDownloader {
	private packages: PackageInfo[] = [];
	private repos: RepoInfo[] = [];
	private downloadProgress: Map<string, {progress: number, status: string}> = new Map();
	private downloadTasks: Map<string, Job> = new Map();
	private popupMessageTitle = "";
	private popupMessage = "";
	private popupShow = false;
	private cancelDownload = false;
	private isDownloading = false;
	private node: Node.Type;
	private previewTextures: Map<string, Texture2D.Type> = new Map();
	private previewFiles: Map<string, string> = new Map();
	private downloadedPackages: Set<string> = new Set();
	private isLoading = false;
	private filterBuf = Buffer(20);
	private filterText = "";

	constructor() {
		this.node = Node();
		this.node.schedule(() => {
			this.update();
			return false;
		});
		this.node.onCleanup(() => {
			this.cancelDownload = true;
		});
		this.loadData();
	}

	private showPopup(title: string, msg: string) {
		this.popupMessageTitle = title;
		this.popupMessage = msg;
		this.popupShow = true;
	}

	private loadData() {
		if (this.isLoading) return;
		this.isLoading = true;
		thread(() => {
			let reload = false;
			const versionResponse = HttpClient.getAsync(`${url}/api/v1/package-list-version`);
			const packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json");
			if (versionResponse) {
				const [version] = json.load(versionResponse);
				const packageListVersion = version as PackageListVersion;
				if (Content.exist(packageListVersionFile)) {
					const [oldVersion] = json.load(Content.load(packageListVersionFile));
					const oldPackageListVersion = oldVersion as PackageListVersion;
					if (packageListVersion.version !== oldPackageListVersion.version) {
						reload = true;
					}
				} else {
					reload = true;
				}
			}
			if (reload) {
				this.packages = [];
				this.repos = [];
				this.previewTextures.clear();
				this.previewFiles.clear();
				const cachePath = Path(Content.appPath, ".cache", "preview");
				Content.remove(cachePath);
			}
			// Load packages data
			const cachePath = Path(Content.appPath, ".cache", "preview");
			Content.mkdir(cachePath);
			if (reload && versionResponse) {
				Content.save(packageListVersionFile, versionResponse);
			}
			const packagesFile = Path(cachePath, "packages.json");
			if (Content.exist(packagesFile)) {
				const [packages] = json.load(Content.load(packagesFile));
				this.packages = packages as PackageInfo[];
			} else {
				const packagesResponse = HttpClient.getAsync(`${url}/api/v1/packages`);
				if (packagesResponse) {
					// Cache packages data
					const [packages] = json.load(packagesResponse);
					this.packages = packages as PackageInfo[];
					Content.save(packagesFile, packagesResponse);
				}
			}
			for (const pkg of this.packages) {
				pkg.currentVersion = 1;
				pkg.versionNames = pkg.versions.map(v => {
					return v.tag === "" ? "No Tag" : v.tag;
				});
			}

			// Load repos data
			const reposFile = Path(cachePath, "repos.json");
			if (Content.exist(reposFile)) {
				const [repos] = json.load(Content.load(reposFile));
				this.repos = repos as RepoInfo[];
			} else {
				const reposResponse = HttpClient.getAsync(`${url}/assets/repos.json`);
				if (reposResponse) {
					const [repos] = json.load(reposResponse);
					this.repos = repos as RepoInfo[];
					Content.save(reposFile, reposResponse);
				}
			}

			// Load preview images for each package
			for (const pkg of this.packages) {
				const downloadPath = Path(Content.writablePath, "Download", pkg.name);
				if (Content.exist(downloadPath)) {
					this.downloadedPackages.add(pkg.name);
				}
				this.loadPreviewImage(pkg.name);
			}
			this.isLoading = false;
		});
	}

	private loadPreviewImage(name: string) {
		const cachePath = Path(Content.appPath, ".cache", "preview");
		const cacheFile = Path(cachePath, name + ".jpg");
		if (Content.exist(cacheFile)) {
			Cache.loadAsync(cacheFile);
			const texture = Texture2D(cacheFile);
			if (texture) {
				this.previewTextures.set(name, texture);
				this.previewFiles.set(name, cacheFile);
			}
			return;
		}
		const imageUrl = `${url}/assets/${name}/banner.jpg`;
		const response = HttpClient.downloadAsync(imageUrl, cacheFile, 10);
		if (response) {
			Cache.loadAsync(cacheFile);
			const texture = Texture2D(cacheFile);
			if (texture) {
				this.previewTextures.set(name, texture);
				this.previewFiles.set(name, cacheFile);
			}
		} else {
			print(`Failed to load preview image for ${name}`);
		}
	}

	private isDownloaded(name: string): boolean {
		return this.downloadedPackages.has(name);
	}

	private downloadPackage(pkg: PackageInfo) {
		if (this.downloadTasks.has(pkg.name)) {
			return;
		}

		const task = thread(() => {
			this.isDownloading = true;
			let downloadStatus = (zh ? "正在下载：" : "Downloading: ") + pkg.name;
			const downloadPath = Path(Content.writablePath, ".download");
			Content.mkdir(downloadPath);
			const currentVersion = pkg.currentVersion ?? 1;
			const version = pkg.versions[currentVersion - 1];
			const targetFile = Path(downloadPath, version.file);

			const success = HttpClient.downloadAsync(
				version.download,
				targetFile,
				30,
				(current, total) => {
					if (this.cancelDownload) {
						return true;
					}
					this.downloadProgress.set(pkg.name, {progress: current / total, status: downloadStatus});
					return false;
				}
			);

			if (success) {
				downloadStatus = zh ? `解压中：${pkg.name}` : `Unziping: ${pkg.name}`;
				this.downloadProgress.set(pkg.name, {progress: 1, status: downloadStatus})
				const unzipPath = Path(Content.writablePath, "Download", pkg.name);
				Content.remove(unzipPath);
				if (Content.unzipAsync(targetFile, unzipPath)) {
					Content.remove(targetFile);
					this.downloadedPackages.add(pkg.name);
					Director.postNode.emit("UpdateEntries");
				} else {
					Content.remove(unzipPath);
					this.showPopup(
						zh ? "解压失败" : "Failed to unzip",
						zh ? `无法解压文件：${version.file}` : `Failed to unzip: ${version.file}`
					);
				}
			} else {
				Content.remove(targetFile);
				this.showPopup(
					zh ? "下载失败" : "Download failed",
					zh ? `无法从该地址下载：${version.download}` : `Failed to download from: ${version.download}`
				);
			}

			this.isDownloading = false;
			this.downloadProgress.delete(pkg.name);
			this.downloadTasks.delete(pkg.name);
		});

		this.downloadTasks.set(pkg.name, task);
	}

	private messagePopup() {
		ImGui.Text(this.popupMessageTitle);
		ImGui.Separator();
		ImGui.PushTextWrapPos(300, () => {
			ImGui.TextWrapped(this.popupMessage);
		});
		if (ImGui.Button(zh ? "确认" : "OK", Vec2(300, 30))) {
			ImGui.CloseCurrentPopup();
		}
	}

	public update() {
		const {width, height} = App.visualSize;
		ImGui.SetNextWindowPos(Vec2.zero, SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, 51), SetCond.Always);
		ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(10, 0), () => ImGui.Begin("Dora Community Header", windowsNoScrollFlags, () => {
			ImGui.Dummy(Vec2(0, 0));
			ImGui.TextColored(themeColor, zh ? "Dora SSR 社区资源" : "Dora SSR Resources");
			ImGui.SameLine();
			ImGui.TextDisabled("(?)");
			if (ImGui.IsItemHovered()) {
				ImGui.BeginTooltip(() => {
					ImGui.PushTextWrapPos(300, () => {
						ImGui.Text(zh ? "使用该工具来下载 Dora SSR 的社区资源到 `Download` 目录。" : "Use this tool to download Dora SSR community resources to the `Download` directory.");
					});
				});
			}
			const padding = zh ? 400 : 440;
			if (width >= padding) {
				ImGui.SameLine();
				ImGui.Dummy(Vec2(width - padding, 0));
				ImGui.SameLine();
				ImGui.SetNextItemWidth(zh ? -40 : -55);
				if (ImGui.InputText(zh ? '筛选' : 'Filter', this.filterBuf, [ImGui.InputTextFlag.AutoSelectAll,])) {
					const [res] = string.match(this.filterBuf.text, "[^%%%.%[]+");
					this.filterText = (res ?? '').toLowerCase();
				}
			}
			ImGui.Separator();
		}));
		const maxColumns = math.max(math.floor(width / 320), 1);
		const itemWidth = (width - 60) / maxColumns - 10;
		ImGui.SetNextWindowPos(Vec2(0, 51), SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, height - 100), SetCond.Always);
		ImGui.PushStyleVar(ImGui.StyleVarNum.Alpha, 1, () => ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(20, 10), () => ImGui.Begin("Dora Community Resources", windowsFlags, () => {
			ImGui.Columns(maxColumns, false);

			// Display resources
			for (const pkg of this.packages) {
				const repo = this.repos.find(r => r.name === pkg.name);
				if (!repo) continue;

				if (this.filterText !== '') {
					const [res] = string.match(repo.name.toLowerCase(), this.filterText);
					if (!res) continue;
				}

				// Title
				ImGui.TextColored(themeColor, repo.title[zh ? "zh" : "en"]);

				// Preview image
				const previewTexture = this.previewTextures.get(pkg.name);
				if (previewTexture) {
					const {width, height} = previewTexture;
					// 保持宽高比，适应宽度
					const scale = itemWidth / width;
					const scaledSize = Vec2(width * scale, height * scale);
					const previewFile = this.previewFiles.get(pkg.name);
					if (previewFile) {
						ImGui.Image(previewFile, scaledSize);
					}
				} else {
					ImGui.Text(zh ? "加载预览图中..." : "Loading preview...");
				}

				ImGui.TextWrapped(repo.desc[zh ? "zh" : "en"]);

				ImGui.TextColored(themeColor, zh ? `项目地址：` : `Repo URL:`);
				ImGui.SameLine();
				if (ImGui.TextLink((zh ? '这里' : 'here') + `###${pkg.url}`)) {
					App.openURL(pkg.url);
				}
				if (ImGui.IsItemHovered()) {
					ImGui.BeginTooltip(() => {
						ImGui.PushTextWrapPos(300, () => {
							ImGui.Text(pkg.url);
						});
					});
				}

				const currentVersion = pkg.currentVersion ?? 1;
				const version = pkg.versions[currentVersion - 1];
				if ("number" === typeof version.updatedAt) {
					ImGui.TextColored(themeColor, zh ? `同步时间：` : `Updated:`);
					ImGui.SameLine();
					const dateStr = os.date("%Y-%m-%d %H:%M:%S", version.updatedAt);
					ImGui.Text(dateStr);
				}

				// Progress bar
				const progress = this.downloadProgress.get(pkg.name);
				if (progress !== undefined) {
					ImGui.ProgressBar(progress.progress, Vec2(-1, 30));
						ImGui.BeginDisabled(() => {
						ImGui.Button(progress.status);
					});
				}

				// Download button
				if (progress === undefined) {
					const isDownloaded = this.isDownloaded(pkg.name);
					const buttonText = (isDownloaded ?
						(zh ? "重新下载" : "Re-Download") :
						(zh ? "下载" : "Download")) + `###download-${pkg.name}`;
					const deleteText = (zh ? "删除" : "Delete") + `###delete-${pkg.name}`;
					if (this.isDownloading) {
						ImGui.BeginDisabled(() => {
							ImGui.Button(buttonText);
							if (isDownloaded) {
								ImGui.SameLine();
								ImGui.Button(deleteText);
							}
						});
					} else {
						if (ImGui.Button(buttonText)) {
							this.downloadPackage(pkg);
						}
						if (isDownloaded) {
							ImGui.SameLine();
							if (ImGui.Button(deleteText)) {
								Content.remove(Path(Content.writablePath, "Download", pkg.name));
								this.downloadedPackages.delete(pkg.name);
							}
						}
					}
				}

				// Package info
				ImGui.SameLine();
				ImGui.Text(`${(version.size / 1024 / 1024).toFixed(2)} MB`);
				if (!this.isDownloading && pkg.versionNames && pkg.currentVersion) {
					ImGui.SameLine();
					ImGui.SetNextItemWidth(-20);
					const [changed, currentVersion] = ImGui.Combo("###" + pkg.name, pkg.currentVersion, pkg.versionNames);
					if (changed) {
						pkg.currentVersion = currentVersion;
					}
				}

				thinSep();
				ImGui.NextColumn();
			}

			ImGui.Columns(1, false);
			ImGui.ScrollWhenDraggingOnVoid();

			if (this.popupShow) {
				this.popupShow = false;
				ImGui.OpenPopup("MessagePopup");
			}
			ImGui.BeginPopupModal("MessagePopup", () => this.messagePopup());
		})));
	}
}

new ResourceDownloader();
