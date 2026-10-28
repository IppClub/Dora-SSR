#!/usr/bin/env python3
"""Compile the production Web queue against a deterministic async-call scheduler."""
import argparse, hashlib, json, subprocess, tempfile
from pathlib import Path
root = Path(__file__).resolve().parents[4]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args(); out = a.output.resolve(); out.mkdir(parents=True, exist_ok=True)
report = out / 'verification.json'; report.unlink(missing_ok=True)
fixture = r'''
#include "Web/WebTaskQueue.h"
#include <cassert>
#include <deque>
#include <memory>
#include <string>
#include <utility>
#include <vector>
static std::deque<std::pair<void(*)(void*),void*>> callbacks;
extern "C" void emscripten_async_call(void(*callback)(void*), void* data, int) {
    callbacks.emplace_back(callback,data);
}
void flush() {
    while (!callbacks.empty()) {
        auto [callback,data] = callbacks.front(); callbacks.pop_front(); callback(data);
    }
}
int main(int argc, char** argv) {
    assert(argc == 2); using namespace Dora::Web;
    std::vector<int> executed;
    postTask([&] { executed.push_back(1); postTask([&] { executed.push_back(2); }); });
    assert(pendingTaskCount() == 1 && callbacks.size() == 1); flush();
    assert((executed == std::vector<int>{1,2}));
    auto token = std::make_shared<int>(1); std::weak_ptr<int> lifetime = token;
    const bool inside = std::string(argv[1]) == "inside";
    if (inside) postTask([&] { executed.push_back(3); stopTaskQueue(); });
    postTask([&, held = token] { executed.push_back(99); }); token.reset();
    assert(!lifetime.expired());
    if (!inside) stopTaskQueue();
    flush();
    assert(lifetime.expired() && pendingTaskCount() == 0 && callbacks.empty());
    assert((executed == (inside ? std::vector<int>{1,2,3} : std::vector<int>{1,2})));
    postTask([&] { executed.push_back(100); });
    assert(pendingTaskCount() == 0 && callbacks.empty());
    stopTaskQueue(); // Final teardown is idempotent.
}
'''
with tempfile.TemporaryDirectory(dir=out) as temporary:
    stage = Path(temporary); (stage / 'emscripten').mkdir()
    (stage / 'emscripten/emscripten.h').write_text('extern "C" void emscripten_async_call(void(*)(void*), void*, int);\n')
    (stage / 'main.cpp').write_text(fixture)
    subprocess.run(['c++', '-std=c++20', '-Wall', '-Wextra', '-Werror', '-I'+str(stage), '-I'+str(root/'Source'), str(stage/'main.cpp'), str(root/'Source/Web/WebTaskQueue.cpp'), '-o', str(stage/'test')], check=True)
    for mode in ('outside', 'inside'):
        subprocess.run([str(stage/'test'), mode], check=True)
report.write_text(json.dumps({'passed': True, 'scope': 'Production queue with deterministic native scheduler; no autorelease-pool or browser/GPU execution', 'cases': ['outside-stop-late-callback', 'inside-stop-cancel-followups'], 'source_sha256': hashlib.sha256((root/'Source/Web/WebTaskQueue.cpp').read_bytes()).hexdigest()}, indent=2)+'\n')
print('Web queue final teardown: PASS')
