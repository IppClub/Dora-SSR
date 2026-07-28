// @preview-file off
import { Content, HttpClient, json, Path, thread } from "Dora";
import { gitHeadFromStatus, quoteGitArgument, runGit, type GitOperationStatus } from "Script/Tools/ResourceDownloader/Git";
import {
	loadUpdateManifest,
	type UpdateManifest,
	type UpdatePackage,
	type UpdatePlatform,
} from "Script/Tools/SelfUpdater/Manifest";

const ATOMGIT_RELEASES_REMOTE = "https://gitcode.com/ippclub/Dora-Releases.git";

export type UpdateSource = "AtomGit" | "GitHub";

interface UpdateState {
	schemaVersion: 1;
	commit: string;
	source: string;
	signer: string;
	verifiedAt: string;
	checkedAt: number;
}

export interface AtomGitUpdateSnapshot {
	source: "AtomGit";
	manifest: UpdateManifest;
	commit: string;
	remote: string;
	signer: string;
	verifiedAt: string;
}

export interface GitHubUpdatePackage {
	file: string;
	size: number;
	sha256: string;
	github: string;
}

export interface GitHubUpdateSnapshot {
	source: "GitHub";
	version: string;
	publishedAt: string;
	packages: Record<UpdatePlatform, GitHubUpdatePackage>;
}

export type UpdateSnapshot = AtomGitUpdateSnapshot | GitHubUpdateSnapshot;

export interface UpdateProgress {
	progress: number;
	message: string;
	source?: UpdateSource;
}

export interface UpdateSyncResult {
	success: boolean;
	snapshot?: UpdateSnapshot;
	message?: string;
	usedCache?: boolean;
}

export interface UpdateOperationOptions {
	onProgress?: (status: UpdateProgress) => void;
	isCanceled?: () => boolean;
}

export interface PreparedUpdate {
	source: UpdateSource;
	file: string;
	cleanupPath: string;
}

const cacheRoot = () => Path(Content.appPath, ".cache", "self-updater");
const repoPath = () => Path(cacheRoot(), "repo");
const statePath = () => Path(cacheRoot(), "state.json");

const emit = (
	options: UpdateOperationOptions,
	progress: number,
	message: string,
	source?: UpdateSource,
) => {
	if (options.onProgress) options.onProgress({ progress, message, source });
};

const localeIsChinese = (locale: string) => string.match(locale, "^zh")[0] !== undefined;

export const updateSourcesForLocale = (locale: string): UpdateSource[] => localeIsChinese(locale)
	? ["AtomGit", "GitHub"]
	: ["GitHub", "AtomGit"];

const readState = (): UpdateState | undefined => {
	if (!Content.exist(statePath())) return undefined;
	const [decoded, err] = json.decode(Content.load(statePath()));
	if (err !== undefined || typeof decoded !== "object" || decoded === undefined) return undefined;
	const state = decoded as Partial<UpdateState>;
	if (state.schemaVersion !== 1
		|| typeof state.commit !== "string"
		|| typeof state.source !== "string"
		|| typeof state.signer !== "string"
		|| typeof state.verifiedAt !== "string"
		|| typeof state.checkedAt !== "number") {
		return undefined;
	}
	return state as UpdateState;
};

const writeState = (state: UpdateState) => {
	const [text] = json.encode(state);
	return text !== undefined && Content.save(statePath(), text);
};

const snapshotFrom = (path: string, state: UpdateState): UpdateSyncResult => {
	const result = loadUpdateManifest(path);
	if (!result.manifest) return { success: false, message: result.message ?? "invalid update manifest" };
	return {
		success: true,
		snapshot: {
			source: "AtomGit",
			manifest: result.manifest,
			commit: state.commit,
			remote: state.source,
			signer: state.signer,
			verifiedAt: state.verifiedAt,
		},
	};
};

