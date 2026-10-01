# Android Gradle integration

The root xmake targets are the single source of native source files, defines,
per-file options and dependencies. `Projects/Android/Dora/app/CMakeLists.txt`
configures an isolated xmake project for Gradle's ABI/build type and runs
`export.lua`. Gradle/CMake/Ninja compile the exported C/C++ targets with the NDK.
Generated files live under `app/.cxx` and are never edited or committed.

Install the latest xmake and Android Studio's SDK/JDK. The project uses NDK
26.1.10909125, CMake 3.22.1 and Android API 28 for native compilation. xmake
installs its managed Go/Rust/rustup packages when needed. Android SDK licenses
and platform components remain managed by Android Studio/the SDK manager.

From the repository root:

```sh
xmake dora-package --platform=android --mode=debug
xmake dora-package --platform=android --mode=release
xmake dora-package --platform=android --mode=release --format=aab
```

Android Studio can open `Projects/Android/Dora` and use Gradle Sync and the
normal Run/Debug actions. CMake generates the source model during Sync; no
prebuilt engine libraries or manual generation command is required. Use
Native Only when debugging just C/C++ to avoid a paused native breakpoint
delaying Java debugger attachment. Open sources through their real `Source/`
paths; the old `app/src/main/cpp` symlink is not used by the generated graph.
If the staged Wa AAR is missing, Gradle prepares it during configuration so
Studio's initial model import can resolve its Java classes. Subsequent builds
use the normal preparation task and xmake's incremental dependency checks.

From `Projects/Android/Dora`, using a compatible `JAVA_HOME`:

```sh
./gradlew :app:assembleDebug
./gradlew :app:assembleDebug -Pdora.android.abis=arm64-v8a
./gradlew :app:assembleRelease
./gradlew :app:bundleRelease
```

The default ABIs are `armeabi-v7a,arm64-v8a,x86_64`. The optional
`dora.android.abis` property restricts local builds. Set `DORA_XMAKE` or
`-Pdora.xmake=/absolute/path/to/xmake` if the executable is not on Studio's
PATH; macOS Homebrew locations are also discovered. Signing uses the existing
`DORA_ANDROID_SIGNING_*` environment variables in the package task. A release
APK without credentials is unsigned.

CMake runs the existing `dora-lua-bindings` and `dora-rust-runtime` xmake
targets before compiling. Their shared output paths are serialized with a
CMake process lock; Cargo and xmake retain their own incremental checks.
Gradle's `prepareXmakeAndroid` task builds/stages the Wa AAR and module assets.
It does not invoke Gradle recursively. Existing `app/build/xmake-jniLibs`
files and vendor prebuilt C/C++ libraries are not inputs to this integration.

Native target/rule/manifest changes trigger CMake regeneration. Header/source
edits use Ninja's dependency tracking, and additions/removals in source globs
trigger target export again. Gradle owns STL selection, NDK toolchain, ABI
output directories and packaging; the exporter never copies xmake's resolved
sysroot/target/output flags into CMake.

Local acceptance on macOS/Apple Silicon covers all three ABI Debug/Release
builds, APK/AAB integrity and test signing, Studio Sync/Run/Native Only Debug
with a real C++ line breakpoint, missing Wa/Rust artifact recovery, and ARM64
emulator cold launch, touch and text input. A no-change build retains all three
engine library timestamps and leaves APK packaging up-to-date. Production
signing/distribution, remote CI, clean-host bootstrap and x86_64 emulator
runtime remain separate acceptance gates; see the migration progress document.
