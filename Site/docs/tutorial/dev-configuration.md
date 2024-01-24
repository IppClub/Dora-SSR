# Engine Dev Configuration

## 1. Get the Source

```sh
git clone https://github.com/ippclub/Dora-SSR.git
```

## 2. Game Engine Development

### Windows

1. Install **Visual Studio Community 2022**.
2. Open the project file in the IDE: **Project/Windows/Dora.sln**.
3. Compile, debug, and run the project.

### macOS

1. Install latest **Xcode**.
2. Open the project file in the IDE: **Project/macOS/Dora.xcodeproj**.
3. Compile, debug, and run the project.

### iOS

1. Install latest **Xcode**.
2. Open the project file in the IDE: **Project/iOS/Dora.xcodeproj**.
3. Compile, debug, and run the project.

### Android

1. Manually generate Lua bindings.
   ```sh
   # ubuntu
   sudo apt-get install lua5.1
   sudo apt-get install -y luarocks
   sudo luarocks install luafilesystem
   cd Tools/tolua++
   lua tolua++.lua

   # macOS
   cd Tools/tolua++
   ./build.sh

   # Windows
   cd Tools\tolua++
   build.bat
   ```


2. Install latest **Android Studio**.
3. Open the project directory in the IDE: **Project/Android/Dora**.
4. Compile, debug, and run the project.

### Linux

1. Manually generate Lua bindings.
   ```sh
   # ubuntu
   sudo apt-get install lua5.1
   sudo apt-get install -y luarocks
   sudo luarocks install luafilesystem
   cd Tools/tolua++
   lua tolua++.lua
   ```
2. Install dependent packages.
   ```sh
   # ubuntu
   sudo apt-get install -y libsdl2-dev libgl1-mesa-dev x11proto-core-dev libx11-dev
   ```
3. Run the compile scripts.
   * For the first time build
   ```sh
   # For arm architecture
   cd Project/Linux
   make arm

   # For x86_64 architecture
   cd Project/Linux
   make x86_64
   ```
   * For incremental build
   ```sh
   cd Project/Linux
   make
   ```
4. Run the generated software.
   ```sh
   cd Assets
   ../Project/Linux/build/dora-ssr
   ```

## 3. Dora Dora Editor Development

1. Compile and run the Dora SSR engine.
2. Install the latest version of **Node.js**.
3. Initialize the project and enter the Dora Dora editor development mode.
   ```sh
   cd Tools/YarnEditor && yarn && yarn build
   rm -rf ../dora-dora/public/yarn-editor
   mv dist ../dora-dora/public/yarn-editor
   cd ../../Tools/dora-dora
   yarn
   yarn start
   ```
