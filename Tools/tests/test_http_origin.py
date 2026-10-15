#!/usr/bin/env python3
"""Sanitize the production HTTP/WS request classification matrix."""
from pathlib import Path
import os
import subprocess
import tempfile
root=Path(__file__).resolve().parents[2]
source=(root/'Source/Http/HttpServer.cpp').read_text()
headers=source[source.index('static HttpPolicy::Access web_request_access('):source.index('\nclass WebSocketServer')]
code=r'''
#include "Source/Http/HttpOriginPolicy.h"
#include "Source/Http/XrtNetwork.h"
#include <cassert>
#include <iostream>
using namespace Dora;
HEADERS
int main() {
 using namespace Dora::HttpPolicy;
 std::vector<std::string> hosts{"localhost","127.0.0.1","::1","192.168.1.10","dev.local"};
 auto policy=[&](std::string_view host,std::optional<std::string_view> origin,bool local=true,unsigned listener=8866,unsigned page=8866,std::string_view site={}) {return access(host,origin,listener,page,hosts,local,site);};
 assert(policy("localhost:8866","http://localhost:8866")==Access::Local);
 assert(policy("LOCALHOST:8866","HTTP://LOCALHOST:8866")==Access::Local);
 assert(policy("[::1]:8866","http://[0:0:0:0:0:0:0:1]:8866")==Access::Local);
 assert(policy("localhost:8868","http://localhost:8866",true,8868)==Access::Local);
 assert(policy("localhost","http://localhost:80",true,80,80)==Access::Local);
 for(auto origin:{"http://evil.test","http://localhost:3000","https://localhost:8866","https://example.org","https://example.org:443"})
  assert(policy("localhost:8866",origin)==Access::Authenticate);
 assert(policy("192.168.1.10:8866","http://192.168.1.10:8866")==Access::Authenticate);
 assert(policy("dev.local:8866","http://dev.local:8866")==Access::Authenticate);
 assert(policy("localhost:8866","http://localhost:8866",false)==Access::Authenticate); // forged Host/Origin from LAN
 assert(policy("localhost:8866",std::nullopt)==Access::Authenticate);
 assert(policy("localhost:8866",std::nullopt,true,8866,8866,"same-origin")==Access::Local);
 assert(policy("localhost:8866",std::nullopt,false,8866,8866,"same-origin")==Access::Authenticate);
 assert(policy("localhost:8866","http://localhost:8866",true,8866,8866,"cross-site")==Access::Authenticate);
 for(auto origin:{"null", "", "ftp://localhost:8866", "http://localhost:8866/", "http://localhost:8866?x", "http://user@localhost:8866", "http://localhost:8866#x", "localhost:8866", "http://localhost:8866 http://evil.test"}) assert(policy("localhost:8866",origin)==Access::Denied);
 assert(policy("evil.test:8866","http://evil.test:8866")==Access::Denied);
 for(auto host:{"localhost:8866@evil.test", "localhost:0", "localhost:65536", "localhost:", "[::1]garbage", "::1:8866", "localhost:8866/", "localhost:8866,evil.test"}) assert(policy(host,std::nullopt)==Access::Denied);
 DoraXrtHttpHeaderView valid[]={{"Host","localhost:8866"},{"Origin","http://localhost:8866"}};
 assert(web_request_access(valid,2,8866,8866,hosts,true)==Access::Local);
 assert(web_request_access(valid,2,8866,8866,hosts,false)==Access::Authenticate);
 DoraXrtHttpHeaderView duplicate[]={{"Host","localhost:8866"},{"Origin","http://localhost:8866"},{"Origin","http://evil.test"}};
 assert(web_request_access(duplicate,3,8866,8866,hosts,true)==Access::Denied);
 duplicate[2]={"Host","localhost:8866"};assert(web_request_access(duplicate,3,8866,8866,hosts,true)==Access::Denied);
 duplicate[1]={"Sec-Fetch-Site","same-origin"};duplicate[2]=duplicate[1];
 assert(web_request_access(duplicate,3,8866,8866,hosts,true)==Access::Denied);
 assert(web_request_access(nullptr,0,8866,8866,hosts)==Access::Denied);
 std::cout<<"HTTP/WS local, LAN, CLI, cross-origin policy: all cases passed\n";
}
'''.replace('HEADERS',headers)
with tempfile.TemporaryDirectory(prefix='dora-http-origin-') as temp:
    cpp=Path(temp)/'test.cpp';exe=Path(temp)/'test';cpp.write_text(code)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-fsanitize=address,undefined','-I',str(root),str(cpp),'-o',str(exe)],check=True)
    subprocess.run([str(exe)],check=True)
