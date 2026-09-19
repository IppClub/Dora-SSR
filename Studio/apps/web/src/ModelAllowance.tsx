import {useEffect,useState} from 'react';
import './model-allowance.css';

const amount=(value:unknown):value is string=>typeof value==='string'&&/^(0|[1-9][0-9]{0,59})$/.test(value);
type Balance={spent:string;reserved:string;limit:string};
export type ModelAllowanceData={grantId:string;state:string;available:string|null;account:Balance;grant:Balance};
export function decodeAllowance(value:unknown,grantId:string):ModelAllowanceData {
  const v=value as Record<string,unknown>|null;
  if(!v||v.version!==1||v.currency!=='CNY'||v.unit!=='nano-CNY'||v.funding!=='platform'||v.grantId!==grantId||!['available','unavailable','zero-capacity','insufficient-amount','concurrency'].includes(String(v.state)))throw new Error('Invalid allowance');
  for(const key of ['account','grant']){
    const row=v[key] as Record<string,unknown>|undefined;
    if(!row||!amount(row.spent)||!amount(row.reserved)||!amount(row.limit))throw new Error('Invalid amount');
  }
  if(v.available!==null&&!amount(v.available))throw new Error('Invalid available amount');
  if((v.state==='unavailable'||v.state==='zero-capacity')!==(v.available===null))throw new Error('Invalid allowance state');
  return structuredClone(v) as unknown as ModelAllowanceData;
}
export function formatNanoCny(value:string):string {
  if(!amount(value))throw new Error('Invalid amount');
  const nano=BigInt(value),cent=10000000n;
  if(nano>0n&&nano<cent)return '< ¥0.01';
  const cents=(nano+cent/2n)/cent;
  return `${nano%cent?'≈ ':''}¥${cents/100n}.${String(cents%100n).padStart(2,'0')}`;
}
const labels:Record<string,string>={available:'当前可用',concurrency:'并发已满，调用需排队','insufficient-amount':'可用额度已耗尽',unavailable:'配置或授权已停用','zero-capacity':'调用容量已停用'};
export function ModelAllowanceView({data}:{data:ModelAllowanceData}) {
  return <div className="model-allowance"><div className="model-allowance-heading"><span>平台模型额度</span><strong>{data.available===null?'不可用':formatNanoCny(data.available)}</strong></div>
    <span>{labels[data.state]}</span><details><summary>使用明细</summary><p>账号已使用 <b>{formatNanoCny(data.account.spent)}</b></p><p>账号暂时预留 <b>{formatNanoCny(data.account.reserved)}</b></p><p>当前配置已使用 <b>{formatNanoCny(data.grant.spent)}</b></p><small>两层额度不相加；预留未计入消费。此为平台服务额度，不是供应商余额。金额为展示近似值。</small></details></div>;
}
export function ModelAllowanceCompactView({data}:{data:ModelAllowanceData}) {
  return <span className="model-allowance-compact"><span>可用额度 {data.available===null?'不可用':formatNanoCny(data.available)}</span>{data.state!=='available'&&<small>{labels[data.state]}</small>}</span>;
}
/** A selected authorized grant comes from account settings, never a secret. */
export async function loadAllowance(grantId:string,signal:AbortSignal):Promise<ModelAllowanceData> {
  if(!/^[A-Za-z0-9_-]{1,128}$/.test(grantId))throw new Error('Invalid grant');
  signal.throwIfAborted();
  const response=await fetch(`/api/model-grants/${grantId}/allowance`,{credentials:'same-origin',cache:'no-store',redirect:'error',signal});
  if(!response.ok||!response.body)throw new Error('Unavailable');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{for(;;){signal.throwIfAborted();const {done,value}=await reader.read();if(done)break;size+=value.byteLength;if(size>65536)throw new Error('Oversize allowance');chunks.push(value);}}
  finally{await reader.cancel();reader.releaseLock();}
  signal.throwIfAborted();const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
  return decodeAllowance(JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(bytes)),grantId);
}
export function ModelAllowance({grantId,compact=false,refreshSignal}:{grantId:string;compact?:boolean;refreshSignal?:string|number}) {
  const [result,setResult]=useState<{grantId:string;data?:ModelAllowanceData;failed?:boolean}>();
  useEffect(()=>{
    let retired=false,active:AbortController|undefined,deadline:ReturnType<typeof setTimeout>|undefined;
    setResult(current=>current?.grantId===grantId?current:undefined);
    const refresh=()=>{
      active?.abort();if(deadline)clearTimeout(deadline);
      const controller=new AbortController();active=controller;deadline=setTimeout(()=>controller.abort(),10000);
      void loadAllowance(grantId,controller.signal).then(data=>{if(!retired&&active===controller)setResult({grantId,data});},()=>{if(!retired&&active===controller)setResult({grantId,failed:true});}).finally(()=>{if(active===controller){if(deadline)clearTimeout(deadline);deadline=undefined;}});
    };
    const onFocus=()=>refresh();
    const onVisibility=()=>{if(document.visibilityState==='visible')refresh();};
    refresh();
    const interval=setInterval(()=>{if(document.visibilityState==='visible')refresh();},10000);
    addEventListener('focus',onFocus);document.addEventListener('visibilitychange',onVisibility);
    return()=>{retired=true;clearInterval(interval);if(deadline)clearTimeout(deadline);active?.abort();removeEventListener('focus',onFocus);document.removeEventListener('visibilitychange',onVisibility);};
  },[grantId,refreshSignal]);
  const current=result?.grantId===grantId?result:undefined;
  if(compact)return <span role="status" aria-label="模型使用额度" className="model-allowance-inline">{current?.data?<ModelAllowanceCompactView data={current.data}/>:current?.failed?'额度暂时不可用':'额度更新中'}</span>;
  return <section aria-label="模型使用额度" className="model-allowance-container">
    {current?.data?<ModelAllowanceView data={current.data}/>:<div className="model-allowance" role="status">{current?.failed?'额度暂时无法读取，不代表余额为零。':'正在读取模型额度…'}</div>}
  </section>;
}
