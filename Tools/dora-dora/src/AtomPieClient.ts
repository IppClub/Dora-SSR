import { addr } from './Service';

const prefix = 'dora:atompie:';
const bindingKey = prefix + 'browser';
export const randomId = (size = 16) => Array.from(crypto.getRandomValues(new Uint8Array(size)),
	byte => byte.toString(16).padStart(2, '0')).join('');

function clientId() {
	let id = localStorage.getItem(bindingKey);
	if (!id) {
		id = randomId(32);
		localStorage.setItem(bindingKey, id);
	}
	return id;
}

type Reply<T = unknown> = {
	success: boolean; definitive?:boolean; code?: string; message?: string; slot?: string; status?: string;
	user_code?: string; verification_uri?: string; interval?: number; expires_in?: number; data: T;
};

class BrokerError extends Error {
	constructor(message: string, readonly code?: string, readonly definitive=false) {super(message);}
}

async function call<T = unknown>(action: string, fields: object = {}): Promise<Reply<T>> {
	const response = await fetch(addr('/atompie'), {
		method:'POST', headers:{'Content-Type':'application/json'}, cache:'no-store',
		body:JSON.stringify({client:clientId(), action, ...fields}),
	});
	if (!response.ok) throw new Error('Dora 原子派服务不可用，请检查引擎版本和连接。');
	const result = await response.json() as Reply<T>;
	if (!result.success) throw new BrokerError(result.message || '原子派请求失败。', result.code, result.definitive);
	return result;
}

const padKey = (slot:string) => prefix + clientId() + ':' + slot;

async function credential() {
	const id = clientId();
	const {slot} = await call('binding');
	if (!slot) return;
	const pad = localStorage.getItem(padKey(slot));
	if (!pad) {
		if (clientId() === id) localStorage.setItem(bindingKey, randomId(32));
		return;
	}
	return {slot,pad};
}

async function issue(action:'poll'|'restore', previous?:{slot:string; pad:string}, user_code?:string) {
	const slot = randomId();
	const pad = randomId(512);
	// Persist before exchange. A lost HTTP response must not strand a rotated grant.
	localStorage.setItem(padKey(slot), pad);
	try {
		const result = await call(action, {...previous, user_code, new_slot:slot, new_pad:pad});
		if (result.slot !== slot) localStorage.removeItem(padKey(slot));
		else if (previous) localStorage.removeItem(padKey(previous.slot));
		return result;
	} catch (error) {
		// Only discard our candidate after confirming the engine did not commit it.
		const state = await call('binding').catch(() => undefined);
		if (state && state.slot !== slot) localStorage.removeItem(padKey(slot));
		throw error;
	}
}

const wait = (ms:number) => new Promise<void>(resolve => window.setTimeout(resolve, ms));
async function withBinding<T>(run: () => Promise<T>): Promise<T> {
	for (let attempt=0; ; attempt++) {
		try {return await run();}
		catch (error) {
			if (attempt >= 4 || !(error instanceof BrokerError) || !['busy','binding_changed','refresh_needed'].includes(error.code ?? '')) throw error;
			await wait(180 * (attempt + 1));
		}
	}
}

export interface Profile {
	id:number; email:string; full_name?:string; can_publish:boolean;
}
export interface Account extends Profile { organizations:{id:number; name:string}[]}
export interface Grant {user_code:string; url:string; expires:number; interval:number}

export async function startAuthorization():Promise<Grant> {
	const reply = await call('start');
	const url = new URL(reply.verification_uri ?? '');
	if (url.origin !== 'https://atompie.osgame.org' || url.pathname !== '/dora/authorize' || !reply.user_code) {
		throw new Error('原子派返回了无效的授权地址。');
	}
	return {user_code:reply.user_code,url:url.href,expires:Date.now()+(reply.expires_in ?? 600)*1000,interval:reply.interval ?? 5};
}
export const pollAuthorization = (code:string) => withBinding(() => issue('poll',undefined,code));
export const cancelAuthorization = (code:string) => call('cancel',{user_code:code});

async function restoredCredential() {
	const before = await credential();
	if (!before) throw new BrokerError('请连接原子派账号。','disconnected');
	const {slot} = await issue('restore',before);
	const pad = slot && localStorage.getItem(padKey(slot));
	if (!slot || !pad) throw new BrokerError('授权已更改，请重试。','binding_changed');
	return {slot,pad};
}

export function isDefinitive(error:unknown) {
	return error instanceof BrokerError && error.definitive;
}

export function readAccount() {
	return withBinding(async ():Promise<Account | undefined> => {
		if (!(await credential())) return;
		return (await call<Account>('me',await restoredCredential())).data;
	});
}

// Validate the publisher on the same broker slot used by the write. A rotation
// retries identification; a switch of account must never migrate the operation.
export type DraftRequest = <T>(action:string, payload?:object, id?:number)=>Promise<T>;
export function publisherRequest(userId:number, organization:number | null):DraftRequest {
	let verifiedSlot:string | undefined;
	return <T>(action:string, payload:object = {}, id?:number) => withBinding(async () => {
		const binding = await restoredCredential();
		if (binding.slot !== verifiedSlot || action === 'me') {
			const {data:user} = await call<Account>('me',binding);
			if (user.id !== userId || (organization !== null && !user.organizations.some(org=>org.id === organization))) {
				window.dispatchEvent(new Event('atompie-account'));
				throw new Error('原子派账号或发布归属已更改，请重新确认。');
			}
			verifiedSlot = binding.slot;
			if (action === 'me') return user as T;
		}
		const result = await call<T>(action,{...binding,id,payload});
		if (action === 'disconnect') localStorage.removeItem(padKey(binding.slot));
		return result.data;
	});
}

export function announceAccountChange() {
	localStorage.setItem(prefix+'account-change',randomId());
	window.dispatchEvent(new Event('atompie-account'));
}
export function isAccountChange(event:StorageEvent) {
	return event.key === null || event.key === bindingKey || event.key === prefix+'account-change';
}

export function fileBase64(file:Blob):Promise<string> {
	return new Promise((resolve,reject) => {
		const reader = new FileReader();
		reader.onerror = () => reject(new Error('读取封面失败。'));
		reader.onload = () => resolve(String(reader.result).split(',')[1]);
		reader.readAsDataURL(file);
	});
}
