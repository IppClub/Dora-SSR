import {useEffect,useRef,useState} from 'react';
import {decodeByokConfigurations,type ByokConfiguration} from './byok-configurations-client';
class ConfigurationCapacityError extends Error {}

export async function requestConfiguration(path:string,signal:AbortSignal,body?:unknown) {
  const operation=AbortSignal.any([signal,AbortSignal.timeout(10000)]);
  operation.throwIfAborted();
  const response=await fetch(path,{method:body?'PUT':'GET',credentials:'same-origin',cache:'no-store',redirect:'error',signal:operation,...(body?{headers:{'Content-Type':'application/json'},body:JSON.stringify(body)}:{})});
  if(body&&response.status===429)throw new ConfigurationCapacityError();
  if(!response.ok||!response.body)throw new Error('Unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){operation.throwIfAborted();const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>131072)throw new Error('Too large');chunks.push(value);}}
  finally{await reader.cancel();reader.releaseLock();}
  operation.throwIfAborted();const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes));
}
const request=requestConfiguration;
export function ByokCreateConfiguration({onCreated}:{onCreated:(configuration:ByokConfiguration)=>void}) {
  const [providers,setProviders]=useState<{id:string;label:string}[]>(),[failed,setFailed]=useState(false);
  const [label,setLabel]=useState(''),[model,setModel]=useState(''),[providerId,setProvider]=useState('');
  const [state,setState]=useState<'idle'|'saving'|'uncertain'|'limited'>('idle');
  const pendingId=useRef<string|undefined>(undefined);
  const [checking,setChecking]=useState(false),[checkFailed,setCheckFailed]=useState(false);
  const checkBusy=useRef(false);
  const context=useRef<{active:boolean;busy:boolean;controller:AbortController}|undefined>(undefined);
  useEffect(()=>{
    const current={active:true,busy:false,controller:new AbortController()};context.current=current;
    void request('/api/byok/providers',current.controller.signal).then(value=>{
      const ids=new Set<string>();
      if(value?.version!==1||!Array.isArray(value.providers)||value.providers.length>100)throw new Error('Invalid providers');
      for(const item of value.providers){if(!item||Object.keys(item).some(key=>!['id','label'].includes(key))||![item.id,item.label].every(value=>typeof value==='string'&&value.trim()&&value.length<=256)||ids.has(item.id))throw new Error('Invalid provider');ids.add(item.id);}
      if(current.active)setProviders(value.providers);
    }).catch(()=>{if(current.active)setFailed(true);});
    return()=>{current.active=false;current.controller.abort();};
  },[]);
  const valid=(value:string)=>value.trim().length>0&&value.length<=256&&!/[\u0000-\u001f\u007f]/.test(value);
  return <form className="model-config-create" onSubmit={event=>{
    event.preventDefault();const current=context.current;
    if(!current?.active||current.busy||state!=='idle'||!valid(label)||!valid(model)||!providers?.some(item=>item.id===providerId))return;
    current.busy=true;setState('saving');const id=crypto.randomUUID();pendingId.current=id;
    void request(`/api/byok/configurations/${id}`,current.controller.signal,{label:label.trim(),model:model.trim(),providerId,enabled:true,expectedVersion:0}).then(value=>{
      const saved=decodeByokConfigurations({version:1,configurations:[value],nextCursor:null}).configurations[0];
      if(saved?.id!==id||saved.version!==1||saved.providerId!==providerId||saved.label!==label.trim()||saved.model!==model.trim()||!saved.enabled)throw new Error('Invalid receipt');
      if(current.active)onCreated(saved);
    }).catch(error=>{if(current.active)setState(error instanceof ConfigurationCapacityError?'limited':'uncertain');});
  }}>
    <h3>添加自带 API 配置</h3>
    {state==='limited'&&<p role="alert">创建请求受到平台限制。请联系管理员或稍后再试，已有配置仍可使用；不会自动重试。</p>}
    <p>先保存名称和模型，再单独授权托管 API Key。此操作不会调用模型或消耗平台额度。</p>
    {!providers?<p role="status">{failed?'供应商列表暂时无法读取，请关闭后重试。':'正在读取可用供应商…'}</p>:providers.length===0?<p>平台暂未开放自带 API 供应商。</p>:<>
      <label className="model-config-select">配置名称<input value={label} maxLength={256} disabled={state!=='idle'} onChange={event=>setLabel(event.target.value)} placeholder="例如：我的创作模型"/></label>
      <label className="model-config-select">供应商<select aria-label="供应商" value={providerId} disabled={state!=='idle'} onChange={event=>setProvider(event.target.value)}><option value="">请选择供应商</option>{providers.map(item=><option key={item.id} value={item.id}>{item.label}</option>)}</select></label>
      <label className="model-config-select">模型标识<input value={model} maxLength={256} disabled={state!=='idle'} onChange={event=>setModel(event.target.value)} placeholder="填写供应商提供的模型标识"/></label>
      <button disabled={state!=='idle'||!valid(label)||!valid(model)||!providerId} type="submit">{state==='saving'?'正在创建…':'创建配置'}</button>
    </>}
    {state==='uncertain'&&<><p role="alert">未能确认创建结果。请核对本次创建，不要直接重复创建。</p><button type="button" disabled={checking} onClick={()=>{
      const current=context.current,id=pendingId.current;if(!current?.active||!id||checkBusy.current)return;
      checkBusy.current=true;setChecking(true);setCheckFailed(false);
      void request(`/api/byok/configurations/${id}`,current.controller.signal).then(value=>{
        const saved=decodeByokConfigurations({version:1,configurations:[value],nextCursor:null}).configurations[0];
        if(saved?.id!==id||saved.providerId!==providerId||saved.label!==label.trim()||saved.model!==model.trim())throw new Error('Different configuration');
        if(current.active)onCreated(saved);
      }).catch(()=>{if(current.active)setCheckFailed(true);}).finally(()=>{checkBusy.current=false;if(current.active)setChecking(false);});
    }}>{checking?'正在核对…':'核对创建结果'}</button>{checkFailed&&<p role="status">暂未核实到匹配配置。原请求仍可能在处理中，请稍后再次核对；不会自动重新创建。</p>}</>}
  </form>;
}
