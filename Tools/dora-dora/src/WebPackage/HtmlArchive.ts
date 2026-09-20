import {strFromU8, strToU8} from 'fflate';
import type {PackageFiles} from './Archive';
import {htmlPlayer} from './HtmlPlayer';
import {prepareHtmlRuntime} from './RuntimeAdapter';

function base64(bytes: Uint8Array): string {
  const chunks: string[] = [];
  for (let offset = 0; offset < bytes.length; offset += 32768) {
    chunks.push(String.fromCharCode(...bytes.subarray(offset, offset + 32768)));
  }
  return btoa(chunks.join(''));
}

// Convert the validated HTTP package without changing the engine or its manifest protocol.
export function createHtmlFiles(input: PackageFiles, digest: (bytes: Uint8Array) => string): PackageFiles {
  const output = {...input};
  const manifest = JSON.parse(strFromU8(input['dora-web-manifest.json']));
  output['dora-player-runtime.js'] = prepareHtmlRuntime(input['dora-player-runtime.js']);
  const records: Record<string, {script: string; size: number; sha256: string}> = Object.create(null);
  const names = ['dora-player-runtime.wasm', 'dora-player-runtime.data', 'dora-audio-mixer.wasm', 'audio-worklet.js',
    ...manifest.files.map((file: {url: string}) => decodeURIComponent(file.url))];
  for (const [index, name] of names.entries()) {
    const bytes = input[name];
    const script = `html-assets/${index}.js`;
    records[name] = {script, size: bytes.length, sha256: digest(bytes)};
    output[script] = strToU8(`DoraHtmlPackage.deliver(${JSON.stringify(name)},"${base64(bytes)}");\n`);
    delete output[name];
  }
  output['html-loader.js'] = strToU8(`(${htmlPlayer})(${JSON.stringify({manifest, records})});\n`);
  // The manifest is delivered through Module.doraSnapshot, not fetched from disk.
  delete output['dora-web-manifest.json'];
  output['README-Web.txt'] = strToU8('Web (HTML)\n\n完整解压 ZIP 后，双击根目录 index.html 即可启动，无需 HTTP Server。请保留所有配套文件，使用支持 WebAssembly 的现代浏览器。\n也可将整个目录部署到静态网站。资源编码为本地 JavaScript，启动时读入内存；包体积会增加，不适合超大资源项目。\n\nExtract the entire ZIP and open index.html directly; no HTTP server is required. Keep all accompanying files. A modern WebAssembly-capable browser is required. The directory can also be hosted on a static website. Assets are encoded as local JavaScript and loaded into memory at startup, increasing package size.\n');
  const metadata = JSON.parse(strFromU8(input['runtime.json']));
  output['runtime.json'] = strToU8(JSON.stringify({...metadata, format: 'html', files: Object.fromEntries(
    Object.entries(output).filter(([name]) => name !== 'runtime.json').map(([name, bytes]) => [name, {size: bytes.length, sha256: digest(bytes)}])
  )}));
  return output;
}
