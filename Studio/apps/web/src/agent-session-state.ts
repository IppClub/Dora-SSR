import {
  applyMessageCollectionPatches, applyStepCollectionPatches, applyCheckpointCollectionPatches,
  createMessageCollection, createStepCollection, createCheckpointCollection,
  reconcileMessageCollection, reconcileStepCollection, reconcileCheckpointCollection,
  type AgentSession, type AgentSessionPatch, type AgentSessionMessage, type AgentSessionStep,
  type AgentCheckpointItem, type AgentQuestionnaire, type AgentSessionSpawnInfo,
  type AgentPendingMergeJob,
} from '@dora-studio/agent-contracts/session-patches';

export interface AgentSessionSnapshot {
  session: AgentSession;
  messages: AgentSessionMessage[];
  hasEarlierMessages?: boolean;
  steps: AgentSessionStep[];
  checkpoints: AgentCheckpointItem[];
  relatedSessions: AgentSession[];
  pendingQuestionnaire: AgentQuestionnaire | null;
  spawnInfo: AgentSessionSpawnInfo | null;
  hasActivePlan: boolean;
  pendingMergeCount?: number;
  pendingMergeJobs?: AgentPendingMergeJob[];
}

/** Typed, trusted host inputs only. This reducer does not authenticate or decode wire data. */
export function createAgentSessionState(snapshot: AgentSessionSnapshot) {
  if (!Number.isSafeInteger(snapshot.session.id) || snapshot.session.id <= 0) throw new Error('Invalid session ID');
  const copy = structuredClone(snapshot);
  return {
    ...copy,
    hasEarlierMessages: copy.hasEarlierMessages ?? false,
    pendingMergeCount: copy.pendingMergeCount ?? 0,
    pendingMergeJobs: copy.pendingMergeJobs ?? [],
    messages: createMessageCollection(copy.messages),
    steps: createStepCollection(copy.steps),
    checkpoints: createCheckpointCollection(copy.checkpoints),
    deleted: false,
  };
}
export type AgentSessionState = ReturnType<typeof createAgentSessionState>;

/** Caller must first synchronize snapshot and event cursor; never apply a stale response. */
export function replaceAgentSessionSnapshot(state: AgentSessionState, snapshot: AgentSessionSnapshot): AgentSessionState {
  if (snapshot.session.id !== state.session.id) throw new Error('Mismatched snapshot session');
  if (state.deleted) return state;
  const next = createAgentSessionState(snapshot);
  return {
    ...next,
    messages: reconcileMessageCollection(state.messages, [...next.messages.byId.values()]),
    steps: reconcileStepCollection(state.steps, [...next.steps.byId.values()]),
    checkpoints: reconcileCheckpointCollection(state.checkpoints, [...next.checkpoints.byId.values()]),
  };
}

export function applyAgentSessionPatch(state: AgentSessionState, input: AgentSessionPatch): AgentSessionState {
  if (state.deleted || input.sessionId !== state.session.id) return state;
  if (input.session && input.session.id !== state.session.id) throw new Error('Mismatched session payload');
  if (input.message && input.message.sessionId !== state.session.id) throw new Error('Mismatched message session');
  if (input.step && input.step.sessionId !== state.session.id) throw new Error('Mismatched step session');
  const patch = structuredClone(input);
  if (patch.sessionDeleted) return {...state, deleted: true};
  const session = patch.session ?? state.session;
  return {
    ...state,
    session: patch.metrics ? {...session, metrics: {...session.metrics, ...patch.metrics}} : session,
    messages: applyMessageCollectionPatches(state.messages, [patch]),
    steps: applyStepCollectionPatches(state.steps, [patch]),
    checkpoints: applyCheckpointCollectionPatches(state.checkpoints, [patch]),
    relatedSessions: patch.relatedSessions ?? state.relatedSessions,
    pendingQuestionnaire: 'pendingQuestionnaire' in patch ? patch.pendingQuestionnaire || null : state.pendingQuestionnaire,
    spawnInfo: 'spawnInfo' in patch ? patch.spawnInfo ?? null : state.spawnInfo,
    hasActivePlan: patch.hasActivePlan ?? state.hasActivePlan,
    pendingMergeCount: patch.pendingMergeCount ?? state.pendingMergeCount,
    pendingMergeJobs: patch.pendingMergeJobs ?? state.pendingMergeJobs,
  };
}
