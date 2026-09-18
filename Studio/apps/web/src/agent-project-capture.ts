import {isProjectPath} from '@dora-studio/contracts';

export interface AgentProjectCapture {
  projectId:string;generation:string;sessionId:number;
  reconciliationRequired:true;
  files:Array<{path:string;bytes:Uint8Array}>;
}

/** Validate before copying any byte arrays. This does not authorize a write. */
export function decodeAgentProjectCapture(value:unknown,binding:{projectId:string;generation:string;sessionId:number}):AgentProjectCapture {
  const input=value as AgentProjectCapture|null;
  if(!input||input.projectId!==binding.projectId||input.generation!==binding.generation||input.sessionId!==binding.sessionId||
    !binding.projectId||!binding.generation||!Number.isSafeInteger(binding.sessionId)||binding.sessionId<=0||input.reconciliationRequired!==true||!Array.isArray(input.files)||input.files.length>4096)
    throw new Error('Invalid Agent project capture binding');
  let total=0;const paths=new Set<string>();
  for(const file of input.files){
    if(!file||typeof file.path!=='string'||!isProjectPath(file.path)||file.path==='.agent'||file.path.startsWith('.agent/')||paths.has(file.path)||!(file.bytes instanceof Uint8Array)||
      (typeof SharedArrayBuffer!=='undefined'&&file.bytes.buffer instanceof SharedArrayBuffer)||file.bytes.byteLength>64*1024*1024||(total+=file.bytes.byteLength)>256*1024*1024)
      throw new Error('Invalid Agent project capture files');
    paths.add(file.path);
  }
  return {...binding,reconciliationRequired:true,files:input.files.map(file=>({path:file.path,bytes:new Uint8Array(file.bytes)}))};
}
