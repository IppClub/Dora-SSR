import {ProjectMessageError} from './project-messages';
import { validateSnapshot, type ProjectSnapshot } from '@dora-studio/contracts';

export async function exportProject(name: string, input: ProjectSnapshot): Promise<Uint8Array> {
  if (!name.trim() || name.length > 200) throw new ProjectMessageError('projects.invalidBackupName');
  const snapshot = structuredClone(input);
  const errors = validateSnapshot(snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  if (snapshot.files.some(file => file.path === '.studio' || file.path.startsWith('.studio/'))) {
    throw new ProjectMessageError('projects.reservedBackupPath');
  }
  await import(/* @vite-ignore */ `${import.meta.env.BASE_URL}web-package.js`);
  const api = (globalThis as unknown as { DoraWebPackage: { createArchive(files: { path: string; data: Uint8Array }[]): Uint8Array } }).DoraWebPackage;
  const encoder = new TextEncoder();
  const files = snapshot.files.map(file => ({ path: file.path,
    data: file.kind === 'text' ? encoder.encode(file.text) : file.bytes }));
  const metadata = encoder.encode(JSON.stringify({
    format: 'dora-studio-project', version: 1, name, entry: snapshot.entry,
    files: snapshot.files.map(file => ({ path: file.path, kind: file.kind })),
  }, null, 2));
  if (metadata.length > 65536) throw new ProjectMessageError('projects.largeBackupMetadata');
  files.push({ path: '.studio/project.json', data: metadata });
  return api.createArchive(files);
}
