// @preview-file on clear
import { App, Buffer, Cache, Color, Content, Director, Node, Path, Texture2D, thread, Vec2 } from "Dora";
import { ChildFlag, SetCond, TabBarFlag, WindowFlag } from "ImGui";
import * as ImGui from "ImGui";
import {
	filterResources,
	isMinigame,
	paginateResources,
	type ResourceInfo,
	type ResourcePage,
	type ResourceSection,
} from "Script/Tools/ResourceDownloader/Catalog";
import {
	loadCachedCatalog,
	syncCatalog,
	type CatalogSnapshot,
	type CatalogSyncStatus,
} from "Script/Tools/ResourceDownloader/CatalogSync";
import {
	getResourceInstallPath,
	installResource,
	isResourceInstalled,
	type ResourceInstallProgress,
} from "Script/Tools/ResourceDownloader/GitInstaller";

const windowsNoScrollFlags = [
	WindowFlag.NoMove,
	WindowFlag.NoCollapse,
	WindowFlag.NoResize,
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoBringToFrontOnFocus,
];

const windowsFlags = [
	...windowsNoScrollFlags,
	WindowFlag.AlwaysVerticalScrollbar,
];

const tabBarFlags = [
	TabBarFlag.FittingPolicyScroll,
	TabBarFlag.DrawSelectedOverline,
	TabBarFlag.NoCloseWithMiddleMouseButton,
	TabBarFlag.TabListPopupButton,
];

let zh = false;
{
	const [matchedLocale] = string.match(App.locale, "^zh");
	zh = matchedLocale !== undefined;
}
const themeColor = App.themeColor;
const defaultBanner = () => Path(Content.assetPath, "Image", "banner.jpg");

const run = (fileName: string) => {
	const Entry = require("Script.Dev.Entry");
	Entry.allClear();
	thread(() => Entry.enterEntryAsync({ entryName: "Project", fileName }));
};

const inlineText = (text: string) => {
	const [collapsed] = string.gsub(text, "%s+", " ");
	const [withoutLeadingSpace] = string.gsub(collapsed, "^%s+", "");
	const [trimmed] = string.gsub(withoutLeadingSpace, "%s+$", "");
	return trimmed;
};

const truncateText = (text: string, byteLimit: number) => {
	if (string.len(text) <= byteLimit) return { text, truncated: false };
	const nextCharacter = utf8.offset(text, 0, byteLimit + 1) ?? byteLimit + 1;
	return {
		text: `${string.sub(text, 1, nextCharacter - 1)}…`,
		truncated: true,
	};
};

const displayText = (text: string, byteLimit: number) => truncateText(text, byteLimit).text;

class ResourceDownloader {
	private readonly node: Node.Type;
	private readonly filterBuffer = Buffer(80);
	private resources: ResourceInfo[] = [];
	private categories: string[] = [];
	private snapshot?: CatalogSnapshot;
	private section: ResourceSection = "featured";
	private categoryIndex = 1;
	private filterText = "";
	private page = 0;
	private resetListScroll = false;
	private headerHeight = 88;
	private isCatalogLoading = false;
	private catalogStatus?: CatalogSyncStatus;
	private catalogWarning = "";
	private catalogError = "";
	private cancelOperations = false;
	private installingId?: string;
	private installProgress?: ResourceInstallProgress;
	private popupTitle = "";
	private popupMessage = "";
	private popupShow = false;
	private deleteResource?: ResourceInfo;
	private deletePopupShow = false;
	private detailsResource?: ResourceInfo;
	private detailsPopupShow = false;
	private previewTextures = new Map<string, Texture2D.Type>();
	private pendingPreviews = new Set<string>();
	private previewOrder: string[] = [];

	constructor() {
		this.node = Node();
		this.node.schedule(() => {
			this.update();
			return false;
		});
		this.node.onCleanup(() => {
			this.cancelOperations = true;
			this.previewTextures.clear();
			this.pendingPreviews.clear();
		});
		const cached = loadCachedCatalog();
		if (cached.success && cached.snapshot) this.applySnapshot(cached.snapshot);
		this.refreshCatalog(false);
	}

