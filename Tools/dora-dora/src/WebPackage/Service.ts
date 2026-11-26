import * as Service from '../Service';
import type {AndroidExportOptions} from './AndroidExportOptions';
import Info from '../Info';
import {downloadBlob} from './Download';
import {toUrlPath} from '../PathUtils';

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

async function encodeKey(key: File) {
  if (key.size > 1024 * 1024) throw new Error('export.androidKeyInvalid');
  const bytes = new Uint8Array(await key.arrayBuffer());
  const parts: string[] = [];
  for (let offset = 0; offset < bytes.length; offset += 32768) {
    parts.push(String.fromCharCode(...bytes.subarray(offset, offset + 32768)));
  }
  return btoa(parts.join(''));
}

export async function packageGame(directory: string, writablePath: string, title: string, format: Service.GamePackageFormat, android?: AndroidExportOptions): Promise<AndroidDownloads | true | undefined> {
  const signing = android && {
    game: {title: android.title, packageName: android.packageName, versionName: android.versionName, versionCode: android.versionCode},
    password: android.password,
    key: android.keyFile ? await encodeKey(android.keyFile) : undefined,
  };
  const result = await Service.exportGame(directory, format, signing);
  if (!result.success) throw new Error(result.message || 'export.failed');
  if (format === 'android' && !result.archive && !android) return true;
  if (!result.archive) throw new Error('export.failed');
  try {
    if (android) {
      const apk = await (await requestWorkspaceFile(result.archive, writablePath, 600000)).blob();
      const store = result.signingKey
        ? new Blob([Uint8Array.from(atob(result.signingKey), character => character.charCodeAt(0))], {type: 'application/x-pkcs12'})
        : undefined;
      return {apk, store, packageName: android.packageName, versionCode: android.versionCode};
    }
    const name = format === 'windows' ? Info.path.basename(result.archive) : `${title}-web-${format}.zip`;
    await downloadWorkspaceFile(result.archive, writablePath, name);
  } finally {
    await Service.deleteFile({path: Info.path.dirname(result.archive)}).catch(() => undefined);
  }
}
