// @preview-file off
import { Director, Git } from "Dora";

export interface GitOperationStatus {
	id: number;
	state: "queued" | "running" | "done" | "error" | "canceled";
	kind: string;
	repoPath: string;
	progress: number;
	message?: string;
	error?: string;
	data?: Record<string, unknown>;
}

export interface GitOperationResult {
	success: boolean;
	status?: GitOperationStatus;
	message?: string;
	canceled?: boolean;
}

export interface GitOperationOptions {
	timeout?: number;
	onStatus?: (status: GitOperationStatus) => void;
	isCanceled?: () => boolean;
}

export const quoteGitArgument = (value: string) => {
	const [escapedSlashes] = string.gsub(value, "\\", "\\\\");
	const [escapedQuotes] = string.gsub(escapedSlashes, '"', '\\"');
	return `"${escapedQuotes}"`;
};

export const runGit = (
	repoPath: string,
	command: string,
	options: GitOperationOptions = {},
): Promise<GitOperationResult> => {
	return new Promise(resolve => {
		const timeout = options.timeout ?? 1200;
		let currentStatus: GitOperationStatus | undefined;
		let settled = false;
		let jobId = 0;
		const finish = (result: GitOperationResult) => {
			if (settled) return;
			settled = true;
			resolve(result);
		};
		const consumeTerminalStatus = () => {
			if (!currentStatus) return false;
			if (currentStatus.state === "done") {
				finish({ success: true, status: currentStatus });
				return true;
			}
			if (currentStatus.state === "error" || currentStatus.state === "canceled") {
				finish({
					success: false,
					status: currentStatus,
					message: currentStatus.error ?? currentStatus.message ?? "Git operation failed",
					canceled: currentStatus.state === "canceled",
				});
				return true;
			}
			return false;
		};
		jobId = Git.run(repoPath, command, status => {
			const nextStatus = status as unknown as GitOperationStatus;
			if (typeof nextStatus.progress !== "number") {
				nextStatus.progress = currentStatus?.progress ?? 0;
			}
			currentStatus = nextStatus;
			if (options.onStatus) options.onStatus(currentStatus);
			consumeTerminalStatus();
		});
		if (jobId <= 0) {
			finish({ success: false, message: "Failed to start Git operation" });
			return;
		}
		const startedAt = os.time();
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (options.isCanceled && options.isCanceled()) {
				Git.cancel(jobId);
				finish({ success: false, status: currentStatus, message: "Git operation canceled", canceled: true });
				return true;
			}
			if (consumeTerminalStatus()) return true;
			if (os.time() - startedAt >= timeout) {
				Git.cancel(jobId);
				finish({ success: false, status: currentStatus, message: "Git operation timed out" });
				return true;
			}
			return false;
		});
	});
};

export const gitHeadFromStatus = (status?: GitOperationStatus) => {
	const value = status?.data?.head;
	return typeof value === "string" ? value : undefined;
};
