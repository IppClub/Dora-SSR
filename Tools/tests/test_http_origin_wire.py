#!/usr/bin/env python3
"""Exercise real XRT HTTP and WebSocket handshakes with the production policy."""
from pathlib import Path
import http.client
import os
import socket
import subprocess
import tempfile
root=Path(__file__).resolve().parents[2]
source=(root/'Source/Http/HttpServer.cpp').read_text()
headers=source[source.index('static HttpPolicy::Access web_request_access('):source.index('\nclass WebSocketServer')]
code=r'''
#include "Source/Http/HttpOriginPolicy.h"
#include "Source/Http/XrtNetwork.h"
#include <iostream>
#include <cstdlib>
using namespace Dora;
HEADERS
unsigned hp,wp;
std::vector<std::string> hosts{"localhost","127.0.0.1"};
int main(int argc,char** argv){
 hp=std::atoi(argv[1]);wp=std::atoi(argv[2]);
 DoraXrtHttpServerEvents h{};
 h.shouldDefer=[](void*,const char* path) -> int {return std::string_view(path)=="/deferred";};
 h.onRequest=[](void*,const DoraXrtHttpServerRequest* req,DoraXrtHttpServerResponse* res){
  auto access=web_request_access(req->headers,req->headerCount,hp,hp,hosts,req->loopbackPeer);
  const char* token=DoraXrtHttpServerRequestHeader(req,"X-Dora-Auth");
  unsigned status=access==HttpPolicy::Access::Denied?403:access==HttpPolicy::Access::Local || token && std::string_view(token)=="wire-secret"?200:401;
  DoraXrtHttpServerResponseSetStatus(res,status,nullptr);
  DoraXrtHttpServerResponseSetBodyCopy(res,"ok",2,"text/plain");return 1;
 };
 DoraXrtWebSocketServerEvents w{};
 w.onAuthorize=[](void*,DoraXrtWebSocketConnection* connection,const char* target,const DoraXrtHttpHeaderView* headers,size_t count){
  auto access=web_request_access(headers,count,wp,hp,hosts,DoraXrtWebSocketIsLoopback(connection));
  if(access==HttpPolicy::Access::Denied)return 403;
  return access==HttpPolicy::Access::Local || std::string_view(target)=="/?auth=wire-secret"?0:401;
 };
 auto http=DoraXrtHttpServerCreate(hp,1024*1024,&h,nullptr);
 auto ws=DoraXrtWebSocketServerCreate(wp,1024*1024,&w,nullptr);
 if(!http||!ws)return 2;
 std::cout<<"READY"<<std::endl;std::cin.get();
 DoraXrtWebSocketServerDestroy(ws);DoraXrtHttpServerDestroy(http);
}
'''.replace('HEADERS',headers)
def free_port():
    with socket.socket() as sock:
        sock.bind(('127.0.0.1',0))
        return sock.getsockname()[1]
with tempfile.TemporaryDirectory(prefix='dora-http-wire-') as temp:
    temp=Path(temp);cpp=temp/'test.cpp';exe=temp/'test';obj=temp/'xrt.o';cpp.write_text(code)
    subprocess.run([os.environ.get('CC','cc'),'-std=c11','-pthread','-w','-I',str(root/'Source'),'-I',str(root/'Source/3rdParty'),'-c',str(root/'Source/Http/XrtNetwork.c'),'-o',str(obj)],check=True)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-pthread','-I',str(root),str(cpp),str(obj),'-lm','-o',str(exe)],check=True)
    hp,wp=free_port(),free_port()
    proc=subprocess.Popen([str(exe),str(hp),str(wp)],stdin=subprocess.PIPE,stdout=subprocess.PIPE,text=True)
    try:
        assert proc.stdout.readline().strip()=='READY'
        cases=0
        for path,method in [('/', 'GET'),('/auth','POST'),('/','OPTIONS'),('/deferred','POST')]:
            for origin,want in [(None,401),(f'http://127.0.0.1:{hp}',200),('http://evil.test',401),('null',403)]:
                conn=http.client.HTTPConnection('127.0.0.1',hp,timeout=5)
                conn.request(method,path,headers={} if origin is None else {'Origin':origin})
                response=conn.getresponse();assert response.status==want,(path,origin,response.status);assert response.getheader('Access-Control-Allow-Origin') is None
                response.read();conn.close();cases+=1
        def handshake(origin,host=None,target='/',want=403,extra=''):
            request=f'GET {target} HTTP/1.1\r\nHost: {host or f"127.0.0.1:{wp}"}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n'
            if origin is not None:request+=f'Origin: {origin}\r\n'
            with socket.create_connection(('127.0.0.1',wp),timeout=5) as sock:
                sock.sendall((request+extra+'\r\n').encode());reply=sock.recv(4096)
                assert reply.startswith(f'HTTP/1.1 {want} '.encode()),reply
        handshake(f'http://127.0.0.1:{hp}',want=101)
        handshake(None,want=401)
        handshake('http://evil.test',want=401);handshake('null')
        handshake(f'http://evil.test:{hp}',host=f'evil.test:{wp}')
        handshake(f'http://127.0.0.1:{wp}',want=401)
        handshake('http://evil.test',target='/?auth=wire-secret',want=101)
        handshake(f'http://127.0.0.1:{hp}',extra='Origin: http://evil.test\r\n')
        for origin in [None,'http://evil.test','https://dev.example']:
            conn=http.client.HTTPConnection('127.0.0.1',hp,timeout=5)
            conn.request('POST','/deferred',headers={'X-Dora-Auth':'wire-secret',**({'Origin':origin} if origin else {})})
            response=conn.getresponse();assert response.status==200;response.read();conn.close();cases+=1
        print(f'XRT wire regression: {cases+8} HTTP/WS cases passed')
    finally:
        proc.communicate('\n',timeout=10)
        assert proc.returncode==0,proc.returncode
