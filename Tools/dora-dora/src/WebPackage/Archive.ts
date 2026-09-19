import {strToU8, strFromU8, unzipSync, zip} from 'fflate';
import {sha256} from '@noble/hashes/sha2.js';
import {bytesToHex} from '@noble/hashes/utils.js';

export type PackageFiles = Record<string, Uint8Array>;
export const runtimeFiles = ['index.html', 'dora-player-runtime.js', 'dora-player-runtime.wasm', 'dora-player-runtime.data', 'dora-web-features.json', 'audio-worklet.js', 'dora-audio-mixer.wasm', 'dora-logo.png'];
const maxFileBytes = 64 * 1024 * 1024;
const maxTotalBytes = 256 * 1024 * 1024;

function brandPlayerShell(bytes: Uint8Array): Uint8Array {
  const shell = strFromU8(bytes);
  const content = '<div id="status-content">';
  if (!shell.includes(content) || !shell.includes('</head>')) throw new Error('Unsupported Web player shell');
  const style = `<style>
    #engine-brand { display: flex; flex-direction: column; align-items: center; gap: 16px; margin-bottom: 28px; }
    #engine-logo { display: block; width: 128px; height: 128px; object-fit: contain; }
    #engine-name { font: 600 28px/1.2 system-ui, sans-serif; letter-spacing: .4px; color: #f1f5fa; }
    #status-message { font-size: 12px; line-height: 1.6; color: #aeb6bf; overflow-wrap: anywhere; }
    @media (max-height: 360px) { #engine-brand { gap: 8px; margin-bottom: 12px; } #engine-logo { width: 80px; height: 80px; } }
  </style>`;
  const brand = '<div id="engine-brand"><img id="engine-logo" src="dora-logo.png" alt="" width="128" height="128"><div id="engine-name">Dora SSR</div></div>';
  return strToU8(shell.replace('</head>', style + '</head>').replace(content, content + brand));
}

function validatePath(name: string) {
  if (!name || /[\\\x00-\x1f]/.test(name) || /^[A-Za-z]:/.test(name)
    || name.split('/').some(part => !part || part === '.' || part === '..')) {
    throw new Error(`Invalid package path: ${name}`);
  }
}

function allowed(name: string) {
  return !name.split('/').some(part => part.startsWith('.') || ['node_modules', '__MACOSX'].includes(part))
    && !/(?:^|\/)(?:credentials\.json|config\.db)$|\.log$/i.test(name);
}

export function readProjectZip(bytes: Uint8Array): PackageFiles {
  if (bytes.length > maxTotalBytes) throw new Error('Project archive is too large');
  let total = 0;
  let count = 0;
  return unzipSync(bytes, {filter(file) {
    if (file.name.endsWith('/')) return false;
    validatePath(file.name);
    if (!allowed(file.name)) return false;
    total += file.originalSize;
    if (++count > 4096 || file.originalSize > maxFileBytes || total > maxTotalBytes) {
      throw new Error('Project archive is too large');
    }
    return true;
  }});
}

export function digest(bytes: Uint8Array): string {
  // Also works when the IDE is reached over a device's LAN HTTP address.
  return bytesToHex(sha256(bytes));
}

export async function createWebArchive(project: PackageFiles, runtime: PackageFiles): Promise<Uint8Array> {
  for (const file of runtimeFiles) {
    if (!runtime[file]?.length) throw new Error(`Missing Web runtime file: ${file}`);
  }
  const features = JSON.parse(strFromU8(runtime['dora-web-features.json']));
  if (features.activeProfile !== 'dora-preset' || features.modules?.threads || features.modules?.crossOriginIsolationRequired) {
    throw new Error('Unsupported Web runtime profile');
  }
  const metadata = JSON.parse(strFromU8(runtime['runtime.json'] || new Uint8Array()));
  if (!/^\d+\.\d+\.\d+$/.test(metadata.engineVersion)) throw new Error('Invalid Web runtime version');
  const output: PackageFiles = {...runtime};
  output['index.html'] = brandPlayerShell(runtime['index.html']);
  output['runtime.json'] = strToU8(JSON.stringify({...metadata, files: {...metadata.files,
    'index.html': {size: output['index.html'].length, sha256: digest(output['index.html'])},
  }}));
  let total = 0;
  const files = Object.keys(project).sort().filter(name => {
    validatePath(name);
    return allowed(name);
  }).map(name => {
    const bytes = project[name];
    total += bytes.length;
    if (bytes.length > maxFileBytes || total > maxTotalBytes) throw new Error('Project is too large');
    const hash = digest(bytes);
    const asset = `assets/${hash}/${name}`;
    output[asset] = bytes;
    return {path: name, url: asset.split('/').map(encodeURIComponent).join('/'), size: bytes.length, sha256: hash, startup: true};
  });
  if (files.length > 4096) throw new Error('Too many project files');
  if (!files.some(file => file.path === 'init.lua')) throw new Error('Missing compiled Web entry: init.lua');
  const manifest = JSON.stringify({format: 'dora-web-game', version: 1, engineVersion: metadata.engineVersion, profile: 'dora-preset', entry: 'init.lua', files}, null, 2);
  if (strToU8(manifest).length > 1024 * 1024) throw new Error('Project manifest is too large');
  output['dora-web-manifest.json'] = strToU8(manifest);
  output['README-Web.txt'] = strToU8('Web 游戏 / Web game\n\n将整个目录部署到静态网站，通过 HTTPS 或 localhost 打开 index.html。\nDeploy this entire directory to a static web host and open index.html over HTTPS or localhost.\n不能通过 file:// 双击运行。 / Opening index.html directly via file:// is not supported.\n');
  return new Promise((resolve, reject) => zip(output, {level: 6}, (error, data) => error ? reject(error) : resolve(data)));
}
