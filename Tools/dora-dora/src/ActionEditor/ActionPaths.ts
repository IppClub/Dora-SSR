import Info from "../Info";

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

export const splitActionPath = (path: string) => {
	const normalized = Info.path.normalize(path);
	const dir = Info.path.dirname(normalized);
	return {
		dir: dir === "." ? "" : dir,
		file: Info.path.basename(normalized),
	};
};

export const joinActionPath = (...parts: string[]) => Info.path.normalize(Info.path.join(...parts.filter((part) => part !== "")));

const stripActionExt = (file: string, ext: string) => {
	const actualExt = Info.path.extname(file);
	if (actualExt.toLowerCase() !== ext.toLowerCase()) return file;
	return Info.path.basename(file, actualExt);
};

export const getActionClipsDirectories = (entries: string[]) => entries
	.filter((entry) => Info.path.extname(entry).toLowerCase() === ".clips")
	.sort((a, b) => a.localeCompare(b));

export const getActionClipFiles = (entries: string[]) => entries
	.filter((entry) => Info.path.extname(entry).toLowerCase() === ".clip")
	.sort((a, b) => a.localeCompare(b));

export const chooseActionClipsDirectory = (modelPath: string, entries: string[]) => {
	const { file } = splitActionPath(modelPath);
	const modelBaseName = stripActionExt(file, ".model");
	const candidates = getActionClipsDirectories(entries);
	const preferred = `${modelBaseName}.clips`;
	return candidates.includes(preferred) ? preferred : candidates[0];
};

export const getActionAtlasPaths = (modelPath: string, clipsDirName?: string): ActionAtlasPaths => {
	const { dir, file } = splitActionPath(modelPath);
	const modelBaseName = stripActionExt(file, ".model");
	const selectedClipsDir = clipsDirName ?? `${modelBaseName}.clips`;
	const outputBaseName = stripActionExt(selectedClipsDir, ".clips");
	return {
		modelPath: Info.path.normalize(modelPath),
		modelDir: dir,
		modelBaseName,
		clipsDirName: selectedClipsDir,
		clipsDirPath: joinActionPath(dir, selectedClipsDir),
		outputBaseName,
		clipPath: joinActionPath(dir, `${outputBaseName}.clip`),
		pngPath: joinActionPath(dir, `${outputBaseName}.png`),
		modelClipReference: `${outputBaseName}.clip`,
	};
};
