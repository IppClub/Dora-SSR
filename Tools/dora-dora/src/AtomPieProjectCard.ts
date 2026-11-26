import Info from './Info';
import projectCoverPaths from '../../../Assets/Script/Dev/ProjectCoverPaths.json';
import * as Service from './Service';
import {uploadFile} from './UploadFile';

// Mobile packages use description. Resource Downloader installations use desc.
export function projectDescriptions(metadata: {description?: unknown; desc?: unknown}) {
	const translated = (value: unknown, language: 'zh' | 'en') => {
		if (!value || typeof value !== 'object') return undefined;
		const text = (value as Record<string, unknown>)[language];
		return typeof text === 'string' ? text.trim() : undefined;
	};
	return {
		zh: translated(metadata.description, 'zh') ?? translated(metadata.desc, 'zh') ?? '',
		en: translated(metadata.description, 'en') ?? translated(metadata.desc, 'en') ?? '',
	};
}

export async function readProjectCard(project: string) {
	const file = Info.path.join(project, '.dora', 'repo.json');
	if (!(await Service.exist({file})).success) return {file, content: '', metadata: {}};
	const result = await Service.read({path: file});
	if (!result.success) throw new Error('repo.json');
	const metadata = JSON.parse(result.content);
	if (!metadata || typeof metadata !== 'object' || Array.isArray(metadata)
		|| (metadata.title !== undefined && (!metadata.title || typeof metadata.title !== 'object' || Array.isArray(metadata.title)))) throw new Error('repo.json');
	return {file, content: result.content, metadata};
}

export async function findProjectCover(project: string) {
	for (const path of projectCoverPaths) {
		if ((await Service.exist({file: Info.path.join(project, path)})).success) return path;
	}
	return '';
}

type Translations = Partial<Record<'zh' | 'en', string>>;
export type CardEdit = {title?: Translations; description?: Translations; categories?: string[]; cover?: File};

export async function saveProjectCard(project: string, original: string, edit: CardEdit) {
	const {file, content, metadata} = await readProjectCard(project);
	const before = JSON.parse(original || '{}');
	for (const field of ['title', 'description'] as const) {
		for (const lang of ['zh', 'en'] as const) {
			const value = edit[field]?.[lang]?.trim();
			if (value === undefined) continue;
			const current = field === 'description' ? projectDescriptions(metadata)[lang] : metadata.title?.[lang];
			const previous = field === 'description' ? projectDescriptions(before)[lang] : before.title?.[lang];
			if (current !== previous && current !== value) throw new Error('changed');
			metadata[field] = {...metadata[field], [lang]:value};
		}
	}
	if (edit.categories) {
		if (JSON.stringify(before.categories) !== JSON.stringify(metadata.categories)
			&& JSON.stringify(edit.categories) !== JSON.stringify(metadata.categories)) throw new Error('changed');
		metadata.categories = edit.categories;
	}
	const dir = Info.path.dirname(file);
	if (!(await Service.exist({file:dir})).success && !(await Service.newFile({path:dir, folder:true, content:''})).success) throw new Error('mkdir');
	if (edit.cover) await uploadFile(Service.addr('/upload?' + new URLSearchParams({path:dir, name:'banner.jpg'})), edit.cover);
	if (!edit.title && !edit.description && !edit.categories) return content;
	const next = JSON.stringify(metadata, null, 2) + '\n';
	if (!(await Service.write({path:file, content:next})).success) throw new Error('repo.json');
	return next;
}

function combine(first:CardEdit, next:CardEdit):CardEdit {
	const merged = {...first,...next};
	if (first.title && next.title) merged.title = {...first.title,...next.title};
	if (first.description && next.description) merged.description = {...first.description,...next.description};
	return merged;
}

// One writer per open project. Edits that arrive during an upload form the next batch.
export class ProjectCardWriter {
	private pending?: CardEdit;
	private writing?: Promise<boolean>;
	private timer?: ReturnType<typeof setTimeout>;
	constructor(readonly root:string, private original:string,
		private status:(state:'pending'|'saved'|'error'|'conflict', cover?:File)=>void) {}
	get unsaved() {return Boolean(this.pending || this.writing);}
	edit(change:CardEdit) {
		this.pending = combine(this.pending ?? {}, change);
		this.status('pending');
		clearTimeout(this.timer);
		this.timer = setTimeout(() => void this.flush(), 450);
	}
	flush():Promise<boolean> {
		clearTimeout(this.timer);
		if (this.writing) return this.writing;
		if (!this.pending) return Promise.resolve(true);
		this.writing = this.drain().finally(() => {this.writing = undefined;});
		return this.writing;
	}
	private async drain() {
		while (this.pending) {
			const batch = this.pending;
			this.pending = undefined;
			try {
				this.original = await saveProjectCard(this.root, this.original, batch);
			} catch (error) {
				this.pending = combine(batch, this.pending ?? {});
				this.status(error instanceof Error && error.message === 'changed' ? 'conflict' : 'error');
				return false;
			}
			this.status(this.pending ? 'pending' : 'saved', batch.cover);
		}
		return true;
	}
}
