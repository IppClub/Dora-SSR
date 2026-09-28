cmake_minimum_required(VERSION 3.30)

# Generate the macOS Xcode project with `cmake -G Xcode`.
set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0" CACHE STRING "Minimum supported macOS version")
project(Dora LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include("${CMAKE_CURRENT_SOURCE_DIR}/../apple/AppleApp.cmake")
dora_add_apple_app(TARGET Dora PLATFORM macos)
