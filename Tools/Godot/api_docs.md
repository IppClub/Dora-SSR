# Godot in Dora

These English API references are generated from the Godot source version recorded in manifest.json.
Use search_dora_doc with docType="godot-api" and programmingLanguage="gdscript".
Search a class name or Class.member. Inherited members resolve to the declaring class.
Read the returned @dora-doc/godot-api/... path with read_file or grep_files.

init.ts is the Dora host entry. project.godot, .gd, .tscn and .tres belong to Godot.
Build the project directory to validate sources with the bundled runtime, then run the built Dora entry.
Use previewGame for requested visual checks; it waits for readiness but covers only the observation interval and errors actually reported by the runtime.
Use the execute_command Lua injection importGodotAssets({project=".", paths={"art/player.png", "models/player.glb"}}) to prepare desktop image/audio/font/glTF assets through the bundled runtime. It returns per-file results in godotImports; failed batches fail the command. Stop the running project first. Existing editor-managed import settings are preserved and are not reimported by this service. No separate Godot Agent tool or external Godot process is used.
Static checks do not import assets or validate GPU pipelines. Editor-only APIs, C#/Mono and native GDExtensions are outside the supported workflow.
Godot development is supported in desktop Dora Web IDE; Dora Studio does not support it.
Document availability does not establish that a class/module/backend exists in the bundled runtime.
Sources are English; Chinese requests receive English originals rather than an unverified translation.

Source: vendored Godot Engine XML class documentation. Formatting was converted to Markdown and C# examples were omitted.
See LICENSE.txt and COPYRIGHT.txt for the original notices and license terms.
