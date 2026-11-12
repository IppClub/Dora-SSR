import * as Service from './Service';
import {uploadFile} from './UploadFile';

/** Files stay in the draft until send. Unique directories avoid overwriting assets. */
export async function uploadAgentAttachment(projectRoot:string,file:File,id:string,signal?:AbortSignal):Promise<string>{
 signal?.throwIfAborted();
 // Control characters cannot be represented safely in an upload filename.
 // eslint-disable-next-line no-control-regex
 const name=Array.from(file.name.replace(/[\\/\u0000-\u001f<>:"|?*]/g,'_').replace(/^\.+/,'_').replace(/[ .]+$/,'')).slice(-60).join('')||'attachment';
 if(!/^[\w-]+$/.test(id))throw new Error('Invalid attachment identifier');
 const relative=`.agent/tmp/attachments/${id}/${name}`;
 const root=projectRoot.replace(/[\\/]+$/,'');
 const directory=`${root}/.agent/tmp/attachments/${id}`;
 const created=await Service.newFile({path:directory,content:'',folder:true});
 if(!created.success&&created.message!=='TargetExisted')throw new Error('无法创建附件目录');
 signal?.throwIfAborted();
 await uploadFile(Service.addr(`/upload?path=${encodeURIComponent(directory)}&name=${encodeURIComponent(name)}`),file,signal);
 const stored=await Service.exist({file:`${root}/${relative}`});
 if(!stored.success)throw new Error(`附件上传未完成：${name}`);
 return relative;
}
