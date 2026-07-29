import Info from "./Info";
import type { Path } from "./3rdParty/Path";

export type PathApi = Pick<
	Path,
	"basename" | "isAbsolute" | "join" | "normalize" | "relative" | "sep"
>;

export const isPathWithin = (
	child: string,
	parent: string,
	pathApi: PathApi = Info.path,
) => {
	if (child === "" || parent === "") return false;
	const relative = pathApi.relative(parent, child);
	return relative === "" || (
		!pathApi.isAbsolute(relative)
		&& relative !== ".."
		&& !relative.startsWith(`..${pathApi.sep}`)
	);
};

export const toUrlPath = (value: string, pathApi: PathApi = Info.path) => (
	pathApi.sep === "/" ? value : value.split(pathApi.sep).join("/")
);

export const toCanonicalRelativePath = (
	value: string,
	pathApi: PathApi = Info.path,
) => {
	const normalized = toUrlPath(pathApi.normalize(value), pathApi);
	return normalized === "." ? "" : normalized.replace(/^\/+/, "");
};

export const relativePathFromRoot = (
	root: string,
	target: string,
	pathApi: PathApi = Info.path,
) => {
	if (!isPathWithin(target, root, pathApi)) return null;
	return toCanonicalRelativePath(pathApi.relative(root, target), pathApi);
};

export const joinCanonicalRelativePath = (
	root: string,
	relative: string,
	pathApi: PathApi = Info.path,
) => pathApi.join(root, ...toCanonicalRelativePath(relative, pathApi).split("/").filter(Boolean));
