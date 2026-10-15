import * as Service from '../Service';
import Info from '../Info';
import {toUrlPath} from '../PathUtils';
import {strToU8} from 'fflate';
import {createWebArchive, digest, readProjectZip, runtimeFiles, type PackageFiles, type WebPackageFormat} from './Archive';

async function fetchBytes(url: string, limit: number): Promise<Uint8Array> {
  const response = await fetch(url, {signal: AbortSignal.timeout(120000)});
  if (!response.ok || Number(response.headers.get('content-length')) > limit) throw new Error(`Download failed: ${response.status}`);
  const reader = response.body?.getReader();
  if (!reader) throw new Error('Download body is unavailable');
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    while (true) {
      const {done, value} = await reader.read();
      if (done) break;
      size += value.length;
      if (size > limit) throw new Error('Download is too large');
      chunks.push(value);
    }
  } finally {
    await reader.cancel();
  }
  const result = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) { result.set(chunk, offset); offset += chunk.length; }
  return result;
}

function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = Array.from(filename, character => (
    character.charCodeAt(0) < 32 || '<>:"/\\|?*'.includes(character) ? '_' : character
  )).join('');
  document.body.appendChild(anchor);
  anchor.click();
  anchor.remove();
  setTimeout(() => URL.revokeObjectURL(url), 60000);
}

async function readWorkspaceFile(filename: string, writablePath: string): Promise<Blob> {
  const relative = toUrlPath(Info.path.relative(writablePath, filename), Info.path);
  const url = Service.addr('/' + relative.split('/').map(encodeURIComponent).join('/'));
  const response = await fetch(url, {signal: AbortSignal.timeout(120000)});
  if (!response.ok) throw new Error(`Download failed: ${response.status}`);
  return await response.blob();
}

export async function downloadWorkspaceFile(filename: string, writablePath: string, title: string) {
  downloadBlob(await readWorkspaceFile(filename, writablePath), title);
}

export async function packageDirectory(directory: string, writablePath: string, title: string, obfuscated: boolean) {
  const id = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  const zipFile = Info.path.join(writablePath, '.download', `export-${id}.zip`);
  try {
    const result = await Service.zip({path: directory, zipFile, obfuscated});
    if (!result.success) throw new Error('export.failed');
    const suffix = obfuscated ? '-obfuscated.zip' : '.zip';
    downloadBlob(await readWorkspaceFile(zipFile, writablePath), `${title}${suffix}`);
  } finally {
    await Service.deleteFile({path: zipFile}).catch(() => undefined);
  }
}

async function loadRuntime(): Promise<PackageFiles> {
  try {
    const base = new URL('web-player/', document.baseURI);
    const index = JSON.parse(new TextDecoder().decode(await fetchBytes(new URL('runtime.json', base).href, 65536)));
    const files: PackageFiles = Object.create(null);
    for (const file of runtimeFiles.concat(['LICENSE-Dora.txt', 'LICENSES.3rdparty.md', 'NOTICE.txt'])) {
      const entry = index.files?.[file];
      if (!entry || !Number.isSafeInteger(entry.size) || entry.size <= 0 || entry.size > 128 * 1024 * 1024) throw new Error('Invalid runtime index');
      const bytes = await fetchBytes(new URL(file, base).href, entry.size);
      if (bytes.length !== entry.size || digest(bytes) !== entry.sha256) throw new Error('Runtime checksum mismatch');
      files[file] = bytes;
    }
    files['runtime.json'] = strToU8(JSON.stringify(index));
    return files;
  } catch {
    throw new Error('webPackage.runtimeUnavailable');
  }
}

export async function packageWebProject(projectRoot: string, writablePath: string, format: WebPackageFormat): Promise<Uint8Array> {
  // The runtime is distributed with the IDE. Game code never leaves the user's Dora host.
  const runtime = await loadRuntime();
  const id = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  const zipFile = Info.path.join(writablePath, '.download', `web-package-${id}.zip`);
  try {
    const result = await Service.zip({path: projectRoot, zipFile, obfuscated: false});
    if (!result.success) throw new Error('webPackage.snapshotFailed');
    const relative = toUrlPath(Info.path.relative(writablePath, zipFile), Info.path);
    const bytes = await fetchBytes(Service.addr('/' + relative.split('/').map(encodeURIComponent).join('/')), 256 * 1024 * 1024);
    return await createWebArchive(readProjectZip(bytes), runtime, format);
  } finally {
    await Service.deleteFile({path: zipFile}).catch(() => undefined);
  }
}

export function downloadWebArchive(bytes: Uint8Array, title: string, format: WebPackageFormat) {
  downloadBlob(new Blob([bytes as BlobPart], {type: 'application/zip'}), `${title}-web-${format}.zip`);
}
