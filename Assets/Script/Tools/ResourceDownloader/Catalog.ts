// @preview-file off
import { Content, json, Path } from "Dora";

export const CATALOG_SCHEMA_VERSION = 1;
export const MAX_CATALOG_RESOURCES = 5000;
export const MAX_RESOURCE_JSON_BYTES = 256 * 1024;
export const MAX_BANNER_BYTES = 4 * 1024 * 1024;

export type ResourceStatus = "active" | "deprecated" | "unavailable" | "blocked";
export type ResourceSourceRole = "upstream" | "mirror";

export interface LocalizedText {
	"zh-Hans": string;
	en: string;
}

export interface ResourceLicensePending {
	status: "pending";
}

export interface ResourceLicenseConfirmed {
	status: "confirmed";
	spdx: string;
	file?: string;
}

export type ResourceLicense = ResourceLicensePending | ResourceLicenseConfirmed;

export interface ResourceEntrypoint {
	name: string;
	path: string;
}

export interface ResourceSource {
	role: ResourceSourceRole;
	url: string;
}

export interface ResourceVersion {
	name: string;
	tag?: string;
	publishedAt: string;
	sources: ResourceSource[];
}

export interface ResourceInfo {
	schemaVersion: 1;
	id: string;
	status: ResourceStatus;
	title: LocalizedText;
	description: LocalizedText;
	categories: string[];
	tags: string[];
	license: ResourceLicense;
	runnable: boolean;
	entrypoints: ResourceEntrypoint[];
	versions: ResourceVersion[];
	projectPath: string;
	bannerPath?: string;
	selectedVersion: number;
}

export interface CatalogIssue {
	project: string;
	message: string;
}

export interface CatalogLoadResult {
	resources: ResourceInfo[];
	issues: CatalogIssue[];
	categories: string[];
}

export type ResourceSection = "featured" | "minigame" | "all";

export interface ResourceFilter {
	section: ResourceSection;
	category?: string;
	query?: string;
}

export interface ResourcePage {
	items: ResourceInfo[];
	page: number;
	pageCount: number;
	total: number;
}

type DataRecord = Record<string, unknown>;

const isRecord = (value: unknown): value is DataRecord =>
	typeof value === "object" && value !== undefined && !Array.isArray(value);

const isNonEmptyString = (value: unknown, maxLength: number): value is string =>
	typeof value === "string" && value.length > 0 && value.length <= maxLength;

const hasOnlyResourceIdChars = (value: string) => {
	const [invalid] = string.match(value, "[^A-Za-z0-9._-]");
	return invalid === undefined;
};

const hasOnlyTagChars = (value: string) => {
	const [invalid] = string.match(value, "[^a-z0-9-]");
	const [first] = string.match(value, "^[a-z0-9]");
	return invalid === undefined && first !== undefined;
};

export const isSafeHttpsGitUrl = (value: string) => {
	if (!value.startsWith("https://") || value.length > 2048) return false;
	const [whitespace] = string.match(value, "%s");
	if (whitespace !== undefined) return false;
	const authorityEnd = value.indexOf("/", "https://".length);
	const authority = authorityEnd >= 0
		? value.substring("https://".length, authorityEnd)
		: value.substring("https://".length);
	return authority.length > 0 && authority.indexOf("@") < 0;
};

const isSafeRelativePath = (value: string) => {
	if (value.length === 0 || value.length > 512 || value.startsWith("/") || value.indexOf("\\") >= 0) {
		return false;
	}
	for (const segment of value.split("/")) {
		if (segment === "" || segment === "." || segment === "..") return false;
	}
	return true;
};

const parseLocalized = (value: unknown, field: string, errors: string[]): LocalizedText | undefined => {
	if (!isRecord(value)
		|| !isNonEmptyString(value["zh-Hans"], field === "title" ? 200 : 4000)
		|| !isNonEmptyString(value.en, field === "title" ? 200 : 4000)) {
		errors.push(`${field} must contain non-empty zh-Hans and en text`);
		return undefined;
	}
	return {
		"zh-Hans": value["zh-Hans"],
		en: value.en,
	};
};

const parseStringList = (
	value: unknown,
	field: string,
	maxItems: number,
	errors: string[],
	tag = false,
): string[] | undefined => {
	if (!Array.isArray(value) || value.length > maxItems) {
		errors.push(`${field} must be an array with at most ${maxItems} items`);
		return undefined;
	}
	const result: string[] = [];
	const seen = new Set<string>();
	for (const item of value) {
		if (!isNonEmptyString(item, 100) || (tag && !hasOnlyTagChars(item))) {
			errors.push(`${field} contains an invalid value`);
			return undefined;
		}
		if (seen.has(item)) {
			errors.push(`${field} contains duplicate value ${item}`);
			return undefined;
		}
		seen.add(item);
		result.push(item);
	}
	return result;
};

