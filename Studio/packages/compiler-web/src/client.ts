import { matchesCompileResult, matchesRequest, isBuildArtifact, isDiagnostic, type CompileRequest, type CompileResult, type RequestFailure } from '@dora-studio/contracts';

export type CompileReply = CompileResult | RequestFailure;
export interface CompileWorker {
  onmessage: ((event: MessageEvent) => void) | null;
  onerror: ((event: ErrorEvent) => void) | null;
  onmessageerror: ((event: MessageEvent) => void) | null;
  postMessage(message: CompileRequest): void;
  terminate(): void;
}

/** One worker per build: terminating synchronous TS/TSTL is the cancellation primitive. */
export class CompilerClient {
  private active: { request: CompileRequest; finish: (reply: CompileReply) => void } | undefined;
  private disposed = false;
  constructor(private readonly createWorker: () => CompileWorker) {}

  compile(input: CompileRequest, signal?: AbortSignal): Promise<CompileReply> {
    if (this.disposed) return Promise.reject(new Error('Compiler client disposed'));
    if (!Number.isSafeInteger(input.timeoutMs) || input.timeoutMs < 1 || input.timeoutMs > 2_147_483_647) {
      return Promise.reject(new Error('Invalid compiler timeout'));
    }
    // Do not retain caller-owned identity or bytes while waiting for a reply.
    const request = structuredClone(input);
    const cancelled = (): CompileResult => ({
      version: request.version, sessionId: request.sessionId, projectId: request.projectId,
      revision: request.revision, requestId: request.requestId, buildId: request.buildId, type: 'cancelled',
    });
    // A cancelled task must neither start a worker nor evict another active task.
    if (signal?.aborted) return Promise.resolve(cancelled());
    this.cancel();
    return new Promise(resolve => {
      let worker: CompileWorker | undefined;
      let timer: ReturnType<typeof setTimeout> | undefined;
      let done = false;
      const finish = (reply: CompileReply) => {
        if (done) return;
        done = true;
        signal?.removeEventListener('abort', onAbort);
        if (timer !== undefined) clearTimeout(timer);
        if (worker) {
          worker.onmessage = worker.onerror = worker.onmessageerror = null;
          worker.terminate();
        }
        if (this.active?.finish === finish) this.active = undefined;
        resolve(reply);
      };
      // Capture this invocation, not the mutable active request or a reused requestId.
      const onAbort = () => finish(cancelled());
      this.active = { request, finish };
      signal?.addEventListener('abort', onAbort, { once: true });
      const failure = (code: RequestFailure['code'], message: string): RequestFailure => ({
        version: request.version, sessionId: request.sessionId, projectId: request.projectId,
        revision: request.revision, requestId: request.requestId, type: 'requestFailed', code, message,
      });
      try {
        worker = this.createWorker();
        // Factories can synchronously abort; dispose the newly returned worker too.
        if (done || signal?.aborted) {
          worker.terminate();
          if (!done) onAbort();
          return;
        }
        worker.onmessage = event => {
          const reply = event.data;
          if (!reply || typeof reply !== 'object' || !matchesRequest(request, reply)) return;
          if (reply.type === 'requestFailed') {
            if (['unsupportedVersion', 'unsupportedCapability', 'invalidRequest', 'timeout', 'cancelled', 'internal'].includes(reply.code) && typeof reply.message === 'string') finish(reply);
          } else if (['compiled', 'compileFailed', 'cancelled'].includes(reply.type)) {
            if (reply.type === 'compiled' && (!reply.artifact || !Array.isArray(reply.artifact.files))) return;
            if (reply.type !== 'cancelled' && !Array.isArray(reply.diagnostics)) return;
            if (reply.type !== 'cancelled' && !reply.diagnostics.every(isDiagnostic)) return;
            if (reply.type === 'compiled') {
              const artifact = reply.artifact;
              if (!isBuildArtifact(artifact)) return;
            }
            if (matchesCompileResult(request, reply)) finish(reply);
          }
        };
        worker.onerror = () => finish(failure('internal', 'Compiler worker failed to load or execute'));
        worker.onmessageerror = () => finish(failure('internal', 'Compiler reply could not be decoded'));
        timer = setTimeout(() => finish(failure('timeout', 'Compilation timed out')), request.timeoutMs);
        worker.postMessage(request);
      } catch {
        finish(failure('internal', 'Compiler worker could not be started'));
      }
    });
  }

  cancel(requestId?: string): boolean {
    const active = this.active;
    if (!active || (requestId !== undefined && active.request.requestId !== requestId)) return false;
    const { version, sessionId, projectId, revision, requestId: id, buildId } = active.request;
    active.finish({ version, sessionId, projectId, revision, requestId: id, buildId, type: 'cancelled' });
    return true;
  }

  dispose(): void { this.disposed = true; this.cancel(); }
}

/** Serve the package's browser directory unchanged; no native service is needed. */
export function createBrowserCompiler(workerURL: URL): CompilerClient {
  return new CompilerClient(() => new Worker(workerURL));
}