export const loadCachedUpdateManifest = (): UpdateSyncResult => {
	const state = readState();
	if (!state || !Content.isdir(repoPath())) {
		return { success: false, message: "no verified update metadata cache is available" };
	}
	const result = snapshotFrom(repoPath(), state);
	if (result.success) result.usedCache = true;
	return result;
};

export const syncUpdateManifest = async (
	options: UpdateOperationOptions = {},
): Promise<UpdateSyncResult> => {
	const existingState = readState();
	const cached = loadCachedUpdateManifest();
	const root = cacheRoot();
	if (!Content.mkdir(root) && !Content.isdir(root)) {
		return cached.success ? cached : { success: false, message: "failed to create update metadata cache" };
	}
	const candidateName = "candidate";
	const candidatePath = Path(root, candidateName);
	let lastMessage = "AtomGit update metadata is unavailable";
	for (const remote of [{ source: "AtomGit" as UpdateSource, url: ATOMGIT_RELEASES_REMOTE }]) {
		if (options.isCanceled && options.isCanceled()) {
			return { success: false, message: "update check canceled" };
		}
		if (Content.exist(candidatePath)) Content.remove(candidatePath);
		emit(options, 0.02, "Connecting to update metadata", remote.source);
		const clone = await runGit(
			root,
			`clone ${quoteGitArgument(remote.url)} ${quoteGitArgument(candidateName)} --branch main`,
			{
				timeout: 180,
				isCanceled: options.isCanceled,
				onStatus: (status: GitOperationStatus) => emit(
					options,
					math.max(0.03, math.min(0.65, status.progress * 0.65)),
					status.message ?? "Receiving update metadata",
					remote.source,
				),
			},
		);
		if (!clone.success) {
			Content.remove(candidatePath);
			lastMessage = clone.message ?? "failed to clone update metadata";
			continue;
		}
		const commit = gitHeadFromStatus(clone.status);
		if (!commit) {
			Content.remove(candidatePath);
			lastMessage = "update metadata clone did not return a commit";
			continue;
		}
		emit(options, 0.7, "Verifying update signature and history", remote.source);
		let command = `verify-update ${quoteGitArgument(commit)}`;
		if (existingState) command += ` ${quoteGitArgument(existingState.commit)}`;
		const verified = await runGit(candidatePath, command, {
			timeout: 60,
			isCanceled: options.isCanceled,
		});
		if (!verified.success) {
			Content.remove(candidatePath);
			lastMessage = verified.message ?? "update metadata signature verification failed";
			continue;
		}
		const signer = verified.status?.data?.signer;
		if (typeof signer !== "string" || signer === "") {
			Content.remove(candidatePath);
			lastMessage = "update metadata verification did not return a signer";
			continue;
		}
		emit(options, 0.8, "Validating update manifest", remote.source);
		const state: UpdateState = {
			schemaVersion: 1,
			commit,
			source: remote.url,
			signer,
			verifiedAt: os.date("!%Y-%m-%dT%H:%M:%SZ"),
			checkedAt: os.time(),
		};
		const candidate = snapshotFrom(candidatePath, state);
		if (!candidate.success) {
			Content.remove(candidatePath);
			lastMessage = candidate.message ?? "update manifest validation failed";
			continue;
		}
		const backupPath = Path(root, "repo-backup");
		if (Content.exist(backupPath)) Content.remove(backupPath);
		if (Content.exist(repoPath()) && !Content.move(repoPath(), backupPath)) {
			Content.remove(candidatePath);
			lastMessage = "failed to prepare update metadata replacement";
			continue;
		}
		if (!Content.move(candidatePath, repoPath())) {
			if (Content.exist(backupPath)) Content.move(backupPath, repoPath());
			lastMessage = "failed to activate verified update metadata";
			continue;
		}
		if (!writeState(state)) {
			Content.remove(repoPath());
			if (Content.exist(backupPath)) Content.move(backupPath, repoPath());
			lastMessage = "failed to save update metadata state";
			continue;
		}
		if (Content.exist(backupPath)) Content.remove(backupPath);
		emit(options, 1, "Update metadata is ready", remote.source);
		return snapshotFrom(repoPath(), state);
	}
	if (cached.success) {
		cached.usedCache = true;
		cached.message = lastMessage;
		return cached;
	}
	return { success: false, message: lastMessage };
};

