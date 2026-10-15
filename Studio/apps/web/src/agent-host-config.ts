export interface AgentHostConfig {
  version:1;parentOrigin:string;accountId:string;projectId:string;generation:string;projectRoot:string;title:string;
}

/** Validates shape, not authorization. Only trusted provisioning may supply it. */
export function decodeAgentHostConfig(value:unknown):Readonly<AgentHostConfig> {
  if(!value || typeof value!=='object' || Array.isArray(value))throw new Error('Invalid Agent host configuration');
  const input=value as Record<string,unknown>;
  const keys=['version','parentOrigin','accountId','projectId','generation','projectRoot','title'];
  if(Object.keys(input).length!==keys.length || Object.keys(input).some(key=>!keys.includes(key)) || input.version!==1)throw new Error('Invalid Agent host configuration fields');
  for(const key of keys.slice(1))if(typeof input[key]!=='string' || (input[key] as string).length>1024
    || (key!=='title' && !(input[key] as string).length) || /[\u0000-\u001f\u007f]/.test(input[key] as string)
    || [...input[key] as string].some(character=>/^[\ud800-\udfff]$/.test(character)))throw new Error('Invalid Agent host configuration value');
  const config={...input} as unknown as AgentHostConfig;
  const origin=new URL(config.parentOrigin);
  if(!['http:','https:'].includes(origin.protocol) || origin.origin!==config.parentOrigin)throw new Error('Invalid Agent parent origin');
  if(!config.projectRoot.startsWith('/') || config.projectRoot.includes('\\')
    || config.projectRoot.slice(1).split('/').some(part=>!part || part==='.' || part==='..'))throw new Error('Invalid Agent project root');
  return Object.freeze(config);
}
