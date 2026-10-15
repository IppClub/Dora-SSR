/** Dedicated worker per file. The original Agent predicate is polled off-worker. */
export function createTealWorkerBuild(createWorker, inputDeclarations, options = {}) {
  const declarations = structuredClone(inputDeclarations);
  const timeoutMs = options.timeoutMs ?? 30000;
  if (!Number.isSafeInteger(timeoutMs) || timeoutMs < 1 || timeoutMs > 2147483647) throw new Error('Invalid Teal timeout');
  return ({ snapshot, path, isCancelled, signal = options.signal }) => {
    if (signal?.aborted || isCancelled?.()) return Promise.resolve({ success: false, message: 'Build canceled.', interrupted: true });
    if (!/\.(lua|tl|yarn)$/.test(path)) return Promise.resolve({ success: false, message: `Browser compiler unavailable for ${path}` });
    const request = structuredClone({ id: crypto.randomUUID(), snapshot, path, declarations });
    return new Promise(resolve => {
      let worker, timeout, poll, done = false;
      const finish = result => {
        if (done) return;
        done = true;
        clearTimeout(timeout); clearInterval(poll); signal?.removeEventListener('abort', abort);
        if (worker) { worker.onmessage = worker.onerror = worker.onmessageerror = null; worker.terminate(); }
        resolve(result);
      };
      const abort = () => finish({ success: false, message: 'Build canceled.', interrupted: true });
      signal?.addEventListener('abort', abort, { once: true });
      try {
        worker = createWorker();
        if (done) { worker.terminate(); return; }
        if (signal?.aborted || isCancelled?.()) { abort(); return; }
        worker.onmessage = event => {
          const result = event.data;
          if (!result || result.id !== request.id || result.type !== 'result' || typeof result.success !== 'boolean') return;
          if (!result.success && typeof result.message !== 'string') return;
          if (result.code !== undefined && typeof result.code !== 'string') return;
          if (result.tic80 !== undefined && typeof result.tic80 !== 'boolean') return;
          if (result.diagnostics !== undefined && (!Array.isArray(result.diagnostics) || !result.diagnostics.every(d =>
            d && typeof d.path === 'string' && typeof d.message === 'string' && typeof d.type === 'string' &&
            Number.isSafeInteger(d.line) && d.line >= 1 && Number.isSafeInteger(d.column) && d.column >= 0))) return;
          if (signal?.aborted || isCancelled?.()) { abort(); return; }
          finish({ success: result.success, ...(result.success ? { ...(result.code === undefined ? {} : { code: result.code }), ...(result.tic80 === undefined ? {} : {tic80:result.tic80}) } : { message: result.message, ...(result.diagnostics ? {diagnostics: structuredClone(result.diagnostics)} : {}) }) });
        };
        worker.onerror = () => finish({ success: false, message: 'Lua/Teal Worker failed' });
        worker.onmessageerror = () => finish({ success: false, message: 'Invalid Lua/Teal Worker message' });
        timeout = setTimeout(() => finish({ success: false, message: 'Lua/Teal build timed out', interrupted: true }), timeoutMs);
        poll = setInterval(() => { if (isCancelled?.()) abort(); }, 20);
        worker.postMessage(request);
      } catch (error) { finish({ success: false, message: error instanceof Error ? error.message : 'Lua/Teal Worker startup failed' }); }
    });
  };
}