interface GitHubReleaseAsset {
	name: string;
	size: number;
	digest: string;
	browser_download_url: string;
}

interface GitHubReleaseInfo {
	tag_name: string;
	published_at: string;
	assets: GitHubReleaseAsset[];
}

export const checkGitHubRelease = (
	options: UpdateOperationOptions = {},
): Promise<UpdateSyncResult> => new Promise(resolve => {
	thread(() => {
		if (options.isCanceled && options.isCanceled()) {
			resolve({ success: false, message: "update check canceled" });
			return;
		}
		emit(options, 0.05, "Checking GitHub Releases", "GitHub");
		const response = HttpClient.getAsync("https://api.github.com/repos/IppClub/Dora-SSR/releases/latest");
		if (!response) {
			resolve({ success: false, message: "GitHub Release API is unavailable" });
			return;
		}
		const [decoded, err] = json.decode(response);
		if (err !== undefined || typeof decoded !== "object" || decoded === undefined) {
			resolve({ success: false, message: "GitHub returned invalid release metadata" });
			return;
		}
		const release = decoded as Partial<GitHubReleaseInfo>;
		if (typeof release.tag_name !== "string"
			|| string.match(release.tag_name, "^v%d+%.%d+%.%d+$")[0] === undefined
			|| typeof release.published_at !== "string"
			|| !Array.isArray(release.assets)) {
			resolve({ success: false, message: "GitHub latest release metadata is incomplete" });
			return;
		}
		const packages = {} as Record<UpdatePlatform, GitHubUpdatePackage>;
		for (const platform of ["android", "windows-x86", "macos-universal"] as UpdatePlatform[]) {
			const file = `dora-ssr-${release.tag_name}-${platform}.zip`;
			let matched: GitHubReleaseAsset | undefined;
			for (const value of release.assets) {
				if (value.name === file) {
					matched = value;
					break;
				}
			}
			const github = `https://github.com/IppClub/Dora-SSR/releases/download/${release.tag_name}/${file}`;
			if (!matched
				|| typeof matched.size !== "number"
				|| matched.size < 1
				|| typeof matched.digest !== "string"
				|| matched.digest.length !== 71
				|| string.find(matched.digest, "sha256:", 1, true)[0] !== 1
				|| string.match(string.sub(matched.digest, 8), "^[0-9a-f]+$")[0] === undefined
				|| matched.browser_download_url !== github) {
				resolve({ success: false, message: `GitHub asset metadata is invalid: ${file}` });
				return;
			}
			packages[platform] = {
				file,
				size: matched.size,
				sha256: string.sub(matched.digest, 8),
				github,
			};
		}
		emit(options, 1, "GitHub release metadata is ready", "GitHub");
		resolve({
			success: true,
			snapshot: {
				source: "GitHub",
				version: release.tag_name,
				publishedAt: release.published_at,
				packages,
			},
		});
	});
});

const verifyPackage = async (
	root: string,
	item: GitHubUpdatePackage,
	options: UpdateOperationOptions,
) => runGit(
	root,
	`verify-update-package ${quoteGitArgument(item.file)} ${quoteGitArgument(item.sha256)} ${item.size}`,
	{ timeout: 300, isCanceled: options.isCanceled },
);

