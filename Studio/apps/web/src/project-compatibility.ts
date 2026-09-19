import type {ProjectSnapshot} from '@dora-studio/contracts';
/** Static observations only: never a build or runtime certification. */
export function inspectProjectCompatibility(snapshot:ProjectSnapshot) {
  const extension=snapshot.entry.split('.').at(-1)?.toLowerCase()??'';
  const entrySupported=['ts','tsx','lua','tl'].includes(extension);
  const warnings:string[]=[];
  if(!entrySupported)warnings.push(`当前入口 ${snapshot.entry} 的编译尚未接通，源码仍可编辑和导出。`);
  const pending=snapshot.files.filter(file=>/\.(yue|xml)$/i.test(file.path));
  if(pending.length&&entrySupported)warnings.push(`包含 ${pending.length} 个 Yue/XML 文件；若项目依赖它们，当前编译链可能无法完成。`);
  const wasm=snapshot.files.filter(file=>/\.wasm$/i.test(file.path)).length;
  if(wasm)warnings.push(`包含 ${wasm} 个 Wasm 文件，尚未验证其加载方式、接口与浏览器兼容性。`);
  let declaredEngine:string|undefined;
  const manifest=snapshot.files.find(file=>file.path==='dora-package.json');
  if(manifest){
    try{
      if(manifest.kind!=='text'||manifest.text.length>65536)throw new Error('Invalid metadata');
      const parsed=JSON.parse(manifest.text.replace(/^\ufeff/,''));
      if(!parsed||typeof parsed!=='object'||Array.isArray(parsed))throw new Error('Invalid metadata');
      if(parsed.engineVersion!==undefined){
        if(typeof parsed.engineVersion!=='string'||!parsed.engineVersion.trim()||parsed.engineVersion.length>120)throw new Error('Invalid version');
        declaredEngine=parsed.engineVersion;
      }
    }catch{warnings.push('原包元数据无法识别；文件已保留，未根据它判断运行兼容性。');}
  }
  return {entrySupported,declaredEngine,warnings};
}
