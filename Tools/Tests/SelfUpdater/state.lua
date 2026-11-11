local root=assert(arg[1])
package.path=root..'/Assets/Script/Lib/?.lua;'..package.path
local lib=require('lualib_bundle')
local response, download, pendingResolve, removals, installs
local platform='windows-x64-msi'
local function compare(a,b)
 local function parts(s)local t={} for n in s:gmatch('%d+') do t[#t+1]=tonumber(n) end return t end
 local x,y=parts(a),parts(b) for i=1,3 do if x[i]~=y[i] then return x[i]<y[i] and -1 or 1 end end return 0
end
local path=setmetatable({getPath=function(_,s)return s:match('(.+)/') or '.' end},{__call=function(_,...)return table.concat({...},'/')end})
package.preload.Dora=function()return {
 App={locale='zh',version='1.10.2.1',platform='Windows',install=function(_,file) installs=installs+1 end},
 PlatformType={Linux='Linux'},Path=path,
 Content={exist=function()return true end,remove=function(_,file)removals=removals+1 end},
 Director={postNode={emit=function()end}},thread=function(f)f()end
}end
package.preload['Tools.SelfUpdater.Manifest']=function()return {compareVersions=compare,updatePlatformForApp=function()return platform end,isWindowsUpdatePlatform=function(p)return p:match('^windows%-x64')~=nil end}end
package.preload['Tools.SelfUpdater.UpdateSync']=function()return {
 updateSourcesForLocale=function()return{'AtomGit','GitHub'}end,
 syncUpdateManifest=function(options) return lib.__TS__Promise.resolve(response) end,
 checkGitHubRelease=function(options) return lib.__TS__Promise.resolve(response) end,
 prepareUpdatePackage=function(_,p,options)
  if download=='pending' then return lib.__TS__New(lib.__TS__Promise,function(_,resolve)pendingResolve=function(v)resolve(nil,v)end end)end
  return lib.__TS__Promise.resolve(download)
 end
}end
local function reset()
 installs,removals=0,0
 return dofile(root..'/Assets/Script/Tools/SelfUpdater/Service.lua')
end
local function atom(version,revision,cache)
 response={success=true,usedCache=cache,snapshot={source='AtomGit',manifest={version=version,revision=revision,publishedAt='now',packages={['windows-x64-msi']={file='test.msi',size=1024},['windows-x64-opengl-msi']={file='compat.msi',size=1024}}}}}
end
local service=reset()
assert(not service.getState().available,'unknown must hide badge')
atom('v1.10.2',2);assert(service.checkForUpdates());assert(service.getState().available,'new revision must show badge')
response={success=false,message='offline'};service.checkForUpdates();assert(not service.getState().available and service.getState().phase=='error','failed check must hide badge')
atom('v1.10.2',2,true);service.checkForUpdates();assert(not service.getState().available and service.getState().usedCache,'cache must not advertise a fresh update')
atom('v1.10.2',1);service.checkForUpdates();assert(not service.getState().available,'equal revision must hide badge')
atom('v1.9.2',4);service.checkForUpdates();assert(not service.getState().canDownload and not service.downloadUpdate(),'must reject downgrade')
response={success=true,snapshot={source='GitHub',version='v1.10.2',publishedAt='now',packages={['windows-x64-msi']={file='repair.msi',size=1024}}}}
service.checkForUpdates('GitHub');assert(not service.getState().available and service.getState().canDownload,'same GitHub base is repair only')
atom('v1.10.3',0);service.checkForUpdates('AtomGit');download='pending';assert(service.downloadUpdate());assert(not service.checkForUpdates(),'must serialize operations')
assert(service.cancelOperation());assert(service.getState().phase=='canceling');assert(not service.checkForUpdates(),'cancel must wait for worker acknowledgement')
pendingResolve({file='temp.msi',cleanupPath='temp'});assert(service.getState().phase=='available' and removals==1 and installs==0,'late completion must be discarded after cancel')
download={file='update.msi',cleanupPath='cache'};assert(service.downloadUpdate());assert(service.getState().phase=='ready' and installs==0,'download must stop before installation')
assert(not service.installUpdate(false) and installs==0,'installation requires confirmation')
assert(not service.checkForUpdates() and not service.downloadUpdate(),'prepared target is pinned')
assert(service.installUpdate(true) and installs==1,'confirmed install must use prepared package')
service=reset();atom('v1.10.3',0);service.checkForUpdates();download={file='update.msi',cleanupPath='cache'};service.downloadUpdate();assert(service.discardPrepared() and not service.getState().prepared and removals==1)
print('PASS: notification visibility, revisions, GitHub repair, cached/offline checks, downgrade rejection, task serialization, late cancel cleanup, download/install separation and confirmation')
service=reset()
local entryState=service.getState()
service.bindEntryState(function()return entryState end,function(value)entryState=value end)
atom('v1.10.3',0);assert(service.checkForUpdates())
assert(service.getState()==entryState and entryState.available and entryState.phase=='available' and entryState.serial>0,'real service must publish to and read back Entry state')
print('PASS: real update service publishes to and reads back Entry-owned state')

service=reset()
assert(not service.ignoreUpdate(),'unknown versions cannot be ignored')
local public=service.getState()
service.bindEntryState(function()return public end,function(value)public=value end)
atom('v1.10.2',2);service.checkForUpdates('AtomGit')
assert(public.canIgnore and service.ignoreUpdate())
assert(public.ignored and not public.available and not public.canIgnore and public.canDownload,'ignore hides notification but preserves manual download')
assert(public.ignoredVersion=='v1.10.2-2' and not service.ignoreUpdate())
service.checkForUpdates('AtomGit');assert(public.ignored and not public.available,'manual check respects the ignored version')
local saved=public.ignoredVersion
service=reset();public=service.getState()
service.bindEntryState(function()return public end,function(value)public=value end,saved)
atom('v1.10.2',2);service.checkForUpdates('AtomGit');assert(public.ignored and not public.available,'ignore survives restart')
atom('v1.10.2',3);service.checkForUpdates('AtomGit');assert(public.available and public.canIgnore and not public.ignored,'newer revisions must notify again')
download='pending';service.downloadUpdate();assert(not service.ignoreUpdate(),'do not ignore an in-flight update')
service.cancelOperation();pendingResolve(nil)
atom('v1.10.3',0,true);service.checkForUpdates();assert(not public.canIgnore and not service.ignoreUpdate(),'do not persist unverified cached versions')
print('PASS: ignore persistence, exact-version scope, newer revisions, manual downloads and busy/cache guards')
