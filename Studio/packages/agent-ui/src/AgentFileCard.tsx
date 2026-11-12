import React from 'react';
import Box from '@mui/material/Box';
import InsertDriveFileOutlinedIcon from '@mui/icons-material/InsertDriveFileOutlined';

function fileSize(bytes:number){
 if(bytes>=1024**3)return `${(bytes/1024**3).toFixed(1)} GB`;
 if(bytes>=1024**2)return `${(bytes/1024**2).toFixed(1)} MB`;
 if(bytes>=1024)return `${(bytes/1024).toFixed(1)} KB`;
 return `${bytes} B`;
}
/** Fixed geometry keeps short and long filenames aligned in attachment rows. */
export function AgentFileCard({name,size}:{name:string;size?:number}){
 const extension=name.includes('.')?name.split('.').at(-1)?.slice(0,10).toUpperCase():'FILE';
 return <Box data-agent-file-card title={name} sx={{width:160,height:112,boxSizing:'border-box',flexShrink:0,border:'1px solid #ffffff20',borderRadius:1.5,backgroundColor:'#161616',p:1.5,display:'flex',flexDirection:'column',gap:.75}}>
  <Box sx={{display:'flex',alignItems:'center',gap:.75,pr:2.5,color:'#aaa'}}><InsertDriveFileOutlinedIcon sx={{fontSize:23,flexShrink:0}}/><Box sx={{fontSize:10,fontWeight:600,letterSpacing:'.04em',overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{extension||'FILE'}</Box></Box>
  <Box sx={{color:'#eee',fontSize:12,fontWeight:500,lineHeight:1.4,overflowWrap:'anywhere',overflow:'hidden',display:'-webkit-box',WebkitLineClamp:2,WebkitBoxOrient:'vertical'}}>{name}</Box>
  {size!==undefined?<Box sx={{mt:'auto',color:'#aaa',fontSize:10,lineHeight:1}}>{fileSize(size)}</Box>:null}
 </Box>;
}