	private applySnapshot(snapshot: CatalogSnapshot) {
		this.snapshot = snapshot;
		this.resources = snapshot.catalog.resources;
		this.categories = snapshot.catalog.categories;
		this.page = 0;
	}

	private refreshCatalog(force: boolean) {
		if (this.isCatalogLoading) return;
		this.isCatalogLoading = true;
		this.catalogError = "";
		this.catalogWarning = "";
		(async () => {
			const result = await syncCatalog({
				force,
				isCanceled: () => this.cancelOperations,
				onStatus: status => {
					if (this.isCatalogLoading) this.catalogStatus = status;
				},
			});
			this.isCatalogLoading = false;
			this.catalogStatus = undefined;
			if (result.success && result.snapshot) {
				this.applySnapshot(result.snapshot);
				if (result.usedCache && result.message) this.catalogWarning = result.message;
			} else {
				this.catalogError = result.message ?? (zh ? "资源目录同步失败" : "Catalog synchronization failed");
			}
		})();
	}

	private showMessage(title: string, message: string) {
		this.popupTitle = title;
		this.popupMessage = message;
		this.popupShow = true;
	}

	private touchPreview(file: string) {
		const oldIndex = this.previewOrder.indexOf(file);
		if (oldIndex >= 0) this.previewOrder.splice(oldIndex, 1);
		this.previewOrder.push(file);
		while (this.previewOrder.length > 36) {
			const expiredFile = this.previewOrder.shift();
			if (!expiredFile) break;
			this.previewTextures.delete(expiredFile);
			Cache.unload(expiredFile);
		}
	}

	private loadPreview(resource: ResourceInfo) {
		const file = resource.bannerPath ?? defaultBanner();
		const existing = this.previewTextures.get(file);
		if (existing) {
			this.touchPreview(file);
			return existing;
		}
		if (this.pendingPreviews.has(file)) return undefined;
		if (!Content.exist(file)) return undefined;
		this.pendingPreviews.add(file);
		thread(() => {
			Cache.loadAsync(file);
			this.pendingPreviews.delete(file);
			if (this.cancelOperations) return;
			const texture = Texture2D(file);
			if (!texture) return;
			if (texture.width > 4096 || texture.height > 4096) {
				Cache.unload(file);
				return;
			}
			this.previewTextures.set(file, texture);
			this.touchPreview(file);
		});
		return undefined;
	}

	private selectedVersion(resource: ResourceInfo) {
		const index = math.max(1, math.min(resource.selectedVersion, resource.versions.length));
		resource.selectedVersion = index;
		return resource.versions[index - 1];
	}

	private install(resource: ResourceInfo) {
		if (this.installingId || !this.snapshot) return;
		const version = this.selectedVersion(resource);
		this.installingId = resource.id;
		this.installProgress = { progress: 0, message: zh ? "准备安装" : "Preparing installation" };
		(async () => {
			const result = await installResource(resource, version, {
				catalogCommit: this.snapshot?.commit ?? "",
				isCanceled: () => this.cancelOperations,
				onProgress: progress => {
					this.installProgress = progress;
				},
			});
			this.installingId = undefined;
			this.installProgress = undefined;
			if (!result.success && !result.canceled) {
				this.showMessage(
					zh ? "安装失败" : "Installation failed",
					result.message ?? (zh ? "无法安装资源" : "Could not install the resource"),
				);
			}
		})();
	}

	private runResource(resource: ResourceInfo) {
		const basePath = getResourceInstallPath(resource.id);
		if (resource.entrypoints.length === 0) {
			run(Path(basePath, "init"));
			return;
		}
		if (resource.entrypoints.length === 1) {
			run(Path(basePath, resource.entrypoints[0].path));
			return;
		}
		ImGui.OpenPopup(`run-${resource.id}`);
	}

	private drawRunPopup(resource: ResourceInfo) {
		if (resource.entrypoints.length <= 1) return;
		ImGui.BeginPopup(`run-${resource.id}`, () => {
			for (const entry of resource.entrypoints) {
				if (ImGui.Selectable(`${entry.name}##${resource.id}-${entry.path}`)) {
					run(Path(getResourceInstallPath(resource.id), entry.path));
				}
			}
		});
	}

