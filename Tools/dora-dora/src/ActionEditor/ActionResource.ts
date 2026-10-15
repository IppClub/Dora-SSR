import Info from "../Info";
import { isPathWithin, toUrlPath } from "../PathUtils";

export const toServedResourcePath = (filePath: string, resourceBasePath?: string) => {
	if (resourceBasePath && isPathWithin(filePath, resourceBasePath, Info.path)) {
		return toUrlPath(Info.path.relative(resourceBasePath, filePath), Info.path);
	}
	return toUrlPath(Info.path.normalize(filePath), Info.path).replace(/^\/+/, "");
};

export const toServedResourceUrl = (filePath: string, resourceBasePath?: string) => {
	const servedPath = toServedResourcePath(filePath, resourceBasePath);
	return `/${servedPath}`;
};
