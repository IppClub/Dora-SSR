import {type StudioTranslate, useStudioI18n} from './i18n';
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
function describe(t:StudioTranslate,row:Snapshot|null){return row?`${row.enabled?t('admin.enabled'):t('admin.disabled')} · ${row.administrator===undefined?t('admin.unrecordedPermissions'):row.administrator?t('admin.administrator'):t('admin.creator')} · v${row.version}`:t('admin.accountMissing');}
export function AdminAccountAudit(){
  const {t, date} = useStudioI18n();
  const [after,setAfter]=useState(0),[refresh,setRefresh]=useState(0),[page,setPage]=useState<Page>(),[failed,setFailed]=useState(false);
  useEffect(()=>{
    let active=true;const controller=new AbortController();setPage(undefined);setFailed(false);
    void requestConfiguration(`/api/admin/account-audit?limit=20&after=${after}`,controller.signal).then(value=>{const result=decode(value,after);if(active)setPage(result);}).catch(()=>{if(active)setFailed(true);});
    return()=>{active=false;controller.abort();};
  },[after,refresh]);
  return <section aria-label={t('admin.accountAudit')}><p>{t('admin.auditDescription')}</p><button onClick={()=>setRefresh(value=>value+1)}>{t('admin.refreshAudit')}</button>
    {!page?<p role="status">{failed?t('admin.auditFailed'):t('admin.loadingAudit')}</p>:<>
      <ul className="admin-account-list">{page.items.map(row=><li key={row.sequence}><strong>{row.after.accountId}</strong><span>{t('admin.auditEntry', {sequence: row.sequence, actor: row.actorId})}</span><time dateTime={new Date(row.createdAt).toISOString()}>{date(row.createdAt, true)}</time><span>{t('admin.auditBefore', {snapshot: describe(t,row.before)})}</span><span>{t('admin.auditAfter', {snapshot: describe(t,row.after)})}</span></li>)}</ul>
      {!page.items.length&&<p>{t('admin.noAudit')}</p>}
      <div className="model-config-toolbar">{after>0&&<button onClick={()=>setAfter(0)}>{t('admin.firstAudit')}</button>}{page.nextCursor!==null&&<button onClick={()=>setAfter(page.nextCursor!)}>{t('admin.nextAudit')}</button>}</div>
    </>}
  </section>;
}
