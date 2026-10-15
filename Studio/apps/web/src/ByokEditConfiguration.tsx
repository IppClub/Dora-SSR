import {useEffect,useRef,useState} from 'react';
import {decodeByokConfigurations,type ByokConfiguration} from './byok-configurations-client';
import {requestConfiguration} from './ByokCreateConfiguration';

export function ByokEditConfiguration({configuration,onSaved}:{configuration:ByokConfiguration;onSaved:(value:ByokConfiguration)=>void}) {
  const [label,setLabel]=useState(configuration.label),[model,setModel]=useState(configuration.model),[enabled,setEnabled]=useState(configuration.enabled);
  const [state,setState]=useState<'idle'|'saving'|'uncertain'>('idle');
  const [checking,setChecking]=useState(false),[checkFailed,setCheckFailed]=useState(false);
  const checkBusy=useRef(false);
  const live=useRef<{active:boolean;busy:boolean;controller:AbortController}|undefined>(undefined);
  useEffect(()=>{const context={active:true,busy:false,controller:new AbortController()};live.current=context;return()=>{context.active=false;context.controller.abort();};},[]);
  const valid=(value:string)=>value.trim().length>0&&value.length<=256&&!/[\u0000-\u001f\u007f]/.test(value);
  return <form className="model-config-create" onSubmit={event=>{
    event.preventDefault();const context=live.current;
    if(!context?.active||context.busy||state!=='idle'||!valid(label)||!valid(model))return;
    context.busy=true;setState('saving');
    void requestConfiguration(`/api/byok/configurations/${encodeURIComponent(configuration.id)}`,context.controller.signal,{label:label.trim(),model:model.trim(),enabled,providerId:configuration.providerId,expectedVersion:configuration.version}).then(value=>{
      const saved=decodeByokConfigurations({version:1,configurations:[value],nextCursor:null}).configurations[0];
      if(!saved||saved.id!==configuration.id||saved.version!==configuration.version+1||saved.providerId!==configuration.providerId||saved.label!==label.trim()||saved.model!==model.trim()||saved.enabled!==enabled)throw new Error('Invalid configuration receipt');
      if(context.active)onSaved(saved);
    }).catch(()=>{if(context.active)setState('uncertain');});
  }}>
    <h3>编辑 API 配置</h3>
    <p>修改不会调用模型或更换已托管的密钥。供应商保持不变；如需更换供应商，请新建配置。</p>
    <label className="model-config-select">配置名称<input value={label} maxLength={256} disabled={state!=='idle'} onChange={event=>setLabel(event.target.value)}/></label>
    <label className="model-config-select">模型标识<input value={model} maxLength={256} disabled={state!=='idle'} onChange={event=>setModel(event.target.value)}/></label>
    <label><input type="checkbox" checked={enabled} disabled={state!=='idle'} onChange={event=>setEnabled(event.target.checked)}/>启用此配置</label>
    <button type="submit" disabled={state!=='idle'||!valid(label)||!valid(model)}>{state==='saving'?'正在保存…':'保存配置'}</button>
    {state==='uncertain'&&<><p role="alert">未能确认保存结果，配置也可能已被其他页面修改。请刷新配置核对当前状态，不要重复提交；不会自动重试。</p>
      <button type="button" disabled={checking} onClick={()=>{
        const context=live.current;if(!context?.active||checkBusy.current)return;
        checkBusy.current=true;setChecking(true);setCheckFailed(false);
        void requestConfiguration(`/api/byok/configurations/${encodeURIComponent(configuration.id)}`,context.controller.signal).then(value=>{
          const saved=decodeByokConfigurations({version:1,configurations:[value],nextCursor:null}).configurations[0];
          if(!saved||saved.id!==configuration.id||saved.version<=configuration.version||saved.providerId!==configuration.providerId||saved.label!==label.trim()||saved.model!==model.trim()||saved.enabled!==enabled)throw new Error('Unmatched current configuration');
          if(context.active)onSaved(saved);
        }).catch(()=>{if(context.active)setCheckFailed(true);}).finally(()=>{checkBusy.current=false;if(context.active)setChecking(false);});
      }}>{checking?'正在核对…':'核对保存结果'}</button>
      {checkFailed&&<p role="status">暂未核实到匹配的当前配置。请稍后再核对，或刷新配置查看其他页面的修改；不会重新发送保存请求。</p>}
    </>}
  </form>;
}
