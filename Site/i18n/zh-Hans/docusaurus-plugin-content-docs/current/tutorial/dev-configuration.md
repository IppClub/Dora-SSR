# 引擎项目的开发配置

## 一、获取项目源码

```sh
git clone https://github.com/ippclub/Dora-SSR.git
```

## 二、进行游戏引擎的开发配置

### Windows

1. 安装 **Visual Studio Community 2022**。
2. 在 IDE 中打开工程文件：**Project/Windows/Dora.sln**。
3. 进行编译、调试和运行。

### macOS

1. 安装最新版 **Xcode**。
2. 在 IDE 中打开工程文件：**Project/macOS/Dora.xcodeproj**。
3. 进行编译、调试和运行。

### iOS

1. 安装最新版 **Xcode**。
2. 在 IDE 中打开工程文件：**Project/iOS/Dora.xcodeproj**。
3. 进行编译、调试和运行。

### Android

1. 手动生成 Lua 绑定。
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



2. 安装最新版 **Android Studio**。
3. 在 IDE 打开工程目录：**Project/Android/Dora**。
4. 进行编译、调试和运行。

### Linux

1. 手动生成 Lua 绑定。
   ```sh
   # ubuntu
   sudo apt-get install lua5.1
   sudo apt-get install -y luarocks
   sudo luarocks install luafilesystem
   cd Tools/tolua++
   lua tolua++.lua
   ```
2. 安装依赖包。
   ```sh
   # ubuntu
   sudo apt-get install -y libsdl2-dev libgl1-mesa-dev x11proto-core-dev libx11-dev
   ```
3. 运行编译脚本。
   * 进行首次编译
   ```sh
   # 硬件架构为 arm
   cd Project/Linux
   make arm

   # 硬件架构为 x86_64
   cd Project/Linux
   make x86_64
   ```

   * 进行后续增量编译
   ```sh
   cd Project/Linux
   make
   ```
4. 运行生成的软件。
   ```sh
   cd Assets
   ../Project/Linux/build/dora-ssr
   ```


## 三、进行 Dora Dora 编辑器的开发

1. 编译并运行 Dora SSR 引擎。
2. 安装最新版的 **Node.js**。
3. 初始化项目并进入 Dora Dora 编辑器开发模式。
   ```sh
   cd Tools/YarnEditor && yarn && yarn build
   rm -rf ../dora-dora/public/yarn-editor
   mv dist ../dora-dora/public/yarn-editor
   cd ../../Tools/dora-dora
   yarn
   yarn start
   ```
