import { Content, Path } from "Dora";
import type { ResourceInfo } from "Tools/ResourceDownloader/Catalog";
import { getResourceInstallPath, installResource, isResourceInstalled } from "Tools/ResourceDownloader/GitInstaller";

export interface MobileReadyEntry {
	fileName: string;
	workDir: string;
	installed: true;
}

export interface MobileLaunchEntry {
	fileName: string;
	workDir: string;
}

export interface MobilePrepareResult {
	success: boolean;
	entry?: MobileReadyEntry;
	message?: string;
	repairable?: boolean;
}

const installedEntry = (resource: ResourceInfo): MobileReadyEntry => {
	const workDir = getResourceInstallPath(resource.id);
	return {
		fileName: Path(workDir, Path.replaceExt(resource.entrypoints[0].path, "")),
		workDir,
		installed: true,
	};
};

// Remix needs the repository root, while games resolve relative assets from the
// directory containing their selected entrypoint.
export const resolveMobileLaunchEntry = (entry: MobileLaunchEntry): MobileLaunchEntry => ({
	fileName: entry.fileName,
	workDir: Path.getPath(entry.fileName),
});

export const isMobileResourceReady = (resource: ResourceInfo) => {
	const entrypoint = resource.entrypoints[0];
	if (!entrypoint || !isResourceInstalled(resource.id)) return false;
	const entryPath = Path(getResourceInstallPath(resource.id), entrypoint.path);
	if (Content.exist(entryPath)) return true;
	if (Path.getExt(entrypoint.path) !== "") return false;
	for (const extension of ["lua", "xml", "yue", "tl", "wasm"]) {
		if (Content.exist(`${entryPath}.${extension}`)) return true;
	}
	return false;
};

const reserveRecoveryPath = (resourceId: string) => {
	const downloadPath = Path(Content.writablePath, "Download");
	const stem = `${resourceId}.recovery-${os.time()}`;
	let recoveryPath = Path(downloadPath, stem);
	let suffix = 1;
	while (Content.exist(recoveryPath)) {
		recoveryPath = Path(downloadPath, `${stem}-${suffix}`);
		suffix++;
	}
	return recoveryPath;
};

export const prepareMobileResource = (
	resource: ResourceInfo,
	catalogCommit: string,
	onProgress: (progress: number, message: string) => void,
	onDone: (result: MobilePrepareResult) => void,
	repairIncomplete = false,
) => {
	if (isMobileResourceReady(resource)) {
		onDone({ success: true, entry: installedEntry(resource) });
		return;
	}
	const index = math.max(1, math.min(resource.selectedVersion, resource.versions.length));
	const version = resource.versions[index - 1];
	if (!version) {
		onDone({ success: false, message: "resource version is unavailable" });
		return;
	}
	let recoveryPath: string | undefined;
	const installPath = getResourceInstallPath(resource.id);
	if (isResourceInstalled(resource.id)) {
		if (!repairIncomplete) {
			onDone({
				success: false,
				message: "installed resource is incomplete; tap again to repair it",
				repairable: true,
			});
			return;
		}
		recoveryPath = reserveRecoveryPath(resource.id);
		if (!Content.move(installPath, recoveryPath)) {
			onDone({ success: false, message: "failed to preserve the incomplete installation" });
			return;
		}
	}
	(async () => {
		const result = await installResource(resource, version, {
			catalogCommit,
			onProgress: item => onProgress(item.progress, item.message),
		});
		if (!result.success) {
			let message = result.message ?? "installation failed";
			if (recoveryPath && !Content.exist(installPath)) {
				if (Content.move(recoveryPath, installPath)) message += "; previous installation restored";
				else message += `; previous installation remains at ${recoveryPath}`;
			}
			onDone({ success: false, message, repairable: isResourceInstalled(resource.id) });
			return;
		}
		onDone({ success: true, entry: installedEntry(resource) });
	})();
};