	private drawStatusLine() {
		if (this.catalogStatus) {
			ImGui.TextDisabled(this.catalogStatus.message);
			ImGui.SameLine();
			ImGui.ProgressBar(this.catalogStatus.progress, Vec2(130, 0));
			return;
		}
		if (this.snapshot) {
			ImGui.TextDisabled(
				`${zh ? "目录" : "Catalog"} ${this.snapshot.commit.substring(0, 8)}`,
			);
			if (ImGui.IsItemHovered()) {
				ImGui.BeginTooltip(() => {
					ImGui.PushTextWrapPos(420, () => {
						ImGui.TextWrapped(`${zh ? "来源" : "Source"}: ${this.snapshot?.source ?? ""}`);
						ImGui.Text(`${zh ? "同步时间" : "Synced"}: ${this.snapshot?.syncedAt ?? ""}`);
					});
				});
			}
			return;
		}
		ImGui.TextDisabled(
			this.catalogError !== ""
				? (zh ? "目录不可用" : "Catalog unavailable")
				: (zh ? "正在获取资源目录…" : "Fetching the resource catalog…"),
		);
	}

	private drawHeader(width: number, page: ResourcePage) {
		this.headerHeight = this.catalogError !== "" || this.catalogWarning !== "" ? 148 : 118;
		ImGui.SetNextWindowPos(Vec2.zero, SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, this.headerHeight), SetCond.Always);
		ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(16, 8), () => {
			ImGui.Begin("Dora Resource Catalog Header", windowsNoScrollFlags, () => {
				ImGui.TextColored(themeColor, zh ? "Dora SSR 社区资源" : "Dora SSR Community");
				ImGui.SameLine();
				ImGui.TextDisabled("(?)");
				if (ImGui.IsItemHovered()) {
					ImGui.BeginTooltip(() => {
						ImGui.PushTextWrapPos(420, () => {
							ImGui.TextWrapped(
								zh
									? "项目通过 Git 安装到 Download；安装后可通过 Git 继续更新和维护。"
									: "Projects are installed with Git. After installation, your Git workflow owns updates and local changes.",
							);
						});
					});
				}
				ImGui.SameLine();
				this.drawStatusLine();
				const refreshWidth = zh ? 80 : 85;
				ImGui.SameLine();
				ImGui.Dummy(Vec2(math.max(0, width - ImGui.GetCursorPosX() - refreshWidth - 24), 0));
				ImGui.SameLine();
				if (this.isCatalogLoading) {
					ImGui.BeginDisabled(() => ImGui.Button(zh ? "同步中" : "Syncing", Vec2(refreshWidth, 0)));
				} else if (ImGui.Button(zh ? "刷新目录" : "Refresh", Vec2(refreshWidth, 0))) {
					this.refreshCatalog(true);
				}

				if (this.catalogError !== "") {
					ImGui.TextColored(Color(0xffff5a5a), displayText(this.catalogError, 150));
				} else if (this.catalogWarning !== "") {
					ImGui.TextColored(Color(0xff66b3ff), displayText(this.catalogWarning, 150));
				}

				ImGui.BeginTabBar("resource-sections", tabBarFlags, () => {
					ImGui.BeginTabItem(zh ? "作品" : "Projects", () => {
						if (this.section !== "featured") {
							this.section = "featured";
							this.page = 0;
						}
					});
					ImGui.BeginTabItem("Mini Games", () => {
						if (this.section !== "minigame") {
							this.section = "minigame";
							this.page = 0;
						}
					});
					ImGui.BeginTabItem(zh ? "全部" : "All", () => {
						if (this.section !== "all") {
							this.section = "all";
							this.page = 0;
						}
					});
				});

				ImGui.SameLine();
				ImGui.SetNextItemWidth(zh ? 150 : 165);
				const categoryNames = [zh ? "全部分类" : "All categories", ...this.categories];
				const [categoryChanged, categoryIndex] = ImGui.Combo("##resource-category", this.categoryIndex, categoryNames);
				if (categoryChanged) {
					this.categoryIndex = categoryIndex;
					this.page = 0;
				}
				ImGui.SameLine();
				ImGui.TextDisabled(zh ? "搜索" : "Search");
				ImGui.SameLine();
				ImGui.SetNextItemWidth(-1);
				if (ImGui.InputText("##resource-search", this.filterBuffer, [ImGui.InputTextFlag.AutoSelectAll])) {
					this.filterText = this.filterBuffer.text;
					this.page = 0;
				}

				if (this.resources.length > 0) {
					ImGui.TextDisabled(
						zh
							? `共 ${page.total} 项 · 第 ${page.page + 1}/${page.pageCount} 页`
							: `${page.total} items · page ${page.page + 1}/${page.pageCount}`,
					);
					ImGui.SameLine();
					if (page.page > 0 && ImGui.SmallButton(zh ? "上一页" : "Previous")) {
						this.page--;
						this.resetListScroll = true;
					}
					if (page.page > 0) ImGui.SameLine();
					if (page.page + 1 < page.pageCount && ImGui.SmallButton(zh ? "下一页" : "Next")) {
						this.page++;
						this.resetListScroll = true;
					}
				}
			});
		});
	}

	private drawPreview(resource: ResourceInfo, itemWidth: number, previewHeight: number) {
		const texture = this.loadPreview(resource);
		const availableWidth = itemWidth - 20;
		if (!texture) {
			ImGui.Dummy(Vec2(availableWidth, previewHeight));
			return;
		}
		const scale = math.min(availableWidth / texture.width, previewHeight / texture.height);
		const imageWidth = texture.width * scale;
		const imageHeight = texture.height * scale;
		if (imageWidth < availableWidth) {
			ImGui.Dummy(Vec2((availableWidth - imageWidth) / 2, 0));
			ImGui.SameLine();
		}
		ImGui.Image(resource.bannerPath ?? defaultBanner(), Vec2(imageWidth, imageHeight));
		if (imageHeight < previewHeight) ImGui.Dummy(Vec2(0, previewHeight - imageHeight));
	}

	private drawResourceCard(resource: ResourceInfo, itemWidth: number) {
		const title = resource.title[zh ? "zh-Hans" : "en"];
		const description = inlineText(resource.description[zh ? "zh-Hans" : "en"]);
		const displayedDescription = truncateText(description, 160);
		const descriptionLines = (itemWidth >= 500 ? 2 : itemWidth >= 340 ? 3 : 4) + (zh ? 0 : 1);
		const descriptionHeight = ImGui.GetTextLineHeightWithSpacing() * descriptionLines;
		const previewHeight = math.max(150, math.min(240, (itemWidth - 20) * 0.45));
		const cardHeight = 164 + previewHeight + descriptionHeight;
		const version = this.selectedVersion(resource);
		const source = version.sources[0];
		const installed = isResourceInstalled(resource.id);
		ImGui.BeginChild(`card-${resource.id}`, Vec2(itemWidth, cardHeight), [ChildFlag.NavFlattened], () => {
			ImGui.TextColored(themeColor, displayText(title, 46));
			if (isMinigame(resource)) {
				ImGui.SameLine();
				ImGui.TextDisabled("MINI");
			}
			if (resource.status !== "active") {
				ImGui.SameLine();
				ImGui.TextDisabled(resource.status.toUpperCase());
			}
			this.drawPreview(resource, itemWidth, previewHeight);
			ImGui.BeginChild(
				`description-${resource.id}`,
				Vec2(-1, descriptionHeight),
				[],
				[WindowFlag.NoScrollbar, WindowFlag.NoScrollWithMouse],
				() => {
					ImGui.TextWrapped(displayedDescription.text);
				},
			);
			if (source !== undefined && ImGui.TextLink(`${zh ? "项目仓库" : "Repository"}##repo-${resource.id}`)) {
				App.openURL(source.url);
			}
			if (source !== undefined && ImGui.IsItemHovered()) {
				ImGui.BeginTooltip(() => {
					ImGui.PushTextWrapPos(420, () => ImGui.Text(source.url));
				});
			}
			if (source !== undefined) ImGui.SameLine();
			if (ImGui.TextLink(`${zh ? "详情" : "Details"}##details-${resource.id}`)) {
				this.detailsResource = resource;
				this.detailsPopupShow = true;
			}
			ImGui.TextDisabled(
				`${version.name} · ${
					resource.license.status === "pending"
						? (zh ? "许可待完善" : "license pending")
						: resource.license.spdx
				}`,
			);
			const versionNames = resource.versions.map(item => item.name);
			if (versionNames.length > 1 && !installed) {
				ImGui.SetNextItemWidth(-1);
				const [changed, selected] = ImGui.Combo(`##version-${resource.id}`, resource.selectedVersion, versionNames);
				if (changed) resource.selectedVersion = selected;
			}
			const currentInstall = this.installingId === resource.id;
			if (currentInstall && this.installProgress) {
				ImGui.ProgressBar(this.installProgress.progress, Vec2(-1, 26));
				ImGui.TextDisabled(displayText(this.installProgress.message, 60));
			} else if (installed) {
				if (resource.runnable && resource.status !== "blocked") {
					if (ImGui.Button(`${zh ? "测试" : "Run"}##run-button-${resource.id}`)) {
						this.runResource(resource);
					}
					ImGui.SameLine();
				}
				ImGui.BeginDisabled(() => ImGui.Button(`${zh ? "已安装" : "Installed"}##installed-${resource.id}`));
				ImGui.SameLine();
				if (ImGui.Button(`${zh ? "删除" : "Delete"}##delete-${resource.id}`)) {
					this.deleteResource = resource;
					this.deletePopupShow = true;
				}
			} else {
				const cannotInstall = this.installingId !== undefined
					|| resource.status === "unavailable"
					|| resource.status === "blocked"
					|| !this.snapshot;
				if (cannotInstall) {
					ImGui.BeginDisabled(() => ImGui.Button(`${zh ? "安装" : "Install"}##install-${resource.id}`));
				} else if (ImGui.Button(`${zh ? "安装" : "Install"}##install-${resource.id}`)) {
					this.install(resource);
				}
			}
			this.drawRunPopup(resource);
		});
	}

	private drawDetailsPopup() {
		const popupTitle = zh ? "作品详情" : "Project Details";
		if (this.detailsPopupShow) {
			this.detailsPopupShow = false;
			ImGui.OpenPopup(popupTitle);
		}
		const { width, height } = App.visualSize;
		ImGui.SetNextWindowSize(
			Vec2(
				math.max(260, math.min(560, width - 40)),
				math.max(220, math.min(420, height - 40)),
			),
			SetCond.Appearing,
		);
		ImGui.BeginPopupModal(popupTitle, () => {
			const resource = this.detailsResource;
			if (!resource) {
				ImGui.CloseCurrentPopup();
				return;
			}
			const version = this.selectedVersion(resource);
			const status = resource.status === "active"
				? (zh ? "可用" : "Available")
				: resource.status === "deprecated"
					? (zh ? "已弃用" : "Deprecated")
					: resource.status === "unavailable"
						? (zh ? "暂不可用" : "Unavailable")
						: (zh ? "已阻止" : "Blocked");
			const license = resource.license.status === "pending"
				? (zh ? "许可待完善" : "Pending")
				: resource.license.spdx;
			const detailLine = (label: string, value: string) => {
				ImGui.TextDisabled(`${label}:`);
				ImGui.SameLine();
				ImGui.TextWrapped(value);
			};
			ImGui.TextColored(themeColor, resource.title[zh ? "zh-Hans" : "en"]);
			ImGui.Separator();
			ImGui.BeginChild("resource-details-text", Vec2(-1, -48), () => {
				ImGui.TextColored(themeColor, zh ? "简介" : "Description");
				ImGui.TextWrapped(resource.description[zh ? "zh-Hans" : "en"]);
				ImGui.Spacing();
				ImGui.TextColored(themeColor, zh ? "项目信息" : "Project Information");
				detailLine(zh ? "类型" : "Type", isMinigame(resource) ? (zh ? "小游戏" : "Mini Game") : (zh ? "社区作品" : "Community Project"));
				detailLine(
					zh ? "分类" : "Categories",
					resource.categories.length > 0
						? resource.categories.join(" · ")
						: (zh ? "未分类" : "Uncategorized"),
				);
				detailLine(
					zh ? "标签" : "Tags",
					resource.tags.length > 0 ? resource.tags.join(" · ") : (zh ? "无" : "None"),
				);
				detailLine(zh ? "状态" : "Status", status);
				detailLine(zh ? "版本" : "Version", version.name);
				detailLine(zh ? "发布时间" : "Published", version.publishedAt);
				detailLine(zh ? "许可证" : "License", license);
				ImGui.ScrollWhenDraggingOnVoid();
			});
			if (ImGui.Button(zh ? "关闭" : "Close", Vec2(-1, 30))) {
				this.detailsResource = undefined;
				ImGui.CloseCurrentPopup();
			}
		});
	}

	private drawDeletePopup() {
		const popupTitle = zh ? "删除项目" : "Delete project";
		if (this.deletePopupShow) {
			this.deletePopupShow = false;
			ImGui.OpenPopup(popupTitle);
		}
		ImGui.BeginPopupModal(popupTitle, () => {
			const resource = this.deleteResource;
			if (!resource) {
				ImGui.CloseCurrentPopup();
				return;
			}
			ImGui.TextWrapped(
				zh
					? `将删除 Download/${resource.id}，其中可能包含你的 Git 提交和本地修改。`
					: `This removes Download/${resource.id}, including any local Git commits and changes.`,
			);
			if (ImGui.Button(zh ? "取消" : "Cancel", Vec2(120, 30))) {
				this.deleteResource = undefined;
				ImGui.CloseCurrentPopup();
			}
			ImGui.SameLine();
			if (ImGui.Button(zh ? "确认删除" : "Delete", Vec2(120, 30))) {
				const removed = Content.remove(getResourceInstallPath(resource.id));
				this.deleteResource = undefined;
				if (removed) {
					Director.postNode.emit("UpdateEntries");
				} else {
					this.showMessage(
						zh ? "删除失败" : "Deletion failed",
						zh ? "无法删除项目目录，请检查文件是否正被占用。" : "Could not remove the project directory.",
					);
				}
				ImGui.CloseCurrentPopup();
			}
		});
	}

	private drawMessagePopup() {
		if (this.popupShow) {
			this.popupShow = false;
			ImGui.OpenPopup("ResourceMessage");
		}
		ImGui.BeginPopupModal("ResourceMessage", () => {
			ImGui.Text(this.popupTitle);
			ImGui.Separator();
			ImGui.PushTextWrapPos(380, () => ImGui.TextWrapped(this.popupMessage));
			if (ImGui.Button(zh ? "确认" : "OK", Vec2(380, 30))) ImGui.CloseCurrentPopup();
		});
	}

	private update() {
		const { width, height } = App.visualSize;
		const maxColumns = math.max(math.floor(width / 360), 1);
		const category = this.categoryIndex > 1 ? this.categories[this.categoryIndex - 2] : undefined;
		const filtered = filterResources(this.resources, {
			section: this.section,
			category,
			query: this.filterText,
		});
		const pageSize = 12;
		const page = paginateResources(filtered, this.page, pageSize);
		this.page = page.page;
		this.drawHeader(width, page);

		ImGui.SetNextWindowPos(Vec2(0, this.headerHeight), SetCond.Always, Vec2.zero);
		ImGui.SetNextWindowSize(Vec2(width, height - this.headerHeight), SetCond.Always);
		ImGui.PushStyleVar(ImGui.StyleVarVec.WindowPadding, Vec2(14, 10), () => {
			ImGui.Begin("Dora Resource Catalog", windowsFlags, () => {
				if (this.resetListScroll) {
					this.resetListScroll = false;
					ImGui.SetScrollY(0);
				}
				if (this.resources.length === 0) {
					ImGui.Dummy(Vec2(0, 30));
					ImGui.TextWrapped(
						this.catalogError !== ""
							? this.catalogError
							: (zh ? "正在准备资源目录…" : "Preparing the resource catalog…"),
					);
				} else {
					ImGui.Columns(maxColumns, false);
					for (const resource of page.items) {
						this.drawResourceCard(resource, ImGui.GetContentRegionAvail().x);
						ImGui.NextColumn();
					}
					ImGui.Columns(1, false);
					ImGui.Dummy(Vec2(0, 60));
				}
				this.drawDetailsPopup();
				this.drawDeletePopup();
				this.drawMessagePopup();
				ImGui.ScrollWhenDraggingOnVoid();
			});
		});
	}
}

new ResourceDownloader();
