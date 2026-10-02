#!/usr/bin/env python3
"""Exercise the Agent Content facade through a running native Dora CLI bridge.

Usage: python3 Tools/tests/test_agent_command_content.py --dora /path/to/Dora
A native Dora service and its connected Web IDE are required.
"""
import argparse
import json
from pathlib import Path
import re
import subprocess
import tempfile

SCOPED = r'''
local native = requireProjectModule("Dora").Content
local nativeAsset, nativeWritable = native.assetPath, native.writablePath
local nativePaths = table.concat(native.searchPaths, "|")
assert(Content ~= native)
for _, name in ipairs(methods) do assert(type(Content[name]) == "function", name) end
assert(Content.assetPath == "." and Content.writablePath == "." and Content.appPath == ".")
local function check(list, expected)
  table.sort(list)
  assert(table.concat(list, "|") == expected, table.concat(list, "|"))
end
check(Content:getDirs("resources/.agent"), "nested")
check(Content.getFiles("resources/.agent"), "one_in.md")
check(Content:getAllFiles("resources/.agent"), "nested/two_out.md|one_in.md")
assert(Content:isAbsolutePath(projectDir))
assert(Content:getFullPath("resources/.agent/one_in.md") == Path(projectDir, "resources/.agent/one_in.md"))
assert(Content:mkdir("created"))
assert(Content:isdir("created"))
assert(Content:remove("created"))
local size, binary = Content.getAttr("resources/.agent/one_in.md")
assert(size == 8 and binary == false)
Content.assetPath = "resources"
assert(Content:load(".agent/one_in.md") == "fixture\n")
Content.writablePath = "output"

assert(Content:save("saved.md", "written\n"))
assert(Content:saveAsync("async.md", "asynchronous\n"))
assert(Content:loadAsync(".agent/one_in.md") == "fixture\n")
Content.assetPath = "."
assert(Content:load("output/saved.md") == "written\n")
assert(Content.copy("resources/.agent/one_in.md", "copied.md"))
assert(Content:move("copied.md", "moved.md"))
assert(Content:copyAsync("output/moved.md", "async-copy.md"))
assert(Content:remove("moved.md"))
assert(Content:zipAsync("resources", "archive.zip"))
assert(Content:unzipAsync("output/archive.zip", "unpacked"))
assert(Content:load("output/unpacked/.agent/one_in.md") == "fixture\n")
Content:insertSearchPath(1, "resources/.agent")
assert(Content:load("one_in.md") == "fixture\n")
Content:removeSearchPath("resources/.agent")
Content.addSearchPath("resources/.agent/nested")
assert(Content.load("two_out.md") == "second\n")
Content.searchPaths = {"resources/.agent"}
local copy = Content.searchPaths
copy[1] = "../outside"
assert(Content:load("one_in.md") == "fixture\n")
Content:clearPathCache()
Content.searchPaths = {}
check(Content:glob("resources/.agent", {"**.md"}), "nested/two_out.md|one_in.md")
local found = Content:searchFilesAsync("resources", {"md"}, {}, {"**"}, "fixture", false, true, true, 0)
assert(#found == 1)
local invalid = {"../outside", "resources/../../outside", "/tmp/outside", "C:\\outside", "resources\\..\\outside", "a\0b"}
local singles = {"exist", "isdir", "getAttr", "getDirs", "getFiles", "getAllFiles", "getFullPath", "glob", "searchFilesAsync", "load", "loadAsync", "loadExcel", "loadExcelAsync", "save", "saveAsync", "mkdir", "remove", "addSearchPath", "removeSearchPath"}
for _, method in ipairs(singles) do
  for _, path in ipairs(invalid) do
    local ok, err = pcall(function() Content[method](Content, path) end)
    assert(not ok and tostring(err):find("inside projectDir", 1, true), method .. ": " .. path)
  end
end
for _, method in ipairs({"copy", "copyAsync", "move", "zipAsync", "unzipAsync"}) do
  for _, path in ipairs(invalid) do
    assert(not pcall(function() Content[method](Content, path, "valid") end), method)
    assert(not pcall(function() Content[method](Content, "valid", path) end), method)
  end
end
for _, path in ipairs(invalid) do
  assert(not pcall(function() Content.assetPath = path end))
  assert(not pcall(function() Content.writablePath = path end))
  assert(not pcall(function() Content.searchPaths = {path} end))
  assert(not pcall(function() Content:insertSearchPath(1, path) end))
end
assert(not pcall(function() Content.appPath = "output" end))
assert(native.assetPath == nativeAsset and native.writablePath == nativeWritable)
assert(table.concat(native.searchPaths, "|") == nativePaths)
print("PASS: all 27 methods present; directory traversal, relative roots, search paths, sync/async writes, ZIP, multiple returns, both call styles, invalid source/destination/property paths, engine state isolation")

'''

