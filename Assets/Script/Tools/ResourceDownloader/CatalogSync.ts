// @preview-file off
import { App, Content, json, Path } from "Dora";
import { loadCatalog, type CatalogLoadResult } from "Script/Tools/ResourceDownloader/Catalog";
import { gitHeadFromStatus, quoteGitArgument, runGit, type GitOperationStatus } from "Script/Tools/ResourceDownloader/Git";

const GITHUB_CATALOG_REMOTE = "https://github.com/ippclub/Dora-Catalog.git";
const ATOMGIT_CATALOG_REMOTE = "https://gitcode.com/ippclub/Dora-Catalog.git";

export const catalogRemotesForLocale = (locale: string) => {
	const [isChinese] = string.match(locale, "^zh");
	return isChinese !== undefined
		? [ATOMGIT_CATALOG_REMOTE, GITHUB_CATALOG_REMOTE]
		: [GITHUB_CATALOG_REMOTE, ATOMGIT_CATALOG_REMOTE];
};

export const CATALOG_REMOTES = catalogRemotesForLocale(App.locale);

interface CatalogState {
	schemaVersion: 1;
	commit: string;
	source: string;
	syncedAt: string;
	checkedAt: number;
	preferredSource?: string;
}

export interface CatalogSnapshot {
	catalog: CatalogLoadResult;
	commit: string;
	source: string;
	syncedAt: string;
}

export interface CatalogSyncStatus {
	progress: number;
	message: string;
	source?: string;
}

export interface CatalogSyncResult {
	success: boolean;
	snapshot?: CatalogSnapshot;
	message?: string;
	usedCache?: boolean;
}

export interface CatalogSyncOptions {
	force?: boolean;
	remotes?: string[];
	onStatus?: (status: CatalogSyncStatus) => void;
	isCanceled?: () => boolean;
}

const CACHE_TTL_SECONDS = 6 * 60 * 60;

const cacheRoot = () => Path(Content.appPath, ".cache", "resource-catalog");
const repoPath = () => Path(cacheRoot(), "repo");
const statePath = () => Path(cacheRoot(), "state.json");

const readState = (): CatalogState | undefined => {
	const file = statePath();
	if (!Content.exist(file)) return undefined;
	const [decoded, err] = json.decode(Content.load(file));
	if (err !== undefined || typeof decoded !== "object" || decoded === undefined) return undefined;
	const state = decoded as Partial<CatalogState>;
	if (state.schemaVersion !== 1
		|| typeof state.commit !== "string"
		|| typeof state.source !== "string"
		|| typeof state.syncedAt !== "string"
		|| typeof state.checkedAt !== "number") {
		return undefined;
	}
	return state as CatalogState;
};

const writeState = (state: CatalogState) => {
	const [text] = json.encode(state);
	return text !== undefined && Content.save(statePath(), text);
};

const emitStatus = (
	options: CatalogSyncOptions,
	progress: number,
	message: string,
	source?: string,
) => {
	if (options.onStatus) options.onStatus({ progress, message, source });
};

const snapshotFrom = (
	path: string,
	state: CatalogState,
): CatalogSyncResult => {
	const catalog = loadCatalog(path);
	if (catalog.resources.length === 0) {
		return { success: false, message: "catalog contains no usable resources" };
	}
	if (catalog.issues.length > 0) {
		const first = catalog.issues[0];
		return {
			success: false,
			message: `catalog validation failed at ${first.project !== "" ? first.project : "root"}: ${first.message}`,
		};
	}
	return {
		success: true,
		snapshot: {
			catalog,
			commit: state.commit,
			source: state.source,
			syncedAt: state.syncedAt,
		},
	};
};

export const loadCachedCatalog = (): CatalogSyncResult => {
	const state = readState();
	const path = repoPath();
	if (!state || !Content.isdir(path)) {
		return { success: false, message: "no catalog cache is available" };
	}
	const result = snapshotFrom(path, state);
	if (result.success) result.usedCache = true;
	return result;
};

export const syncCatalog = async (options: CatalogSyncOptions = {}): Promise<CatalogSyncResult> => {
	const remotes = options.remotes !== undefined && options.remotes.length > 0
		? options.remotes
		: CATALOG_REMOTES;
	const existingState = readState();
	const cached = loadCachedCatalog();
	if (!options.force
		&& cached.success
		&& existingState
		&& (existingState.preferredSource ?? existingState.source) === remotes[0]
		&& os.time() - existingState.checkedAt < CACHE_TTL_SECONDS) {
		return cached;
	}
	const root = cacheRoot();
	if (!Content.mkdir(root) && !Content.isdir(root)) {
		return cached.success ? cached : { success: false, message: "failed to create catalog cache directory" };
	}
	let lastMessage = "catalog sources are unavailable";
	const candidateName = "candidate";
	const candidatePath = Path(root, candidateName);
	for (const source of remotes) {
		if (options.isCanceled && options.isCanceled()) {
			return { success: false, message: "catalog synchronization canceled" };
		}
		if (Content.exist(candidatePath)) Content.remove(candidatePath);
		emitStatus(options, 0.02, "Connecting to catalog", source);
		const cloneResult = await runGit(
			root,
			`clone ${quoteGitArgument(source)} ${quoteGitArgument(candidateName)}`,
			{
				timeout: 300,
				isCanceled: options.isCanceled,
				onStatus: (status: GitOperationStatus) => {
					emitStatus(
						options,
						math.max(0.03, math.min(0.78, status.progress * 0.78)),
						status.message ?? "Receiving catalog",
						source,
					);
				},
			},
		);
		if (!cloneResult.success) {
			Content.remove(candidatePath);
			lastMessage = cloneResult.message ?? "failed to clone catalog";
			continue;
		}
		const commit = gitHeadFromStatus(cloneResult.status);
		if (!commit) {
			Content.remove(candidatePath);
			lastMessage = "catalog clone did not return a commit hash";
			continue;
		}
		emitStatus(options, 0.82, "Validating catalog entries", source);
		const candidateState: CatalogState = {
			schemaVersion: 1,
			commit,
			source,
			syncedAt: os.date("!%Y-%m-%dT%H:%M:%SZ"),
			checkedAt: os.time(),
			preferredSource: remotes[0],
		};
		const candidateSnapshot = snapshotFrom(candidatePath, candidateState);
		if (!candidateSnapshot.success) {
			Content.remove(candidatePath);
			lastMessage = candidateSnapshot.message ?? "catalog validation failed";
			continue;
		}
		const currentPath = repoPath();
		const backupPath = Path(root, "repo-backup");
		if (Content.exist(backupPath)) Content.remove(backupPath);
		if (Content.exist(currentPath) && !Content.move(currentPath, backupPath)) {
			Content.remove(candidatePath);
			lastMessage = "failed to prepare catalog cache replacement";
			continue;
		}
		if (!Content.move(candidatePath, currentPath)) {
			if (Content.exist(backupPath)) Content.move(backupPath, currentPath);
			Content.remove(candidatePath);
			lastMessage = "failed to activate the downloaded catalog";
			continue;
		}
		if (!writeState(candidateState)) {
			Content.remove(currentPath);
			if (Content.exist(backupPath)) Content.move(backupPath, currentPath);
			lastMessage = "failed to save catalog state";
			continue;
		}
		if (Content.exist(backupPath)) Content.remove(backupPath);
		emitStatus(options, 1, "Catalog is ready", source);
		return snapshotFrom(currentPath, candidateState);
	}
	if (cached.success) {
		cached.message = lastMessage;
		cached.usedCache = true;
		return cached;
	}
	return { success: false, message: lastMessage };
};
