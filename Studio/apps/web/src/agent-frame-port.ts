/** Bootstrap for an application-owned Agent frame, never a project preview frame.
 * The configured origin must serve trusted host code only. This is not account authorization.
 */
export function requestAgentFramePort(target: Window, origin: string, signal: AbortSignal, timeoutMs = 15000): Promise<MessagePort> {
  return new Promise((resolve, reject) => {
    if (new URL(origin).origin !== origin || origin === location.origin || !/^https?:/.test(origin)) {
      reject(new Error('Agent host requires a distinct explicit HTTP(S) origin')); return;
    }
    if (!Number.isFinite(timeoutMs) || timeoutMs <= 0 || timeoutMs > 60000) {reject(new Error('Invalid Agent handshake timeout'));return;}
    if (signal.aborted) {reject(signal.reason ?? new DOMException('Aborted','AbortError'));return;}
    const requestId = crypto.randomUUID();
    let settled = false;
    const cleanup = () => {
      clearTimeout(timer);
      window.removeEventListener('message', onMessage);
      signal.removeEventListener('abort', onAbort);
    };
    const fail = (error: unknown) => {
      if (settled) return;
      settled = true; cleanup(); reject(error);
    };
    const onAbort = () => fail(signal.reason ?? new DOMException('Aborted','AbortError'));
    const onMessage = (event: MessageEvent<unknown>) => {
      if (settled || event.source !== target || event.origin !== origin) return;
      const data = event.data;
      if (!data || typeof data !== 'object' || Array.isArray(data)) return;
      const message = data as Record<string, unknown>;
      if (message.type !== 'studio-agent-port') return;
      if (message.version !== 1 || message.requestId !== requestId || event.ports.length !== 1) {
        for (const port of event.ports) port.close();
        return;
      }
      settled = true; cleanup(); resolve(event.ports[0]!);
    };
    const timer = setTimeout(() => fail(new Error('Agent frame handshake timed out')), timeoutMs);
    window.addEventListener('message', onMessage);
    signal.addEventListener('abort', onAbort, {once:true});
    try {target.postMessage({type:'studio-agent-connect',version:1,requestId}, origin);} catch (error) {fail(error);}
  });
}
