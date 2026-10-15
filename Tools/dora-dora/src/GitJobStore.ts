import type { GitJobState, GitKind, GitStatus } from './Service';

export interface GitJobSnapshot {
	jobId: number;
	command: string;
	startedAt: number;
	status?: GitStatus;
}

type Listener = () => void;
type Completion = (status: GitStatus) => void;

const snapshots = new Map<string, GitJobSnapshot>();
const listeners = new Map<string, Set<Listener>>();
const timers = new Map<string, number>();
const completions = new Map<number, Completion>();
const claimedTerminalJobs = new Set<number>();
const terminalStates = new Set<GitJobState>(["done", "error", "canceled"]);

type GitJobStatusResponse = {
	success: true;
	status: GitStatus;
	command: string;
} | {
	success: false;
	message?: string;
};

const pollGitStatus = async (jobId: number): Promise<GitJobStatusResponse> => {
	const url = !process.env.NODE_ENV || process.env.NODE_ENV === "development"
		? "http://localhost:8866/git/status"
		: "/git/status";
	const response = await fetch(url, {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ jobId }),
	});
	return response.json();
};

const emit = (repoPath: string) => {
	for (const listener of listeners.get(repoPath) ?? []) listener();
};

const stopTimer = (repoPath: string) => {
	const timer = timers.get(repoPath);
	if (timer !== undefined) window.clearTimeout(timer);
	timers.delete(repoPath);
};

const schedulePoll = (repoPath: string, delay = 0) => {
	stopTimer(repoPath);
	const timer = window.setTimeout(async () => {
		timers.delete(repoPath);
		const current = snapshots.get(repoPath);
		if (!current) return;
		const res = await pollGitStatus(current.jobId);
		if (snapshots.get(repoPath)?.jobId !== current.jobId) return;
		if (!res.success) {
			snapshots.set(repoPath, {
				...current,
				status: {
					id: current.jobId,
					state: "error",
					kind: current.command.trim().split(/\s+/, 1)[0] as GitKind,
					repoPath,
					progress: 1,
					error: res.message ?? "failed to poll Git job",
				},
			});
			emit(repoPath);
			return;
		}
		const next = { ...current, status: res.status };
		snapshots.set(repoPath, next);
		emit(repoPath);
		if (terminalStates.has(res.status.state)) {
			const completion = completions.get(current.jobId);
			completions.delete(current.jobId);
			if ((listeners.get(repoPath)?.size ?? 0) > 0) completion?.(res.status);
			return;
		}
		schedulePoll(repoPath, 600);
	}, delay);
	timers.set(repoPath, timer);
};

export const trackGitJob = (
	repoPath: string,
	jobId: number,
	command: string,
	onDone?: Completion,
) => {
	const snapshot = { jobId, command, startedAt: Date.now() };
	snapshots.set(repoPath, snapshot);
	claimedTerminalJobs.delete(jobId);
	if (onDone) completions.set(jobId, onDone);
	emit(repoPath);
	schedulePoll(repoPath);
};

export const getGitJobSnapshot = (repoPath: string) => snapshots.get(repoPath) ?? null;

export const subscribeGitJob = (repoPath: string, listener: Listener) => {
	const repoListeners = listeners.get(repoPath) ?? new Set<Listener>();
	repoListeners.add(listener);
	listeners.set(repoPath, repoListeners);
	return () => {
		repoListeners.delete(listener);
		if (repoListeners.size === 0) listeners.delete(repoPath);
	};
};

export const claimTerminalGitJob = (repoPath: string, jobId: number) => {
	const snapshot = snapshots.get(repoPath);
	if (!snapshot?.status || snapshot.jobId !== jobId || !terminalStates.has(snapshot.status.state)) return false;
	if (claimedTerminalJobs.has(jobId)) return false;
	claimedTerminalJobs.add(jobId);
	return true;
};
