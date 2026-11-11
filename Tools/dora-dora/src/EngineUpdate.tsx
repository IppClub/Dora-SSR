import React, {useCallback, useEffect, useRef, useState} from 'react';
import {Alert, Box, Button, CircularProgress, Collapse, Dialog, DialogActions, DialogContent, DialogTitle, IconButton, LinearProgress, MenuItem, Stack, TextField, Tooltip, Typography} from '@mui/material';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpward';
import CloseIcon from '@mui/icons-material/Close';
import {Color} from './Theme';
import Info from './Info';
import * as Service from './Service';

export default function EngineUpdate({children, open, onOpen, onClose, saveBeforeInstall}: {
 children: React.ReactNode; open: boolean; onOpen: () => void; onClose: () => void; saveBeforeInstall: () => Promise<boolean>;
}) {
 const zh = /^zh/.test(Info.locale);
 const tr = (cn: string, en: string) => zh ? cn : en;
 const [state, setState] = useState<Service.EngineUpdateState | null>(null);
 const [error, setError] = useState('');
 const [connectionError, setConnectionError] = useState('');
 const [details, setDetails] = useState(false);
 const [confirm, setConfirm] = useState(false);
 const [acting, setActing] = useState(false);
 const [backend, setBackend] = useState<'d3d12' | 'opengl'>('d3d12');
 const alive = useRef(true);
 const inFlight = useRef(false);
 const manualCheckRequested = useRef(false);
 const refresh = useCallback(async () => {
  if (inFlight.current) return;
  inFlight.current = true;
  try {
   const next = await Service.engineUpdateState();
   if (alive.current) { setState(next); setConnectionError(''); }
  } catch {
   if (alive.current) { setState(previous => previous ? {...previous, available: false} : null); setConnectionError(zh ? '无法连接引擎，正在重试连接…' : 'Cannot reach the engine. Reconnecting…'); }
  } finally { inFlight.current = false; }
 }, [zh]);
 useEffect(() => {
  alive.current = true;
  void refresh();
  const timer = window.setInterval(() => { void refresh(); }, open ? 750 : 15000);
  return () => { alive.current = false; window.clearInterval(timer); };
 }, [open, refresh]);
 useEffect(() => { if (!open) setConfirm(false); }, [open]);
 const action = async (name: Parameters<typeof Service.engineUpdateAction>[0], data?: Parameters<typeof Service.engineUpdateAction>[1]) => {
  setActing(true); setError('');
  try {
   if (name === 'install' && !await saveBeforeInstall()) { setError(tr('保存失败，未开始安装。', 'Save failed. Installation has not started.')); return; }
   const result = await Service.engineUpdateAction(name, data);
   if (!result.success) { setError(tr('当前状态不允许此操作，请刷新后重试。', 'This action is unavailable in the current state. Refresh and retry.')); return; }
   setConfirm(false);
   await refresh();
  } catch { setError(tr('无法完成操作，请检查引擎连接后重试。', 'Action failed. Check the engine connection and retry.')); }
  finally { setActing(false); }
 };
 const busy = state && ['checking', 'downloading', 'canceling', 'installing'].includes(state.phase);
 const canCancel = state?.phase === 'checking' || state?.phase === 'downloading';
 const status = state?.phase === 'ready' ? tr('更新已准备好', 'Update ready')
  : state?.phase === 'checking' ? tr('正在检查更新…', 'Checking for updates…')
  : state?.available ? tr('有可用更新', 'Update available')
  : state?.comparison === 1 ? tr('当前版本高于稳定版', 'Newer than stable')
  : state?.comparison === 0 ? tr('版本相同', 'Matching release version') : tr('检查引擎更新', 'Check engine updates');
 useEffect(() => {
  if (!open) manualCheckRequested.current = false;
  else if (state?.phase === 'idle' && !manualCheckRequested.current) { manualCheckRequested.current = true; void action('check'); }
  // Opening a manual entry bypasses the automatic seven-day schedule.
  // eslint-disable-next-line react-hooks/exhaustive-deps
 }, [open, state?.phase]);
 const show = () => { onOpen(); void refresh(); };
 return <>
  <Box sx={{position: 'relative', display: 'inline-flex', flexShrink: 0}}>
   {children}
   {state?.available && !connectionError ? <Tooltip title={tr('有新版本，打开引擎更新', 'Update available. Open engine update.')}>
    <IconButton aria-label={tr('有新版本，打开引擎更新', 'Update available. Open engine update.')} onClick={show}
     sx={{position: 'absolute', left: -9, top: -9, width: 28, height: 28, p: 0, zIndex: 1,
      '@media (pointer: coarse)': {width: 44, height: 44, left: -17, top: -17}}}>
     <Box component="span" sx={{display: 'grid', placeItems: 'center', width: 20, height: 20, borderRadius: '50%', bgcolor: Color.Theme, color: '#17130a', border: `2px solid ${Color.BackgroundDark}`}}><ArrowUpwardIcon sx={{fontSize: 15}} /></Box>
    </IconButton>
   </Tooltip> : null}
  </Box>
  <Dialog open={open} onClose={onClose} fullWidth maxWidth="xs" aria-labelledby="engine-update-title">
   <DialogTitle id="engine-update-title" sx={{display:'flex', alignItems:'center', justifyContent:'space-between'}}>
    {tr('引擎更新', 'Engine update')}<IconButton onClick={onClose} aria-label={tr('关闭更新面板','Close updater')}><CloseIcon /></IconButton>
   </DialogTitle>
   <DialogContent dividers>
    <Stack spacing={2.5}>
     <Typography variant="caption" color="text.secondary">{tr('更新目标：当前连接的引擎', 'Target: the connected engine')}{state ? ` · ${state.platform}` : ''}</Typography>
     {connectionError || error ? <Alert severity="error">{connectionError || error}</Alert> : null}
     {!state ? <CircularProgress size={24} /> : <>
      <Box><Typography sx={{color: Color.Theme}}>{status}</Typography><Typography variant="h5" sx={{my: 0.75}}>{state.targetVersion ?? '—'}</Typography><Typography variant="body2" color="text.secondary">{tr('当前版本','Installed')} {state.currentVersion}</Typography></Box>
      <Stack direction="row" alignItems="center" justifyContent="space-between" gap={1} flexWrap="wrap">
       <Typography variant="caption">{state.packagePlatform ?? state.platform}{state.packageSize ? ` · ${(state.packageSize / 1048576).toFixed(1)} MiB` : ''}</Typography>
       <TextField select size="small" label={tr('更新源','Source')} value={state.source} disabled={!!busy || state.prepared || acting} onChange={e => { void action('check', {source: e.target.value as Service.EngineUpdateState['source']}); }} sx={{minWidth: 120}}>
        <MenuItem value="AtomGit">AtomGit</MenuItem><MenuItem value="GitHub">GitHub</MenuItem>
       </TextField>
      </Stack>
      {state.publishedAt ? <Typography variant="caption" color="text.secondary">{tr('发布时间','Published')}: {state.publishedAt}</Typography> : null}
      {state.usedCache ? <Alert severity="info">{tr('离线缓存结果，不作为新版提示。请联网重新检查。','Offline cached result. Check again online to confirm availability.')}</Alert> : null}
      {state.source === 'GitHub' && state.comparison === 0 ? <Typography variant="body2" color="text.secondary">{tr('GitHub 无法判断发布修订。如需修复，可在安装选项中重新下载。','GitHub cannot compare release revisions. Redownload under installation options if needed.')}</Typography> : null}
      {state.message ? <Alert severity={state.phase === 'error' ? 'error' : 'info'}>{state.message}</Alert> : null}
      {busy ? <Box><Typography variant="body2">{state.progress?.message ?? tr('处理中…','Working…')}</Typography><LinearProgress sx={{mt:1}} variant={state.progress ? 'determinate' : 'indeterminate'} value={Math.max(0,Math.min(100,(state.progress?.progress ?? 0)*100))} /></Box> : null}
      {state.releaseUrl ? <Button component="a" href={state.releaseUrl} target="_blank" rel="noreferrer" variant="outlined">{tr('查看发布说明','Release notes')}</Button> : null}
      {state.platform === 'Linux' ? <Alert severity="info">{tr('请在引擎所在设备通过 PPA / apt 更新：','Update on the engine device using PPA / apt:')}<Box component="pre" sx={{whiteSpace:'pre-wrap', mb:0}}>sudo apt update{'\n'}sudo apt install --only-upgrade dora-ssr</Box></Alert> : null}
      <Box><Button size="small" onClick={() => setDetails(!details)} aria-expanded={details}>{tr('安装选项与校验信息','Installation and verification')}</Button><Collapse in={details}><Stack spacing={1.5} sx={{pt:1}}>
       <Typography variant="body2" color="text.secondary">{tr('保留项目和设置。安装前校验大小与 SHA-256；AtomGit 另验证发布签名。','Projects and settings are preserved. Size and SHA-256 are checked; AtomGit also verifies release signatures.')}</Typography>
       {state.platform === 'macOS' ? <Typography variant="caption">{tr('Homebrew 用户也可继续使用 brew upgrade。','Homebrew installations can also use brew upgrade.')}</Typography> : null}
       {state.windows && state.canDownload ? <><TextField select label={tr('切换图形后端','Switch graphics backend')} size="small" value={backend} onChange={e=>setBackend(e.target.value as 'd3d12'|'opengl')}><MenuItem value="d3d12">D3D12</MenuItem><MenuItem value="opengl">OpenGL</MenuItem></TextField><Button disabled={acting} onClick={()=>void action('download',{platform:`windows-x64${backend==='opengl'?'-opengl':''}${state.packagePlatform?.endsWith('-msi')?'-msi':''}`})}>{tr('下载所选图形版本','Download selected backend')}</Button></> : null}
       {state.canDownload && state.comparison === 0 ? <Button disabled={acting} onClick={()=>void action('download')}>{tr('重新下载安装包','Redownload package')}</Button> : null}
       {state.prepared && !busy ? <Button disabled={acting} onClick={()=>void action('discard')}>{tr('丢弃安装包','Discard package')}</Button> : null}
      </Stack></Collapse></Box>
      {state.phase === 'ready' ? <Typography variant="body2" color="text.secondary">{tr('安装包已通过校验，可以稍后安装。','Package verified. You can install it later.')}</Typography> : null}
      {confirm ? <Alert severity="warning">{tr('安装将退出引擎。请确认所有已连接编辑器均已保存；当前页面会先保存修改，重启后自动尝试重新连接。Android 将打开系统安装器。','Installation exits the engine. Save all connected editors first. This page saves its changes and reconnects after restart. Android opens the system installer.')}</Alert> : null}
     </>}
    </Stack>
   </DialogContent>
   <DialogActions sx={{px:3, py:2, justifyContent:'space-between'}}>
    <Button disabled={acting || state?.phase === 'canceling' || state?.phase === 'installing'} onClick={()=>{ if(confirm) setConfirm(false); else if(canCancel) void action('cancel'); else if(state?.prepared) onClose(); else void action('check'); }}>{confirm ? tr('返回','Back') : canCancel ? tr('取消','Cancel') : state?.prepared ? tr('稍后安装','Later') : tr('重新检查','Check again')}</Button>
    <Button variant="contained" disabled={acting || !!connectionError || !(state?.phase === 'ready' || (state?.available && state.canDownload))} onClick={()=>{ if(state?.phase === 'ready') { if(confirm) void action('install',{confirmed:true}); else setConfirm(true); } else void action('download'); }} sx={{bgcolor:Color.Theme,color:'#17130a','&:hover':{bgcolor:Color.Theme}}}>{state?.phase === 'ready' ? confirm ? tr('保存并确认安装','Save and install') : state.platform === 'Android' ? tr('打开系统安装器','Open system installer') : tr('安装并重启','Install and restart') : tr('下载更新','Download update')}</Button>
   </DialogActions>
  </Dialog>
 </>;
}
