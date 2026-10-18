#!/usr/bin/env python3
"""Compile and exercise the production constant-time auth comparison."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
source = (root / 'Source/Http/HttpServer.cpp').read_text()
helper = source[source.index('static bool constant_time_equal'):source.index('static bool has_valid_auth')]

harness = r'''
#include <cassert>
#include <cstdio>
#include <string>
#include <string_view>
''' + helper + r'''
int main() {
	struct { std::string left, right; bool want; } cases[] = {
		{"", "", true},
		{"token", "token", true},
		{"token", "tokem", false},
		{"token", "tokens", false},
		{"tokens", "token", false},
		{"", "x", false},
		{"x", "", false},
		{std::string("a\0b", 3), std::string("a\0b", 3), true},
		{std::string("a\0b", 3), std::string("a\0c", 3), false},
		{"session-123:secret-abc", "session-123:secret-abc", true},
		{"session-123:secret-abc", "session-123:secret-abd", false},
	};
	int failures = 0;
	for (const auto& item : cases) {
		const bool got = constant_time_equal(item.left, item.right);
		if (got != item.want) {
			++failures;
			std::printf("FAIL constant_time_equal mismatch (want %d)\n", static_cast<int>(item.want));
		}
	}
	if (!failures) std::printf("HTTP constant-time auth comparison: %zu cases passed\n", sizeof(cases) / sizeof(cases[0]));
	return failures ? 1 : 0;
}
'''

def main():
    compiler = os.environ.get('CXX', 'c++')
    with tempfile.TemporaryDirectory(prefix='dora-constant-time-') as temporary:
        source_path = Path(temporary) / 'constant_time.cpp'
        binary = Path(temporary) / 'constant_time'
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
