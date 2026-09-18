/** One bounded internal maintenance batch. No provider calls, refunds, or age-
 * based guesses. Run complete passes from an empty cursor repeatedly: requests
 * can acquire receipts behind the current cursor, and failed rows need retry.
 * The scheduler must provide backoff and surface failures, not busy-loop them.
 */
export function recoverModelReceipts(ledger,{after='',limit=100,signal}={}) {
  if(signal?.aborted)return {cursor:after,processed:[],interrupted:true};
  const rows=ledger.recoveryReceipts({after,limit}),processed=[];
  let cursor=after;
  for(const row of rows){
    if(signal?.aborted)return {cursor,processed,interrupted:true};
    cursor=row.requestId;
    try {
      const record=ledger.transition(row.requestId,row.version,'finish');
      processed.push({requestId:row.requestId,state:record.request.state});
    } catch {
      // Another process may have won the version transition. Report it only
      // after reading authoritative state; storage errors remain retryable.
      let current;
      try{current=ledger.request(row.requestId);}catch{}
      processed.push({requestId:row.requestId,state:current&&['settled','pending-usage'].includes(current.request.state)?'already-processed':'retry-required'});
    }
  }
  return {cursor,processed,interrupted:false};
}
