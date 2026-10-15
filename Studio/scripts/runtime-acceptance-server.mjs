import {createServer} from 'node:https';
import {readFile} from 'node:fs/promises';
import {extname,resolve,sep} from 'node:path';

const root=resolve(process.env.STUDIO_RUNTIME_ROOT??'../build/studio-runtime');
const port=Number(process.env.STUDIO_RUNTIME_PORT??8951);
const key=await readFile(process.env.STUDIO_RUNTIME_TLS_KEY);
const cert=await readFile(process.env.STUDIO_RUNTIME_TLS_CERT);
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.wasm':'application/wasm','.json':'application/json; charset=utf-8','.data':'application/octet-stream'};
const server=createServer({key,cert},async(request,response)=>{
  response.setHeader('Cross-Origin-Opener-Policy','same-origin');
  response.setHeader('Cross-Origin-Embedder-Policy','require-corp');
  response.setHeader('Cross-Origin-Resource-Policy','cross-origin');
  response.setHeader('Cache-Control','no-store');
  if(request.method!=='GET'&&request.method!=='HEAD'){response.writeHead(405);response.end();return;}
  try{
    const path=resolve(root,'.'+new URL(request.url,'https://127.0.0.1').pathname);
    if(!path.startsWith(root+sep))throw new Error('outside runtime root');
    const content=await readFile(path);
    response.setHeader('Content-Type',types[extname(path)]??'application/octet-stream');
    response.setHeader('Content-Length',content.length);
    response.end(request.method==='HEAD'?undefined:content);
  }catch{response.writeHead(404);response.end();}
});
server.listen(port,'127.0.0.1',()=>process.stdout.write(`Studio acceptance runtime listening on https://127.0.0.1:${port}\n`));
for(const signal of ['SIGINT','SIGTERM'])process.once(signal,()=>server.close(()=>process.exit(0)));
