#!/usr/bin/env python3
"""Compile the production filesystem boundary policy against std and ghc backends."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[2]
code = r'''
BACKEND
#include "Source/Common/PathPolicy.h"
#include <cassert>
#include <iostream>
using namespace Dora::PathPolicy;
int main(int argc, char** argv) {
 assert(argc == 2);
 fs::path temp(argv[1]);
 auto base = temp / "writable";
 auto outside = temp / "outside";
 fs::create_directories(base / "nested");
 fs::create_directories(outside);
 fs::create_directories(base / "deep" / "sub");
 fs::create_directory_symlink(base / "deep" / "sub", base / "walk");
 fs::create_directory_symlink(outside, base / "alias");
 auto allowed = [&](const fs::path& path) { return isWithin(path.string(), base.string()); };
 assert(allowed(base));
 assert(allowed(base / "nested"));
 assert(allowed(base / "new" / "repo"));
 assert(!allowed(base / "nested" / ".." / "new"));
 assert(allowed(base.string() + "/"));
 assert(!allowed(outside));
 assert(!allowed(base.string() + "-sibling"));
 assert(!allowed(base / ".." / "outside"));
 assert(!allowed(base / "missing" / ".." / ".." / "outside"));
 assert(!isWithin("relative/repo", base.string()));
 assert(!isWithin("", base.string()));
 assert(!isWithin(base.string(), ""));
 assert(!isWithin(base.string(), (temp / "missing-root").string()));
 assert(!isWithin(base.string() + std::string("\0/../outside", 12), base.string()));
 fs::create_directory_symlink(outside, base / "escape");
 fs::create_directory_symlink(base / "nested", base / "inside");
 fs::create_directory_symlink(outside / "missing", base / "dangling");
 fs::create_directory_symlink(base, temp / "root-alias");
 assert(!allowed(base / "escape"));
 assert(!allowed(base / "walk" / ".." / "alias"));
 assert(!allowed(base / "." / "nested"));
 assert(!allowed(base / "escape" / "new"));
 assert(!allowed(base / "escape" / ".." / "outside"));
 assert(!allowed(base / "dangling"));
 assert(allowed(base / "inside" / "new"));
 assert(isWithin((base / "nested").string(), (temp / "root-alias").string()));
 std::cout << "Git path policy: 22 root, traversal, new-directory and symlink cases passed\n";
}
'''
with tempfile.TemporaryDirectory(prefix='dora-git-path-policy-') as temporary:
    temp = Path(temporary)
    for backend in ('std', 'ghc'):
        # Exercise the ghc implementation used by the Linux/Windows engine too.
        cpp = temp / (backend + '.cpp')
        cpp.write_text(code.replace('BACKEND', '' if backend == 'std' else
            '#include "ghc/filesystem.hpp"\n#define BX_PLATFORM_LINUX 1'))
        binary = temp / backend
        subprocess.run([os.environ.get('CXX', 'c++'), '-std=c++17', '-fsanitize=address,undefined',
                        '-I', str(root), '-I', str(root / 'Source/3rdParty'),
                        str(cpp), '-o', str(binary)], check=True)
        work = temp / (backend + '-files'); work.mkdir()
        subprocess.run([str(binary), str(work)], check=True)

server = (root / 'Assets/Script/Dev/WebServer.yue').read_text()
assert 'not Git\\isRepoPathAllowed repoPath' in server
assert '"invalid clone target" if gitInvalidRepoPath targetPath' in server
binding = (root / 'Tools/tolua++/Dora.h').read_text()
assert 'Git::isRepoPathAllowed @ isRepoPathAllowed(String repoPath)' in binding
print('Web Git repository and clone-target policy wiring passed')
