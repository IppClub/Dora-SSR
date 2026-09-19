import { createSnapshotBuildBackend } from './snapshot-build.js';
import { formatTypeScriptDiagnostics } from '@dora-studio/contracts';

/** The client must be owned by this Agent task, not the manual-preview compiler. */
export function createWorkerBuildBackend(snapshot, client, options) {
  const config = structuredClone({ sessionId: options.sessionId, compilerVersion: options.compilerVersion,
    declarations: options.declarations, timeoutMs: options.timeoutMs ?? 30000 });
  const signal = options.signal;
  let sequence = 0;
  const bindingId = crypto.randomUUID();
  const build = createSnapshotBuildBackend(snapshot, async ({ snapshot: input, path, isCancelled }) => {
    if (!/\.tsx?$/.test(path)) {
      if (options.compileNonTs) return options.compileNonTs({ snapshot: input, path, isCancelled, signal });
      return { success: false, message: `Browser Agent syntax checker is not yet available for ${path}` };
    }
    const controller = new AbortController();
    const abort = () => controller.abort();
    signal?.addEventListener('abort', abort, { once: true });
    if (signal?.aborted || isCancelled?.()) abort();
    // The existing Agent cancellation interface is a predicate, not an event.
    const poll = setInterval(() => { if (isCancelled?.()) abort(); }, 20);
    try {
      const id = `${bindingId}:${++sequence}`;
      const reply = await client.compile({
        version: 1, type: 'compile', sessionId: config.sessionId, projectId: input.projectId,
        revision: input.revision, requestId: id, buildId: id, compilerVersion: config.compilerVersion,
        snapshot: { ...input, entry: path }, rootNames: [path], declarations: config.declarations,
        timeoutMs: config.timeoutMs, options: {},
      }, controller.signal);
      if (controller.signal.aborted || reply.type === 'cancelled' || reply.code === 'cancelled') {
        return { success: false, message: 'Build canceled.', interrupted: true };
      }
      if (reply.type === 'compiled') {
        const issues=reply.diagnostics.filter(d=>d.severity==='warning'||d.severity==='error');
        if(issues.length)return {success:false,message:formatTypeScriptDiagnostics(`/project/${path}`,issues.slice(0,8),input.files)};
        return { success: true };
      }
      if (reply.type === 'compileFailed') return { success: false,
        message: formatTypeScriptDiagnostics(`/project/${path}`,reply.diagnostics.slice(0,8),input.files) || 'Compilation failed' };
      return { success: false, message: reply.message || 'Compiler request failed' };
    } finally {
      clearInterval(poll);
      signal?.removeEventListener('abort', abort);
    }
  });
  // Cancellation must stop upstream traversal too, not only an individual worker.
  return request => build({ ...request, isCancelled: () => signal?.aborted === true || request.isCancelled?.() === true });
}
