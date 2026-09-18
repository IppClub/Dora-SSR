import { defineConfig } from 'vite';
import { readFileSync } from 'node:fs';
const headers = { 'Cross-Origin-Opener-Policy': 'same-origin', 'Cross-Origin-Embedder-Policy': 'require-corp' };
const apiTarget=process.env.STUDIO_API_URL;
const tls=process.env.STUDIO_TLS_KEY&&process.env.STUDIO_TLS_CERT?{key:readFileSync(process.env.STUDIO_TLS_KEY),cert:readFileSync(process.env.STUDIO_TLS_CERT)}:undefined;
const proxy=apiTarget?{'/api':{target:apiTarget,changeOrigin:false,secure:false}}:undefined;
export default defineConfig({ publicDir: '.generated', server: { port: 8898, strictPort: true, headers, https:tls, proxy }, preview: { headers, https:tls, proxy } });
