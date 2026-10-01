# iOS build

On macOS with Xcode and the required SDK/runtime installed:

```sh
xmake dora-package --platform=ios --appledev=simulator --mode=debug
xmake dora-package --platform=ios --appledev=simulator --mode=release
xmake dora-package --platform=ios --appledev=device --mode=release
```

The root native manifest and Apple application rule build the engine, vendor
libraries, Lua bindings, Rust and Wa from source. No checked-in Xcode project
or prebuilt iOS archives are consumed. SDK, architecture and mode have separate
configuration/runtime/output trees. Device supports arm64; simulator supports
arm64 and x86_64 (`--arch=x86_64`). The default deployment target remains iOS 13.

Apps are under `build/iphoneos/<device|simulator>/<arch>/<mode>/Dora.app`.
Packages are under `build/package/iphoneos/<device|simulator>/<arch>/<mode>`:
ZIP for simulator, IPA with `Payload/Dora.app` for device. `--format=zip` can
also package a device App. Use these root tasks directly; old shell wrappers
have been removed.

For an editable IDE workspace, generate it rather than maintaining a second
source list:

```sh
xmake dora-ide --platform=ios --appledev=simulator
open build/ide/iphoneos/simulator/arm64/Dora-SSR.xcodeproj
```

Use `--appledev=device` for the device SDK. The generated build phases invoke
xmake and preserve the SDK-specific application output layout. These projects
are disposable, ignored build artifacts; make durable changes in
`Projects/xmake/` or the platform's checked-in resources instead.

Default signing is local ad-hoc. A device IPA built this way is **not** an
installable/distributable release. For authorized device signing, set
`DORA_IOS_SIGN_IDENTITY` to the installed Apple identity name and
`DORA_IOS_PROVISION` to the installed provisioning-profile name. Packaging
embeds the original CMS profile, signs with its entitlements, and verifies the
bundle signature. Production signing, provisioning/device entitlement matching
and distribution remain release acceptance gates.

Interactive IDE breakpoint validation was explicitly waived by the user on
2026-10-01; that does not assert that IDE debugging has been tested.
