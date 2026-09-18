import {availableModelAmount} from './model-amount.mjs';

/** Pure decision over a trusted transaction snapshot. The caller must reserve
 * money and increment all counters atomically with this check before dispatch. */
export function decideModelAdmission({api,account,grant,reservation,amounts,cancelled=false}) {
  if(typeof cancelled!=='boolean')throw new TypeError('Invalid cancellation state');
  for(const item of [api,account,grant]){
    if(!item||typeof item.enabled!=='boolean'||!Number.isSafeInteger(item.limit)||item.limit<0||!Number.isSafeInteger(item.active)||item.active<0)
      throw new TypeError('Invalid concurrency snapshot');
  }
  if(typeof reservation!=='bigint'||reservation<0n)throw new TypeError('Invalid reservation');
  const available=availableModelAmount(amounts);
  if(cancelled)return {state:'denied',reason:'cancelled'};
  if(!api.enabled||!account.enabled||!grant.enabled)return {state:'denied',reason:'unavailable'};
  if(available<reservation)return {state:'denied',reason:'insufficient-amount',available};
  // Zero is a disabled capacity, not a queue that can ever acquire a slot.
  if([api,account,grant].some(item=>item.limit===0))return {state:'denied',reason:'zero-capacity'};
  const saturated=[];
  for(const [name,item] of [['api',api],['account',account],['grant',grant]])if(item.active>=item.limit)saturated.push(name);
  if(saturated.length)return {state:'queued',reason:'concurrency',saturated};
  return {state:'admitted',reservation};
}
