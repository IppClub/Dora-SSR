import {decodeAgentSessionPatch} from './agent-session-decode';
import type {AgentSessionPatch} from '@dora-studio/agent-contracts/session-patches';

export interface AgentSessionEnvelope {
  version:1;
  projectId:string;
  generation:string;
  sessionId:number;
  sequence:number;
  payload:string;
}
export type AgentFeedResult =
  | {status:'accepted';patch:AgentSessionPatch}
  | {status:'ignored'}
  | {status:'resync-required'};

/** Protocol validation for a separately authenticated trusted Agent channel.
 * A matching generation is not authentication; never connect a game iframe here.
 * After a sequence gap, recreate the feed only after fetching a full snapshot.
 */
export function createAgentSessionFeed(projectId:string,generation:string,sessionId:number,afterSequence=0) {
  if(!projectId || !generation || !Number.isSafeInteger(sessionId) || sessionId<=0 ||
    !Number.isSafeInteger(afterSequence) || afterSequence<0) throw new Error('Invalid Agent feed binding');
  let sequence=afterSequence,needsResync=false;
  return {
    receive(value:unknown):AgentFeedResult {
      if(!value || typeof value!=='object') return {status:'ignored'};
      const event=value as Partial<AgentSessionEnvelope>;
      if(event.version!==1 || event.projectId!==projectId || event.generation!==generation || event.sessionId!==sessionId)
        return {status:'ignored'};
      if(needsResync) return {status:'resync-required'};
      if(typeof event.sequence!=='number' || !Number.isSafeInteger(event.sequence) || event.sequence<=0) return {status:'ignored'};
      if(event.sequence<=sequence) return {status:'ignored'};
      if(event.sequence!==sequence+1 || typeof event.payload!=='string' ||
        event.payload.length>1024*1024 || new TextEncoder().encode(event.payload).length>1024*1024) {
        needsResync=true;return {status:'resync-required'};
      }
      let patch:AgentSessionPatch;
      try {patch=decodeAgentSessionPatch(event.payload);} catch {needsResync=true;return {status:'resync-required'};}
      if(patch.sessionId!==sessionId) {
        needsResync=true;return {status:'resync-required'};
      }
      sequence=event.sequence;
      return {status:'accepted',patch};
    },
    get sequence(){return sequence;},
    get needsResync(){return needsResync;},
  };
}
