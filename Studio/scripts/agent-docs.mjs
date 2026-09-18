import { readFile, readdir, mkdir, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import ts from 'typescript';
import { build } from 'esbuild';

export async function buildAgentDocs(output) {
  const workspace = new URL('../../Assets/Script/Lib/Agent/Tool/Workspace.ts', import.meta.url);
  const ast = ts.createSourceFile(workspace.pathname, await readFile(workspace, 'utf8'), ts.ScriptTarget.Latest, true);
  const scope = ast.statements.find(node => ts.isFunctionDeclaration(node) && node.name?.text === 'isDoraDocFileInScope');
  if (!scope) throw new Error('Upstream document scope changed');
  const code = await build({ stdin: { contents: scope.getText(ast), loader: 'ts' }, format: 'esm', write: false });
  const { isDoraDocFileInScope } = await import(`data:text/javascript;base64,${Buffer.from(code.outputFiles[0].text).toString('base64')}`);
  async function collect(root, prefix = '') {
    const files = [];
    for (const item of (await readdir(new URL(prefix, root), { withFileTypes: true })).sort((a, b) => a.name.localeCompare(b.name, 'en'))) {
      const path = prefix + item.name;
      if (item.isSymbolicLink()) throw new Error(`Document symlink needs review: ${path}`);
      if (item.isDirectory()) files.push(...await collect(root, path + '/'));
      else if (item.isFile()) files.push(path);
    }
    return files;
  }
  await mkdir(output, { recursive: true });
  for (const [language, directory] of [['en', 'en'], ['zh', 'zh-Hans']]) {
    const documents = [];
    for (const [rootPath, types] of [
      [`../../Assets/Script/Lib/Dora/${directory}/`, ['dora-api', 'love-api', 'tic80-api']],
      [`../../Assets/Doc/${directory}/Tutorial/`, ['dora-tutorial']]
    ]) {
      const root = new URL(rootPath, import.meta.url);
      for (const file of await collect(root)) for (const type of types) {
        if (!isDoraDocFileInScope(type, file)) continue;
        const bytes = await readFile(new URL(file, root));
        documents.push({ path: `@dora-doc/${type}/${file}`, text: new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(bytes),
          sha256: createHash('sha256').update(bytes).digest('hex') });
      }
    }
    await writeFile(new URL(`${language}.json`, output), JSON.stringify({ version: 1, language, documents }));
  }
}
