import { isBuildArtifact, serializeArtifactContent, type BuildArtifact } from '@dora-studio/contracts';

const encoder = new TextEncoder();
async function digest(bytes: Uint8Array<ArrayBuffer>): Promise<string> {
  const hash = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(hash)].map(byte => byte.toString(16).padStart(2, '0')).join('');
}

/** The pinned Player currently accepts this version/profile, not arbitrary engine builds. */
export async function prepareRuntimeSnapshot(input: BuildArtifact, engineVersion: string) {
  if (!isBuildArtifact(input)) throw new Error('无效的编译产物');
  if (!/^\d+\.\d+\.\d+$/.test(engineVersion)) throw new Error('无效的 Player 引擎版本');
  // Copy before the first await so edits/caller mutation cannot race the hash.
  const artifact = structuredClone(input);
  if (await digest(encoder.encode(serializeArtifactContent(artifact))) !== artifact.sha256) {
    throw new Error('编译产物完整性校验失败，请重新编译');
  }
  const files = artifact.files.map(file => ({ path: file.path,
    bytes: file.kind === 'text' ? encoder.encode(file.text) : new Uint8Array(file.bytes) }));
  if (files.length > 4096 || files.some(file => file.bytes.byteLength > 64 * 1024 * 1024) ||
      files.reduce((total, file) => total + file.bytes.byteLength, 0) > 256 * 1024 * 1024) {
    throw new Error('项目超出当前 Web Player 的资源限制');
  }
  const manifestFiles = await Promise.all(files.map(async (file, index) => ({
    path: file.path, url: `files/${index}`, size: file.bytes.byteLength,
    sha256: await digest(file.bytes), startup: true,
  })));
  return {
    identity: { projectId: artifact.projectId, revision: artifact.revision,
      buildId: artifact.buildId, sha256: artifact.sha256 },
    manifest: { format: 'dora-web-game', version: 1, engineVersion,
      profile: 'dora-preset', entry: artifact.entry, files: manifestFiles },
    files,
  };
}
