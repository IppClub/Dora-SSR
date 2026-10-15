export type GitProgressMessage = {
	kind: "lfs-download";
	done: number;
	total: number;
	received?: string;
	totalBytes?: string;
	raw: string;
} | {
	kind: "message";
	raw: string;
};

const lfsDownloadPattern = /^downloading LFS objects (\d+)\/(\d+)(?: · (.+) \/ (.+))?$/i;

export const parseGitProgressMessage = (message: string): GitProgressMessage => {
	const match = lfsDownloadPattern.exec(message);
	if (!match) return { kind: "message", raw: message };
	return {
		kind: "lfs-download",
		done: Number(match[1]),
		total: Number(match[2]),
		received: match[3],
		totalBytes: match[4],
		raw: message,
	};
};
