#!/usr/bin/env python3
"""Production XRT pool ownership and real keep-alive/framing/concurrency regressions."""
from pathlib import Path
import os, socketserver, subprocess, tempfile, threading, time
root=Path(__file__).resolve().parents[2]
code=r'''
#include "Source/Http/XrtNetwork.c"
#include <assert.h>
void pool_slots(void) {
 assert(DoraXrtHttpAbortCloseFallbackTest());
 xhttprequest request; DoraXrtHttpStreamContext contexts[5] = {0};
 DoraXrtHttpPooledConnection* slots[4];
 xrtHttpRequestInit(&request); assert(xrtHttpRequestSetURL(&request,"http://localhost:8080/"));
 for(int i=0;i<4;i++) {
  slots[i]=DoraXrtHttpPoolAcquire(&request,1,&contexts[i]); assert(slots[i]);
  for(int j=0;j<i;j++) assert(slots[i]!=slots[j]);
 }
 assert(!DoraXrtHttpPoolAcquire(&request,1,&contexts[4]));
 // Expiry and eviction must not touch active connections, even at zero age.
 xnetengine* engine=xrtNetSyncGetHiddenEngine(); assert(engine);
 for(int i=0;i<4;i++){slots[i]->stream=xrtNetStreamCreate(engine,DoraXrtPooledStreamEvents(),slots[i]);assert(slots[i]->stream);slots[i]->parkedAt=0;}
 assert(!DoraXrtHttpPoolAcquire(&request,1,&contexts[4]));
 for(int i=0;i<4;i++) DoraXrtHttpPoolParkOrRelease(slots[i],0);
 // Delayed callbacks from a retired stream must not touch a new owner.
 DoraXrtHttpPooledConnection* pc=DoraXrtHttpPoolAcquire(&request,1,&contexts[0]);
 xnetstream* old=xrtNetStreamCreate(engine,DoraXrtPooledStreamEvents(),pc);
 pc->stream=xrtNetStreamCreate(engine,DoraXrtPooledStreamEvents(),pc);assert(old&&pc->stream);
 DoraXrtPooledOnClose(pc,old,XRT_NET_CLOSED);assert(!pc->dead);
 xrtNetStreamDestroy(old);DoraXrtHttpPoolParkOrRelease(pc,0);
 // A queued legacy callback must not dereference an already detached owner.
 xnetstream* detached=xrtNetStreamCreate(engine,DoraXrtPooledStreamEvents(),(ptr)1);
 __xnetStreamAddAsyncHold(detached);xrtNetStreamDestroy(detached);
 DoraXrtPooledOnClose((ptr)1,detached,XRT_NET_CLOSED);
 __xnetStreamReleaseAsyncHold(detached);
 xrtHttpRequestUnit(&request);xrtThreadDetachCurrent();
}
'''
driver=r'''
#include "Source/Http/XrtNetwork.h"
#include <cassert>
#include <string>
#include <thread>
#include <vector>
#include <atomic>
#include <chrono>
#include <iostream>
extern "C" void pool_slots();
int chunk(const char* data,size_t n,size_t,size_t,void* user){static_cast<std::string*>(user)->append(data,n);return 0;}
std::atomic<bool> blockedEntered{false}, unblock{false};
int blocking(const char* data,size_t n,size_t,size_t,void* user){
 chunk(data,n,0,0,user);blockedEntered=true;
 while(!unblock.load())std::this_thread::sleep_for(std::chrono::milliseconds(1));return 0;
}
int cancel(const char* data,size_t n,size_t,size_t,void* user){chunk(data,n,0,0,user);return 1;}
void request(const std::string& url,const char* method="POST",unsigned timeout=2000,int expected=0,bool stop=false,bool close=false){
 std::string body;int status=0;const char* names[]={"Connection"};const char* values[]={"close"};
 int result=DoraXrtHttpExecuteStream(method,url.c_str(),close?names:nullptr,close?values:nullptr,close?1:0,
  "data",4,timeout,1,nullptr,nullptr,stop?cancel:chunk,&body,&status);
 if(result!=expected)std::cerr<<url<<" status="<<result<<" expected="<<expected<<" body="<<body<<std::endl;
 assert(result==expected);
 if(result==0){assert(status==200);assert(body==(std::string(method)=="HEAD"?"":"ok"));}
}
int main(int argc,char** argv){pool_slots();std::string base=argv[1];
 for(int i=0;i<8;i++)request(base+"/fixed");
 for(int i=0;i<4;i++)request(base+"/chunked");
 for(auto path:{"/close","/http10","/eof","/trail","/interim"})for(int i=0;i<2;i++)request(base+path);
 request(base+"/head","HEAD");request(base+"/fixed");
 for(int i=0;i<2;i++)request(base+"/request-close","POST",2000,0,false,true);
 request(base+"/idle-close");std::this_thread::sleep_for(std::chrono::milliseconds(80));request(base+"/fixed");
 std::atomic<int> ready{0};std::atomic<bool> start{false};std::vector<std::thread> threads;
 for(int i=0;i<12;i++)threads.emplace_back([&]{ready++;while(!start.load())std::this_thread::yield();request(base+"/slow");});
 while(ready!=12)std::this_thread::yield();start=true;for(auto& t:threads)t.join();
 std::thread blocked([&]{std::string body;int status=0;auto url=base+"/blocked";
  assert(DoraXrtHttpExecuteStream("POST",url.c_str(),nullptr,nullptr,0,nullptr,0,2000,1,nullptr,nullptr,blocking,&body,&status)==0);assert(body=="ok");});
 while(!blockedEntered.load())std::this_thread::sleep_for(std::chrono::milliseconds(1));
 auto before=std::chrono::steady_clock::now();request(base+"/blocked-timeout","POST",30,-3);
 assert(std::chrono::steady_clock::now()-before<std::chrono::milliseconds(500));unblock=true;blocked.join();
 request(base+"/timeout","POST",30,-3);request(base+"/fixed");
 request(base+"/cancel","POST",2000,-5,true);request(base+"/fixed");
 std::cout<<"PASS: pool reservations, active eviction, stale callbacks, reuse, framing, 12 concurrent requests, blocked-worker cancellation, timeout and cancellation"<<std::endl;
}
'''
seen={}; lock=threading.Lock()
class Handler(socketserver.StreamRequestHandler):
    def handle(self):
        self.connection.settimeout(5)
        try:
            while True:
                line=self.rfile.readline()
                if not line:return
                method,path,_=line.decode().strip().split(' ',2);headers={}
                while (line:=self.rfile.readline()) not in (b'\r\n',b''):
                    key,value=line.decode().split(':',1);headers[key.lower()]=value.strip()
                self.rfile.read(int(headers.get('content-length','0')))
                with lock:seen.setdefault(path,[]).append(self.client_address[1])
                if path=='/slow':time.sleep(.15)
                if path=='/timeout':time.sleep(.3)
                if path=='/chunked':reply=b'HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n2\r\nok\r\n0\r\nX-Test: yes\r\n\r\n'
                elif path=='/cancel':
                    self.connection.sendall(b'HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n2\r\nok\r\n');time.sleep(.3);return
                elif path=='/http10':reply=b'HTTP/1.0 200 OK\r\nContent-Length: 2\r\n\r\nok'
                elif path=='/eof':reply=b'HTTP/1.1 200 OK\r\n\r\nok'
                elif path=='/close':reply=b'HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok'
                elif method=='HEAD':reply=b'HTTP/1.1 200 OK\r\nContent-Length: 99\r\n\r\n'
                else:reply=b'HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nok'
                if path=='/interim':reply=b'HTTP/1.1 100 Continue\r\n\r\nHTTP/1.1 103 Early Hints\r\nLink: </x>\r\n\r\n'+reply
                if path=='/trail':reply+=b'JUNK'
                self.connection.sendall(reply)
                if path in ('/close','/http10','/eof','/trail','/idle-close'):return
        except (OSError,ValueError):pass
