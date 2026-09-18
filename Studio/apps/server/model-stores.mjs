import {isAbsolute} from 'node:path';
import {openModelConfigurationStore} from './model-configuration-store.mjs';
import {openModelLedger} from './model-ledger-sqlite.mjs';
import {openModelSecretVault} from './model-secret-vault.mjs';

/** Trusted deployment assembly. No generated keys, implicit path, or relaxed
 * dispatch option. Drain active requests before closing these owned stores. */
export function openModelStores({path,providerIds,maxByokConfigurationsPerAccount=100,activeKeyId,keys}) {
  if(typeof path!=='string'||!isAbsolute(path))throw new TypeError('Model database requires an absolute file path');
  const opened=[];
  const cleanup=()=>{
    const errors=[];
    while(opened.length){try{opened.pop().close();}catch(error){errors.push(error);}}
    if(errors.length)throw new AggregateError(errors,'Model store shutdown failed');
  };
  try{
    const vault=openModelSecretVault(path,{activeKeyId,keys});opened.push(vault);
    const catalog=openModelConfigurationStore(path,{providerIds,maxByokConfigurationsPerAccount});opened.push(catalog);
    const ledger=openModelLedger(path,{requireConfigurationVersion:true});opened.push(ledger);
    return {vault,catalog,ledger,close:cleanup};
  }catch(error){
    try{cleanup();}catch(cleanupError){throw new AggregateError([error,cleanupError],'Model store initialization failed');}
    throw error;
  }
}
