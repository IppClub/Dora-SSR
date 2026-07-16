---
name: agent-command
description: Rules and examples for using execute_command with Lua and Git safely inside the Dora Agent runtime.
always: true
requiredTools:
  - execute_command
---

# Agent Command

Use `execute_command` only for short engine-side Lua snippets or supported Git operations. Prefer normal file tools for deterministic file edits.

## Modes

- `mode: "lua"` runs raw Lua code in the Dora engine.
- `mode: "git"` runs a supported Git command through the engine Git client.
- Shell syntax is not supported. Do not use pipes, redirects, command chaining, subshells, environment assignments, or `git -C`.

## Lua Mode

Lua command code runs in a temporary environment:

- Dora API globals are available through the command environment.
- `projectDir` is the current project directory.
- `print(...)` is the only output captured into the tool result.
- Return values are not captured.
- Global writes are local to the current command and are not shared with later commands.
- Dora async APIs such as `Content:copyAsync(...)`, `Content:zipAsync(...)`, and `Content:unzipAsync(...)` may be called directly.
- The tool call waits until the Lua command finishes, including yielding async calls made inside the command.
- Keep commands short. Do not run infinite loops or long CPU-bound work.
- Lua commands default to a 30 second timeout. `timeoutSeconds` may be set explicitly for a bounded engine test.
- `getEntryStatus()` returns the current Dora entry status.
- `enterEntryAsync({ entryName?, fileName? })` starts a built Lua entry from the current project. `fileName` is project-relative, defaults to `init`, and may include its source or Lua extension.
- `stopEntry()` stops an entry started by this command. The tool also stops it automatically when the command succeeds, fails, is canceled, or times out.
- The Dora entry runtime is shared. If another Agent command owns it, do not wait in a loop; report the contention or retry in a later Agent turn.

## In-Engine Game Script Validation

Use an in-engine test for gameplay state, scheduling, DoraX updates, input handling, actions, physics, or other runtime behavior. A successful build alone is not runtime validation.

Follow this short path before searching APIs or probing paths:

1. Write a focused test entry in the project's authored language. For TS/TSX, build it first and run the generated Lua entry.
2. Write the result to a unique marker under the **project root** `.agent/test-results`, not under `Content.writablePath`. The command-side absolute marker is `Path(projectDir, ".agent", "test-results", name)`.
3. In an Agent-started entry, the project root is `Content.searchPaths[0]`. Attach scheduled nodes to `Director.entry`; an unattached node is not driven by the scene scheduler.
4. Remove a stale marker, start the built entry with `enterEntryAsync`, and poll with short `sleep(...)` yields plus an `App.runningTime` deadline.
5. Read the marker, explicitly call `stopEntry()`, then verify `getEntryStatus().success` and `getEntryStatus().running == false` before asserting the result.
6. Treat only `passed` as success. Raise an error for failure text, a missing marker, timeout, or a still-running entry.
7. Report build and runtime validation separately with the printed command evidence. Do not search Dora APIs first when the template below applies; investigate only a concrete build or runtime error.

Canonical root-level TypeScript test entry (`init.ts`):

```ts
import { Content, Director, Node, Path } from "Dora";

const resultDir = Path(Content.searchPaths[0], ".agent", "test-results");
if (!Content.exist(resultDir)) Content.mkdir(resultDir);

const node = Node();
node.addTo(Director.entry);
node.schedule(() => {
  Content.save(Path(resultDir, "engine-case.txt"), "passed");
  return true;
});
```

Canonical command after building the entry:

```lua
local resultDir = Path(projectDir, ".agent", "test-results")
if not Content:exist(resultDir) then
  assert(Content:mkdir(resultDir), "failed to create test result directory")
end
local marker = Path(resultDir, "engine-case.txt")
Content:remove(marker)

local success, loadError = enterEntryAsync({
  fileName = "init.ts"
})
assert(success, loadError)

local deadline = App.runningTime + 10
while not Content:exist(marker) and App.runningTime < deadline do
  sleep(0.05)
end

local result = Content:exist(marker) and Content:load(marker) or nil
stopEntry()
local status = getEntryStatus()

assert(status.success, "entry status failed")
assert(not status.running, "entry still running after stopEntry")
assert(result ~= nil, "runtime test timed out")
assert(result == "passed", result)
print("build entry: init.ts")
print("marker: " .. marker .. " = " .. result)
print("after stop: success=" .. tostring(status.success) .. " running=" .. tostring(status.running))
print("runtime test passed")
```

Keep the marker until its evidence has been reported or read, then remove test artifacts. The test entry must yield back to the engine scheduler. A pure CPU loop that never yields blocks the Dora runtime and cannot be interrupted by the command timeout.

After file changes, refresh the Web IDE resource tree:

