// @preview-file off
import { Content, Director, json, Path } from "Dora";
import type { ResourceInfo, ResourceVersion } from "Tools/ResourceDownloader/Catalog";
import { quoteGitArgument, runGit, type GitOperationStatus } from "Tools/ResourceDownloader/Git";

export interface ResourceInstallProgress {
	progress: number;
	message: string;
	source?: string;
	transferredBytes?: number;
}

export interface ResourceInstallOptions {
	catalogCommit: string;
	onProgress?: (progress: ResourceInstallProgress) => void;
	isCanceled?: () => boolean;
}

export interface ResourceInstallResult {
	success: boolean;
	targetPath?: string;
	source?: string;
	message?: string;
	canceled?: boolean;
	forceable?: boolean;
}

const activeProjects = new Set<string>();
let operationSequence = 0;

const emitProgress = (
	options: ResourceInstallOptions,
	progress: number,
	message: string,
	source?: string,
	transferredBytes?: number,
) => {
	if (options.onProgress) options.onProgress({ progress, message, source, transferredBytes });
};

const installMetadata = (
	resource: ResourceInfo,
	version: ResourceVersion,
	installedCommit: string,
	catalogCommit: string,
	source: string,
	tempPath: string,
) => {
	const doraPath = Path(tempPath, ".dora");
	if (!Content.mkdir(doraPath) && !Content.isdir(doraPath)) {
		return "failed to create .dora directory";
	}
	const [stateJSON] = json.encode({
		schemaVersion: 1,
		resourceId: resource.id,
		version: version.name,
		commit: installedCommit,
		source,
		catalogCommit,
		installedAt: os.date("!%Y-%m-%dT%H:%M:%SZ"),
	});
	if (!stateJSON || !Content.save(Path(doraPath, "resource-state.json"), stateJSON)) {
		return "failed to save resource installation state";
	}
	const oldEntrypoints = resource.entrypoints.map(entry => Path.getPath(entry.path));
	const [repoJSON] = json.encode({
		name: resource.id,
		title: {
			zh: resource.title["zh-Hans"],
			en: resource.title.en,
		},
		desc: {
			zh: resource.description["zh-Hans"],
			en: resource.description.en,
		},
		categories: resource.categories,
		exe: resource.runnable
			? (oldEntrypoints.length > 0 ? oldEntrypoints : true)
			: false,
		noBanner: resource.bannerPath === undefined,
	});
	if (!repoJSON || !Content.save(Path(doraPath, "repo.json"), repoJSON)) {
		return "failed to save compatibility metadata";
	}
	const previewSource = resource.bannerPath ?? Path(Content.assetPath, "Image", "banner.jpg");
	if (Content.exist(previewSource)
		&& !Content.copy(previewSource, Path(doraPath, "banner.jpg"))) {
		return "failed to copy resource preview";
	}
	return undefined;
};

export const getResourceInstallPath = (resourceId: string) =>
	Path(Content.writablePath, "Download", resourceId);

export const isResourceInstalled = (resourceId: string) =>
	Content.isdir(getResourceInstallPath(resourceId));

// Both Git and legacy archive installations must carry matching Catalog identity.
// Entries can be nested below the repository root.
export const getInstalledCatalogResource = (workDir: string, resources: ResourceInfo[]) => {
	const prefix = Path(Content.writablePath, "Download").split("\\").join("/") + "/";
	const normalized = workDir.split("\\").join("/");
	if (!normalized.startsWith(prefix)) return undefined;
	const resourceId = normalized.slice(prefix.length).split("/")[0];
	const resource = resources.find(item => item.id === resourceId);
	if (!resource) return undefined;
	const installPath = getResourceInstallPath(resourceId);
	if (!Content.isdir(installPath)) return undefined;
	const stateFile = Path(installPath, ".dora", "resource-state.json");
	const hasState = Content.exist(stateFile);
	// Older archive downloads stored the Catalog id as repo.name. A present but
	// invalid Git state must never fall back to legacy identity.
	const file = hasState ? stateFile : Path(installPath, ".dora", "repo.json");
	if (!Content.exist(file)) return undefined;
	const [state, err] = json.decode(Content.load(file));
	if (err === undefined && typeof state === "object" && state !== undefined
		&& (hasState ? (state as { resourceId?: string }).resourceId : (state as { name?: string }).name) === resourceId) return resource;
	return undefined;
};

