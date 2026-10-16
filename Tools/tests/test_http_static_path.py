#!/usr/bin/env python3
"""Compile and exercise the production static path validator."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
source = (root / 'Source/Http/HttpServer.cpp').read_text()
validator = source[source.index('static bool valid_static_path'):source.index('static const char* content_type_for_path')]

harness = r'''
#include <cassert>
#include <cstdio>
#include <string>
#include <string_view>
using namespace std::literals;
''' + validator + r'''
int main() {
	struct { const char* name; std::string path; bool want; } cases[] = {
		{"plain file", "/index.html", true},
		{"nested file", "/assets/js/bundle.js", true},
		{"directory slash", "/assets/", true},
		{"double slash tolerated", "/a//b.txt", true},
		{"dot segment tolerated", "/a/./b.txt", true},
		{"empty", "", false},
		{"relative", "index.html", false},
		{"parent segment", "/..", false},
		{"parent mid path", "/a/../b", false},
		{"parent trailing", "/assets/..", false},
		{"backslash whole segment", "/..\\..\\secret", false},
		{"backslash in filename", "/b1\\b2.txt", false},
		{"trailing backslash parent", "/a\\..\\..\\b", false},
		{"embedded nul", std::string("/a\0b", 4), false},
	};
	int failures = 0;
	for (const auto& item : cases) {
		const bool got = valid_static_path(item.path);
		if (got != item.want) {
			++failures;
			std::printf("FAIL %-28s valid_static_path(%s) = %d, want %d\n",
				item.name, item.path.c_str(), static_cast<int>(got), static_cast<int>(item.want));
		}
	}
	if (!failures) std::printf("HTTP static path validation: %zu cases passed\n", sizeof(cases) / sizeof(cases[0]));
	return failures ? 1 : 0;
}
'''

def main():
    compiler = os.environ.get('CXX', 'c++')
    with tempfile.TemporaryDirectory(prefix='dora-static-path-') as temporary:
        source_path = Path(temporary) / 'static_path.cpp'
        binary = Path(temporary) / 'static_path'
        source_path.write_text(harness)
        compile_result = subprocess.run([compiler, '-std=c++17', '-O0', '-g0',
                                         '-o', str(binary), str(source_path)],
                                        text=True, capture_output=True)
        assert compile_result.returncode == 0, compile_result.stderr
        run_result = subprocess.run([str(binary)], text=True, capture_output=True)
        print(run_result.stdout.strip())
        assert run_result.returncode == 0, run_result.stdout + run_result.stderr

if __name__ == '__main__':
    main()
