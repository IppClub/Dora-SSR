import { validateSnapshot } from '@dora-studio/contracts';

/** Build a derived runtime input. Never writes generated Lua into authoring storage. */
export async function compileTealProject(input, compileFile, options = {}) {
  const source = structuredClone(input);
  const errors = validateSnapshot(source);
  if (errors.length) throw new Error(errors.join('; '));
  const cancelled = () => options.signal?.aborted === true || options.isCancelled?.() === true;
  const interrupted = () => ({success: false, interrupted: true, message: 'Build canceled.'});
  const generated = new Map();
  const targets = source.files.filter(file => file.kind === 'text' && file.path.endsWith('.tl') && !file.path.endsWith('.d.tl'));
  // Check collisions before spending work; a source Lua file is not a disposable cache.
  for (const file of targets) {
    const path = file.path.slice(0, -3) + '.lua';
    if (source.files.some(existing => existing.path === path)) return {success: false, message: `Generated Lua would overwrite source: ${path}`};
  }
  const checked = options.checkLua ? [...targets, ...source.files.filter(file => file.kind === 'text' && file.path.endsWith('.lua'))] : targets;
  for (const file of checked) {
    if (cancelled()) return interrupted();
    const result = await compileFile({snapshot: structuredClone(source), path: file.path, signal: options.signal, isCancelled: cancelled});
    if (cancelled() || result.interrupted) return interrupted();
    const isTeal = file.path.endsWith('.tl');
    if (!result.success || (isTeal && typeof result.code !== 'string')) return {success: false, message: result.message || `Missing compiled Lua: ${file.path}`, diagnostics: (result.diagnostics ?? []).map(d => {
      const text = source.files.find(f => f.path === d.path && f.kind === 'text')?.text;
      // Teal columns are not guaranteed to be UTF-16 offsets. Select the source line
      // instead of misplacing the cursor after non-ASCII characters.
      const lines = text?.match(/[^\r\n]*(?:\r\n|\r|\n|$)/g) ?? [];
      const line = lines[d.line - 1];
      return {severity: d.type === 'warning' ? 'warning' : 'error', code: `${isTeal ? 'teal' : 'lua'}-${d.type}`, path: d.path,
        message: `${d.message}（行 ${d.line}${d.column > 0 ? `，列 ${d.column}` : ''}）`,
        ...(line === undefined ? {} : {start: lines.slice(0, d.line - 1).join('').length, length: line.replace(/[\r\n]+$/, '').length})};
    })};
    if (!isTeal) continue;
    const path = file.path.slice(0, -3) + '.lua';
    generated.set(file.path, {path, kind: 'text', text: result.code});
  }
  if (cancelled()) return interrupted();
  const snapshot = {...source, entry: generated.get(source.entry)?.path ?? source.entry,
    files: source.files.map(file => generated.get(file.path) ?? file)};
  const derivedErrors = validateSnapshot(snapshot);
  if (derivedErrors.length) return {success: false, message: derivedErrors.join('; ')};
  return {success: true, snapshot};
}
