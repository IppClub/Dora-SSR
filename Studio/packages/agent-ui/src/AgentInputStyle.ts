import type {CSSProperties} from 'react';
import {AgentColor as Color} from './agent-theme';

export const AGENT_COMPOSER_MAX_WIDTH=980;

export const agentInputSurface=(compact=false)=>({
  border:`1px solid ${Color.Line}`,
  borderRadius:compact?2:3,
  backgroundColor:Color.BackgroundDark,
  overflow:'hidden',
  transition:'border-color 140ms ease',
  '&:focus-within':{borderColor:`${Color.Theme}88`},
});

/** Keep draft and queued-message editing consistent across browser defaults. */
export const agentTextAreaStyle=(compact=false):CSSProperties=>({
  display:'block',width:'100%',minHeight:compact?44:64,maxHeight:compact?160:220,
  padding:compact?'8px 10px 4px':'14px 16px 8px',border:'none',outline:'none',boxShadow:'none',
  appearance:'none',resize:'none',overflow:'hidden',backgroundColor:'transparent',
  color:Color.TextPrimary,font:'inherit',lineHeight:'1.65',boxSizing:'border-box',
});
