// @preview-file off clear
import { Content, Path } from 'Dora';
import { ENGINE_LOG_DOWNLOAD_DIR } from 'Agent/Tool/Workspace';

const AGENT_DOWNLOAD_TEMP_DIR = "agent";

export function createOperationId(): string {
	const raw = `${tostring(os.time())}-${tostring(math.floor(math.random() * 1000000000))}`;
	const [safe] = string.gsub(raw, "[^%w%-_]", "-");
	return safe;
}

export function getAgentDownloadTempRoot(): string {
	return Path(Content.writablePath, ENGINE_LOG_DOWNLOAD_DIR, AGENT_DOWNLOAD_TEMP_DIR);
}

export function cleanupPath(path: string): string | undefined {
	if (!path || path === "" || !Content.exist(path)) return undefined;
	if (Content.remove(path)) return undefined;
	return `failed to remove temporary path: ${path}`;
}