const installResourceInternal = async (
	resource: ResourceInfo,
	version: ResourceVersion,
	options: ResourceInstallOptions,
	replaceExisting = false,
): Promise<ResourceInstallResult> => {
	const downloadPath = Path(Content.writablePath, "Download");
	if (!Content.mkdir(downloadPath) && !Content.isdir(downloadPath)) {
		return { success: false, message: "failed to create Download directory" };
	}
	const targetPath = getResourceInstallPath(resource.id);
	if (Content.exist(targetPath) && !replaceExisting) {
		return {
			success: false,
			message: "target directory already exists; use Git tools to maintain the installed project",
		};
	}
	if (resource.status !== "active" && resource.status !== "deprecated") {
		return { success: false, message: `resource status ${resource.status} cannot be installed` };
	}
	const stagingRoot = Path(Content.writablePath, ".download");
	if (!Content.mkdir(stagingRoot) && !Content.isdir(stagingRoot)) {
		return { success: false, message: "failed to create download staging directory" };
	}
	let lastMessage = "no resource source is available";
	for (let sourceIndex = 0; sourceIndex < version.sources.length; sourceIndex++) {
		if (options.isCanceled && options.isCanceled()) {
			return { success: false, message: "installation canceled", canceled: true };
		}
		const source = version.sources[sourceIndex];
		const operationId = `${os.time()}-${++operationSequence}-${sourceIndex + 1}`;
		const tempName = `.resource-${resource.id}-${operationId}`;
		const tempPath = Path(stagingRoot, tempName);
		if (Content.exist(tempPath)) Content.remove(tempPath);
		emitProgress(
			options,
			0.02,
			sourceIndex === 0 ? "Connecting to resource repository" : "Trying the next resource source",
			source.url,
		);
		let command = `clone ${quoteGitArgument(source.url)} ${quoteGitArgument(tempName)} --depth 1`;
		if (version.tag) {
			command += ` --branch ${quoteGitArgument(`refs/tags/${version.tag}`)}`;
		}
		const cloneResult = await runGit(stagingRoot, command, {
			timeout: 1800,
			isCanceled: options.isCanceled,
			onStatus: (status: GitOperationStatus) => {
				emitProgress(
					options,
					math.max(0.03, math.min(0.82, status.progress * 0.82)),
					status.message ?? "Receiving Git objects",
					source.url,
					status.transferredBytes,
				);
			},
		});
		if (!cloneResult.success) {
			Content.remove(tempPath);
			lastMessage = cloneResult.message ?? "Git clone failed";
			if (cloneResult.canceled) {
				return { success: false, message: lastMessage, canceled: true };
			}
			continue;
		}
		emitProgress(options, 0.86, "Checking resource structure", source.url);
		const verifyResult = await runGit(
			tempPath,
			"verify-resource",
			{ timeout: 60, isCanceled: options.isCanceled },
		);
		if (!verifyResult.success) {
			Content.remove(tempPath);
			lastMessage = verifyResult.message ?? "resource repository safety verification failed";
			continue;
		}
		const installedCommit = verifyResult.status?.data?.commit;
		if (typeof installedCommit !== "string") {
			Content.remove(tempPath);
			lastMessage = "resource repository safety verification did not return HEAD";
			continue;
		}
		emitProgress(options, 0.92, "Writing Dora resource metadata", source.url);
		const metadataError = installMetadata(
			resource,
			version,
			installedCommit,
			options.catalogCommit,
			source.url,
			tempPath,
		);
		if (metadataError) {
			Content.remove(tempPath);
			lastMessage = metadataError;
			continue;
		}
		if (options.isCanceled?.()) {
			Content.remove(tempPath);
			return { success: false, message: "synchronization canceled", canceled: true };
		}
		if (Content.exist(targetPath) && !replaceExisting) {
			Content.remove(tempPath);
			return {
				success: false,
				message: "target directory was created while the resource was installing",
			};
		}
		emitProgress(options, 0.97, "Installing project", source.url);
		// Keep the original until the replacement is verified and ready. No await
		// occurs between the two moves; a failed replacement restores the original.
		const backupPath = Path(stagingRoot, `${tempName}-previous`);
		const hadOriginal = Content.exist(targetPath);
		if (hadOriginal && !Content.move(targetPath, backupPath)) {
			Content.remove(tempPath);
			return { success: false, message: "failed to preserve the previous project" };
		}
		if (!Content.move(tempPath, targetPath)) {
			Content.remove(tempPath);
			// Content.move may fall back to copying and leave a partial target.
			// Remove that replacement before restoring the intact original.
			const cleared = !Content.exist(targetPath) || Content.remove(targetPath);
			const restored = cleared && (!hadOriginal || Content.move(backupPath, targetPath));
			return { success: false, message: restored
				? "failed to replace the project; previous project restored"
				: `failed to replace the project; previous project remains at ${backupPath}` };
		}
		const cleanupMessage = hadOriginal && !Content.remove(backupPath)
			? `synchronized; previous project could not be removed from ${backupPath}` : undefined;
		Content.clearPathCache();
		Director.postNode.emit("UpdateEntries");
		emitProgress(options, 1, "Installed", source.url);
		return { success: true, targetPath, source: source.url, message: cleanupMessage };
	}
	return { success: false, message: lastMessage };
};

