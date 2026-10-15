#!/usr/bin/env python3
"""Exercise the production conditional-request parser without engine dependencies."""
from pathlib import Path
import os
import subprocess
import tempfile
root = Path(__file__).resolve().parents[2]
source=(root/'Source/Http/HttpServer.cpp').read_text()
helper=source[source.index('static void set_not_modified('):source.index('\nstatic void set_service_unavailable')]
code = r'''
#include "Source/Http/HttpValidators.h"
#include <cassert>
#include <iostream>
#include <string>
struct DoraXrtHttpServerResponse {int status;std::string length,body;};
void DoraXrtHttpServerResponseSetHeader(DoraXrtHttpServerResponse* r,const char*,const char* v){r->length=v;}
void set_response(DoraXrtHttpServerResponse* r,int status,const std::string& body,const std::string&){r->status=status;r->body=body;}
HELPER
int main() {
 DoraXrtHttpServerResponse response{};set_not_modified(&response,680000);assert(response.status==304 && response.length=="680000" && response.body.empty());
 using Dora::HttpPolicy::ifNoneMatch;
 const char* tag="\"abc-100\"";
 for(auto value:{"\"abc-100\"", "W/\"abc-100\"", "*", " \t*\t ", "\"other\", W/\"abc-100\"", ",,\"abc-100\",,", "\"abc-100\", ", "\"abc-100\", , ",}) assert(ifNoneMatch(value,tag));
 for(auto value:{"\"*\"", "\"unrelated*tag\"", "\"abc-100x\"", "\"other\"", "", "W/*", "*,\"other\"", "\"abc-100\"junk", "\"abc-100\",broken", "\"abc-100\", *", "w/\"abc-100\"", "\"abc 100\"", "\"unterminated"}) assert(!ifNoneMatch(value,tag));
 assert(ifNoneMatch("\"other,tag\", \"a,b\"", "\"a,b\""));
 assert(!ifNoneMatch("\"prefix,abc-100\"",tag));
 assert(!ifNoneMatch("\"abc-100-g\"",tag));
 std::cout<<"HTTP validator regression: parser and 304 metadata cases passed\n";
}
'''.replace('HELPER',helper)
with tempfile.TemporaryDirectory(prefix='dora-http-validators-') as temp:
    cpp=Path(temp)/'test.cpp';exe=Path(temp)/'test';cpp.write_text(code)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-fsanitize=address,undefined','-I',str(root),str(cpp),'-o',str(exe)],check=True)
    subprocess.run([str(exe)],check=True)
