import type {ProjectSummary} from './workspace';

export type CloudProjectSummary={projectId:string;name:string;cloudRevision:number;updatedAt:number};
export type ProjectCatalogItem={
 projectId:string;
 name:string;
 updatedAt:number;
 local?:ProjectSummary;
 remote?:CloudProjectSummary;
};

/** Storage location is an implementation detail: one identity produces one row. */
export function mergeProjectCatalog(local:readonly ProjectSummary[],remote:readonly CloudProjectSummary[]):ProjectCatalogItem[]{
 const remoteById=new Map(remote.map(item=>[item.projectId,item]));
 const result:ProjectCatalogItem[]=local.map(item=>{const cloud=remoteById.get(item.projectId),remoteNewer=cloud&&cloud.updatedAt>item.updatedAt;return {
  projectId:item.projectId,name:remoteNewer?cloud.name:item.name,updatedAt:Math.max(item.updatedAt,cloud?.updatedAt??0),
  local:item,...(cloud?{remote:cloud}:{}),
 };});
 const localIds=new Set(local.map(item=>item.projectId));
 for(const item of remote)if(!localIds.has(item.projectId))result.push({projectId:item.projectId,name:item.name,updatedAt:item.updatedAt,remote:item});
 return result.sort((a,b)=>b.updatedAt-a.updatedAt||a.projectId.localeCompare(b.projectId));
}
