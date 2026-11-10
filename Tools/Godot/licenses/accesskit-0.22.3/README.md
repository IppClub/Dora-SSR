# AccessKit static SDK 0.22.3

Godot 4.7.2 uses this upstream SDK for its macOS and Linux accessibility backends. The selected platform archive is linked into LibGodot; no AccessKit dylib is deployed.

`Projects/xmake/godot/macos_accesskit_sdk.json` and `linux_accesskit_sdk.json` pin the official archive URL/SHA-256 and every selected input. `Tools/Godot/ensure_accesskit_sdk.lua` verifies cached inputs and the vendored header before linking. The archive comes from the same release selected by upstream `misc/scripts/install_accesskit.py`.

`GODOT-ACCESSKIT-NOTICES.txt` retains all four upstream notice/author files (MIT, Apache-2.0, Chromium and AUTHORS). The production runtime manifest includes this notice and `GODOT-ACCESSKIT-PROVENANCE.json`; package verification rejects missing or changed metadata. This records build inputs and provided distribution notices; it is not an independent audit of every Rust crate contribution.