const prepareFromAtomGit = async (
	item: UpdatePackage,
	options: UpdateOperationOptions,
): Promise<PreparedUpdate | undefined> => {
	const root = Path(Content.writablePath, ".download");
	const candidateName = `dora-update-${os.time()}-atomgit`;
	const candidatePath = Path(root, candidateName);
	if (Content.exist(candidatePath)) Content.remove(candidatePath);
	emit(options, 0.02, "Connecting to AtomGit LFS", "AtomGit");
	const clone = await runGit(
		root,
		`clone ${quoteGitArgument(ATOMGIT_RELEASES_REMOTE)} ${quoteGitArgument(candidateName)} --branch ${quoteGitArgument(item.ref)} --depth 1`,
		{
			timeout: 1800,
			isCanceled: options.isCanceled,
			onStatus: (status: GitOperationStatus) => emit(
				options,
				math.max(0.03, math.min(0.85, status.progress * 0.85)),
				status.message ?? "Downloading update from AtomGit LFS",
				"AtomGit",
			),
		},
	);
	if (!clone.success) {
		Content.remove(candidatePath);
		return undefined;
	}
	const commit = gitHeadFromStatus(clone.status);
	if (commit !== item.commit) {
		Content.remove(candidatePath);
		return undefined;
	}
	const signature = await runGit(candidatePath, `verify-update ${quoteGitArgument(commit)}`, {
		timeout: 60,
		isCanceled: options.isCanceled,
	});
	if (!signature.success) {
		Content.remove(candidatePath);
		return undefined;
	}
	emit(options, 0.9, "Verifying update package", "AtomGit");
	const packageResult = await verifyPackage(candidatePath, item, options);
	if (!packageResult.success) {
		Content.remove(candidatePath);
		return undefined;
	}
	return {
		source: "AtomGit",
		file: Path(candidatePath, item.file),
		cleanupPath: candidatePath,
	};
};

const downloadFromGitHub = (
	item: GitHubUpdatePackage,
	options: UpdateOperationOptions,
): Promise<[string, string] | undefined> => new Promise(resolve => {
	thread(() => {
		const root = Path(Content.writablePath, ".download");
		const candidatePath = Path(root, `dora-update-${os.time()}-github`);
		if (Content.exist(candidatePath)) Content.remove(candidatePath);
		if (!Content.mkdir(candidatePath) && !Content.isdir(candidatePath)) {
			resolve(undefined);
			return;
		}
		const target = Path(candidatePath, item.file);
		emit(options, 0.02, "Connecting to GitHub Releases", "GitHub");
		const success = HttpClient.downloadAsync(
			item.github,
			target,
			300,
			(current, total) => {
				emit(
					options,
					total > 0 ? math.max(0.03, math.min(0.85, current / total * 0.85)) : 0.03,
					"Downloading update from GitHub Releases",
					"GitHub",
				);
				return options.isCanceled ? options.isCanceled() : false;
			},
		);
		if (!success) {
			Content.remove(candidatePath);
			resolve(undefined);
			return;
		}
		resolve([candidatePath, target]);
	});
});

const prepareFromGitHub = async (
	item: GitHubUpdatePackage,
	options: UpdateOperationOptions,
): Promise<PreparedUpdate | undefined> => {
	const download = await downloadFromGitHub(item, options);
	if (!download) return undefined;
	const [candidatePath, target] = download;
	emit(options, 0.9, "Verifying update package", "GitHub");
	const verified = await verifyPackage(candidatePath, item, options);
	if (!verified.success) {
		Content.remove(candidatePath);
		return undefined;
	}
	return { source: "GitHub", file: target, cleanupPath: candidatePath };
};

export const prepareUpdatePackage = async (
	snapshot: UpdateSnapshot,
	platform: UpdatePlatform,
	options: UpdateOperationOptions = {},
): Promise<PreparedUpdate | undefined> => {
	Content.mkdir(Path(Content.writablePath, ".download"));
	if (options.isCanceled && options.isCanceled()) return undefined;
	if (snapshot.source === "AtomGit") {
		const item = snapshot.manifest.packages[platform];
		return prepareFromAtomGit(item, options);
	}
	const item = snapshot.packages[platform];
	return prepareFromGitHub(item, options);
};
