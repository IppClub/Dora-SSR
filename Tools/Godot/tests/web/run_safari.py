#!/usr/bin/env python3
"""Run the real Web fixture in installed Safari through its native WebDriver.

Requires the user's existing/approved Safari remote-automation permission.
Never enables that permission or changes Safari preferences.
"""
import argparse,hashlib,json,mimetypes,re,subprocess,threading,time,urllib.error,urllib.parse,urllib.request
from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
from pathlib import Path

root=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--package',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--buffers',type=int,choices=[2,3,4],required=True)
p.add_argument('--driver-port',type=int,default=0,help='WebDriver port; 0 selects a fresh available port')
a=p.parse_args();package=a.package.resolve();out=a.output.resolve()
assert not out.exists(),'Use a fresh output directory'
assert a.driver_port==0 or 1024<=a.driver_port<=65535
out.mkdir(parents=True);session=None;driver=None;server=None
endpoint=f'http://127.0.0.1:{a.driver_port}'
def digest(path):
    with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
instrumentation=Path(__file__).with_name('acceptance_init.js')
names=['dora-player-runtime.js','dora-player-runtime.wasm','dora-player-runtime.data','dora-web-manifest.json','dora-web-features.json','godot/dora-godot.js','godot/dora-godot.wasm','godot/shared_gl.mjs','godot/runtime_bridge.mjs']
artifacts={name:digest(package/name) for name in names if (package/name).is_file()}
result={'passed':False,'browser_engine':'safari','browser_headless':False,'artifacts':artifacts,
        'test_instrumentation_sha256':digest(instrumentation),'index_source_sha256':digest(package/'index.html'),
        'scope':'Installed native Safari WebDriver; test-only instrumentation served before loader, no runtime files changed'}
def request(method,path,payload=None):
    data=None if payload is None else json.dumps(payload).encode()
    req=urllib.request.Request(endpoint+path,data=data,method=method,headers={'Content-Type':'application/json'})
    try:
        with urllib.request.urlopen(req,timeout=180 if path.endswith('/url') else 60) as response:body=json.load(response)
    except urllib.error.HTTPError as error:
        body=json.loads(error.read());raise RuntimeError(body) from error
    value=body.get('value')
    if isinstance(value,dict) and 'error' in value:raise RuntimeError(value)
    return value
def execute(script,*args):return request('POST',f'/session/{session}/execute/sync',{'script':script,'args':list(args)})
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        name=urllib.parse.unquote(urllib.parse.urlsplit(self.path).path).lstrip('/') or 'index.html'
        if name=='favicon.ico':self.send_response(204);self.end_headers();return
        if name=='__dora_acceptance_init.js':file=instrumentation
        else:
            file=(package/name).resolve()
            if not file.is_relative_to(package):self.send_error(403);return
        if not file.is_file():self.send_error(404);return
        data=file.read_bytes()
        if name=='index.html':
            assert b'<head>' in data
            data=data.replace(b'<head>',b'<head><script src="/__dora_acceptance_init.js"></script>',1)
        self.send_response(200)
        self.send_header('Content-Type',mimetypes.guess_type(file.name)[0] or 'application/octet-stream')
        self.send_header('Content-Length',str(len(data)))
        for key,value in [('Cache-Control','no-store'),('Cross-Origin-Opener-Policy','same-origin'),('Cross-Origin-Embedder-Policy','require-corp')]:self.send_header(key,value)
        self.end_headers();self.wfile.write(data)
    def log_message(self,*args):pass
