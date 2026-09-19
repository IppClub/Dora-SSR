import {useEffect,useRef,useState} from 'react';
import {ByokSecretSettings} from './ByokSecretSettings';
import {ByokUsage} from './ByokUsage';
import {PlatformModelSettings} from './PlatformModelSettings';
import {loadByokConfigurations,type ByokConfigurationPage,type ByokConfiguration} from './byok-configurations-client';
import './model-settings.css';
import {ByokCreateConfiguration} from './ByokCreateConfiguration';
import {ByokEditConfiguration} from './ByokEditConfiguration';

export function ModelSettings({accountId,modelGrantId}:{accountId:string;modelGrantId?:string|undefined}) {
  const [tab,setTab]=useState<'platform'|'byok'|'usage'>('byok');
  return <div className="model-settings"><nav aria-label="模型设置分类">{(['platform','byok','usage'] as const).map(value=><button key={value} aria-pressed={tab===value} onClick={()=>setTab(value)}>{({platform:'平台额度',byok:'自带 API',usage:'用量记录'})[value]}</button>)}</nav>
    {tab==='platform'?<PlatformModelSettings key={accountId} initialGrantId={modelGrantId}/>:tab==='usage'?<ByokUsage accountId={accountId}/>:<ByokConfigurations key={accountId} accountId={accountId}/>}
  </div>;
}
function ByokConfigurations({accountId}:{accountId:string}) {
  const [creating,setCreating]=useState(false);
  const [created,setCreated]=useState<ByokConfiguration>();
  const [after,setAfter]=useState(''),[refresh,setRefresh]=useState(0),[selected,setSelected]=useState('');
  const [result,setResult]=useState<{after:string;page?:ByokConfigurationPage;failed?:boolean}>();
  useEffect(()=>{
    let active=true;const controller=new AbortController();setResult(undefined);setSelected('');
    void loadByokConfigurations(after,controller.signal).then(page=>{if(active)setResult({after,page});},()=>{if(active)setResult({after,failed:true});});
    return()=>{active=false;controller.abort();};
  },[after,refresh]);
  const current=result?.after===after?result:undefined,config=created??current?.page?.configurations.find(item=>item.id===selected);
  return <><div className="model-config-toolbar"><h3>我的 API 配置</h3><button disabled={!current} onClick={()=>{setCreated(undefined);setAfter('');setRefresh(value=>value+1);}}>刷新配置</button></div>
    <button onClick={()=>{setCreated(undefined);setSelected('');setCreating(value=>!value);}}>{creating?'关闭创建表单':'添加 API 配置'}</button>
    {creating&&<ByokCreateConfiguration onCreated={configuration=>{setCreated(configuration);setCreating(false);setAfter('');setRefresh(value=>value+1);}}/>}
    {created&&<p role="status">已确认配置“{created.label}”。可在下方授权托管密钥；未切换正在使用的模型。<button onClick={()=>setCreated(undefined)}>返回配置列表</button></p>}
    <p>选择配置以管理托管密钥，不会切换正在使用的模型。切换或刷新会清空未提交的密钥。</p>
    {!created&&(!current?.page?<p role="status">{current?.failed?'配置暂时无法读取，请重试。':'正在读取配置…'}</p>:<>
      {current.page.configurations.length?<label className="model-config-select">配置<select aria-label="选择自带 API 配置" value={selected} onChange={event=>setSelected(event.target.value)}><option value="">请选择配置</option>{current.page.configurations.map(item=><option key={item.id} value={item.id}>{item.label} · {item.model}{item.enabled?'':' · 已停用'}</option>)}</select></label>:<p>本页暂无自带 API 配置，可通过“添加 API 配置”创建。</p>}
      <div className="model-config-toolbar">{after&&<button onClick={()=>setAfter('')}>返回首页</button>}{current.page.nextCursor&&<button onClick={()=>setAfter(current.page!.nextCursor!)}>下一页配置</button>}</div>
    </>)}
    {config&&<ByokConfigurationDetails key={`${config.id}:${config.version}`} accountId={accountId} config={config} onSaved={saved=>{
      setCreated(saved);
      // Keep the loaded page consistent with the confirmed server version when
      // returning from details. Do not insert off-page items or change cursors.
      setResult(previous=>previous?.page?{...previous,page:{...previous.page,configurations:previous.page.configurations.map(item=>item.id===saved.id&&item.version<=saved.version?saved:item)}}:previous);
    }}/>}
  </>;
}
function ByokConfigurationDetails({accountId,config,onSaved}:{accountId:string;config:ByokConfiguration;onSaved:(value:ByokConfiguration)=>void}) {
  const [editing,setEditing]=useState(false);
  return <>{!config.enabled&&<p className="model-config-warning">此配置已停用。可以管理密钥，但不代表允许调用。</p>}
    <button onClick={()=>setEditing(value=>!value)}>{editing?'关闭编辑表单':'编辑配置'}</button>
    {editing?<ByokEditConfiguration configuration={config} onSaved={onSaved}/>:<ByokSecretSettings accountId={accountId} configurationId={config.id} label={config.label}/>}
  </>;
}
export function ModelSettingsDialog({accountId,modelGrantId,onClose}:{accountId:string;modelGrantId?:string|undefined;onClose:()=>void}) {
  const dialog=useRef<HTMLDialogElement>(null);
  useEffect(()=>{const element=dialog.current;element?.showModal();return()=>element?.close();},[]);
  return <dialog ref={dialog} className="model-settings-dialog" aria-label="模型与用量设置" onCancel={event=>{event.preventDefault();onClose();}}><header><h2>模型与用量</h2><button autoFocus aria-label="关闭模型设置" onClick={onClose}>关闭</button></header><ModelSettings key={accountId} accountId={accountId} modelGrantId={modelGrantId}/></dialog>;
}
