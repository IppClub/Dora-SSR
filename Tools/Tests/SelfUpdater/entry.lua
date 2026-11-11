local root=assert(arg[1])
local f=assert(io.open(root..'/Assets/Script/Dev/Entry.lua'));local source=f:read('*a');f:close()
local block=assert(source:match('(local updateSceneCache = moduleCache.-)local Set, Struct, LintYueGlobals'))
local week=7*24*60*60
local now=2000000
local function boot(last,notice,platform,notificationVersion,ignoredVersion)
 local calls=0
 local current={available=false,checkedAt=0,usedCache=false,phase='idle'}
 local publish,read
 local updater={getState=function()return current end,bindEntryState=function(r,p,ignored)read,publish=r,p;assert(ignored==ignoredVersion) end,checkForUpdates=function(selected)calls=calls+1;return true end}
 local config={lastUpdateCheck=last,updateNotification=notice,updateNotificationVersion=notificationVersion or "1.10.2.2",ignoredUpdateVersion=ignoredVersion}
 local entry={}
 local env={moduleCache={},oldRequire=function()return updater end,config=config,_module_0=entry,App={platform=platform or 'macOS',version='1.10.2.2'},os={time=function()return now end,difftime=os.difftime},thread=function(fn)fn()end,sleep=function()end}
 assert(load(block,'Entry update policy','t',env))()
 return entry,config,function()return calls end,publish,read
end
local e,c,calls,publish,read=boot(now-6*86400,true)
assert(calls()==0 and e.getUpdateState().available,'recent startup must preserve Entry notification without checking')
assert(e.getUpdateState()==read(),'service must read Entry-owned state')
assert(e.checkForUpdates() and calls()==1,'manual checks must bypass seven-day throttle')
assert(e.checkForUpdates(true,'GitHub') and calls()==2,'manual source switching must bypass throttle')
local state={available=false,checkedAt=0,usedCache=false,phase='error'};publish(state)
assert(e.getUpdateState()==state and not c.updateNotification and c.lastUpdateCheck==now-6*86400,'failure publishes Entry state without advancing successful check time')
publish({available=true,checkedAt=now,usedCache=false,phase='available'})
assert(c.updateNotification and c.lastUpdateCheck==now,'successful checks persist timestamp and notification in Entry')
assert(not e.checkForUpdates(false) and calls()==2,'fresh successful check must throttle automatic checks')
for _,last in ipairs({now-week,now-week-1}) do local _,_,n=boot(last,false);assert(n()==1,'seven-day boundary must check') end
local _,_,n=boot(nil,false);assert(n()==1,'first startup must check')
local _,_,web=boot(nil,false,'Emscripten');assert(web()==0,'Web Player must skip automatic checks')
print('PASS: Entry-owned shared state, persisted notification, seven-day boundary, first startup, unrestricted manual checks, successful timestamps and Web Player exclusion')

for _,previous in ipairs({'1.10.2.1','1.10.1.9',''}) do
 local e,c,n=boot(now-60,true,'Windows',previous)
 assert(not e.getUpdateState().available and not c.updateNotification,'upgraded or legacy builds must clear stale notification')
 assert(c.updateNotificationVersion=='1.10.2.2' and n()==0,'upgrade must not change seven-day auto-check schedule')
end
local e,c,n,p=boot(now-60,false,'Android',nil,'v1.10.3-0')
p({available=false,checkedAt=now,usedCache=false,ignoredVersion='v1.10.3-0'})
assert(c.ignoredUpdateVersion=='v1.10.3-0' and not c.updateNotification,'Entry persists ignore state')
print('PASS: upgraded/legacy notification cleanup, unchanged seven-day interval and persisted ignored version')
