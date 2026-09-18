type Edit={start:number;end:number;lines:string[]};
const lines=(text:string)=>text.match(/[^\r\n]*(?:\r\n|\r|\n)|[^\r\n]+$/g)??[];
function edits(base:string[],target:string[]):Edit[]|null{
 const width=target.length+1;
 if((base.length+1)*width>1000000)return null;
 const table=new Uint32Array((base.length+1)*width);
 for(let i=base.length-1;i>=0;i--)for(let j=target.length-1;j>=0;j--)table[i*width+j]=base[i]===target[j]?1+table[(i+1)*width+j+1]!:Math.max(table[(i+1)*width+j]!,table[i*width+j+1]!);
 const result:Edit[]=[];let i=0,j=0,current:Edit|undefined;
 const flush=()=>{if(current){result.push(current);current=undefined;}};
 while(i<base.length||j<target.length){
  if(i<base.length&&j<target.length&&base[i]===target[j]){flush();i++;j++;continue;}
  current??={start:i,end:i,lines:[]};
  if(j<target.length&&(i===base.length||table[i*width+j+1]!>table[(i+1)*width+j]!)){current.lines.push(target[j++]!);}
  else{current.end=++i;}
 }
 flush();return result;
}
/** Exact newline/BOM preserving merge. null means explicit conflict or bounded
 * analysis limit, never permission to choose one side silently. */
export function mergeCloudText(base:string,local:string,remote:string):string|null{
 if(local===remote)return local;if(local===base)return remote;if(remote===base)return local;
 if(Math.max(base.length,local.length,remote.length)>1024*1024)return null;
 const original=lines(base),left=edits(original,lines(local)),right=edits(original,lines(remote));if(!left||!right)return null;
 const combined=[...left];
 for(const next of right){let duplicate=false;
  for(const prior of left){
   if(prior.start===next.start&&prior.end===next.end&&prior.lines.join('')===next.lines.join('')){duplicate=true;continue;}
   const insertion=prior.start===prior.end||next.start===next.end;
   if(insertion?prior.start<=next.end&&next.start<=prior.end:prior.start<next.end&&next.start<prior.end)return null;
  }
  if(!duplicate)combined.push(next);
 }
 combined.sort((a,b)=>a.start-b.start);const output:string[]=[];let cursor=0;
 for(const edit of combined){for(let i=cursor;i<edit.start;i++)output.push(original[i]!);for(const line of edit.lines)output.push(line);cursor=edit.end;}
 for(let i=cursor;i<original.length;i++)output.push(original[i]!);return output.join('');
}
