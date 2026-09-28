cmake_minimum_required(VERSION 3.30)

# Generate the iOS Xcode project with `cmake -G Xcode`.
set(CMAKE_OSX_DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum supported iOS version")
project(Dora LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DORA_IOS_VARIANT simulator CACHE STRING "Which prebuilt iOS bgfx libraries to link (simulator/device)")
include("${CMAKE_CURRENT_SOURCE_DIR}/../apple/AppleApp.cmake")
dora_add_apple_app(TARGET Dora PLATFORM ios)
