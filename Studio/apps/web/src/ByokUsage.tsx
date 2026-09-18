import {useEffect,useState} from 'react';
import {loadByokUsage,type ByokUsageReport} from './byok-usage-client';
import './byok-usage.css';
const number=(value:string)=>BigInt(value).toLocaleString('zh-CN');
export function ByokUsageView({report}:{report:ByokUsageReport}) {
  return <><div className="byok-usage-metrics"><div><span>已记录输入 Token</span><strong>{number(report.summary.inputTokens)}</strong></div><div><span>已记录输出 Token</span><strong>{number(report.summary.outputTokens)}</strong></div><div><span>待补记请求</span><strong>{number(report.summary.pendingUsageRequests)}</strong></div></div>
    <p>已知用量 {number(report.summary.knownUsageRequests)} 条 / 已登记 {number(report.summary.registeredRequests)} 条。未返回用量不计入已知 Token，不代表免费。</p>
    <div className="byok-usage-records">{report.records.length?report.records.map(row=><details key={row.requestId}><summary><span>{row.model}</span><b>{row.usage?'已记录':'待补记'}</b></summary><p>项目 {row.projectId}</p><p>{new Date(row.createdAt).toLocaleString('zh-CN')}</p>{row.usage?<><p>输入 {number(row.usage.inputTokens)} · 输出 {number(row.usage.outputTokens)}</p>{Object.entries(row.usage).filter(([key])=>!['inputTokens','outputTokens'].includes(key)).map(([key,count])=><p key={key}>{({totalTokens:'供应商报告总数',cachedInputTokens:'缓存命中',cacheMissInputTokens:'缓存未命中',cacheCreationInputTokens:'缓存创建',reasoningOutputTokens:'推理输出',inputAudioTokens:'音频输入',outputAudioTokens:'音频输出'} as Record<string,string>)[key]??key}：{number(count)}</p>)}</>:<p>用量尚未返回，等待补记。</p>}<small>请求 {row.requestId}</small></details>):<p>本页没有用量记录。</p>}</div></>;
}
export function ByokUsage({accountId}:{accountId:string}) {return <UsagePage key={accountId}/>;}
function UsagePage(){
  const [after,setAfter]=useState(''),[refresh,setRefresh]=useState(0);
  const [result,setResult]=useState<{after:string;report?:ByokUsageReport;failed?:boolean}>();
  useEffect(()=>{
    let active=true;const controller=new AbortController();setResult(undefined);
    void loadByokUsage(after,controller.signal).then(report=>{if(active)setResult({after,report});},()=>{if(active)setResult({after,failed:true});});
    return()=>{active=false;controller.abort();};
  },[after,refresh]);
  const current=result?.after===after?result:undefined;
  return <section className="byok-usage" aria-label="自带 API 用量"><header><h2>自带 API 用量</h2><button disabled={!current} onClick={()=>{setAfter('');setRefresh(value=>value+1);}}>刷新记录</button></header><p>只记录通过 Studio 发起的请求，不查询供应商余额。缓存与推理明细可能重叠，不重复加入总数。</p>
    {current?.report?<ByokUsageView report={current.report}/>:<p role="status">{current?.failed?'用量暂时无法读取，不代表没有消费。':'正在读取用量…'}</p>}
    <nav>{after&&<button disabled={!current} onClick={()=>setAfter('')}>返回首页</button>}{current?.report?.nextCursor&&<button onClick={()=>setAfter(current.report!.nextCursor!)}>下一页记录</button>}</nav>
  </section>;
}
