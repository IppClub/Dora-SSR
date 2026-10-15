import createModule from './compiler.mjs';
import { createTealCompiler } from './teal-compiler.js';
let accepted = false;
self.onmessage = async event => {
  if (accepted) return;
  accepted = true;
  const { id, snapshot, declarations, path } = event.data ?? {};
  let compiler;
  const send = result => self.postMessage({ id, ...result });
  try {
    if (typeof id !== 'string' || !id || typeof path !== 'string' || !/\.(lua|tl)$/.test(path)) throw new Error('Invalid Lua/Teal build request');
    send({ type: 'started' });
    compiler = await createTealCompiler(snapshot, declarations, createModule);
    if (path.endsWith('.tl')) {
      const result = compiler.compile(snapshot.projectId, path);
      send({ type: 'result', success: result.success, ...(result.success ? { code: result.code, tic80: result.tic80 } : { message: result.message, diagnostics: compiler.check(snapshot.projectId, path).diagnostics }) });
    } else {
      const result = compiler.check(snapshot.projectId, path);
      const source = snapshot.files.find(file => file.path === path)?.text ?? '';
      const lines = source.split(/\r?\n/);
      send({ type: 'result', success: result.success, ...(!result.success ? { diagnostics: result.diagnostics, message: result.diagnostics.map(d =>
        `line ${d.line}, col ${d.column}: ${lines[d.line - 1] ?? ''}\nerror: ${d.message}`).join('\n') || 'lua check failed' } : {}) });
    }
  } catch (error) { send({ type: 'result', success: false, message: error instanceof Error ? error.message : 'Lua/Teal worker failed' }); }
  finally { compiler?.dispose(); }
};
