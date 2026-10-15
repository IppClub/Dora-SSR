import { isProjectPath, type ProjectFile } from '@dora-studio/contracts';

export async function appendResources(existing: readonly ProjectFile[], uploads: readonly File[]): Promise<ProjectFile[]> {
  const paths = existing.map(file => file.path);
  let total = existing.reduce((sum, file) => sum + (file.kind === 'text' ? new TextEncoder().encode(file.text).byteLength : file.bytes.byteLength), 0);
  if (existing.length + uploads.length > 4096) throw new Error('项目文件数量超过限制');
  const planned = uploads.map(file => {
    const path = `Resources/${file.name}`;
    if (!file.name || file.name.includes('/') || file.name.includes('\\') || !isProjectPath(path)) throw new Error('素材文件名无效');
    if (paths.some(value => value === path || value.startsWith(path + '/') || path.startsWith(value + '/'))) throw new Error(`素材路径冲突：${path}，请重命名后上传`);
    if (file.size > 64 * 1024 * 1024) throw new Error(`素材超过 64 MiB：${file.name}`);
    total += file.size;
    if (total > 256 * 1024 * 1024) throw new Error('项目资源总量超过 256 MiB');
    paths.push(path);
    return { file, path };
  });
  const added: ProjectFile[] = [];
  for (const { file, path } of planned) {
    const bytes = new Uint8Array(await file.arrayBuffer());
    if (bytes.byteLength !== file.size) throw new Error(`素材读取不完整：${file.name}`);
    added.push({ path, kind: 'binary', bytes });
  }
  return [...existing, ...added];
}
