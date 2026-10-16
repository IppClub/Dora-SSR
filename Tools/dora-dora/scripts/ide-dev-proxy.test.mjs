import {test} from 'node:test';
import assert from 'node:assert/strict';
import {ideDevProxy} from './ide-dev-proxy.mjs';
const proxies = Object.values(ideDevProxy());
for (const [index, proxy] of proxies.entries()) {
	test(`proxy ${index} validates source before rewriting Origin`, () => {
		const headers = {host:'localhost:3000',origin:'http://localhost:3000'};
		const request = {headers, rawHeaders:['Host',headers.host,'Origin',headers.origin],socket:{remoteAddress:'127.0.0.1',end(){throw new Error('unexpected rejection');}}};
		assert.equal(proxy.bypass(request, undefined),undefined);
		assert.equal(headers.origin,'http://127.0.0.1:8866');
	});
	for (const [host,origin] of [['evil.test:3000','http://evil.test:3000'],['localhost:3000','null'],['localhost:3000','http://localhost:3000/']]) {
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

for (const [index, proxy] of proxies.entries()) {
 for (const address of ['192.168.1.55', '::ffff:192.168.1.55']) {
  test(`proxy ${index} preserves authentication for remote peer ${address}`, () => {
   const headers={host:'localhost:3000',origin:'http://localhost:3000','sec-fetch-site':'same-origin'};
   const req={headers,rawHeaders:['Host',headers.host,'Origin',headers.origin],socket:{remoteAddress:address}};
   assert.equal(proxy.bypass(req,{}),undefined);
   assert.equal(headers.origin,'http://localhost:3000');
   assert.equal(headers['sec-fetch-site'],'cross-site');
  });
 }
 test(`proxy ${index} does not exempt an origin-less remote browser`, () => {
  const headers={host:'localhost:3000','sec-fetch-site':'same-origin'};
  proxy.bypass({headers,rawHeaders:['Host',headers.host],socket:{remoteAddress:'192.168.1.55'}},{});
  assert.equal(headers.origin,undefined);
  assert.equal(headers['sec-fetch-site'],'cross-site');
 });
 test(`proxy ${index} keeps local CLI requests authenticated`, () => {
  const headers={host:'localhost:3000'};
  proxy.bypass({headers,rawHeaders:['Host',headers.host],socket:{remoteAddress:'127.0.0.1'}},{});
  assert.equal(headers.origin,undefined);
  assert.equal(headers['sec-fetch-site'],'cross-site');
 });
}

for (const [index, proxy] of proxies.entries()) {
 test(`proxy ${index} forwards cross-origin traffic without a local exemption`, () => {
  const headers={host:'localhost:3000',origin:'https://dev.example','sec-fetch-site':'cross-site'};
  const req={headers,rawHeaders:['Host',headers.host,'Origin',headers.origin],socket:{remoteAddress:'127.0.0.1'}};
  assert.equal(proxy.bypass(req,{}),undefined);
  assert.equal(headers.origin,'https://dev.example');
  assert.equal(headers['sec-fetch-site'],'cross-site');
 });
}

for (const proxy of proxies) {
 test('engine-origin page cannot acquire a local exemption through Vite', () => {
  const headers={host:'localhost:3000',origin:'http://127.0.0.1:8866'};
  proxy.bypass({headers,rawHeaders:['Host',headers.host,'Origin',headers.origin],socket:{remoteAddress:'127.0.0.1'}},{});
  assert.equal(headers.origin,'http://127.0.0.1:8866');
  assert.equal(headers['sec-fetch-site'],'cross-site');
 });
}

for (const proxy of proxies) {
 test('local same-origin browser GET metadata survives without Origin', () => {
  const headers={host:'localhost:3000','sec-fetch-site':'same-origin'};
  proxy.bypass({headers,rawHeaders:['Host',headers.host,'Sec-Fetch-Site','same-origin'],socket:{remoteAddress:'127.0.0.1'}},{});
  assert.equal(headers.origin,undefined);
  assert.equal(headers['sec-fetch-site'],'same-origin');
 });
}
