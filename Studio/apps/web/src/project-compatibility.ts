import type {StudioMessage} from './i18n';
import type {ProjectSnapshot} from '@dora-studio/contracts';
/** Static observations only: never a build or runtime certification. */
export function inspectProjectCompatibility(snapshot:ProjectSnapshot) {
  const extension=snapshot.entry.split('.').at(-1)?.toLowerCase()??'';
  const entrySupported=['ts','tsx','lua','tl'].includes(extension);
  const warnings:StudioMessage[]=[];
  if(!entrySupported)warnings.push(['projects.unsupportedEntryWarning', {entry: snapshot.entry}]);
  const pending=snapshot.files.filter(file=>/\.(yue|xml)$/i.test(file.path));
  if(pending.length&&entrySupported)warnings.push(['projects.yueXmlWarning', {count: pending.length}]);
  const wasm=snapshot.files.filter(file=>/\.wasm$/i.test(file.path)).length;
  if(wasm)warnings.push(['projects.wasmWarning', {count: wasm}]);
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
    }catch{warnings.push(['projects.invalidManifestWarning']);}
  }
  return {entrySupported,declaredEngine,warnings};
}
