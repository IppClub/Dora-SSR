#!/usr/bin/env python3
"""Compile and exercise production URL parsing and desktop activation transport."""
import os
from pathlib import Path
import subprocess
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[2]
SOURCE = r'''
#include "Source/Basic/ProjectLink.h"
#include "Source/Basic/GuiInstance.h"
#include <cassert>
#include <iostream>
int main(int argc, char** argv) {
    if (argc == 1) {
        const std::string expected = "https://github.com/IppClub/Dora-Example";
        assert(Dora::projectRepository("dora-ssr://open?repo=https%3A%2F%2Fgithub.com%2FIppClub%2FDora-Example.git") == expected);
        assert(Dora::projectRepository("dora-ssr://open/?repo=https://github.com/IppClub/Dora-Example/") == expected);
        for (auto host : {"atomgit.com", "gitee.com", "gitcode.com"})
            assert(!Dora::projectRepository(std::string("dora-ssr://open?repo=https://") + host + "/owner/project").empty());
        for (auto bad : {"", "dora-ssr://open?asset=1", "dora-ssr://open?repo=http://github.com/a/b",
             "dora-ssr://open?repo=https://github.com/a/b&run=1", "dora-ssr://open?repo=https://github.com/a/b%00",
             "dora-ssr://open?repo=https://github.com/a/%2e%2e", "dora-ssr://open?repo=https://github.com/a/b%252fother",
             "dora-ssr://open?repo=https://github.com/a/b%", "dora-ssr://open?repo=https://github.com/a/b%0a",
             "dora-ssr://open?repo=https://github.com@localhost/a/b", "dora-ssr://open?repo=https://localhost/a/b",
             "dora-ssr://open?repo=https://github.com/a/b/tree/main", "dora-ssr://open?repo=https://github.com/a/.git"})
            assert(Dora::projectRepository(bad).empty());
        assert(Dora::projectRepository("dora-ssr://open?repo=" + std::string(2048, 'a')).empty());
        return 0;
    }
    Dora::GuiInstance instance(argv[1]);
    auto result = instance.acquire(argc > 2 ? argv[2] : "");
    if (result == Dora::GuiInstance::Result::Error) return 2;
    if (result != Dora::GuiInstance::Result::Primary) return 0;
    std::cout << "ready" << std::endl;
    std::string command, value;
    while (std::getline(std::cin, command)) {
        bool received = instance.takeActivationRequest(value);
        std::cout << (received ? value : "idle") << std::endl;
    }
}
'''

def main():
    with tempfile.TemporaryDirectory() as temporary:
        directory = Path(temporary)
        source = directory / "links.cpp"
        executable = directory / ("links.exe" if os.name == "nt" else "links")
        source.write_text(SOURCE)
        compiler = os.environ.get("CXX", "cl" if os.name == "nt" else "c++")
        if Path(compiler).stem == "cl":
            args = [compiler, "/nologo", "/std:c++17", "/EHsc", "/I" + str(ROOT), str(source), "/Fe:" + str(executable), "/link", "user32.lib", "advapi32.lib"]
        else:
            args = [compiler, "-std=c++17", "-Wall", "-Wextra", "-pthread", "-I", str(ROOT), str(source), "-o", str(executable)]
        if os.name == "nt" and Path(compiler).stem != "cl":
            args += ["-luser32", "-ladvapi32"]
        subprocess.run(args, check=True, cwd=temporary)
        subprocess.run([str(executable)], check=True)
        name = "dora-project-link-test-" + uuid.uuid4().hex
        owner = subprocess.Popen([str(executable), name], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        try:
            assert owner.stdout.readline().strip() == "ready"
            link = "dora-ssr://open?repo=https%3A%2F%2Fgithub.com%2FIppClub%2FDora-Example"
            # Identical activations must both arrive: each triggers normal re-entry.
            for value in [link, link, "x" * 2048]:
                subprocess.run([str(executable), name, value], check=True, timeout=5)
                owner.stdin.write("poll\n"); owner.stdin.flush()
                assert owner.stdout.readline().strip() == value
            owner.stdin.write("poll\n"); owner.stdin.flush()
            assert owner.stdout.readline().strip() == "idle"
        finally:
            owner.stdin.close(); owner.wait(timeout=5); owner.stdout.close()
    print("PASS: project URL validation and repeated/full-size activation delivery")

if __name__ == "__main__":
    main()
