const profiles=new Map([
  ['deepseek',Object.freeze({
    id:'deepseek',label:'DeepSeek',contextWindow:1000000,temperature:0.1,maxTokens:64000,supportsFunctionCalling:true,
    auxiliaryOptions:Object.freeze({max_tokens:8192,reasoning_effort:null,thinking:Object.freeze({type:'disabled'})}),
    vision:Object.freeze({provider:'deepseek',model:'deepseek-flash'}),
  })],
  ['zai',Object.freeze({
    id:'zai',label:'ZAI',contextWindow:128000,temperature:0.1,maxTokens:8192,supportsFunctionCalling:true,
    auxiliaryOptions:Object.freeze({max_tokens:8192,reasoning_effort:null,thinking:Object.freeze({type:'disabled'})}),
    vision:Object.freeze({provider:'glm-coding-cn',model:'glm-5.3-flash'}),
  })],
  ['openai',Object.freeze({
    id:'openai',label:'OpenAI',contextWindow:128000,temperature:0.1,maxTokens:8192,supportsFunctionCalling:true,
    auxiliaryOptions:Object.freeze({max_tokens:null,max_completion_tokens:8192,reasoning_effort:'none'}),
  })],
]);

export const agentProviderCatalog=Object.freeze([...profiles.values()].map(profile=>Object.freeze({id:profile.id,label:profile.label})));

export function createAgentProviderIds(){return new Set(profiles.keys());}

export function getAgentProviderProfile(providerId){return profiles.get(providerId);}
