// @preview-file off
import { Content, Director, json, Path } from "Dora";
import type { ResourceInfo, ResourceVersion } from "Script/Tools/ResourceDownloader/Catalog";
import { quoteGitArgument, runGit, type GitOperationStatus } from "Script/Tools/ResourceDownloader/Git";

export interface ResourceInstallProgress {
	progress: number;
	message: string;
	source?: string;
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
}

const emitProgress = (
	options: ResourceInstallOptions,
	progress: number,
	message: string,
	source?: string,
) => {
	if (options.onProgress) options.onProgress({ progress, message, source });
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

export const installResource = async (
	resource: ResourceInfo,
	version: ResourceVersion,
	options: ResourceInstallOptions,
): Promise<ResourceInstallResult> => {
	const targetPath = getResourceInstallPath(resource.id);
	if (Content.exist(targetPath)) {
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
		const operationId = `${os.time()}-${sourceIndex + 1}`;
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
		if (Content.exist(targetPath)) {
			Content.remove(tempPath);
			return {
				success: false,
				message: "target directory was created while the resource was installing",
			};
		}
		emitProgress(options, 0.97, "Installing project", source.url);
		if (!Content.move(tempPath, targetPath)) {
			Content.remove(tempPath);
			lastMessage = "failed to move the project into Download";
			continue;
		}
		Director.postNode.emit("UpdateEntries");
		emitProgress(options, 1, "Installed", source.url);
		return { success: true, targetPath, source: source.url };
	}
	return { success: false, message: lastMessage };
};
