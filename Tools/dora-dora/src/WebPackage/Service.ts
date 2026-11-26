import * as Service from '../Service';
import type {AndroidArchiveRequest, AndroidArchiveResponse} from './AndroidArchiveWorker';
import type {AndroidExportOptions} from './AndroidExportOptions';
import Info from '../Info';
import {projectNeedsGodot} from './GodotDependency';
import {downloadBlob} from './Download';
import {toUrlPath} from '../PathUtils';
import {strToU8} from 'fflate';
import {createWebArchive, digest, readProjectZip, runtimeFiles, godotRuntimeFiles, type PackageFiles, type WebPackageFormat} from './Archive';

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


async function requestWorkspaceFile(filename: string, writablePath: string, timeout = 120000): Promise<Response> {
  const relative = toUrlPath(Info.path.relative(writablePath, filename), Info.path);
  const url = Service.addr('/' + relative.split('/').map(encodeURIComponent).join('/'));
  const response = await fetch(url, {signal: AbortSignal.timeout(timeout)});
  if (!response.ok) throw new Error(`Download failed: ${response.status}`);
  return response;
}

export async function downloadWorkspaceFile(filename: string, writablePath: string, title: string) {
  downloadBlob(await (await requestWorkspaceFile(filename, writablePath)).blob(), title);
}

export async function packageDirectory(directory: string, writablePath: string, title: string, obfuscated: boolean) {
  const id = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  const zipFile = Info.path.join(writablePath, '.download', `export-${id}.zip`);
  try {
    const result = await Service.zip({path: directory, zipFile, obfuscated});
    if (!result.success) throw new Error('export.failed');
    const suffix = obfuscated ? '-obfuscated.zip' : '.zip';
    downloadBlob(await (await requestWorkspaceFile(zipFile, writablePath)).blob(), `${title}${suffix}`);
  } finally {
    await Service.deleteFile({path: zipFile}).catch(() => undefined);
  }
}

export interface AndroidDownloads {
  apk: Blob;
  store?: Blob;
  packageName: string;
  versionCode: number;
}

function buildAndroidArchive(request: AndroidArchiveRequest) {
  const worker = new Worker(new URL('./AndroidArchiveWorker.ts', import.meta.url), {type: 'module'});
  return new Promise<AndroidArchiveSuccess>((resolve, reject) => {
    const fail = (message: string) => {
      worker.terminate();
      reject(new Error(message));
    };
    worker.onerror = () => fail('Could not run the Android packager');
    worker.onmessage = ({data}: MessageEvent<AndroidArchiveResponse>) => {
      if ('error' in data) return fail(data.error);
      worker.terminate();
      resolve(data);
    };
    try {
      worker.postMessage(request, request.key ? [request.key] : []);
    } catch (error) {
      fail(error instanceof Error ? error.message : String(error));
    }
  });
}

type AndroidArchiveSuccess = Extract<AndroidArchiveResponse, {apk: Blob}>;

export async function packageNativeProject(directory: string, writablePath: string, format: Service.NativeGameFormat, android?: AndroidExportOptions): Promise<AndroidDownloads | true | undefined> {
  const result = await Service.exportNativeGame(directory, format);
  if (!result.success) throw new Error(result.message || 'export.failed');
  if (format === 'android' && !result.archive) return true;
  if (!result.archive) throw new Error('export.failed');
  try {
    if (format === 'android') {
      if (!result.apk || !android) throw new Error('export.failed');
      const [template, project, key] = await Promise.all([
        requestWorkspaceFile(result.apk, writablePath, 600000).then(response => response.blob()),
        requestWorkspaceFile(result.archive, writablePath).then(response => response.blob()),
        android.keyFile?.arrayBuffer(),
      ]);
      const {packageName, title, versionName, versionCode, password} = android;
      const {apk, store} = await buildAndroidArchive({template, project, game: {packageName, title, versionName, versionCode}, password, key, needsGodot: result.needsGodot});
      return {apk, store: store ? new Blob([store], {type: 'application/x-pkcs12'}) : undefined, packageName, versionCode};
    } else {
      await downloadWorkspaceFile(result.archive, writablePath, Info.path.basename(result.archive));
    }
  } finally {
    await Service.deleteFile({path: Info.path.dirname(result.archive)}).catch(() => undefined);
  }
}

async function loadRuntime(includeGodot: boolean): Promise<PackageFiles> {
  try {
    const base = new URL('web-player/', document.baseURI);
    const index = JSON.parse(new TextDecoder().decode(await fetchBytes(new URL('runtime.json', base).href, 65536)));
    const files: PackageFiles = Object.create(null);
    for (const file of runtimeFiles.concat(includeGodot ? godotRuntimeFiles : [], ['LICENSE-Dora.txt', 'LICENSES.3rdparty.md', 'NOTICE.txt'])) {
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
  const id = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  const zipFile = Info.path.join(writablePath, '.download', `web-package-${id}.zip`);
  try {
    const result = await Service.zip({path: projectRoot, zipFile, obfuscated: false, publishWeb: true});
    if (!result.success) throw new Error(result.message || 'webPackage.snapshotFailed');
    const relative = toUrlPath(Info.path.relative(writablePath, zipFile), Info.path);
    const bytes = await fetchBytes(Service.addr('/' + relative.split('/').map(encodeURIComponent).join('/')), 256 * 1024 * 1024);
    const project = readProjectZip(bytes);
    const includeGodot = result.needsGodot ?? projectNeedsGodot(project);
    const runtime = await loadRuntime(includeGodot);
    return await createWebArchive(project, runtime, format, includeGodot);
  } finally {
    await Service.deleteFile({path: zipFile}).catch(() => undefined);
  }
}

export function downloadWebArchive(bytes: Uint8Array, title: string, format: WebPackageFormat) {
  downloadBlob(new Blob([bytes as BlobPart], {type: 'application/zip'}), `${title}-web-${format}.zip`);
}
