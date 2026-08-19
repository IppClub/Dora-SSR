// @preview-file off clear
import { Content, Path, Director, once, HttpClient } from 'Dora';
import { Log } from 'Agent/Utils';
import { isHttpUrl, isSafePublicHttpUrl } from 'Agent/Tool/NetworkSafety';
import { createOperationId, getAgentDownloadTempRoot, cleanupPath } from 'Agent/Tool/Operation';
import { syncWebIDEFile } from 'Agent/Tool/WebIDESync';
import {
	resolveWorkspaceFilePath,
	ensureDirPath,
	ensureDirForFile,
} from 'Agent/Tool/Workspace';

export type FetchUrlMode = "download";

export type FetchUrlProgress = {
	state: "pending" | "running";
	mode: FetchUrlMode;
	operationId: string;
	target: string;
	tempPath: string;
	progress?: number;
	current?: number;
	total?: number;
	message?: string;
	stage?: string;
	jobId?: number;
	gitState?: string;
	gitKind?: string;
};

export type FetchUrlResult = {
	success: true;
	state: "done";
	mode: FetchUrlMode;
	target: string;
	bytesWritten?: number;
} | {
	success: false;
	state: "failed";
	mode?: FetchUrlMode;
	target?: string;
	message: string;
	interrupted?: boolean;
	cleanupError?: string;
};

function downloadFile(req: {
	url: string;
	tempPath: string;
	timeout: number;
	onProgress: (current: number, total: number) => void;
	isCancelled?: () => boolean;
}): Promise<{ success: boolean; interrupted?: boolean; message?: string; bytesWritten?: number }> {
	return new Promise(resolve => {
		let requestId = 0;
		let settled = false;
		let bytesWritten = 0;
		const finish = (result: { success: boolean; interrupted?: boolean; message?: string; bytesWritten?: number }) => {
			if (settled) return;
			settled = true;
			requestId = 0;
			resolve(result);
		};
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (req.isCancelled?.() === true && requestId !== 0) {
				HttpClient.cancel(requestId);
				finish({ success: false, interrupted: true, message: "download canceled" });
				return true;
			}
			if (requestId !== 0 && !HttpClient.isRequestActive(requestId)) {
				finish({ success: false, message: "download request ended without a completion callback" });
				return true;
			}
			return false;
		});
		Director.systemScheduler.schedule(once(() => {
			requestId = HttpClient.download(req.url, req.tempPath, req.timeout, (interrupted, current, total) => {
				if (typeof current === "number" && current > bytesWritten) {
					bytesWritten = current;
				}
				if (interrupted) {
					finish({ success: false, interrupted: true, message: "download failed" });
					return true;
				}
				if (req.isCancelled?.() === true) {
					finish({ success: false, interrupted: true, message: "download canceled" });
					return true;
				}
				if (current === total) {
					finish({ success: true, bytesWritten });
					return false;
				}
				req.onProgress(current, total);
				return false;
			});
			if (requestId === 0) {
				finish({ success: false, message: "failed to schedule download request" });
			} else if (req.isCancelled?.() === true) {
				HttpClient.cancel(requestId);
				finish({ success: false, interrupted: true, message: "download canceled" });
			}
		}));
	});
}

export async function fetchUrl(req: {
	workDir: string;
	url: string;
	target: string;
	onProgress?: (progress: FetchUrlProgress) => void;
	isCancelled?: () => boolean;
}): Promise<FetchUrlResult> {
	const mode: FetchUrlMode = "download";
	const url = (req.url ?? "").trim();
	const targetRel = (req.target ?? "").trim();
	if (!isHttpUrl(url)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "fetch_url only supports http:// and https:// URLs" };
	}
	if (!isSafePublicHttpUrl(url)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "fetch_url rejects local, private, metadata, and literal-IP destinations" };
	}
	if (targetRel === "") {
		return { success: false, state: "failed", mode, message: "missing target" };
	}
	const target = resolveWorkspaceFilePath(req.workDir, targetRel);
	if (!target) {
		return { success: false, state: "failed", mode, target: targetRel, message: "invalid target path" };
	}
	if (Content.exist(target)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "target already exists" };
	}
	const operationId = createOperationId();
	const tempRoot = getAgentDownloadTempRoot();
	if (!ensureDirPath(tempRoot)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to create agent download temp directory" };
	}
	const tempPath = Path(tempRoot, `${operationId}.download`);
	Content.remove(tempPath);
	const emitProgress = (progress: Partial<FetchUrlProgress>) => {
		if (!req.onProgress) return;
		req.onProgress({
			state: "running",
			mode,
			operationId,
			target: targetRel,
			tempPath,
			...progress,
		});
	};
	emitProgress({
		state: "pending",
		message: "download pending",
		stage: "download",
	});
	const interrupted = () => req.isCancelled?.() === true;
	if (!ensureDirForFile(tempPath)) {
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to create temporary file directory" };
	}
	const downloadRes = await downloadFile({
		url,
		tempPath,
		timeout: 600,
		isCancelled: interrupted,
		onProgress: (current, total) => {
			const totalNumber = typeof total === "number" ? total : 0;
			emitProgress({
				stage: "download",
				message: "downloading",
				current,
				total,
				progress: totalNumber > 0 ? current / totalNumber : undefined,
			});
		},
	});
	if (!downloadRes.success) {
		const cleanupError = cleanupPath(tempPath);
		return {
			success: false,
			state: "failed",
			mode,
			target: targetRel,
			message: interrupted() ? "download canceled" : (downloadRes.message ?? "download failed"),
			interrupted: downloadRes.interrupted || interrupted(),
			cleanupError,
		};
	}
	if (!ensureDirForFile(target)) {
		const cleanupError = cleanupPath(tempPath);
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to create target directory", cleanupError };
	}
	if (!Content.move(tempPath, target)) {
		const cleanupError = cleanupPath(tempPath);
		return { success: false, state: "failed", mode, target: targetRel, message: "failed to move downloaded file into target path", cleanupError };
	}
	let bytesWritten: number | undefined = downloadRes.bytesWritten;
	try {
		const [size] = Content.getAttr(target);
		if (bytesWritten === undefined || bytesWritten <= 0) {
			bytesWritten = typeof size === "number" ? size : undefined;
		}
	} catch (_) {
		// Keep the download callback byte count when Content attributes are unavailable.
	}
	if (bytesWritten === undefined || bytesWritten <= 0) {
		try {
			const loaded = Content.load(target);
			if (typeof loaded === "string") {
				bytesWritten = loaded.length;
			}
		} catch (_) {
			// Keep the stat result when the downloaded file cannot be loaded as text.
		}
	}
	if (!syncWebIDEFile(target, "fetch_url")) {
		Log("Warn", `[fetch_url] failed to sync downloaded file update target=${target}`);
	}
	return { success: true, state: "done", mode, target: targetRel, bytesWritten };
}
