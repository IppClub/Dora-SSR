#!/usr/bin/env python3
"""Test production origin policy, including HTTP/WS's different listener ports."""
from pathlib import Path
import os
import subprocess
import tempfile
root=Path(__file__).resolve().parents[2]
source=(root/'Source/Http/HttpServer.cpp').read_text()
headers=source[source.index('static bool allow_web_request('):source.index('\nclass WebSocketServer')]
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
 auto allow=[&](std::string_view host,std::optional<std::string_view> origin,unsigned listener=8866,unsigned page=8866){return allowRequest(host,origin,listener,page,hosts);};
 assert(allow("localhost:8866","http://localhost:8866"));
 assert(allow("LOCALHOST:8866","HTTP://LOCALHOST:8866"));
 assert(allow("192.168.1.10:8866","http://192.168.1.10:8866"));
 assert(allow("[::1]:8866","http://[0:0:0:0:0:0:0:1]:8866"));
 assert(allow("dev.local:8866","http://dev.local:8866"));
 assert(allow("localhost:8866",std::nullopt));
 assert(allow("localhost:8868","http://localhost:8866",8868));
 assert(allow("localhost","http://localhost:80",80,80));
 for(auto origin:{"http://evil.test", "null", "", "http://localhost:3000", "https://localhost:8866", "http://localhost:8866/", "http://localhost:8866?x", "http://user@localhost:8866", "http://localhost:8866#x", "localhost:8866", "http://localhost:8866 http://evil.test"}) assert(!allow("localhost:8866",origin));
 assert(!allow("evil.test:8866","http://evil.test:8866"));
 assert(!allow("evil.test:8866",std::nullopt));
 assert(!allow("localhost:8868","http://localhost:8868",8868));
 for(auto host:{"localhost:8866@evil.test", "localhost:0", "localhost:65536", "localhost:", "[::1]garbage", "::1:8866", "localhost:8866/", "localhost:8866,evil.test"}) assert(!allow(host,std::nullopt));
 DoraXrtHttpHeaderView valid[]={{"Host","localhost:8866"},{"Origin","http://localhost:8866"}};
 assert(allow_web_request(valid,2,8866,8866,hosts));
 DoraXrtHttpHeaderView duplicate[]={{"Host","localhost:8866"},{"Origin","http://localhost:8866"},{"Origin","http://evil.test"}};
 assert(!allow_web_request(duplicate,3,8866,8866,hosts));
 duplicate[2]={"Host","localhost:8866"};assert(!allow_web_request(duplicate,3,8866,8866,hosts));
 assert(!allow_web_request(nullptr,0,8866,8866,hosts));
 std::cout<<"HTTP/WS origin policy: all cases passed\n";
}
'''.replace('HEADERS',headers)
with tempfile.TemporaryDirectory(prefix='dora-http-origin-') as temp:
    cpp=Path(temp)/'test.cpp';exe=Path(temp)/'test';cpp.write_text(code)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-fsanitize=address,undefined','-I',str(root),str(cpp),'-o',str(exe)],check=True)
    subprocess.run([str(exe)],check=True)
