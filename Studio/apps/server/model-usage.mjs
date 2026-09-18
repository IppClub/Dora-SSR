// Normalized trusted provider counters, not a vendor response parser. Preserve
// breakdowns independently: cache/reasoning counters may overlap other totals.
// The adapter must establish input/output billing semantics for its protocol.
export function normalizeModelUsage(usage) {
  if(!usage||typeof usage!=='object')throw new TypeError('Invalid model usage');
  const result={};
  for(const key of ['inputTokens','outputTokens','totalTokens','cachedInputTokens','cacheMissInputTokens','reasoningOutputTokens','cacheCreationInputTokens','inputAudioTokens','outputAudioTokens']){
    const value=usage[key];
    if(value===undefined&&key!=='inputTokens'&&key!=='outputTokens')continue;
    if(typeof value!=='bigint'||value<0n)throw new TypeError('Model usage counters must be nonnegative bigint');
    result[key]=value;
  }
  return result;
}
