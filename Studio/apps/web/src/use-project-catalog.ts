import {useCallback,useEffect,useMemo,useRef,useState} from 'react';
import type {LocalWorkspace,ProjectSummary} from './workspace';
import {listCloudProjects} from './cloud-project-client';
import {mergeProjectCatalog,type CloudProjectSummary,type ProjectCatalogItem} from './project-catalog';

export type ProjectCatalogState='idle'|'loading'|'ready'|'failed';

async function readRemoteCatalog(accountId:string,signal:AbortSignal){
 const items:CloudProjectSummary[]=[],seen=new Set<string>();let after='',pages=0;
 do{
  const page=await listCloudProjects(signal,after,accountId);
  for(const item of page.items)if(!seen.has(item.projectId)){seen.add(item.projectId);items.push(item);}
  after=page.nextCursor??'';pages++;
 }while(after&&pages<100);
 return items;
}

/** One project identity regardless of where its latest durable copy lives. */
export function useProjectCatalog(store:LocalWorkspace|null,accountId?:string){
 const [local,setLocal]=useState<ProjectSummary[]>([]),[remote,setRemote]=useState<CloudProjectSummary[]>([]);
 const [state,setState]=useState<ProjectCatalogState>('idle');
 const remoteAbort=useRef<AbortController|undefined>(undefined);const remoteReading=useRef(false);
 const refreshLocal=useCallback(async()=>{if(!store){setLocal([]);return [];}const next=await store.list();setLocal(next);return next;},[store]);
 const refreshRemote=useCallback(async()=>{
  if(!accountId){setRemote([]);setState('idle');return [] as CloudProjectSummary[];}
  if(remoteReading.current)return [] as CloudProjectSummary[];
  remoteReading.current=true;remoteAbort.current?.abort();const operation=new AbortController();remoteAbort.current=operation;
  setState(current=>current==='ready'?'ready':'loading');
  try{const next=await readRemoteCatalog(accountId,operation.signal);if(!operation.signal.aborted){setRemote(next);setState('ready');}return next;}
  catch(error){if(!operation.signal.aborted)setState('failed');throw error;}
  finally{if(remoteAbort.current===operation){remoteReading.current=false;remoteAbort.current=undefined;}}
 },[accountId]);
 useEffect(()=>{void refreshLocal();},[refreshLocal]);
 useEffect(()=>{
  remoteAbort.current?.abort();remoteReading.current=false;setRemote([]);
  if(!accountId){setState('idle');return;}
  const refresh=()=>{if(document.visibilityState==='visible')void refreshRemote().catch(()=>{});};
  const timer=setInterval(refresh,30000);addEventListener('focus',refresh);document.addEventListener('visibilitychange',refresh);refresh();
  return()=>{clearInterval(timer);removeEventListener('focus',refresh);document.removeEventListener('visibilitychange',refresh);remoteAbort.current?.abort();remoteReading.current=false;};
 },[accountId,refreshRemote]);
 const items=useMemo(()=>mergeProjectCatalog(local,remote),[local,remote]);
 const refresh=useCallback(async()=>{const [localResult]=await Promise.all([refreshLocal(),refreshRemote().catch(()=>remote)]);return localResult;},[refreshLocal,refreshRemote,remote]);
 return {items,local,remote,state,refreshLocal,refreshRemote,refresh};
}