VIRTUAL = r'''
local doc = "@dora-doc/dora-api/Content.d.tl"
local skill = "@agent-skill/project/test/SKILL.md"
assert(Content:load(doc):find("getDirs", 1, true))
assert(Content:loadAsync(skill) == "project skill fixture\n")
assert(Content:exist(doc) and not Content:isdir(doc))
assert(Content:getFullPath(doc) == doc)
local size, binary = Content:getAttr(skill)
assert(size == #"project skill fixture\n" and binary == false)
local called = false
local matches = Content:searchFilesAsync(doc, {}, {}, {"**"}, "getDirs", false, true, true, 0, function(row)
  assert(row.file == doc)
  called = true
  return false
end)
assert(called and #matches > 0 and matches[1].file == doc)
local optionalMatches = Content:searchFilesAsync(doc, {}, {}, {"**"}, "getDirs", nil, nil, nil, nil, function(row)
  assert(row.file == doc)
  return false
end)
assert(#optionalMatches > 0)
local native = requireProjectModule("Dora").Content
local chinese = requireProjectModule("Agent.Tool.CommandContent").createCommandContent(projectDir, "zh")
assert(chinese:load(doc) == native:load(Path(native.assetPath, "Script/Lib/Dora/zh-Hans/Content.d.tl")))
assert(Content:copy(skill, "skill-copy.md"))
assert(Content:load("skill-copy.md") == "project skill fixture\n")
assert(Content:load("@dora_full_logs.txt"))
for _, virtual in ipairs({doc, skill, "@agent-skill/builtin/test/SKILL.md", "@agent-skill/user/test/SKILL.md", "@dora_full_logs.txt"}) do
  for _, method in ipairs({"save", "saveAsync", "remove", "mkdir"}) do
    local ok, err = pcall(function() Content[method](Content, virtual, "wrong") end)
    assert(not ok and tostring(err):find("read-only", 1, true), method)
  end
  for _, method in ipairs({"copy", "copyAsync", "move", "zipAsync", "unzipAsync"}) do
    assert(not pcall(function() Content[method](Content, "resources", virtual) end), method)
  end
  assert(not pcall(function() Content:move(virtual, "valid.md") end))
  assert(not pcall(function() Content.searchPaths = {virtual} end))
end
for _, invalid in ipairs({"@dora-doc/dora-api/../Content.d.tl", "@agent-skill/project/../test/SKILL.md", "@agent-skill/user/../../outside", "@dora-doc/unknown/Content.d.tl"}) do
  assert(not pcall(function() Content:load(invalid) end))
end
print("PASS: virtual docs/skills/log reads, async load, metadata, search/callback virtual identity, copy to project, namespace traversal and write rejection, no project-file shadowing")
'''

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dora", type=Path, required=True)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[2]
    methods = re.findall(r"^\t(\w+): function", (repo / "Assets/Script/Lib/Dora/en/Content.d.tl").read_text(), re.M)
    with tempfile.TemporaryDirectory(prefix="dora-content-regression-") as temporary:
        root = Path(temporary)
        for name, text in {
            "resources/.agent/one_in.md": "fixture\n",
            "resources/.agent/nested/two_out.md": "second\n",
            ".agent/skills/test/SKILL.md": "project skill fixture\n",
            "@dora-doc/dora-api/Content.d.tl": "spoofed document\n",
        }.items():
            file = root / name
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text(text)
        (root / "output").mkdir()
        def command(code):
            request = root / "request.json"
            request.write_text(json.dumps({"mode": "lua", "code": code, "timeoutSeconds": 30}))
            result = subprocess.run(
                [str(args.dora.resolve()), "--asset", str(repo / "Assets"), "cli", "agent", "command", "-p", str(root), "--input", str(request)],
                text=True, capture_output=True, timeout=45,
            )
            try:
                reply = json.loads(result.stdout)
            except json.JSONDecodeError:
                raise AssertionError(result.stdout + result.stderr)
            assert result.returncode == 0 and reply.get("success"), reply
            print(reply.get("output", ""))
        command('requireProjectModule("Agent.Tool.Workspace"); requireProjectModule("Agent.Tool.CommandContent"); requireProjectModule("Agent.Tool.Command"); print("Reloaded command modules")')
        inventory = "local methods = {" + ",".join(json.dumps(name) for name in methods) + "}\n"
        command(inventory + SCOPED)
        command(VIRTUAL)


if __name__ == "__main__":
    main()