class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address=True
    daemon_threads=True
    request_queue_size=64
with tempfile.TemporaryDirectory(prefix='dora-http-pool-') as tmp, Server(('127.0.0.1',0),Handler) as server:
    tmp=Path(tmp);(tmp/'pool.c').write_text(code);(tmp/'driver.cpp').write_text(driver)
    flags=['-fsanitize=address,undefined','-fno-omit-frame-pointer','-g']
    subprocess.run([os.environ.get('CC','cc'),'-std=c11','-pthread','-w',*flags,'-I',str(root),'-I',str(root/'Source'),'-I',str(root/'Source/3rdParty'),'-c',str(tmp/'pool.c'),'-o',str(tmp/'pool.o')],check=True)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-pthread',*flags,'-I',str(root),str(tmp/'driver.cpp'),str(tmp/'pool.o'),'-lm','-o',str(tmp/'test')],check=True)
    thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
    try:subprocess.run([str(tmp/'test'),f'http://127.0.0.1:{server.server_address[1]}'],check=True,timeout=30,env={**os.environ,'ASAN_OPTIONS':'detect_leaks=0'})
    finally:server.shutdown();thread.join()
    assert len(set(seen['/fixed'][:8]))==1,seen
    assert len(set(seen['/chunked']))==1,seen
    for path in ('/close','/http10','/eof','/trail','/request-close'):
        assert len(seen[path])==2 and len(set(seen[path]))==2,(path,seen[path])
    assert len(seen['/slow'])==12
    assert len(seen['/timeout'])==len(seen['/cancel'])==1 # Never replay an accepted POST.
    print('Wire assertions passed: reuse and non-reuse observed on actual TCP connections')
