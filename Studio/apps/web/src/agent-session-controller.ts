import {createAgentSessionFeed} from './agent-session-feed';
import {decodeAgentSessionSnapshot} from './agent-session-decode';
import {createAgentSessionState, applyAgentSessionPatch, type AgentSessionSnapshot} from './agent-session-state';

export type AgentSessionConnection = 'live' | 'resync-required' | 'closed';

/** Bind only to an authenticated Agent host, never to the game/log channel.
 * snapshot and sequence must describe one atomic host observation.
 * Resync creates a new controller; the retired instance cannot accept late events.
 */
export function createAgentSessionController(binding: {
  projectId: string;
  generation: string;
  sequence: number;
  snapshot: AgentSessionSnapshot;
}) {
  let state = createAgentSessionState(binding.snapshot);
  const feed = createAgentSessionFeed(binding.projectId, binding.generation, state.session.id, binding.sequence);
  let closed = false;
  const listeners = new Set<() => void>();
  let snapshot = {state, connection: 'live' as AgentSessionConnection};
  const notify = (connection: AgentSessionConnection) => {
    if (snapshot.state === state && snapshot.connection === connection) return;
    snapshot = {state, connection};
    for (const listener of [...listeners]) {
      try {listener();} catch { /* A UI subscriber must not interrupt transport state. */ }
    }
  };
  return {
    receive(event: unknown): 'updated' | 'ignored' | 'resync-required' {
      if (closed) return 'ignored';
      const result = feed.receive(event);
      if (result.status !== 'accepted') {
        if (result.status === 'resync-required') notify('resync-required');
        return result.status;
      }
      state = applyAgentSessionPatch(state, result.patch);
      if (state.deleted) closed = true;
      notify(closed ? 'closed' : 'live');
      return 'updated';
    },
    close() {closed = true; notify('closed');},
    subscribe(listener: () => void) {listeners.add(listener); return () => {listeners.delete(listener);};},
    getSnapshot() {return snapshot;},
    get state() {return state;},
    get sequence() {return feed.sequence;},
    get needsResync() {return feed.needsResync;},
    get closed() {return closed;},
  };
}
export type AgentSessionController = ReturnType<typeof createAgentSessionController>;

export interface AgentSnapshotEnvelope {
  version: 1;
  projectId: string;
  generation: string;
  sessionId: number;
  sequence: number;
  payload: string;
}

/** The expected binding is held by the caller, never adopted from a response. */
export function openAgentSessionSnapshot(expected: {projectId:string;generation:string;sessionId:number}, response: unknown): AgentSessionController {
  if (!expected.projectId || !expected.generation || !Number.isSafeInteger(expected.sessionId) || expected.sessionId <= 0) throw new Error('Invalid snapshot binding');
  if (!response || typeof response !== 'object' || Array.isArray(response)) throw new Error('Invalid snapshot envelope');
  const envelope = response as Partial<AgentSnapshotEnvelope>;
  if (envelope.version !== 1 || envelope.projectId !== expected.projectId || envelope.generation !== expected.generation || envelope.sessionId !== expected.sessionId || typeof envelope.payload !== 'string' || !Number.isSafeInteger(envelope.sequence) || (envelope.sequence ?? -1) < 0) throw new Error('Mismatched or invalid snapshot envelope');
  const snapshot = decodeAgentSessionSnapshot(envelope.payload, expected.sessionId);
  return createAgentSessionController({...expected, sequence: envelope.sequence!, snapshot});
}
