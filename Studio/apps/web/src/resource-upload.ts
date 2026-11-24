import {ProjectMessageError} from './project-messages';
import { isProjectPath, type ProjectFile } from '@dora-studio/contracts';

export async function appendResources(existing: readonly ProjectFile[], uploads: readonly File[]): Promise<ProjectFile[]> {
  const paths = existing.map(file => file.path);
  let total = existing.reduce((sum, file) => sum + (file.kind === 'text' ? new TextEncoder().encode(file.text).byteLength : file.bytes.byteLength), 0);
  if (existing.length + uploads.length > 4096) throw new ProjectMessageError('projects.fileLimit');
  const planned = uploads.map(file => {
    const path = `Resources/${file.name}`;
    if (!file.name || file.name.includes('/') || file.name.includes('\\') || !isProjectPath(path)) throw new ProjectMessageError('projects.invalidAssetName');
    if (paths.some(value => value === path || value.startsWith(path + '/') || path.startsWith(value + '/'))) throw new ProjectMessageError('projects.assetPathConflict', {path: path});
    if (file.size > 64 * 1024 * 1024) throw new ProjectMessageError('projects.assetTooLarge', {name: file.name});
    total += file.size;
    if (total > 256 * 1024 * 1024) throw new ProjectMessageError('projects.assetTotalLimit');
    paths.push(path);
    return { file, path };
  });
  const added: ProjectFile[] = [];
  for (const { file, path } of planned) {
    const bytes = new Uint8Array(await file.arrayBuffer());
    if (bytes.byteLength !== file.size) throw new ProjectMessageError('projects.assetReadIncomplete', {name: file.name});
    added.push({ path, kind: 'binary', bytes });
  }
  return [...existing, ...added];
}