const parseLicense = (value: unknown, errors: string[]): ResourceLicense | undefined => {
	if (!isRecord(value) || (value.status !== "pending" && value.status !== "confirmed")) {
		errors.push("license.status must be pending or confirmed");
		return undefined;
	}
	if (value.status === "pending") return { status: "pending" };
	if (!isNonEmptyString(value.spdx, 100)) {
		errors.push("confirmed license must contain spdx");
		return undefined;
	}
	if (value.file !== undefined && (!isNonEmptyString(value.file, 512) || !isSafeRelativePath(value.file))) {
		errors.push("license.file must be a safe relative path");
		return undefined;
	}
	return {
		status: "confirmed",
		spdx: value.spdx,
		file: value.file as string | undefined,
	};
};

const parseEntrypoints = (value: unknown, errors: string[]): ResourceEntrypoint[] | undefined => {
	if (!Array.isArray(value) || value.length > 32) {
		errors.push("entrypoints must be an array with at most 32 items");
		return undefined;
	}
	const result: ResourceEntrypoint[] = [];
	for (const item of value) {
		if (!isRecord(item)
			|| !isNonEmptyString(item.name, 100)
			|| !isNonEmptyString(item.path, 512)
			|| !isSafeRelativePath(item.path)) {
			errors.push("entrypoints contains an invalid entry");
			return undefined;
		}
		result.push({ name: item.name, path: item.path });
	}
	return result;
};

const parseSources = (value: unknown, errors: string[]): ResourceSource[] | undefined => {
	if (!Array.isArray(value) || value.length === 0 || value.length > 8) {
		errors.push("version.sources must contain 1 to 8 sources");
		return undefined;
	}
	const result: ResourceSource[] = [];
	const seen = new Set<string>();
	for (const item of value) {
		if (!isRecord(item)
			|| (item.role !== "upstream" && item.role !== "mirror")
			|| !isNonEmptyString(item.url, 2048)
			|| !isSafeHttpsGitUrl(item.url)) {
			errors.push("version.sources contains an invalid HTTPS Git source");
			return undefined;
		}
		if (seen.has(item.url)) {
			errors.push(`version.sources contains duplicate URL ${item.url}`);
			return undefined;
		}
		seen.add(item.url);
		result.push({ role: item.role, url: item.url });
	}
	return result;
};

const parseVersions = (value: unknown, errors: string[]): ResourceVersion[] | undefined => {
	if (!Array.isArray(value) || value.length === 0 || value.length > 32) {
		errors.push("versions must contain 1 to 32 items");
		return undefined;
	}
	const result: ResourceVersion[] = [];
	const seen = new Set<string>();
	for (const item of value) {
		if (!isRecord(item)
			|| !isNonEmptyString(item.name, 100)
			|| !isNonEmptyString(item.publishedAt, 100)) {
			errors.push("versions contains invalid name or publishedAt");
			return undefined;
		}
		if (item.tag !== undefined && !isNonEmptyString(item.tag, 200)) {
			errors.push("version.tag must be a non-empty string");
			return undefined;
		}
		const sources = parseSources(item.sources, errors);
		if (!sources) return undefined;
		if (seen.has(item.name)) {
			errors.push(`versions contains duplicate name ${item.name}`);
			return undefined;
		}
		seen.add(item.name);
		result.push({
			name: item.name,
			tag: item.tag as string | undefined,
			publishedAt: item.publishedAt,
			sources,
		});
	}
	return result;
};

export const parseResourceJSON = (
	text: string,
	projectName: string,
	projectPath: string,
	bannerPath?: string,
): LuaMultiReturn<[ResourceInfo | undefined, string[]]> => {
	const errors: string[] = [];
	if (text.length > MAX_RESOURCE_JSON_BYTES) {
		return $multi(undefined, [`resource.json exceeds ${MAX_RESOURCE_JSON_BYTES} bytes`]);
	}
	const [decoded, decodeError] = json.decode(text);
	if (decodeError !== undefined || !isRecord(decoded)) {
		return $multi(undefined, [`invalid JSON: ${decodeError ?? "root must be an object"}`]);
	}
	if (decoded.schemaVersion !== CATALOG_SCHEMA_VERSION) {
		errors.push(`unsupported schemaVersion ${decoded.schemaVersion}`);
	}
	if (!isNonEmptyString(decoded.id, 200) || !hasOnlyResourceIdChars(decoded.id)) {
		errors.push("id contains invalid characters");
	} else if (decoded.id !== projectName) {
		errors.push(`id ${decoded.id} does not match directory ${projectName}`);
	}
	const allowedStatus = decoded.status === "active"
		|| decoded.status === "deprecated"
		|| decoded.status === "unavailable"
		|| decoded.status === "blocked";
	if (!allowedStatus) errors.push("status is invalid");
	const title = parseLocalized(decoded.title, "title", errors);
	const description = parseLocalized(decoded.description, "description", errors);
	const categories = parseStringList(decoded.categories, "categories", 32, errors);
	const tags = decoded.tags === undefined
		? []
		: parseStringList(decoded.tags, "tags", 32, errors, true);
	const license = parseLicense(decoded.license, errors);
	if (typeof decoded.runnable !== "boolean") errors.push("runnable must be boolean");
	const entrypoints = parseEntrypoints(decoded.entrypoints, errors);
	const versions = parseVersions(decoded.versions, errors);
	if (errors.length > 0
		|| !title
		|| !description
		|| !categories
		|| !tags
		|| !license
		|| !entrypoints
		|| !versions
		|| typeof decoded.id !== "string") {
		return $multi(undefined, errors);
	}
	return $multi({
		schemaVersion: CATALOG_SCHEMA_VERSION,
		id: decoded.id,
		status: decoded.status as ResourceStatus,
		title,
		description,
		categories,
		tags,
		license,
		runnable: decoded.runnable as boolean,
		entrypoints,
		versions,
		projectPath,
		bannerPath,
		selectedVersion: 1,
	}, []);
};

