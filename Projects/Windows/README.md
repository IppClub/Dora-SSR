# Windows application project

`CMakeLists.txt` generates the Visual Studio solution and project. The generated
files belong in `build-cmake/` and are not committed.

From a Windows Developer Command Prompt, build all prerequisites and the app:

```bat
Tools\build-scripts\build_windows.bat debug
```

To regenerate only the IDE project after prerequisites already exist:

```bat
cmake -S Projects/Windows -B Projects/Windows/build-cmake -A Win32
```

Open `Projects/Windows/build-cmake/DoraWindows.sln` in Visual Studio. The
executable and `wa.dll` are placed in `Projects/Windows/build/Debug` or
`Projects/Windows/build/Release`.

The engine sources come from `Projects/CMake/DoraEngineSources.cmake`. This file
adds the two Windows-only implementations and excludes the Linux native file
dialog and dynamic SDL audio backends. The prebuilt Windows libraries are x86,
so the generated project must use the Win32 platform.
