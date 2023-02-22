cmake_minimum_required(VERSION 3.20)

project(CoreSwift LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

add_library(CoreSwift INTERFACE)
target_include_directories(CoreSwift INTERFACE
    include)
target_compile_definitions(CoreSwift INTERFACE
    CS_HEADER_STYLE_CMAKE)

add_subdirectory(Tests)
