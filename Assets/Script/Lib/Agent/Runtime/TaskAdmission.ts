// Default-open, runtime-local host gate. No policy changes until a host holds it.
const holds: Record<string, number> = {};

export function isProjectTaskAdmissionClosed(projectRoot: string): boolean {
	return (holds[projectRoot] ?? 0) > 0;
}

/** Use the canonical project root from the session record. */
export function holdProjectTaskAdmission(projectRoot: string): () => void {
	if (projectRoot === "") error("project root is required");
	holds[projectRoot] = (holds[projectRoot] ?? 0) + 1;
	let released = false;
	return () => {
		if (released) return;
		released = true;
		const remaining = (holds[projectRoot] ?? 1) - 1;
		if (remaining > 0) holds[projectRoot] = remaining;
		else delete holds[projectRoot];
	};
}
