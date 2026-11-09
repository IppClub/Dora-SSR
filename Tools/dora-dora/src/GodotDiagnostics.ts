// Keep diagnostic links independent of whichever project/editor tab is active.
export function formatGodotDiagnostics(message: string, projectRoot: string): string {
	return message.replace(/res:\/\/([^\r\n"()]+?):(\d+)(?::(\d+))?/g, (match, relative: string, row: string, column?: string) => {
		if (relative.split(/[\\/]/).includes('..')) return match;
		const file = `${projectRoot.replace(/[\\/]$/, '')}/${relative}`;
		return `[[dora-file:${encodeURIComponent(file)}:${row}:${column ?? '1'}]]`;
	});
}

export const diagnosticLinkPattern = /\[\[dora-file:([^\]]+):(\d+):(\d+)\]\]/g;
