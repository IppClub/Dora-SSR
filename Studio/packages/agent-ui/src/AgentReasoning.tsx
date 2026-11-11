import React, {useId, useLayoutEffect, useRef, useState} from 'react';
import './AgentReasoning.css';

// Streaming message records exist before the model has produced visible output.
export function hasAgentStepCard(step: {tool: string; reason: string}) {
  return step.tool !== 'message' || step.reason.trim() !== '';
}

export function AgentReasoning({content, active = false, thinkingLabel = '正在思考', label = '思考'}: {
  content: string;
  active?: boolean;
  thinkingLabel?: string;
  label?: string;
}) {
  const [open, setOpen] = useState(false);
  const panelId = useId();
  const panel = useRef<HTMLDivElement>(null);
  const preview = useRef<HTMLSpanElement>(null);
  const follow = useRef(true);
  useLayoutEffect(() => {
    if (preview.current) preview.current.scrollLeft = preview.current.scrollWidth;
    if (active && follow.current && panel.current) panel.current.scrollTop = panel.current.scrollHeight;
  }, [content, open, active]);
  if (!content.trim() && !active) return null;
  return <div data-agent-reasoning={active ? 'active' : 'archived'} style={{minWidth: 0, maxWidth: '100%', color: active ? '#eee' : '#bbb', fontSize: active ? '1rem' : '0.85em'}}>
    <button type="button" data-agent-thinking={active ? 'true' : undefined} aria-expanded={open} aria-controls={panelId}
      disabled={!content.trim()} onClick={() => setOpen(value => !value)}
      style={{display: 'flex', alignItems: 'center', gap: 8, width: active ? '100%' : undefined, maxWidth: '100%', minWidth: 0, padding: active ? '5px 0' : '2px 0', border: 0, borderRadius: 3, background: 'transparent', color: 'inherit', font: 'inherit', textAlign: 'left', cursor: content.trim() ? 'pointer' : 'default'}}>
      <span className={active ? 'dora-agent-thinking-label' : undefined} style={{flexShrink: 0, fontWeight: active ? 500 : 400, opacity: active ? 1 : 0.65}}>{active ? thinkingLabel : label}</span>
      {active && !open && content.trim() && <span aria-hidden="true" ref={preview} style={{display: 'block', flex: '1 1 0', minWidth: 0, overflow: 'hidden', whiteSpace: 'nowrap', opacity: 0.5, maskImage: 'linear-gradient(to right, transparent, black 24px, black calc(100% - 28px), transparent)', WebkitMaskImage: 'linear-gradient(to right, transparent, black 24px, black calc(100% - 28px), transparent)'}}>{content.slice(-1000).replace(/\s+/g, ' ')}</span>}
      {content.trim() && <svg aria-hidden="true" width="14" height="14" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" style={{flexShrink: 0, opacity: 0.55, transform: open ? 'rotate(180deg)' : undefined}}><path d="m4 6 4 4 4-4"/></svg>}
    </button>
    {open && <div id={panelId} ref={panel} tabIndex={0} role="region" aria-label={label}
      onScroll={event => {const node = event.currentTarget; follow.current = node.scrollHeight - node.scrollTop - node.clientHeight < 24;}}
      style={{maxHeight: 280, overflowY: 'auto', overscrollBehavior: 'contain', margin: active ? '8px 0' : '4px 0 2px', padding: '0 12px', borderLeft: '1px solid currentColor', whiteSpace: 'pre-wrap', overflowWrap: 'anywhere', lineHeight: 1.7, opacity: 0.65}}>{content}</div>}
  </div>;
}