export const loadCatalog = (catalogRoot: string): CatalogLoadResult => {
	const projectsPath = Path(catalogRoot, "projects");
	const issues: CatalogIssue[] = [];
	const resources: ResourceInfo[] = [];
	const categories = new Set<string>();
	const ids = new Set<string>();
	if (!Content.isdir(projectsPath)) {
		return {
			resources,
			issues: [{ project: "", message: "projects directory is missing" }],
			categories: [],
		};
	}
	const projectNames = Content.getDirs(projectsPath).sort();
	if (projectNames.length > MAX_CATALOG_RESOURCES) {
		issues.push({
			project: "",
			message: `catalog contains ${projectNames.length} projects; maximum is ${MAX_CATALOG_RESOURCES}`,
		});
		return { resources, issues, categories: [] };
	}
	for (const projectName of projectNames) {
		const projectPath = Path(projectsPath, projectName);
		const resourceFile = Path(projectPath, "resource.json");
		if (!Content.exist(resourceFile)) {
			issues.push({ project: projectName, message: "resource.json is missing" });
			continue;
		}
		const bannerFile = Path(projectPath, "banner.jpg");
		if (Content.exist(bannerFile)) {
			const [bannerBytes] = Content.getAttr(bannerFile);
			if (bannerBytes === undefined || bannerBytes > MAX_BANNER_BYTES) {
				issues.push({
					project: projectName,
					message: `banner.jpg exceeds ${MAX_BANNER_BYTES} bytes`,
				});
				continue;
			}
		}
		const [resource, errors] = parseResourceJSON(
			Content.load(resourceFile),
			projectName,
			projectPath,
			Content.exist(bannerFile) ? bannerFile : undefined,
		);
		if (!resource) {
			for (const message of errors) issues.push({ project: projectName, message });
			continue;
		}
		if (ids.has(resource.id)) {
			issues.push({ project: projectName, message: `duplicate resource id ${resource.id}` });
			continue;
		}
		ids.add(resource.id);
		for (const category of resource.categories) categories.add(category);
		resources.push(resource);
	}
	resources.sort((a, b) => a.id < b.id ? -1 : (a.id > b.id ? 1 : 0));
	return {
		resources,
		issues,
		categories: Array.from(categories).sort(),
	};
};

export const isMinigame = (resource: ResourceInfo) => resource.tags.indexOf("minigame") >= 0;

export const filterResources = (resources: ResourceInfo[], filter: ResourceFilter) => {
	const query = (filter.query ?? "").trim().toLowerCase();
	return resources.filter(resource => {
		if (resource.status === "blocked") return false;
		const minigame = isMinigame(resource);
		if (filter.section === "featured" && minigame) return false;
		if (filter.section === "minigame" && !minigame) return false;
		if (filter.category !== undefined && resource.categories.indexOf(filter.category) < 0) return false;
		if (query !== "") {
			const searchText = [
				resource.id,
				resource.title["zh-Hans"],
				resource.title.en,
				resource.description["zh-Hans"],
				resource.description.en,
				resource.categories.join(" "),
			].join("\n").toLowerCase();
			if (searchText.indexOf(query) < 0) return false;
		}
		return true;
	});
};

export const paginateResources = (
	resources: ResourceInfo[],
	requestedPage: number,
	pageSize: number,
): ResourcePage => {
	const safePageSize = math.max(1, math.floor(pageSize));
	const pageCount = math.max(1, math.ceil(resources.length / safePageSize));
	const page = math.max(0, math.min(math.floor(requestedPage), pageCount - 1));
	const start = page * safePageSize;
	return {
		items: resources.slice(start, start + safePageSize),
		page,
		pageCount,
		total: resources.length,
	};
};
