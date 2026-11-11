# SelfUpdater regressions

Run from the repository root after generating the Lua counterparts:

```sh
lua Tools/Tests/SelfUpdater/state.lua "$PWD"
lua Tools/Tests/SelfUpdater/entry.lua "$PWD"
```

`state.lua` runs the production update service with deterministic transport/install
boundaries. It covers release revisions, offline caches, downgrade rejection,
operation serialization, cancellation, install confirmation, and ignoring one
version across restart while allowing later revisions and manual downloads.

`entry.lua` executes the generated Entry update-policy block with a controlled
clock. It covers seven-day automatic checks, unrestricted manual checks, persisted
ignore preferences, and clearing notifications after the installed version changes.

The Windows-only native regression uses the production `GuiInstance` and
`launchWindowsUpdateRestart` headers. Build it in a separate xmake project:

```powershell
Set-Location Tools/Tests/SelfUpdater
xmake f -p windows -a x64 -m release -y
xmake build
```

Run the built executable with `--old` to reproduce the prior race: its replacement
writes `primary:false` to `restart-result.json` while the owner is still alive.
Run without arguments to verify the fix: the parent asserts that no replacement
starts during its three-second teardown window, then the replacement writes
`primary:true` and `workingDirectoryMatches:true`. Wait for this JSON after the
parent exits. Copy the executable to a directory containing spaces, apostrophes
and Unicode characters to exercise Windows/PowerShell path quoting as well.