- `refreshTree()` reloads the full asset tree.
- `refreshTree("relative/file.ext")` refreshes one project-relative file.

Lua examples for common file operations that are not covered by the normal Agent file tools:

Move a file without overwriting an existing target:

```lua
local sourceRel = ".temp/source.txt"
local targetRel = ".temp/archive/source.txt"
local source = Path(projectDir, sourceRel)
local target = Path(projectDir, targetRel)

local function ensureDir(dir)
  if Content:exist(dir) then
    return Content:isdir(dir)
  end
  local parent = Path:getPath(dir)
  if parent ~= dir and parent ~= "" then
    assert(ensureDir(parent), "failed to create parent directory")
  end
  return Content:mkdir(dir)
end

assert(ensureDir(Path:getPath(target)), "failed to create target directory")
assert(Content:exist(source), "source file does not exist")
assert(not Content:exist(target), "target already exists")
assert(Content:move(source, target), "failed to move file")

refreshTree()
print("moved", sourceRel, "to", targetRel)
```

Copy a file or directory asynchronously:

```lua
local sourceRel = "AssetsTemplate"
local targetRel = ".temp/AssetsTemplate"
local source = Path(projectDir, sourceRel)
local target = Path(projectDir, targetRel)

local function ensureDir(dir)
  if Content:exist(dir) then
    return Content:isdir(dir)
  end
  local parent = Path:getPath(dir)
  if parent ~= dir and parent ~= "" then
    assert(ensureDir(parent), "failed to create parent directory")
  end
  return Content:mkdir(dir)
end

assert(Content:exist(source), "source does not exist")
assert(not Content:exist(target), "target already exists")
assert(ensureDir(Path:getPath(target)), "failed to create target directory")
assert(Content:copyAsync(source, target), "failed to copy")

refreshTree()
print("copied", sourceRel, "to", targetRel)
```

Remove a generated file or directory:

```lua
local targetRel = ".temp/generated"
local target = Path(projectDir, targetRel)

if Content:exist(target) then
  assert(Content:remove(target), "failed to remove target")
  refreshTree()
  print("removed", targetRel)
else
  print("target not found", targetRel)
end
```

Create a zip archive, then unzip it into a project folder:

```lua
local sourceRel = ".temp/package-src"
local zipRel = ".temp/package.zip"
local outRel = ".temp/package-unzipped"
local sourceDir = Path(projectDir, sourceRel)
local zipFile = Path(projectDir, zipRel)
local outDir = Path(projectDir, outRel)

local function ensureDir(dir)
  if Content:exist(dir) then
    return Content:isdir(dir)
  end
  local parent = Path:getPath(dir)
  if parent ~= dir and parent ~= "" then
    assert(ensureDir(parent), "failed to create parent directory")
  end
  return Content:mkdir(dir)
end

if Content:exist(sourceDir) then
  assert(Content:remove(sourceDir), "failed to remove existing source directory")
end
assert(ensureDir(sourceDir), "failed to create source directory")
assert(Content:save(Path(sourceDir, "a.txt"), "alpha"), "failed to create source file")

if Content:exist(zipFile) then
  assert(Content:remove(zipFile), "failed to remove existing zip file")
end
assert(Content:zipAsync(sourceDir, zipFile), "failed to zip archive")
assert(Content:exist(zipFile), "zip file was not created")

assert(ensureDir(Path:getPath(outDir)), "failed to create output parent directory")
if Content:exist(outDir) then
  assert(Content:remove(outDir), "failed to remove existing output directory")
end
-- Content:unzipAsync expects paths under Content.writablePath. Project files
-- are valid when projectDir is inside the writable project workspace.
assert(Content:unzipAsync(zipFile, outDir, function(filename)
  return not filename:match("^__MACOSX/")
    and filename ~= ".DS_Store"
    and not filename:match("/%.DS_Store$")
end), "failed to unzip archive")

refreshTree()
print("zipped and unzipped", zipRel, "to", outRel)
```

## Git Mode

Git mode uses the Dora engine Git client, not a shell. Use it for repository operations such as clone, status, diff, add, commit, fetch, pull, and push when those operations are appropriate for the task.

Rules:

- Existing clone targets are not overwritten.
- Clone should use HTTP or HTTPS remotes.
- Do not use credential prompts.
- Keep command text to a single Git command.
- For Git commands inside a sub-repository, pass `cwd` as a project-relative directory.
- Do not use `git -C`; use the tool's `cwd` parameter instead.
- `git clone` target paths are project-relative and are not affected by `cwd`.

Git examples:

```text
git status
```

```text
git diff -- init.ts
```

```text
git clone https://example.com/owner/repo.git .temp/repo
```

Run status inside that cloned sub-repository with:

```json
{"mode":"git","cwd":".temp/repo","command":"git status"}
```

```text
git add init.ts
```

```text
git commit -m "Update init script"
```
