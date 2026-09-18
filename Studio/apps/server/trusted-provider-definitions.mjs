import {endpointURL} from './model-provider-transport.mjs';

/** Operator-controlled deployment allowlist. Administrator imports reference a
 * provider ID; no browser or imported game can select an arbitrary network URL. */
export function loadTrustedProviderDefinitions(encoded,allowedIds){
  if(!(allowedIds instanceof Set)||!allowedIds.size)throw new TypeError('Missing provider IDs');
  if(encoded===undefined||encoded==='')return new Map();
  if(typeof encoded!=='string'||Buffer.byteLength(encoded)>16384)throw new TypeError('Invalid provider definitions');
  let value;try{value=JSON.parse(encoded);}catch{throw new TypeError('Invalid provider definitions');}
  if(!value||typeof value!=='object'||Array.isArray(value))throw new TypeError('Invalid provider definitions');
  const result=new Map();
  for(const [id,item] of Object.entries(value)){
    if(!allowedIds.has(id)||!item||typeof item!=='object'||Array.isArray(item)||Object.keys(item).some(key=>!['endpoint','includeStreamUsage'].includes(key))||typeof item.endpoint!=='string'||item.includeStreamUsage!==undefined&&typeof item.includeStreamUsage!=='boolean')throw new TypeError('Invalid provider definitions');
    result.set(id,{endpoint:endpointURL(item.endpoint),includeStreamUsage:item.includeStreamUsage===true});
  }
  return result;
}
