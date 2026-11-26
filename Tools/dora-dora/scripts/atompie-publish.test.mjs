import assert from 'node:assert/strict';
import {beforeEach, test} from 'node:test';
import {build} from 'esbuild';

// Exercise the browser client and draft store together. Only the IDE transport is replaced.
const bundle = await build({
	stdin: {contents: "export * from './src/AtomPieClient'; export * from './src/AtomPieDraft';", resolveDir:process.cwd()},
	bundle:true, format:'esm', write:false,
	plugins:[{name:'fixture-address', setup(builder) {
		builder.onResolve({filter:/^\.\/Service$/}, () => ({path:'service',namespace:'fixture'}));
		builder.onLoad({filter:/.*/,namespace:'fixture'}, () => ({contents:'export const addr = path => path;'}));
	}}],
});
const {saveDraft,loadDraft,sendForReview,publisherRequest} = await import('data:text/javascript;base64,' +
	Buffer.from(bundle.outputFiles[0].contents).toString('base64'));
const body = {title:'Fixture',short_description:'Summary',long_description:'README',version:'2.5',
	organization_id:null,repository_url:'https://github.com/example/fixture',video_url:null,tags:['demo'],
	game_metadata:{engine:'dora_ssr',play_modes:['single_player'],platforms:['pc']}};
let slot,storage,api;
const request = () => publisherRequest(1,null);
const save = (data=body) => saveDraft('draft',data,undefined,request());
const asset = (data,version) => ({...data,id:17,lock_version:version,cover_file_id:4,tags:data.tags.map(name=>({name}))});
const ok = data => ({success:true,data});
const reject = code => ({success:false,message:code,code,definitive:true});

beforeEach(()=>{
	slot='A';
	storage=new Map([['dora:atompie:browser','test'],['dora:atompie:test:A','pad-a'],['dora:atompie:test:B','pad-b']]);
	globalThis.window=new EventTarget();
	globalThis.localStorage={getItem:k=>storage.get(k) ?? null,setItem:(k,v)=>storage.set(k,v),removeItem:k=>storage.delete(k)};
	globalThis.fetch=async (_url,options)=>{
		const req=JSON.parse(options.body);
		let reply;
		if (req.action==='binding' || req.action==='restore') reply={success:true,slot};
		else if (req.slot!==slot) reply=reject('binding_changed');
		else if (req.action==='me') reply=ok({id:slot==='A'?1:2,organizations:[]});
		else reply=await api(req);
		return Response.json(reply);
	};
});

test('correcting a rejected create sends the corrected content',async()=>{
	const attempts=[];
	api=({payload})=>{
		attempts.push(payload);
		return payload.short_description.length>255 ? reject('invalid_request') : ok(asset(payload,1));
	};
	await assert.rejects(save({...body,short_description:'x'.repeat(256)}),/invalid_request/);
	await save();
	assert.deepEqual(attempts.map(a=>a.short_description.length),[256,7]);
	assert.deepEqual(loadDraft('draft').fields.tags,['demo']);
});

test('a lost create replays the original body and key before applying edits',async()=>{
	const creates=[];
	api=({action,payload})=>{
		if (action==='create') {
			creates.push(payload);
			if (creates.length===1) throw Error('connection lost');
			return ok(asset(payload,1));
		}
		assert.equal(action,'update');
		assert.equal(payload.version,'3.0');
		return ok(asset(payload,2));
	};
	await assert.rejects(save(),/connection lost/);
	await save({...body,version:'3.0'});
	assert.deepEqual(creates[0],creates[1]);
	assert.equal(loadDraft('draft').fields.version,'3.0');
});

for (const externalEdit of [false,true]) {
	test('lost update response with '+(externalEdit?'divergent remote changes':'matching remote content'),async()=>{
		let writes=0;
		let remote=asset(body,1);
		api=({action,payload})=>{
			if (action==='create') return ok(remote);
			if (action==='read') return ok(remote);
			assert.equal(action,'update');
			assert.equal(payload.expected_version,1);
			writes++;
			remote=asset({...payload,title:externalEdit?'Other edit':payload.title},2);
			throw Error('connection lost');
		};
		await save();
		const edited={...body,version:'3.0'};
		await assert.rejects(save(edited),/connection lost/);
		if (externalEdit) {
			await assert.rejects(save(edited),/我的稿件/);
			assert.equal(loadDraft('draft').asset.lock_version,1);
		} else {
			await save(edited);
			assert.equal(loadDraft('draft').asset.lock_version,2);
			assert.equal(loadDraft('draft').fields.version,'3.0');
		}
		assert.equal(writes,1);
	});
}

test('old drafts restore their platform fields before allowing a write',async()=>{
	storage.set('draft',JSON.stringify({key:'old',asset:{id:17,lock_version:1}}));
	api=({action})=>{assert.equal(action,'read');return ok(asset(body,1));};
	const {restored,draft}=await save({...body,tags:[],version:'1.0.0'});
	assert.equal(restored,true);
	assert.deepEqual(draft.fields.tags,body.tags);
	assert.deepEqual(draft.fields.game_metadata,body.game_metadata);
	assert.equal(draft.fields.version,'2.5');
});

test('switching the active slot prevents a write under another account',async()=>{
	const publish=request();
	await publish('me');
	slot='B';
	let writes=0;
	api=()=>{writes++;return ok(asset(body,1));};
	await assert.rejects(saveDraft('draft',body,undefined,publish),/账号或发布归属已更改/);
	assert.equal(writes,0);
});

test('a lost submit response retries the same review attempt',async()=>{
	const submissions=[];
	api=({action,payload})=>{
		if (action==='create') return ok(asset(body,1));
		assert.equal(action,'submit');
		submissions.push(payload);
		if (submissions.length===1) throw Error('connection lost');
		return ok({submission_id:18,revision_id:45,committed_version:2});
	};
	await save();
	await assert.rejects(sendForReview('draft',request()),/connection lost/);
	await sendForReview('draft',request());
	assert.deepEqual(submissions[1],submissions[0]);
});