try:
    manifest=json.loads((package/'dora-web-manifest.json').read_text())
    entry=next(file for file in manifest['files'] if file['path']==manifest['entry'])
    fixture=(package/urllib.parse.urlsplit(entry['url']).path.lstrip('/')).resolve()
    assert fixture.is_relative_to(package) and digest(fixture)==entry['sha256']
    assert b'DORA_WEB_NODE_DONE' in fixture.read_bytes(),'Not the GodotNode acceptance fixture'
    result['fixture_sha256']=entry['sha256']
    started=time.monotonic()
    # Refuse an occupied port; never attach to another task's WebDriver service.
    import socket
    with socket.socket() as probe:
        probe.bind(('127.0.0.1',a.driver_port))
        driver_port=probe.getsockname()[1]
    endpoint=f'http://127.0.0.1:{driver_port}'
    result['driver_port']=driver_port
    driver_log=(out/'driver.log').open('w')
    driver=subprocess.Popen(['/usr/bin/safaridriver','-p',str(driver_port)],stdout=driver_log,stderr=subprocess.STDOUT)
    for _ in range(100):
        assert driver.poll() is None,'SafariDriver exited'
        try:request('GET','/status');break
        except (OSError,urllib.error.URLError):time.sleep(.1)
    else:raise RuntimeError('SafariDriver did not become ready')
    value=request('POST','/session',{'capabilities':{'alwaysMatch':{'browserName':'safari'}}})
    session=value['sessionId'];result['capabilities']=value['capabilities'];result['browser']=value['capabilities'].get('browserVersion')
    request('POST',f'/session/{session}/timeouts',{'pageLoad':120000,'script':30000,'implicit':0})
    request('POST',f'/session/{session}/window/rect',{'width':1280,'height':800})
    dimensions=execute('return {width:outerWidth-innerWidth,height:outerHeight-innerHeight};')
    request('POST',f'/session/{session}/window/rect',{'width':1280+dimensions['width'],'height':720+dimensions['height']})
    server=ThreadingHTTPServer(('127.0.0.1',0),Handler)
    threading.Thread(target=server.serve_forever,daemon=True).start()
    request('POST',f'/session/{session}/url',{'url':f'http://127.0.0.1:{server.server_port}/'})
    deadline=time.monotonic()+180;clicked=False
    while time.monotonic()<deadline:
        state=execute('return {evidence:window.__doraAcceptance,state:document.documentElement.dataset.doraState,width:innerWidth,height:innerHeight,dpr:devicePixelRatio,crossOriginIsolated,sharedArrayBuffer:typeof SharedArrayBuffer!=="undefined"};')
        result['lastState']=state
        evidence=state['evidence'] or {'logs':[],'errors':[],'warnings':[]}
        if not clicked and any('DORA_WEB_NODE_CAPTURE animated' in line for line in evidence['logs']):
            request('POST',f'/session/{session}/actions',{'actions':[{'type':'pointer','id':'mouse','parameters':{'pointerType':'mouse'},'actions':[{'type':'pointerMove','duration':0,'origin':'viewport','x':5,'y':5},{'type':'pointerDown','button':0},{'type':'pointerUp','button':0}]}]})
            clicked=True;result['audio_unlock_gesture']='WebDriver pointer click at viewport 5,5 after first animation capture'
        if any('DORA_WEB_NODE_DONE' in line for line in evidence['logs']):break
        assert state['state']!='faulted',state
        assert not any(not line.startswith('Blocking on the main thread is very dangerous') for line in evidence['errors']),evidence['errors']
        time.sleep(.25)
    else:raise RuntimeError('Safari GodotNode controller timed out')
    renderer=execute("const gl=Module.canvas.getContext('webgl2'),ext=gl.getExtension('WEBGL_debug_renderer_info');return ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):gl.getParameter(gl.RENDERER);")
    time.sleep(.25);execute("Module.ccall('dora_web_stop','number',[],[]);return true;")
    deadline=time.monotonic()+15
    while execute("return document.documentElement.dataset.doraState;")!='stopped':
        assert time.monotonic()<deadline,'Safari teardown timed out'
        time.sleep(.1)
    execute("window.dispatchEvent(new Event('blur'));document.dispatchEvent(new Event('visibilitychange'));return true;")
    time.sleep(.05)
    teardown=execute("return {state:Module.doraWebPlatform.state,dispose_again:Module.doraWebPlatform.dispose({notifyEngine:false}),ime_present:Boolean(document.querySelector('#dora-ime-input'))};")
    assert not teardown['state']['active'] and not teardown['dispose_again'] and not teardown['ime_present'],teardown
    evidence=execute('return window.__doraAcceptance;')
    captures=[{'name':m[0],'frame':int(m[1])} for line in evidence['logs'] for m in re.findall(r'DORA_WEB_NODE_CAPTURE (\S+) frame=(\d+)',line)]
    for capture in captures:
        name=capture['name'];assert re.fullmatch(r'[a-z-]+',name)
        values=execute("return Array.from(Module.FS.readFile('/user/'+arguments[0]+'.png'));",name)
        (out/(name+'.png')).write_bytes(bytes(values))
    metrics=execute('return Module.doraTestAudioMetrics;')
    assert not metrics['underruns'],metrics
    assert not any(not text.startswith('Blocking on the main thread is very dangerous') for text in evidence['errors']),evidence['errors']
    assert not any(re.search(r'GL_INVALID|INVALID_OPERATION|INVALID_VALUE|INVALID_ENUM',text) for text in evidence['warnings']),evidence['warnings']
    assert all(digest(package/name)==sha for name,sha in artifacts.items()),'Artifacts changed during test'
    assert digest(instrumentation)==result['test_instrumentation_sha256'] and digest(package/'index.html')==result['index_source_sha256'],'Test instrumentation changed'
    result.update(passed=True,renderer=renderer,audio_metrics=metrics,teardown=teardown,controller_frames=620,ordinary=False,captures=captures,
                  logs=evidence['logs'],browser_errors=evidence['errors'],browser_warnings=evidence['warnings'],runtime_seconds=time.monotonic()-started,
                  godot_packaged=True,suspension=None)
    (out/'execution.json').write_text(json.dumps(result,indent=2)+'\n')
    subprocess.run(['python3',str(Path(__file__).with_name('verify_node.py')),str(out),'--buffers',str(a.buffers)],check=True)
except BaseException as error:
    result.update(passed=False,error=str(error))
    (out/'verification.json').unlink(missing_ok=True)
    (out/'execution.json').write_text(json.dumps(result,indent=2)+'\n')
    raise
finally:
    if session:
        try:request('DELETE',f'/session/{session}')
        except Exception:pass
    if driver and driver.poll() is None:
        driver.terminate()
        try:driver.wait(timeout=10)
        except subprocess.TimeoutExpired:driver.kill();driver.wait()
    if server:server.shutdown();server.server_close()
