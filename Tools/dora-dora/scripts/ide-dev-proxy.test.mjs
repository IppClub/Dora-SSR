import {test} from 'node:test';
import assert from 'node:assert/strict';
import {ideDevProxy} from './ide-dev-proxy.mjs';
const proxies = Object.values(ideDevProxy());
for (const [index, proxy] of proxies.entries()) {
	test(`proxy ${index} validates source before rewriting Origin`, () => {
		const headers = {host:'localhost:3000',origin:'http://localhost:3000'};
		const request = {headers, rawHeaders:['Host',headers.host,'Origin',headers.origin],socket:{end(){throw new Error('unexpected rejection');}}};
		assert.equal(proxy.bypass(request, undefined),undefined);
		assert.equal(headers.origin,'http://127.0.0.1:8866');
	});
	for (const [host,origin] of [['localhost:3000','http://evil.test'],['evil.test:3000','http://evil.test:3000'],['localhost:3000','null'],['localhost:3000','https://localhost:3000'],['localhost:3000','http://localhost:3000/']]) {
		test(`proxy ${index} rejects ${host} from ${origin}`, () => {
			let response='';const req={headers:{host,origin},rawHeaders:['Host',host,'Origin',origin],socket:{end(text){response=text;}}};
			assert.equal(proxy.bypass(req,undefined),'/__dora_rejected');assert.match(response,/403 Forbidden/);assert.equal(req.headers.origin,origin);
		});
	}
	test(`proxy ${index} rejects duplicate origins and returns HTTP 403`,()=>{
		const req={headers:{host:'localhost:3000',origin:'http://localhost:3000'},rawHeaders:['Host','localhost:3000','Origin','http://localhost:3000','Origin','http://evil.test']};
		const res={statusCode:200,end(){this.ended=true;}};proxy.bypass(req,res);assert.equal(res.statusCode,403);assert.equal(res.ended,true);
	});
}
test('proxy paths preserve engine targets and signed WebSocket queries',()=>{
	assert.equal(proxies[0].rewrite('/__dora/api/auth?x=1'),'/auth?x=1');
	assert.equal(proxies[1].rewrite('/__dora/ws?session=a&sig=b'),'/?session=a&sig=b');
	assert.equal(proxies[0].target,'http://127.0.0.1:8866');assert.equal(proxies[1].target,'ws://127.0.0.1:8868');
});

test('default HTTP port is normalized without allowing malformed authorities',()=>{
 const proxy=proxies[0];
 const headers={host:'localhost:80',origin:'http://localhost'};
 assert.equal(proxy.bypass({headers,rawHeaders:['Host',headers.host,'Origin',headers.origin]},{}),undefined);
});
