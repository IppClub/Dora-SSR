import {tokenCharge} from './model-amount.mjs';
import {normalizeModelUsage} from './model-usage.mjs';

/** Trusted internal boundary, not an HTTP endpoint. The caller authenticates,
 * resolves configuration/secrets and computes intent before entering here.
 * Shared catalog callers must bind intent.configurationVersion from the trusted
 * catalog, co-located with the ledger database; never accept a client omission.
 * send is a provider adapter: resolve completed:true only after a trustworthy
 * terminal result, with normalized bigint usage (or null when unavailable).
 * Rejections/aborts are ambiguous; never assume provider work has stopped.
 */
export async function executeModelRequest({ledger,intent,send,signal,resumeQueued=false}) {
  if(typeof send!=='function')throw new TypeError('Missing model transport');
  if(typeof resumeQueued!=='boolean')throw new TypeError('Invalid queue resume state');
  const owned=structuredClone(intent);
  if(signal?.aborted)return {state:'cancelled-before-admission'};
  let admission=ledger.reserve(owned);
  if(admission.replayed){
    // Only an explicitly authorized live queue resume may acquire a slot.
    // Ordinary HTTP retries and already-reserved/in-flight requests never send.
    if(!resumeQueued||admission.record.request.state!=='queued')return {state:'existing',record:admission.record};
    admission=ledger.admitQueued(owned.requestId,admission.record.version);
  }
  if(admission.decision&&admission.decision.state!=='admitted')return {state:admission.decision.state,decision:admission.decision,...(admission.record?{record:admission.record}:{})};
  if(!admission.record)return {state:admission.decision.state,decision:admission.decision};
  const reserved=admission.record;
  if(signal?.aborted){
    const record=ledger.transition(owned.requestId,reserved.version,'cancel');
    return {state:'cancelled-before-dispatch',record};
  }
  // Commit before calling any transport, and only the CAS winner may send.
  const dispatched=ledger.transition(owned.requestId,reserved.version,'dispatch');
  if(dispatched.request.state==='rejected-before-dispatch')return {state:'denied',record:dispatched,decision:{state:'denied',reason:dispatched.request.reason}};
  let result;
  try {
    result=await send({requestId:owned.requestId,signal});
    if(result?.completed!==true)throw new Error('Unconfirmed provider completion');
    if(result.usage!=null){
      result={...result,usage:normalizeModelUsage(result.usage)};
      tokenCharge(result.usage,dispatched.request.rates);
    }
  } catch {
    // Do not leak transport exceptions (URLs, credentials or response bodies).
    // Both concurrency and money stay held until provider reconciliation.
    return {state:'needs-reconciliation',record:dispatched};
  }
  // Even if the client disconnected, account for a confirmed terminal result.
  // A ledger failure must propagate, not be treated as a provider failure or
  // trigger resend. The persisted in-flight marker protects subsequent retries.
  const received=ledger.transition(owned.requestId,dispatched.version,'receipt',result.usage??null);
  const record=ledger.transition(owned.requestId,received.version,'finish');
  return {state:record.request.state,record,response:result.response};
}

/** Explicit recovery for a durable terminal receipt, never a network retry.
 * Authorization of this internal lookup belongs to the caller. */
export function settleRecordedModelRequest(ledger,requestId) {
  const record=ledger.request(requestId);
  if(!record?.receipt||record.request.state!=='in-flight')throw new Error('No unsettled completion receipt');
  return ledger.transition(requestId,record.version,'finish');
}
