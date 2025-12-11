// @preview-file on clear
import { HttpClient, json, thread, App, Vec2, Path, Content, Node, Texture2D, Job, Cache, Buffer, Director } from 'Dora';
import { SetCond, WindowFlag, TabBarFlag } from "ImGui";
import * as ImGui from 'ImGui';
import * as Config from 'Config';

const DefaultURL = "http://39.155.148.157:8866";

interface ResConfig {
	url: string;
}

const url = Buffer(1024);
const config = Config<ResConfig>(".ResConf", "url");
config.load();

if (typeof config.url === "string") {
	url.text = config.url;
} else {
	url.text = config.url = DefaultURL;
}

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null;
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
	categories?: string[];
	exe?: boolean | string[];
}

const windowsNoScrollFlags = [
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoResize,
	WindowFlag.NoDecoration,
	WindowFlag.NoNav,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoBringToFrontOnFocus,
];

const windowsFlags = [
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoResize,
	WindowFlag.NoDecoration,
	WindowFlag.NoNav,
	WindowFlag.NoSavedSettings,
	WindowFlag.AlwaysVerticalScrollbar,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoBringToFrontOnFocus,
];

const tabBarFlags = [
	TabBarFlag.FittingPolicyScroll,
	TabBarFlag.DrawSelectedOverline,
	TabBarFlag.NoCloseWithMiddleMouseButton,
	TabBarFlag.TabListPopupButton,
];

const themeColor = App.themeColor;

const sep = () => ImGui.SeparatorText("");
const thinSep = () => ImGui.PushStyleVar(ImGui.StyleVarNum.SeparatorTextBorderSize, 1, sep);

const run = (fileName: string) => {
	const Entry = require("Script.Dev.Entry");
	Entry.allClear();
	thread(() => {
		Entry.enterEntryAsync({entryName: "Project", fileName});
	});
};

