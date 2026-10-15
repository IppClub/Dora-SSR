import {useEffect,useState} from 'react';
import {ModelAllowance} from './ModelAllowance';
import {loadModelGrants,type ModelGrantPage} from './model-grants-client';
export function PlatformModelSettings({initialGrantId}:{initialGrantId?:string|undefined}) {
  const [selected,setSelected]=useState(initialGrantId??''),[after,setAfter]=useState(''),[refresh,setRefresh]=useState(0);
  const [page,setPage]=useState<ModelGrantPage>(),[failed,setFailed]=useState(false);
  useEffect(()=>{
    const controller=new AbortController();let active=true;setPage(undefined);setFailed(false);
    void loadModelGrants(after,controller.signal).then(value=>{if(active)setPage(value);},()=>{if(active){setFailed(true);setSelected('');}});
    return()=>{active=false;controller.abort();};
  },[after,refresh]);
  const reload=()=>{setSelected('');setAfter('');setRefresh(value=>value+1);};
  const selectedConfiguration=page?.configurations.find(item=>item.grantId===selected);
  return <section><div className="model-config-toolbar"><h3>平台共享模型</h3><button onClick={reload}>刷新授权配置</button></div>
    <p>选择配置查看人民币使用额度，不会切换正在运行的模型。额度以实际请求准入时为准，不是供应商账户余额。</p>
    {!page?<p role="status">{failed?'授权配置暂时无法读取，请刷新重试。':'正在读取授权配置…'}</p>:<>
      {page.configurations.length?<label className="model-config-select">共享配置<select aria-label="查看共享模型额度" value={selected} onChange={event=>setSelected(event.target.value)}><option value="">请选择配置</option>{selected&&!page.configurations.some(item=>item.grantId===selected)&&<option value={selected}>当前配置</option>}{page.configurations.map(item=><option key={item.grantId} value={item.grantId}>{item.label} · {item.model}{item.enabled?'':' · 配置已停用'}</option>)}</select></label>:<p>本页没有可展示的授权配置。</p>}
      <div className="model-config-toolbar">{after&&<button onClick={reload}>返回授权首页</button>}{page.nextCursor&&<button onClick={()=>{setSelected('');setAfter(page.nextCursor!);}}>下一页授权</button>}</div>
    </>}
    {selectedConfiguration?.enabled===false?<p role="status">此共享配置已停用，当前不可用于调用。未将其历史额度显示为可用金额。</p>:selected?<ModelAllowance key={selected} grantId={selected}/>:<p>尚未选择获授权的共享模型配置。</p>}
  </section>;
}
