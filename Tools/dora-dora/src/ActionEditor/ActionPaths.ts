export type ActionAtlasPaths = {
	modelPath: string;
	modelDir: string;
	modelBaseName: string;
	clipsDirName: string;
	clipsDirPath: string;
	outputBaseName: string;
	clipPath: string;
	pngPath: string;
	modelClipReference: string;
};

const splitPath = (path: string) => {
	const normalized = path.replace(/\\/g, "/");
	const index = normalized.lastIndexOf("/");
	if (index < 0) return {dir: "", file: normalized};
	return {dir: normalized.slice(0, index), file: normalized.slice(index + 1)};
};

const joinPath = (dir: string, file: string) => dir ? `${dir}/${file}` : file;

const stripExt = (file: string, ext: string) => file.toLowerCase().endsWith(ext) ? file.slice(0, -ext.length) : file;

export const getActionClipsDirectories = (entries: string[]) => entries
	.filter((entry) => entry.endsWith(".clips"))
	.sort((a, b) => a.localeCompare(b));

export const chooseActionClipsDirectory = (modelPath: string, entries: string[]) => {
	const {file} = splitPath(modelPath);
	const modelBaseName = stripExt(file, ".model");
	const candidates = getActionClipsDirectories(entries);
	const preferred = `${modelBaseName}.clips`;
	return candidates.includes(preferred) ? preferred : candidates[0];
};

export const getActionAtlasPaths = (modelPath: string, clipsDirName?: string): ActionAtlasPaths => {
	const {dir, file} = splitPath(modelPath);
	const modelBaseName = stripExt(file, ".model");
	const selectedClipsDir = clipsDirName ?? `${modelBaseName}.clips`;
	const outputBaseName = stripExt(selectedClipsDir, ".clips");
	return {
		modelPath,
		modelDir: dir,
		modelBaseName,
		clipsDirName: selectedClipsDir,
		clipsDirPath: joinPath(dir, selectedClipsDir),
		outputBaseName,
		clipPath: joinPath(dir, `${outputBaseName}.clip`),
		pngPath: joinPath(dir, `${outputBaseName}.png`),
		modelClipReference: `${outputBaseName}.clip`,
	};
};
