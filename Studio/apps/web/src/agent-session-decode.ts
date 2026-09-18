import generatedSchema from '@dora-studio/agent-contracts/session-patch-schema';
import detailSchema from '@dora-studio/agent-contracts/session-detail-schema';
import type {AgentSessionPatch, AgentSessionDetailResponse} from '@dora-studio/agent-contracts/session-patches';
import type {AgentSessionSnapshot} from './agent-session-state';

interface Schema {
  $ref?: string;
  $defs?: Record<string, Schema>;
  type?: string;
  const?: unknown;
  anyOf?: Schema[];
  properties?: Record<string, Schema>;
  required?: string[];
  items?: Schema;
  additionalProperties?: boolean | Schema;
}
const invalid = () => {throw new Error('Invalid Agent session payload');};

/** JSON boundary only; authorization must be established by the host/channel. */
function decodePayload(payload: string, schema: Schema): unknown {
  if (payload.length > 1024*1024 || new TextEncoder().encode(payload).length > 1024*1024) invalid();
  const parsed: unknown = JSON.parse(payload);
  // Bound all data, including extension fields and arbitrary tool results.
  const inspect = (value: unknown, depth: number): void => {
    if (depth > 64) invalid();
    if (typeof value === 'number' && !Number.isFinite(value)) invalid();
    if (value && typeof value === 'object') for (const child of Object.values(value)) inspect(child, depth+1);
  };
  inspect(parsed, 0);
  const validate = (value: unknown, rule: Schema, depth = 0): unknown => {
    if (depth > 128) return invalid();
    if (rule.$ref) {
      const definition = schema.$defs?.[rule.$ref.replace(/^#\/\$defs\//, '')];
      if (!definition) return invalid();
      return validate(value, definition, depth+1);
    }
    if (Object.hasOwn(rule, 'const')) {if (value !== rule.const) return invalid(); return value;}
    if (rule.anyOf) {
      for (const variant of rule.anyOf) {try {return validate(value, variant, depth+1);} catch {/* Try the next declared union member. */}}
      return invalid();
    }
    if (rule.type === 'array') {
      if (!Array.isArray(value) || !rule.items) return invalid();
      return value.map(item => validate(item, rule.items!, depth+1));
    }
    if (rule.type === 'object') {
      // Lua's empty table has no object/array distinction. Never coerce nonempty arrays.
      if (Array.isArray(value) && value.length === 0 && !rule.required?.length) value = {};
      if (!value || typeof value !== 'object' || Array.isArray(value)) return invalid();
      const object = value as Record<string, unknown>;
      if (rule.required?.some(key => !Object.hasOwn(object, key))) return invalid();
      return Object.fromEntries(Object.entries(object).map(([key, item]) => {
        const field = Object.hasOwn(rule.properties ?? {}, key) ? rule.properties![key] : undefined;
        if (field) return [key, validate(item, field, depth+1)];
        if (rule.additionalProperties === false) return invalid();
        return [key, typeof rule.additionalProperties === 'object' ? validate(item, rule.additionalProperties, depth+1) : item];
      }));
    }
    if (rule.type && typeof value !== rule.type) return invalid();
    return value;
  };
  return validate(parsed, schema);
}

export function decodeAgentSessionPatch(payload: string): AgentSessionPatch {
  const patch = decodePayload(payload, generatedSchema) as AgentSessionPatch;
  if (!Number.isSafeInteger(patch.sessionId) || patch.sessionId <= 0) invalid();
  for (const record of [patch.message, patch.step]) {
    if (record && (record.sessionId !== patch.sessionId || !Number.isSafeInteger(record.id) || record.id <= 0)) invalid();
  }
  if (patch.session && patch.session.id !== patch.sessionId) invalid();
  if (patch.removedStepIds?.some(id => !Number.isSafeInteger(id) || id <= 0)) invalid();
  return patch;
}

export function decodeAgentSessionSnapshot(payload: string, sessionId: number): AgentSessionSnapshot {
  if (!Number.isSafeInteger(sessionId) || sessionId <= 0) invalid();
  const detail = decodePayload(payload, detailSchema) as AgentSessionDetailResponse;
  if (!detail.success) throw new Error('Agent session snapshot unavailable');
  if (detail.session.id !== sessionId) invalid();
  for (const records of [detail.messages, detail.steps]) {
    const ids = new Set<number>();
    for (const record of records) {
      if (record.sessionId !== sessionId || !Number.isSafeInteger(record.id) || record.id <= 0 || ids.has(record.id)) invalid();
      ids.add(record.id);
    }
  }
  return {...detail, checkpoints: detail.checkpoints ?? [], pendingQuestionnaire: detail.pendingQuestionnaire ?? null, spawnInfo: detail.spawnInfo ?? null};
}
