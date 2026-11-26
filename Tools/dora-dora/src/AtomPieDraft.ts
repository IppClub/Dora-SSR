import { sha256 } from '@noble/hashes/sha2.js';
import { bytesToHex } from '@noble/hashes/utils.js';
import { fileBase64, randomId, isDefinitive, type DraftRequest } from './AtomPieClient';

export interface SubmissionData {
	title:string; short_description:string; long_description:string; repository_url:string;
	version:string; video_url:string | null; tags:string[];
	game_metadata:{engine:string; play_modes:string[]; platforms:string[]};
}
export type PlatformFields = Pick<SubmissionData,'version'|'tags'|'video_url'|'repository_url'|'game_metadata'>;
interface Asset extends Omit<SubmissionData,'tags'> {
	tags:{name:string}[]; organization_id:number | null;
	id:number; lock_version:number; cover_file_id?:number | null;
	pending_submission?:{id:number;revision_id:number} | null;
}
export interface Receipt {submission_id:number; revision_id:number; committed_version:number}
type Content = SubmissionData & {organization_id:number | null};
interface Draft {
	key:string; initial?:Content; asset?:Pick<Asset,'id'|'lock_version'|'cover_file_id'>;
	fields?:PlatformFields; updateAttempt?:{hash:string; fields:PlatformFields}; contentHash?:string; coverHash?:string; review?:{idempotency_key:string; expected_version:number}; receipt?:Receipt;
}
const digest = (data:string) => bytesToHex(sha256(new TextEncoder().encode(data)));
export const draftKey = (project:string,language:string,user:number,org:number | null) =>
	'dora:atompie:draft:' + digest(JSON.stringify([project,language,user,org]));
export function loadDraft(key:string):Draft {
	const saved = localStorage.getItem(key);
	return saved ? JSON.parse(saved) : {key:randomId()};
}
function persist(key:string, draft:Draft) {
	localStorage.setItem(key,JSON.stringify(draft));
}
function remember(draft:Draft, asset:Asset) {
	if (!asset.id || !Number.isInteger(asset.lock_version)) throw new Error('无法读取稿件版本。');
	draft.asset = {id:asset.id,lock_version:asset.lock_version,cover_file_id:asset.cover_file_id};
}

function platformFields(body:SubmissionData):PlatformFields {
	const {version,tags,video_url,repository_url,game_metadata} = body;
	return {version,tags,video_url,repository_url,game_metadata};
}

function remoteContent(asset:Asset):Content {
	const {title,short_description,long_description,version,repository_url,video_url,organization_id} = asset;
	const metadata = asset.game_metadata;
	return {title,short_description,long_description:long_description ?? '',version:version ?? '',
		repository_url:repository_url ?? '',video_url:video_url ?? null,organization_id,
		tags:asset.tags.map(tag=>tag.name), game_metadata:{engine:metadata?.engine ?? '',
			play_modes:metadata?.play_modes ?? [],platforms:metadata?.platforms ?? []}};
}

function fingerprint(body:Content) {
	const {title,short_description,long_description,repository_url,version,video_url,organization_id,tags,game_metadata} = body;
	return digest(JSON.stringify([title,short_description,long_description.trim(),repository_url,version,video_url,organization_id,
		[...tags].sort(),game_metadata.engine,[...game_metadata.play_modes].sort(),[...game_metadata.platforms].sort()]));
}

const conflict = () => new Error('稿件已在原子派更改，请到「我的稿件」核对后继续编辑。');

export async function saveDraft(key:string, body:Content, cover:File | undefined, request:DraftRequest) {
	const draft = loadDraft(key);
	let baseline = localStorage.getItem(key);
	function checkpoint() {
		if (baseline !== localStorage.getItem(key)) throw new Error('草稿已在其他窗口更改，请重新打开发布页。');
		persist(key,draft);
		baseline = localStorage.getItem(key);
	}
	if (draft.review) throw new Error('上次送审结果尚未确认，请重试送审。');
	if (draft.asset && (draft.receipt || draft.updateAttempt || !draft.fields)) {
		const latest = await request<Asset>('read',{},draft.asset.id);
		if (latest.id !== draft.asset.id || !Number.isInteger(latest.lock_version)) throw conflict();
		if (latest.pending_submission) throw new Error('稿件正在审核中，请到「我的稿件」查看。');
		const remote = remoteContent(latest);
		if (draft.receipt) {
			if (latest.lock_version !== draft.receipt.committed_version + 1) throw conflict();
			delete draft.receipt;
		} else if (latest.lock_version !== draft.asset.lock_version) {
			// Only adopt an unacknowledged write if both its contents and its one-step revision match.
			if (latest.lock_version !== draft.asset.lock_version+1 || fingerprint(remote) !== draft.updateAttempt?.hash ||
				(latest.cover_file_id ?? null) !== (draft.asset.cover_file_id ?? null)) throw conflict();
			draft.contentHash = draft.updateAttempt!.hash;
			draft.fields = draft.updateAttempt!.fields;
		}
		delete draft.updateAttempt;
		remember(draft,latest);
		if (!draft.fields) {
			// Older IDEs retained just an ID and hash. Show the actual values before the first write.
			draft.fields = platformFields(remote);
			draft.contentHash = fingerprint(remote);
			checkpoint();
			return {draft,restored:true};
		}
		checkpoint();
	}
	if (!draft.asset) {
		draft.initial ??= body;
		checkpoint();
		try {
			remember(draft,await request<Asset>('create',{...draft.initial,idempotency_key:draft.key}));
		} catch (error) {
			if (isDefinitive(error)) {
				delete draft.initial;
				checkpoint();
			}
			throw error;
		}
		draft.contentHash = fingerprint(draft.initial);
		draft.fields = platformFields(draft.initial);
		delete draft.initial;
		checkpoint();
	}
	const contentHash = fingerprint(body);
	if (draft.contentHash !== contentHash) {
		draft.updateAttempt = {hash:contentHash,fields:platformFields(body)};
		checkpoint();
		remember(draft,await request<Asset>('update',{...body,expected_version:draft.asset!.lock_version},draft.asset!.id));
		draft.contentHash = contentHash;
		delete draft.updateAttempt;
		draft.fields = platformFields(body);
		checkpoint();
	}
	if (cover) {
		const coverHash = bytesToHex(sha256(new Uint8Array(await cover.arrayBuffer())));
		if (draft.coverHash !== coverHash) {
			const response = await request<Asset>('cover',{expected_version:draft.asset!.lock_version,
				expected_file_id:draft.asset!.cover_file_id ?? null,content_type:cover.type,data_base64:await fileBase64(cover)},draft.asset!.id);
			remember(draft,response);
			draft.coverHash = coverHash;
			checkpoint();
		}
	}
	return {draft,restored:false};
}

export async function sendForReview(key:string, request:DraftRequest) {
	const draft = loadDraft(key);
	if (!draft.asset) throw new Error('请先保存稿件。');
	if (draft.receipt) return draft;
	draft.review ??= {idempotency_key:randomId(),expected_version:draft.asset.lock_version};
	persist(key,draft);
	try {
		const receipt = await request<Receipt>('submit',draft.review,draft.asset.id);
		if (!receipt.submission_id || !Number.isInteger(receipt.committed_version)) throw new Error('未收到审核回执。');
		draft.receipt = receipt;
		delete draft.review;
	} catch (error) {
		// Keep the same attempt for uncertain network outcomes. Definitive application
		// rejections can be corrected and sent as a new version.
		if (isDefinitive(error)) delete draft.review;
		persist(key,draft);
		throw error;
	}
	persist(key,draft);
	return draft;
}
