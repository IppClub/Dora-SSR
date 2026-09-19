import createModule from './compiler.mjs';
import {validateSnapshot,isProjectPath} from '@dora-studio/contracts';

let accepted=false;
self.onmessage=async event=>{
  if(accepted)return;accepted=true;
  const {id,snapshot,path}=event.data??{};
  const send=result=>self.postMessage({id,type:'result',...result});
  try{
    if(typeof id!=='string'||!id||!isProjectPath(path)||!path.endsWith('.yarn')||validateSnapshot(snapshot).length)throw new Error('Invalid Yarn build request');
    const source=snapshot.files.find(file=>file.path===path);
    if(source?.kind!=='text'||typeof source.text!=='string'||new TextEncoder().encode(source.text).byteLength>524288)throw new Error('Invalid Yarn source');
    const module=await createModule(),bytes=new TextEncoder().encode(source.text),pointer=module._malloc(Math.max(1,bytes.length));
    if(!pointer)throw new Error('Yarn compiler allocation failed');
    let failed;
    try{module.HEAPU8.set(bytes,pointer);failed=module.cwrap('yarn_check_file','number',['number','number'])(pointer,bytes.length);}
    finally{module._free(pointer);}
    if(!failed){send({success:true});return;}
    const message=module.cwrap('yarn_error_message','string',[])();
    const node=module.cwrap('yarn_error_node','string',[])();
    const line=module.cwrap('yarn_error_line','number',[])(),column=module.cwrap('yarn_error_column','number',[])();
    const lineText=source.text.split(/\r?\n/)[line-1]??'';
    send({success:false,message:`${node?`node: ${node}, `:''}line ${line}, col ${column}: ${lineText}\nerror: ${message}`});
  }catch(error){send({success:false,message:error instanceof Error?error.message:'Yarn compiler failed'});}
};
