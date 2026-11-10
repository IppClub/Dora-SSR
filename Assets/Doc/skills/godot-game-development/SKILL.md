---
name: godot-game-development
description: Create, modify, or debug GDScript Godot games hosted by Dora GodotNode, including project.godot, scenes, resources, resource import, and Dora preview.
---

# Godot Game Development

## Project and runtime boundaries

- Locate `project.godot` before editing. The Web IDE's Godot 2D/3D templates put it beside `init.ts`, `main.tscn`, and `main.gd` in the project root.
- `init.ts` runs in Dora and creates a `GodotNode`. Godot scripts run in the Godot SceneTree and use GDScript/Godot APIs. Keep Dora imports and globals out of `.gd` files.
- Keep the standard Godot project editable in the official editor. Retain resource paths, node paths, scene IDs, signal connections, and `.uid`/`.import` metadata when changing existing files. Do not hand-edit `.godot` caches or generated `init.lua` when `init.ts` exists.
- Current Dora Godot delivery supports GDScript projects; Godot C#/Mono and native GDExtension sidecars are outside that supported workflow.

## Inspect saved scenes

Use the existing `execute_command` Lua injection `inspectGodotScene({path="main.tscn"})` before editing an unfamiliar scene. Optional `project` selects a workspace-relative Godot directory; otherwise the nearest enclosing project is used. `nodePath="Player"` selects a scene subtree (`.` is root), `maxNodes` is 1–512 (default 128), and `maxProperties` is 0–128 (default 64).

The bundled runtime parses authored nodes, script/instance/resource references, sub-resource properties and signal connections without loading resources, constructing scene nodes, running scripts or changing the active project. Read typed values in `properties`, references in `script`/`instance`, and check `warnings`, counts and `truncated`. Inheritance/instances are not expanded and script export defaults are not evaluated. Missing resources are reported, not loaded. This query is not build validation. Reports are returned/printed and attached to `execute_command.godotScenes`; query failures fail the command. Narrow the query when bounded output is insufficient. Binary `.scn`, inline Object constructors and Dora Studio are unsupported. There is no extra Godot Agent tool and no external editor process.

## Edit, import, validate, run

1. Read the project settings, main scene, relevant scripts, and Dora host entry. Check Autoloads, input actions, and the configured renderer when the change depends on them.
2. Edit authored Godot files and assets with the workspace tools. Small procedural scenes can run without external asset imports. On desktop, use the `execute_command` Lua injection for new/changed source assets before building: `importGodotAssets({project=".",paths={"art/player.png","audio/jump.wav","models/player.glb"}})`. It returns and prints per-file results and attaches them to `execute_command.godotImports`; any failed batch makes the command fail. It uses the bundled runtime directly, never an external editor/process. Images, WAV/MP3/Ogg Vorbis audio, fonts and glTF/GLB scenes use default settings. Each file returns imported/skipped/failed, a message and its generated resource path; repair failures before proceeding. Models always reimport to pick up external buffers/textures. Stop a running Godot project before importing. Editor-managed `.import` options are preserved and are not reimported by this service. Other model formats/custom editor import plugins still require the official editor.
3. Call `build` with the Godot project directory, for example `{"paths":["."]}`. This calls the bundled Godot runtime compiler for GDScript and text-resource checks, then compiles the Dora host entry. No external Godot executable is launched. An old host/library without the compiler bridge reports a tool capability error; rebuild the bundled host/runtime instead of rewriting game code.
4. Repair returned file/line diagnostics and rebuild. Live `.gd`, `.tscn`, `.tres`, `.gdshader`, and `.gdshaderinc` editor checks use the same native API with unsaved text. The checker does not start the project main scene, instantiate scene nodes, or run Autoloads. Shaders use the native preprocessor and ShaderLanguage; standalone includes use Godot include mode, while full shaders validate the expanded include context. Diagnostics retain the actual included file and line. Standalone include success does not prove all consumer contexts are valid. Static validation does not import PNG/audio/font/model assets, perform backend GPU shader/pipeline compilation, or establish correct gameplay/GPU rendering. Asset import is a separate preparation step; do not claim it occurred during code validation.
5. Run the built Dora host entry, normally `init.ts`/`init.lua`, through the existing entry tools. Do not run `main.gd` as a Dora Lua entry. For a requested visual check, `previewGame({entry="init.ts", captureAtSeconds={1}})` uses the same host entry and capture budgets as other Dora games.
6. Check asynchronous startup (`GodotNode.running` and `lastError`) and reproduce relevant inputs. GodotNode forwards mouse/touch and provides `sendPointer`, `sendKey`, and `sendText`. Confirm gameplay separately from a screenshot.

## Iteration and diagnostics

- Only one GodotNode may be active. Wait for `unloadAsync` completion before replacing it; use the serial `GodotPlayer` helper for explicit project switching. Do not assume `running === false` means unload completed.
- `restart()` reloads a scene and retains Autoloads. To validate project settings, changed scripts, or a fresh project state, stop/unload and relaunch the host entry.
- Keep a fixed design viewport and fit the Dora Sprite once. Avoid applying equivalent scaling in both Dora and Godot.
- Use build diagnostics for script/resource errors. Dora's virtual engine log includes host-side startup messages; do not assume it contains every Godot print or script stack trace.
- Godot API signatures are distinct from Dora APIs. Use `search_dora_doc` with `docType="godot-api"` and `programmingLanguage="gdscript"` for the offline API reference matching the bundled source version. Search a class or `Class.member`; inherited members resolve to the declaring class. Read results with `read_file` using the exact `@dora-doc/godot-api/...` path. English originals are returned for Chinese requests. Read `@dora-doc/godot-api/README.md` for hosting boundaries. Documentation availability does not establish runtime or backend support.
- Godot game development is supported in the desktop Dora Web IDE. Dora Studio intentionally does not support Godot game development; direct those projects to desktop Dora rather than proposing a Studio editor import service.
- Mobile runtime builds do not contain an editor import service. If `build` reports that limitation, preserve the source and report the missing service instead of claiming validation passed.
