import { defineConfig } from 'vite';
import { readFileSync } from 'node:fs';
const headers = { 'Cross-Origin-Opener-Policy': 'same-origin', 'Cross-Origin-Embedder-Policy': 'require-corp' };
const apiTarget=process.env.STUDIO_API_URL;
const tls=process.env.STUDIO_TLS_KEY&&process.env.STUDIO_TLS_CERT?{key:readFileSync(process.env.STUDIO_TLS_KEY),cert:readFileSync(process.env.STUDIO_TLS_CERT)}:undefined;
const proxy=apiTarget?{'/api':{target:apiTarget,changeOrigin:false,secure:false}}:undefined;
let engineBuild=process.env.VITE_DORA_ENGINE_BUILD;
if(!engineBuild){
  try{
    const manifest=JSON.parse(readFileSync(new URL('../../../build/studio-runtime/studio-runtime.json',import.meta.url),'utf8'));
    if(typeof manifest.engineBuild==='string'&&manifest.engineBuild)engineBuild=manifest.engineBuild;
  }catch{/* RuntimePreview reports a concrete configuration error in the UI. */}
}
export default defineConfig({ publicDir: '.generated',
  define:{'import.meta.env.VITE_DORA_ENGINE_BUILD':JSON.stringify(engineBuild??'')},
  server: { port: 8898, strictPort: true, headers, https:tls, proxy }, preview: { headers, https:tls, proxy } });
