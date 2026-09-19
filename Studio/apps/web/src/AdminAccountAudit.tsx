import {useEffect,useState} from 'react';
import {requestConfiguration} from './ByokCreateConfiguration';

type Snapshot={accountId:string;enabled:boolean;administrator?:boolean|undefined;version:number};
type Entry={sequence:number;actorId:string;before:Snapshot|null;after:Snapshot;createdAt:number};
type Page={items:Entry[];nextCursor:number|null};
function identity(value:unknown):value is string{return typeof value==='string'&&!!value.trim()&&value.length<=256&&!/[\u0000-\u001f\u007f]/.test(value);}
function snapshot(value:unknown):Snapshot{
  const row=value as Snapshot;
  if(!row||!identity(row.accountId)||typeof row.enabled!=='boolean'||row.administrator!==undefined&&typeof row.administrator!=='boolean'||!Number.isSafeInteger(row.version)||row.version<1)throw new Error('Invalid audit snapshot');
  return {accountId:row.accountId,enabled:row.enabled,administrator:row.administrator,version:row.version};
}
function decode(value:unknown,after:number):Page{
  const data=value as {version:number;items:Entry[];nextCursor:number|null};
  if(!data||data.version!==1||!Array.isArray(data.items)||data.items.length>100)throw new Error('Invalid audit page');
  let previous=after;
  const items=data.items.map(row=>{
    if(!row||!Number.isSafeInteger(row.sequence)||row.sequence<=previous||!identity(row.actorId)||!Number.isSafeInteger(row.createdAt)||row.createdAt<0||!Number.isFinite(new Date(row.createdAt).getTime()))throw new Error('Invalid audit entry');
    previous=row.sequence;
    const before=row.before===null?null:snapshot(row.before),next=snapshot(row.after);
    if(before&&before.accountId!==next.accountId)throw new Error('Invalid audit target');
    return {sequence:row.sequence,actorId:row.actorId,before,after:next,createdAt:row.createdAt};
  });
  if(data.nextCursor!==null&&(!items.length||data.nextCursor!==previous))throw new Error('Invalid audit cursor');
  return {items,nextCursor:data.nextCursor};
}
function describe(row:Snapshot|null){return row?`${row.enabled?'已启用':'已停用'} · ${row.administrator===undefined?'权限未记录':row.administrator?'管理员':'创作者'} · v${row.version}`:'账号不存在';}
export function AdminAccountAudit(){
  const [after,setAfter]=useState(0),[refresh,setRefresh]=useState(0),[page,setPage]=useState<Page>(),[failed,setFailed]=useState(false);
  useEffect(()=>{
    let active=true;const controller=new AbortController();setPage(undefined);setFailed(false);
    void requestConfiguration(`/api/admin/account-audit?limit=20&after=${after}`,controller.signal).then(value=>{const result=decode(value,after);if(active)setPage(result);}).catch(()=>{if(active)setFailed(true);});
    return()=>{active=false;controller.abort();};
  },[after,refresh]);
  return <section aria-label="账号操作记录"><p>按操作顺序查看账号变更。历史记录未保存的权限显示为“权限未记录”。</p><button onClick={()=>setRefresh(value=>value+1)}>刷新操作记录</button>
    {!page?<p role="status">{failed?'无法读取操作记录，请确认管理权限后重试。':'正在读取操作记录…'}</p>:<>
      <ul className="admin-account-list">{page.items.map(row=><li key={row.sequence}><strong>{row.after.accountId}</strong><span>记录 #{row.sequence} · 操作者：{row.actorId}</span><time dateTime={new Date(row.createdAt).toISOString()}>{new Date(row.createdAt).toLocaleString()}</time><span>修改前：{describe(row.before)}</span><span>修改后：{describe(row.after)}</span></li>)}</ul>
      {!page.items.length&&<p>本页没有操作记录。</p>}
      <div className="model-config-toolbar">{after>0&&<button onClick={()=>setAfter(0)}>返回记录首页</button>}{page.nextCursor!==null&&<button onClick={()=>setAfter(page.nextCursor!)}>下一页操作记录</button>}</div>
    </>}
  </section>;
}
