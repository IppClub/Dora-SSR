import {decideModelAdmission} from './model-admission.mjs';
import {settleModelReservation,tokenCharge} from './model-amount.mjs';

/** Immutable transitions, to be committed by one database transaction. No I/O.
 * Storage must bind the request to these account/API/grant rows and compare its
 * persisted state/version atomically. An old caller-supplied request is NOT an
 * idempotency check and must never authorize another settlement.
 */
export function reserveModelRequest(snapshot,rates) {
  tokenCharge({inputTokens:0n,outputTokens:0n},rates);
  const decision=decideModelAdmission(snapshot);
  if(decision.state!=='admitted')return {decision};
  const next=structuredClone(snapshot);
  for(const scope of ['api','account','grant']){
    if(next[scope].active===Number.MAX_SAFE_INTEGER)throw new Error('Concurrency counter overflow');
    next[scope].active++;
  }
  next.amounts.accountReserved+=snapshot.reservation;
  next.amounts.grantReserved+=snapshot.reservation;
  return {decision,next,request:{state:'reserved',reserved:snapshot.reservation,rates:structuredClone(rates)}};
}

/** Persist this transition BEFORE network dispatch. A crash after this marker
 * is ambiguous and must be reconciled, never treated as an uncharged cancel. */
export function markModelRequestDispatched(request,snapshot) {
  if(request?.state!=='reserved')throw new Error('Request is not reserved');
  // Recheck current trusted rows, discounting this request's existing hold.
  // Never acquire a second slot or reserve the same amount twice.
  decideModelAdmission(snapshot);
  const available=structuredClone(snapshot);
  for(const scope of ['api','account','grant']){
    if(available[scope].active<1)throw new Error('Missing active request slot');
    available[scope].active--;
  }
  if(available.amounts.accountReserved<request.reserved||available.amounts.grantReserved<request.reserved)
    throw new Error('Missing reserved amount');
  available.amounts.accountReserved-=request.reserved;
  available.amounts.grantReserved-=request.reserved;
  available.reservation=request.reserved;
  const decision=decideModelAdmission(available);
  if(decision.state!=='admitted')throw new Error(`Dispatch no longer admitted: ${decision.reason}`);
  return {...structuredClone(request),state:'in-flight'};
}

export function cancelUndispatchedModelRequest(snapshot,request) {
  if(request?.state!=='reserved')throw new Error('Cannot release a dispatched request');
  const result=finishModelRequest(snapshot,{...request,state:'in-flight'},{inputTokens:0n,outputTokens:0n});
  return {...result,request:{...result.request,state:'cancelled-before-dispatch'}};
}

export function finishModelRequest(snapshot,request,usage) {
  if(!request||!['in-flight','pending-usage'].includes(request.state))throw new Error('Request is not settleable');
  // Validate the current counters and amounts even after administrator revocation.
  decideModelAdmission(snapshot);
  const settlement=settleModelReservation(request.reserved,usage,request.rates);
  const next=structuredClone(snapshot);
  if(request.state==='in-flight')for(const scope of ['api','account','grant']){
    if(next[scope].active<1)throw new Error('Missing active request slot');
    next[scope].active--;
  }
  if(next.amounts.accountReserved<request.reserved||next.amounts.grantReserved<request.reserved)throw new Error('Missing reserved amount');
  if(settlement.state==='settled'){
    next.amounts.accountReserved-=request.reserved;
    next.amounts.grantReserved-=request.reserved;
    next.amounts.accountSpent+=settlement.charged;
    next.amounts.grantSpent+=settlement.charged;
  }
  return {next,request:{...structuredClone(request),state:settlement.state,settlement}};
}
