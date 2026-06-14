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
