import {test} from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import net from 'node:net';
import {createServer} from 'vite';
import {ideDevProxy} from './ide-dev-proxy.mjs';

test('Vite validates HTTP/WS sources and preserves signed upstream targets', {timeout:15000}, async()=>{
	const received=[];
	const backend=http.createServer((req,res)=>{received.push({url:req.url,headers:req.headers});res.end('ok');});
	backend.on('upgrade',(req,socket)=>{
		received.push({url:req.url,headers:req.headers});
		socket.end('HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n');
	});
	await new Promise(resolve=>backend.listen(0,'127.0.0.1',resolve));
	const proxies=ideDevProxy();
	for(const options of Object.values(proxies)) options.target=`http://127.0.0.1:${backend.address().port}`;
	const vite=await createServer({configFile:false,root:import.meta.dirname,server:{port:0,host:'127.0.0.1',proxy:proxies},logLevel:'silent'});
	try {
		await vite.listen();const port=vite.httpServer.address().port;
		const origin=`http://127.0.0.1:${port}`;
		let response=await fetch(`${origin}/__dora/api/read?x=1`,{method:'POST',headers:{Origin:origin,'X-Dora-Signature':'unchanged'},body:'{}'});
		assert.equal(response.status,200);assert.equal(await response.text(),'ok');
		assert.equal(received[0].url,'/read?x=1');assert.equal(received[0].headers.origin,'http://127.0.0.1:8866');assert.equal(received[0].headers['x-dora-signature'],'unchanged');
		response=await fetch(`${origin}/__dora/api/auth`,{method:'POST',headers:{Origin:'http://evil.test'},body:'{}'});
		assert.equal(response.status,200);await response.text();assert.equal(received.length,2);assert.equal(received[1].headers.origin,'http://evil.test');
		async function upgrade(source) {
			return new Promise((resolve,reject)=>{
				const socket=net.connect(port,'127.0.0.1',()=>socket.write(`GET /__dora/ws?session=a&sig=b HTTP/1.1\r\nHost: 127.0.0.1:${port}\r\nOrigin: ${source}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n\r\n`));
				socket.setTimeout(5000,()=>{socket.destroy();reject(new Error('handshake timed out'));});
				socket.once('error',reject);socket.once('data',data=>{socket.destroy();resolve(data.toString());});
			});
		}
		assert.match(await upgrade(origin),/^HTTP\/1.1 101 /);
		assert.equal(received[2].url,'/?session=a&sig=b');assert.equal(received[2].headers.origin,'http://127.0.0.1:8866');
		assert.match(await upgrade('http://evil.test'),/^HTTP\/1.1 101 /);assert.equal(received.length,4);assert.equal(received[3].headers.origin,'http://evil.test');
	} finally {
		await vite.close();await new Promise(resolve=>backend.close(resolve));
	}
});