const withProjectOperation = async (resource: ResourceInfo, operation: () => Promise<ResourceInstallResult>) => {
	const path = getResourceInstallPath(resource.id);
	if (activeProjects.has(path)) return { success: false, message: "project operation already in progress" };
	activeProjects.add(path);
	try {
		return await operation();
	} finally {
		activeProjects.delete(path);
	}
};

export const installResource = (resource: ResourceInfo, version: ResourceVersion, options: ResourceInstallOptions) =>
	withProjectOperation(resource, () => installResourceInternal(resource, version, options));

export const syncResource = (resource: ResourceInfo, version: ResourceVersion, options: ResourceInstallOptions, force = false) =>
	withProjectOperation(resource, async (): Promise<ResourceInstallResult> => {
		const targetPath = getResourceInstallPath(resource.id);
		if (!getInstalledCatalogResource(targetPath, [resource])) {
			return { success: false, message: "project has no matching Catalog installation state" };
		}
		if (resource.status !== "active" && resource.status !== "deprecated") {
			return { success: false, message: `resource status ${resource.status} cannot be synchronized` };
		}
		if (force) return installResourceInternal(resource, version, options, true);
		const remotes = await runGit(targetPath, "remote -v", { isCanceled: options.isCanceled });
		if (!remotes.success) return { ...remotes, forceable: !remotes.canceled };
		const origin = (remotes.status?.data?.remotes as { name: string; urls: string[] }[] | undefined)
			?.find(remote => remote.name === "origin");
		let lastMessage = "no resource source is available";
		for (const source of version.sources) {
			if (options.isCanceled?.()) return { success: false, message: "synchronization canceled", canceled: true };
			emitProgress(options, 0.05, "Pulling from Catalog repository", source.url);
			const configured = await runGit(targetPath,
				`remote ${origin ? "set-url" : "add"} origin ${quoteGitArgument(source.url)}`);
			if (!configured.success) return { success: false, message: configured.message, forceable: true };
			const pulled = await runGit(targetPath, "pull origin", {
					timeout: 1800, isCanceled: options.isCanceled,
					onStatus: status => emitProgress(options, math.max(0.05, status.progress * 0.85),
						status.message ?? "Pulling project", source.url, status.transferredBytes),
				});
			if (!pulled.success) {
				await runGit(targetPath, origin
					? `remote set-url origin ${quoteGitArgument(origin.urls[0])}` : "remote remove origin");
				lastMessage = pulled.message ?? "Git pull failed";
				if (pulled.canceled) return { success: false, message: lastMessage, canceled: true };
				continue;
			}
			const verified = await runGit(targetPath, "verify-resource");
			const commit = verified.status?.data?.commit;
			if (!verified.success || typeof commit !== "string") return {
				success: false, message: verified.message ?? "resource verification failed", forceable: true,
			};
			const metadataError = installMetadata(resource, version, commit, options.catalogCommit, source.url, targetPath);
			if (metadataError) return { success: false, message: metadataError, forceable: true };
			Content.clearPathCache();
			Director.postNode.emit("UpdateEntries");
			emitProgress(options, 1, "Synchronized", source.url);
			return { success: true, targetPath, source: source.url };
		}
		return { success: false, message: lastMessage, forceable: true };
	});
