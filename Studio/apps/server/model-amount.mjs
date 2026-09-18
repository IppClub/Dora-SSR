// Integer nano-CNY throughout. Rates are nano-CNY per million tokens.
// No exchange-rate guesses, provider balance claims, or floating-point money.
const million=1000000n;
const integer=(value,name)=>{
  if(typeof value!=='bigint'||value<0n)throw new TypeError(`${name} must be nonnegative bigint`);
  return value;
};
export function tokenCharge({inputTokens,outputTokens},{inputNanoCnyPerMillion,outputNanoCnyPerMillion}) {
  const numerator=integer(inputTokens,'inputTokens')*integer(inputNanoCnyPerMillion,'input rate')+
    integer(outputTokens,'outputTokens')*integer(outputNanoCnyPerMillion,'output rate');
  // Round once at the total, upward to one nano-CNY; split components must not
  // introduce double rounding. Usage normalization is the provider adapter's job.
  return (numerator+million-1n)/million;
}
export function availableModelAmount({accountLimit,accountSpent,accountReserved,grantLimit,grantSpent,grantReserved}) {
  const remainder=(limit,spent,reserved)=>{
    const result=integer(limit,'limit')-integer(spent,'spent')-integer(reserved,'reserved');
    return result>0n?result:0n;
  };
  const account=remainder(accountLimit,accountSpent,accountReserved),grant=remainder(grantLimit,grantSpent,grantReserved);
  return account<grant?account:grant;
}
export function settleModelReservation(reserved,usage,rates) {
  integer(reserved,'reserved');
  // Missing usage is not zero usage; retain the hold for reconciliation.
  if(usage===undefined||usage===null)return {state:'pending-usage',reserved};
  const charged=tokenCharge(usage,rates);
  return {state:'settled',charged,released:reserved>charged?reserved-charged:0n,overage:charged>reserved?charged-reserved:0n};
}