class ResourceDownloader {
	private packages: PackageInfo[] = [];
	private repos: Map<string, RepoInfo> = new Map();
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
	private categories: string[] = [];
	private headerHeight = 80;

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
			const versionResponse = HttpClient.getAsync(`${config.url}/api/v1/package-list-version`);
			const packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json");
			if (versionResponse) {
				const [version] = json.decode(versionResponse);
				const packageListVersion = version as PackageListVersion;
				if (Content.exist(packageListVersionFile)) {
					const [oldVersion] = json.decode(Content.load(packageListVersionFile));
					const oldPackageListVersion = oldVersion as PackageListVersion;
					if (packageListVersion.version !== oldPackageListVersion.version) {
						reload = true;
					}
				} else {
					reload = true;
				}
			}
			if (reload) {
				this.categories = [];
				this.packages = [];
				this.repos = new Map();
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
				const [packages] = json.decode(Content.load(packagesFile));
				this.packages = packages as PackageInfo[];
			} else {
				const packagesResponse = HttpClient.getAsync(`${config.url}/api/v1/packages`);
				if (packagesResponse) {
					// Cache packages data
					const [packages] = json.decode(packagesResponse);
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
			const catSet = new Set<string>();
			const loadRepos = (repos: RepoInfo[]) => {
				for (let repo of repos) {
					this.repos.set(repo.name, repo);
					if (repo.categories) {
						for (let cat of repo.categories) {
							catSet.add(cat);
						}
					}
				}
			};
			const reposFile = Path(cachePath, "repos.json");
			if (Content.exist(reposFile)) {
				const [repos] = json.decode(Content.load(reposFile));
				loadRepos(repos as RepoInfo[]);
			} else {
				const reposResponse = HttpClient.getAsync(`${config.url}/assets/repos.json`);
				if (reposResponse) {
					const [repos] = json.decode(reposResponse);
					loadRepos(repos as RepoInfo[]);
					Content.save(reposFile, reposResponse);
				}
			}
			for (let cat of catSet) {
				this.categories.push(cat);
			}

			// Load preview images for each package
			for (const pkg of this.packages) {
				const downloadPath = Path(Content.writablePath, "Download", pkg.name);
				if (Content.exist(downloadPath)) {
					this.downloadedPackages.add(pkg.name);
				}
			}
			for (const pkg of this.packages) {
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
		const imageUrl = `${config.url}/assets/${name}/banner.jpg`;
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
					const repo = this.repos.get(pkg.name);
					if (repo) {
						const [str] = json.encode(repo);
						if (str) {
							if (Content.mkdir(Path(unzipPath, ".dora"))) {
								Content.save(Path(unzipPath, ".dora", "repo.json"), str);
								const previewFile = this.previewFiles.get(pkg.name);
								if (previewFile && Content.exist(previewFile)) {
									Content.copy(previewFile, Path(unzipPath, ".dora", "banner.jpg"));
								}
							}
						}
					}
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
		let filterCategory: null | string = null;
		ImGui.SetNextWindowPos(Vec2.zero, SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, this.headerHeight), SetCond.Always);
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
				ImGui.SetNextItemWidth((zh ? -40 : -55) - 40);
				if (ImGui.InputText(zh ? '筛选' : 'Filter', this.filterBuf, [ImGui.InputTextFlag.AutoSelectAll,])) {
					const [res] = string.match(this.filterBuf.text, "[^%%%.%[]+");
					this.filterText = (res ?? '').toLowerCase();
				}
			} else {
				ImGui.SameLine();
				ImGui.Dummy(Vec2(width - (zh ? 250 : 255), 0));
			}
			ImGui.SameLine();
			if (ImGui.CollapsingHeader("##option")) {
				this.headerHeight = 130;
				ImGui.SetNextItemWidth(zh ? -200 : -230);
				if (ImGui.InputText(zh ? "服务器" : "Server", url)) {
					if (url.text == "") {
						url.text = DefaultURL;
					}
					config.url = url.text;
				}
				ImGui.SameLine();
				if (ImGui.Button(zh ? "刷新" : "Reload")) {
					const packageListVersionFile = Path(Content.appPath, ".cache", "preview", "package-list-version.json");
					Content.remove(packageListVersionFile);
					this.loadData();
				}
				ImGui.Separator();
			} else {
				this.headerHeight = 80;
			}
			ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(10, 10), () => ImGui.BeginTabBar("categories", tabBarFlags, () => {
				ImGui.BeginTabItem(zh ? '全部' : 'All', () => {
					filterCategory = null;
				});
				for (let cat of this.categories) {
					ImGui.BeginTabItem(cat, () => {
						filterCategory = cat;
					});
				}
			}));
		}));
		function matchCat(this: any, cat: string) { return filterCategory === cat; }
		const maxColumns = math.max(math.floor(width / 320), 1);
		const itemWidth = (width - 60) / maxColumns - 10;
		ImGui.SetNextWindowPos(Vec2(0, this.headerHeight), SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, height - this.headerHeight - 50), SetCond.Always);
		ImGui.PushStyleVar(ImGui.StyleVarNum.Alpha, 1, () => ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(20, 10), () => ImGui.Begin("Dora Community Resources", windowsFlags, () => {
			ImGui.Columns(maxColumns, false);

			// Display resources
			for (const pkg of this.packages) {
				const repo = this.repos.get(pkg.name)
				if (!repo) continue;
				if (filterCategory !== null) {
					if (!repo.categories) continue;
					if (repo.categories.find(matchCat) === null) {
						continue;
					}
				}

				const title = repo.title[zh ? "zh" : "en"];

				if (this.filterText !== '') {
					const [res] = string.match(title.toLowerCase(), this.filterText);
					if (!res) continue;
				}

				// Title
				ImGui.TextColored(themeColor, title);

				// Preview image
				const previewTexture = this.previewTextures.get(pkg.name);
				if (previewTexture) {
					const {width, height} = previewTexture;
					// 保持宽高比，适应宽度
					const scale = (itemWidth - 30) / width;
					const scaledSize = Vec2(width * scale, height * scale);
					const previewFile = this.previewFiles.get(pkg.name);
					if (previewFile) {
						ImGui.Dummy(Vec2.zero);
						ImGui.SameLine();
						ImGui.Image(previewFile, scaledSize);
					}
				} else {
					ImGui.Text(zh ? "加载预览图中..." : "Loading preview...");
				}

				ImGui.TextWrapped(repo.desc[zh ? "zh" : "en"]);

				ImGui.TextColored(themeColor, zh ? `项目地址：` : `Repo URL:`);
				ImGui.SameLine();
				if (ImGui.TextLink((zh ? '这里' : 'here') + `##${pkg.url}`)) {
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

				// Package info
				ImGui.TextColored(themeColor, zh ? `文件大小：` : `File Size:`);
				ImGui.SameLine();
				ImGui.Text(`${(version.size / 1024 / 1024).toFixed(2)} MB`);

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
					const exeText = (zh ? "测试" : "Test") + `##test-${pkg.name}`;
					const buttonText = (isDownloaded ?
						(zh ? "重新下载" : "Re-Download") :
						(zh ? "下载" : "Download")) + `##download-${pkg.name}`;
					const deleteText = (zh ? "删除" : "Delete") + `##delete-${pkg.name}`;
					const runable = repo.exe !== false;
					if (this.isDownloading) {
						ImGui.BeginDisabled(() => {
							if (runable) {
								ImGui.Button(exeText);
								ImGui.SameLine();
							}
							ImGui.Button(buttonText);
							if (isDownloaded) {
								ImGui.SameLine();
								ImGui.Button(deleteText);
							}
						});
					} else {
						if (isDownloaded && runable) {
							if (typeof repo.exe === 'object') {
								const exeList = repo.exe;
								const popupId = `select-${pkg.name}`;
								if (ImGui.Button(exeText)) {
									ImGui.OpenPopup(popupId);
								}
								ImGui.BeginPopup(popupId, () => {
									for (const entry of exeList) {
										if (ImGui.Selectable(`${entry}##run-${pkg.name}-${entry}`)) {
											run(Path(Content.writablePath, "Download", pkg.name, entry, "init"));
										}
									}
								});
							} else {
								if (ImGui.Button(exeText)) {
									run(Path(Content.writablePath, "Download", pkg.name, "init"));
								}
							}
							ImGui.SameLine();
						}
						if (ImGui.Button(buttonText)) {
							this.downloadPackage(pkg);
						}
						if (isDownloaded) {
							ImGui.SameLine();
							if (ImGui.Button(deleteText)) {
								Content.remove(Path(Content.writablePath, "Download", pkg.name));
								this.downloadedPackages.delete(pkg.name);
								Director.postNode.emit("UpdateEntries");
							}
						}
					}
				}

				if (!this.isDownloading && pkg.versionNames && pkg.currentVersion) {
					ImGui.SameLine();
					ImGui.SetNextItemWidth(-20);
					const [changed, currentVersion] = ImGui.Combo("##" + pkg.name, pkg.currentVersion, pkg.versionNames);
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
