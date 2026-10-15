import ts from 'typescript';
import { Transpiler, LuaTarget, LuaLibImportKind } from '@dora-studio/tstl';
import { compileSnapshot, doraCompilerOptions } from '@dora-studio/compiler';
import { PROTOCOL_VERSION, validateSnapshot, isProjectPath, serializeArtifactContent } from '@dora-studio/contracts';

export const COMPILER_VERSION = 'dora-tstl-0.1.0-ts5.9.3';
const root = '/project/';
const identity = r => ({ version: r.version, sessionId: r.sessionId, projectId: r.projectId,
  revision: r.revision, requestId: r.requestId, buildId: r.buildId });

function validate(r) {
  if (!r || r.type !== 'compile') throw new Error('Expected compile request');
  if (r.version !== PROTOCOL_VERSION || r.compilerVersion !== COMPILER_VERSION) throw new Error('Unsupported protocol or compiler version');
  for (const key of ['sessionId', 'projectId', 'requestId', 'buildId']) {
    if (typeof r[key] !== 'string' || !r[key].trim()) throw new Error(`Missing ${key}`);
  }
  const errors = validateSnapshot(r.snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  if (r.snapshot.projectId !== r.projectId || r.snapshot.revision !== r.revision) throw new Error('Snapshot identity mismatch');
  if (!r.options || typeof r.options !== 'object' || Array.isArray(r.options) || Object.keys(r.options).length) throw new Error('Unsupported compiler options');
  if (!Array.isArray(r.declarations)) throw new Error('Declarations must be an array');
  const paths = new Set();
  for (const file of r.declarations) {
    if (!file || !isProjectPath(file.path) || file.kind !== 'text' || typeof file.text !== 'string' || paths.has(file.path)) throw new Error('Invalid declaration file');
    paths.add(file.path);
  }
  if (!/\.(lua|tsx?)$/.test(r.snapshot.entry) || /\.d\.ts$/.test(r.snapshot.entry)) throw new Error('Unsupported entry language');
  if (r.rootNames !== undefined) {
    if (!Array.isArray(r.rootNames) || !r.rootNames.length || new Set(r.rootNames).size !== r.rootNames.length ||
      !r.rootNames.every(path => isProjectPath(path) && /\.tsx?$/.test(path) && !/\.d\.ts$/.test(path) &&
        r.snapshot.files.some(file => file.path === path && file.kind === 'text'))) {
      throw new Error('Invalid targeted compiler roots');
    }
    if (/\.tsx?$/.test(r.snapshot.entry) && !r.rootNames.includes(r.snapshot.entry)) {
      throw new Error('Targeted roots must include the build entry');
    }
  }
}

export async function compile(r) {
  validate(r);
  // The original Agent/Web IDE `build` writes a .lua sibling next to each TS
  // source. On a later explicit Studio editor build, TSTL replaces that output;
  // retaining it as an immutable resource would be a false collision.
  const generatedLua = new Set(r.snapshot.files.filter(f => f.kind === 'text' && /\.tsx?$/.test(f.path) && !/\.d\.ts$/.test(f.path))
    .map(f => f.path.replace(/\.tsx?$/, '.lua')));
  const files = new Map(r.snapshot.files.filter(f => !/\.tsx?$/.test(f.path) && !generatedLua.has(f.path)).map(f => [f.path, f]));
  const sourceMaps = Object.create(null);
  let diagnostics = [];
  if (r.snapshot.files.some(f => f.kind === 'text' && /\.tsx?$/.test(f.path) && !/\.d\.ts$/.test(f.path))) {
    if (!r.declarations.some(f => f.path === 'Dora.d.ts')) throw new Error('Dora.d.ts is required');
    const virtual = r.snapshot.files.filter(f => f.kind === 'text').map(f => ({ file: root + f.path, content: f.text }));
    for (const f of r.declarations) {
      const file = f.path === 'lualib_bundle.lua' ? root + f.path : '/dora/' + f.path;
      if (virtual.some(v => v.file === file)) throw new Error(`Reserved compiler resource: ${f.path}`);
      virtual.push({ file, content: f.text });
    }
    const result = compileSnapshot(ts, {
      rootNames: (r.rootNames ?? r.snapshot.files.filter(f => f.kind === 'text' && /\.tsx?$/.test(f.path)).map(f => f.path)).map(path => root + path),
      projectRoot: '/project', files: virtual, defaultLibFileName: '/dora/Dora.d.ts',
      options: doraCompilerOptions(ts, LuaTarget.Lua55, LuaLibImportKind.Require),
    }, (program, emitHost, writeFile) => new Transpiler({ emitHost }).emit({ program, writeFile }).diagnostics);
    diagnostics = result.diagnostics.map(d => ({
      severity: d.category === ts.DiagnosticCategory.Error ? 'error' : d.category === ts.DiagnosticCategory.Warning ? 'warning' : 'info',
      code: String(d.code), message: ts.flattenDiagnosticMessageText(d.messageText, '\n'),
      ...(d.file ? { path: d.file.fileName.startsWith(root) ? d.file.fileName.slice(root.length) : d.file.fileName } : {}),
      ...(d.start !== undefined ? { start: d.start } : {}), ...(d.length !== undefined ? { length: d.length } : {}),
    }));
    if (diagnostics.some(d => d.severity === 'error')) return { ...identity(r), type: 'compileFailed', diagnostics };
    for (const [name, output] of result.output) {
      if (!name.startsWith(root) || !isProjectPath(name.slice(root.length))) throw new Error('Compiler emitted outside project');
      const path = name.slice(root.length);
      if (path.endsWith('.map')) sourceMaps[path] = output.content;
      else {
        if (files.has(path)) throw new Error(`Output overwrites project resource: ${path}`);
        files.set(path, { path, kind: 'text', text: output.content });
      }
    }
  }
  const entry = r.snapshot.entry.replace(/\.tsx?$/, '.lua');
  if (!files.has(entry)) throw new Error('Compiler did not emit entry');
  const sorted = [...files.values()].sort((a, b) => a.path < b.path ? -1 : a.path > b.path ? 1 : 0);
  const artifactErrors = validateSnapshot({ ...r.snapshot, entry, files: sorted });
  if (artifactErrors.length) throw new Error(artifactErrors.join('; '));
  const hashInput = serializeArtifactContent({ compilerVersion: COMPILER_VERSION, entry, files: sorted, sourceMaps });
  const hash = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(hashInput));
  const sha256 = [...new Uint8Array(hash)].map(b => b.toString(16).padStart(2, '0')).join('');
  return { ...identity(r), type: 'compiled', diagnostics, artifact: {
    buildId: r.buildId, projectId: r.projectId, revision: r.revision, compilerVersion: COMPILER_VERSION,
    entry, files: sorted, sourceMaps, sha256,
  } };
}

self.onmessage = async event => {
  const request = event.data;
  try {
    validate(request);
    self.postMessage({ ...identity(request), type: 'compileStarted' });
    self.postMessage(await compile(request));
  }
  catch (error) {
    self.postMessage({ ...identity(request ?? {}), type: 'requestFailed', code: 'invalidRequest',
      message: error instanceof Error ? error.message : 'Compilation failed' });
  }
};
