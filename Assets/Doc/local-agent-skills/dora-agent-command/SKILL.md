---
name: dora-agent-command
description: Run Dora engine Lua snippets or supported Git commands through the project-scoped Dora CLI bridge.
---
<!-- dora-managed-skill:dora-agent-command:v1 -->

# Dora Agent Command Bridge

Use this skill when a task needs Dora engine runtime APIs or the engine's Git command implementation. For ordinary repository Git work, direct local `git` is fine; the bridge remains available when a unified project-rooted JSON result or Web IDE refresh behavior is useful.

The injected `dora` command already points at the running engine and its Asset directory. Do not locate the binary, create an alias, or hard-code a machine path.

## Call shape

Write a temporary JSON request inside the project, then run:

```sh
dora cli agent command -p <project> --input .agent/command.json
```

Lua request:

```json
{
  "mode": "lua",
  "code": "print(App.platform)",
  "timeoutSeconds": 30
}
```

Git request:

```json
{
  "mode": "git",
  "command": "status",
  "cwd": ".",
  "timeoutSeconds": 600
}
```

The command prints one JSON result to stdout; stderr is diagnostic output. The bridge calls engine tools only. It never starts Dora Agent or another third-party Agent, so do not construct nested Agent scheduling.

## Lua mode

Lua runs in a temporary bounded environment:

- Dora API globals are available, except unrestricted `Content`, `DB`, `HttpClient`, and `HttpServer`.
- `projectDir` is the current project root.
- `Content` can inspect and read project-relative files only.
- `requireProjectModule(name, reload?)` loads a module from the project or engine Asset search paths.
- `reportProgress({progress?, stage?, message?})` reports meaningful stages.
- `refreshTree(path?)` refreshes the Web IDE tree.
- `getEntryStatus()`, `enterEntryAsync(entry)`, and `stopEntry()` support bounded runtime tests.
- Only `print(...)` output is captured; return values are not.

Keep snippets bounded and yield while waiting for async engine work. The default timeout is 30 seconds and the maximum is 600 seconds. Use `dora cli agent preview` for visual capture instead of calling `previewGame` through this bridge.

## Git mode

Pass only an engine-supported Git subcommand, without the leading `git`. Its arguments are intentionally narrower than the native Git CLI, so start with `status` rather than adding native formatting flags such as `--short`. Shell pipes, redirects, chaining, substitutions, environment assignments, and `git -C` are unsupported. `cwd` must remain inside the project. The default timeout is 600 seconds and the maximum is 1800 seconds.

Remove temporary request files after their evidence has been recorded, unless they are intentionally part of the project.
