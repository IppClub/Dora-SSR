import { readFile } from 'node:fs/promises';
import { studioCompilerResourcesPath, studioDeclarationFiles } from '../packages/compiler/dist/index.js';

export { studioCompilerResourcesPath };

export async function readStudioCompilerResources() {
  const library = new URL('../../Assets/Script/Lib/', import.meta.url);
  const declarations = await Promise.all(studioDeclarationFiles.map(async path => ({
    path, kind: 'text', text: await readFile(new URL(`Dora/en/${path}`, library), 'utf8'),
  })));
  declarations.push({
    path: 'lualib_bundle.lua', kind: 'text',
    text: await readFile(new URL('lualib_bundle.lua', library), 'utf8'),
  });
  return JSON.stringify(declarations);
}
