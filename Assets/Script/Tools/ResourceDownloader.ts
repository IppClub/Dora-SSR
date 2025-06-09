// @preview-file on clear
import { HttpClient, json, thread, App, Vec2, Path, Content, Node, Texture2D, Job, Cache, Buffer } from 'Dora';
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null && ImGui.IsFontLoaded();
}

interface PackageInfo {
	name: string;
	url: string;
	latest: {
		file: string;
		size: number;
		tag: string;
		commit: string;
		download: string;
		updatedAt: string;
	};
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

	private loadData(reload: boolean = false) {
		if (this.isLoading) return;
		this.isLoading = true;
		if (reload) {
			this.packages = [];
			this.repos = [];
			this.previewTextures.clear();
			this.previewFiles.clear();
			const cachePath = Path(Content.appPath, ".cache", "preview");
			Content.remove(cachePath);
		}
		thread(() => {
			// Load packages data
			const cachePath = Path(Content.appPath, ".cache", "preview");
			Content.mkdir(cachePath);
			const packagesFile = Path(cachePath, "packages.json");
			if (Content.exist(packagesFile)) {
				const [packages] = json.load(Content.load(packagesFile));
				this.packages = packages as PackageInfo[];
			} else {
				const packagesResponse = HttpClient.getAsync("http://39.155.148.157:8866/api/v1/packages");
				if (packagesResponse) {
					// Cache packages data
					const [packages] = json.load(packagesResponse);
					this.packages = packages as PackageInfo[];
					Content.save(packagesFile, packagesResponse);
				}
			}

			// Load repos data
			const reposFile = Path(cachePath, "repos.json");
			if (Content.exist(reposFile)) {
				const [repos] = json.load(Content.load(reposFile));
				this.repos = repos as RepoInfo[];
			} else {
				const reposResponse = HttpClient.getAsync("http://39.155.148.157:8866/assets/repos.json");
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
		const imageUrl = `http://39.155.148.157:8866/assets/${name}/banner.jpg`;
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
			const targetFile = Path(downloadPath, pkg.latest.file);

			const success = HttpClient.downloadAsync(
				pkg.latest.download,
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
				} else {
					Content.remove(unzipPath);
					this.showPopup(
						zh ? "解压失败" : "Failed to unzip",
						zh ? `无法解压文件：${pkg.latest.file}` : `Failed to unzip: ${pkg.latest.file}`
					);
				}
			} else {
				Content.remove(targetFile);
				this.showPopup(
					zh ? "下载失败" : "Download failed",
					zh ? `无法从该地址下载：${pkg.latest.download}` : `Failed to download from: ${pkg.latest.download}`
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
			ImGui.SameLine();
			if (this.isDownloading || this.isLoading) {
				ImGui.BeginDisabled(() => {
					ImGui.Button(zh ? "刷新" : "Refresh");
				});
			} else {
				if (ImGui.Button(zh ? "刷新" : "Refresh")) {
					this.loadData(true);
				}
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
		const maxColumns = math.max(math.floor(width / 350), 1);
		const itemWidth = (width - 60) / maxColumns - 10;
		ImGui.SetNextWindowPos(Vec2(0, 51), SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, height - 100), SetCond.Always);
		ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(20, 10), () => ImGui.Begin("Dora Community Resources", windowsFlags, () => {
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
				ImGui.TextLinkOpenURL((zh ? '这里' : 'here') + `###${pkg.url}`, pkg.url);

				ImGui.TextColored(themeColor, zh ? `同步时间：` : `Updated:`);
				ImGui.SameLine();
				const dateStr = pkg.latest.updatedAt.replace("T", " ").replace("Z", "");
				ImGui.Text(dateStr);

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
					const buttonText = isDownloaded ?
						(zh ? "重新下载" : "Download Again") :
						(zh ? "下载" : "Download");
					if (this.isDownloading) {
						ImGui.BeginDisabled(() => {
							ImGui.PushID(pkg.name, () => {
									ImGui.Button(buttonText);
							});
						});
					} else {
						ImGui.PushID(pkg.name, () => {
							if (ImGui.Button(buttonText)) {
								this.downloadPackage(pkg);
							}
						});
					}
				}

				// Package info
				ImGui.SameLine();
				ImGui.Text(`${(pkg.latest.size / 1024 / 1024).toFixed(2)} MB`);

				thinSep();
				ImGui.NextColumn();
			}

			ImGui.ScrollWhenDraggingOnVoid();

			if (this.popupShow) {
				this.popupShow = false;
				ImGui.OpenPopup("MessagePopup");
			}
			ImGui.BeginPopupModal("MessagePopup", () => this.messagePopup());
		}));
	}
}

new ResourceDownloader();
