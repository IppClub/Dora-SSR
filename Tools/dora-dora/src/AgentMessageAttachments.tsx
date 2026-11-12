import React from 'react';
import {SharedAgentAttachmentGallery,type AgentMessageAttachment} from '@dora-studio/agent-ui';
import * as Service from './Service';
export const AgentAttachmentProjectContext=React.createContext<string|undefined>(undefined);
export default function AgentMessageAttachments({attachments}:{attachments:AgentMessageAttachment[]}){
 const projectRoot=React.useContext(AgentAttachmentProjectContext);
 const loadImage=React.useCallback(async(path:string,signal:AbortSignal)=>{
  if(!projectRoot)throw new Error('No attachment project');
  const fullPath=projectRoot.replace(/\\/g,'/').replace(/\/+$/,'')+'/'+path;
  // Encode the entire absolute path so it stays on this origin, including its
  // leading slash. Fetch uses the existing authenticated Web IDE transport.
  const response=await fetch(Service.addr('/'+encodeURIComponent(fullPath)),{signal});
  if(!response.ok)throw new Error('Attachment unavailable');
  return response.blob();
 },[projectRoot]);
 return <SharedAgentAttachmentGallery attachments={attachments} loadImage={loadImage}/>;
}
