#!/usr/bin/env python3
"""Compile and exercise the production pending-result and request-copy code."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
source = (root / 'Source/Http/HttpServer.cpp').read_text()
pending = source[source.index('template <class T>\nclass PendingLogicResult'):source.index('\nHttpServer::HttpServer()')]
make_request = source[source.index('static HttpServer::Request make_request('):source.index('\nstatic bool valid_static_path')]
prefix = r'''
#include <atomic>
#include <cassert>
#include <chrono>
#include <condition_variable>
#include <functional>
#include <iostream>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <string_view>
#include <thread>
#include <vector>
using namespace std::chrono_literals;
#define r_cast reinterpret_cast
using Slice = std::string_view;
namespace bx {
class Semaphore {
 std::mutex mutex; std::condition_variable cv; unsigned count=0;
public:
 void post() { std::lock_guard<std::mutex> lock(mutex); ++count; cv.notify_one(); }
 bool wait(int ms) { std::unique_lock<std::mutex> lock(mutex); if(!cv.wait_for(lock,std::chrono::milliseconds(ms),[&]{return count>0;}))return false; --count; return true; }
};
}
struct Application {
 std::atomic_bool alive{true}; std::mutex mutex; std::vector<std::function<void()>> queue;
 bool isLogicRunning() { return alive; }
 void invokeInLogic(std::function<void()> f) { std::lock_guard<std::mutex> lock(mutex); queue.push_back(std::move(f)); }
 void tick() { std::vector<std::function<void()>> work; {std::lock_guard<std::mutex> lock(mutex); work.swap(queue);} for(auto& f:work)f(); }
} SharedApplication;
constexpr double LogicDispatchTimeoutSeconds=10;
struct HttpServer { struct Request {
 std::shared_ptr<void> storage;
 Slice method,path; std::vector<Slice> headers,params; Slice contentType,body;
}; };
struct Header {const char* name; const char* value;};
struct DoraXrtHttpServerRequest {const char* methodText; const char* path; const char* target; size_t headerCount; Header* headers; const void* body; size_t bodyLen;};
const char* DoraXrtHttpServerRequestHeader(const DoraXrtHttpServerRequest*,const char*) {return "application/json";}
auto parse_query_pairs(const char*) {return std::vector<std::pair<std::string,std::string>>{{"q","copied query"}};}
'''
main = r'''
int main() {
 std::atomic_bool stopping{false}; std::atomic_uint64_t generation{1};
 {PendingLogicResult<int> p; p.complete(42); assert(p.wait(stopping,generation,1,.2)==42);}
 {PendingLogicResult<int> p; std::atomic_bool finished{false};
  std::thread logic([&]{auto until=std::chrono::steady_clock::now()+600ms;while(std::chrono::steady_clock::now()<until){SharedApplication.tick();std::this_thread::sleep_for(5ms);}p.complete(7);finished=true;});
  auto value=p.wait(stopping,generation,1,.2); logic.join();assert(value==7);assert(!p.timedOut());}
 {PendingLogicResult<int> p; assert(!p.wait(stopping,generation,1,.15));assert(p.timedOut());p.complete(3);assert(p.isCancelled());
  {std::lock_guard<std::mutex> lock(SharedApplication.mutex);assert(SharedApplication.queue.size()<=1);}SharedApplication.tick();}
 {PendingLogicResult<int> p;stopping=true;assert(!p.wait(stopping,generation,1,.2));assert(!p.timedOut());stopping=false;}
 {PendingLogicResult<int> p;generation=2;assert(!p.wait(stopping,generation,1,.2));assert(!p.timedOut());}
 {PendingLogicResult<int> p;SharedApplication.alive=false;assert(!p.wait(stopping,generation,2,.2));assert(!p.timedOut());SharedApplication.alive=true;}
 HttpServer::Request saved;
 {std::string method="POST",path="/owned",body(4096,'b'),headerName="X-Test",headerValue="owned header";Header headers[]={{headerName.c_str(),headerValue.c_str()}};
  DoraXrtHttpServerRequest native{method.c_str(),path.c_str(),"/?q=copied",1,headers,body.data(),body.size()};
  auto request=make_request(&native);saved=request;
  method.assign(100,'x');path.assign(100,'x');body.assign(9000,'x');headerName.assign(100,'x');headerValue.assign(100,'x');}
 assert(saved.method=="POST" && saved.path=="/owned" && saved.body==std::string(4096,'b'));
 assert(saved.headers[0]=="X-Test" && saved.headers[1]=="owned header" && saved.params[1]=="copied query");
 std::cout<<"HTTP pending regression: 7 cases passed\n";
}
'''
with tempfile.TemporaryDirectory(prefix='dora-http-pending-') as temp:
    cpp = Path(temp) / 'test.cpp'
    exe = Path(temp) / 'test'
    cpp.write_text(prefix + pending + make_request + main)
    subprocess.run([os.environ.get('CXX', 'c++'), '-std=c++17', '-pthread', '-fsanitize=address,undefined', '-fno-omit-frame-pointer', str(cpp), '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True, timeout=15)
