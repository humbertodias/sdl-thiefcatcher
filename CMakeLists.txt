
cmake_minimum_required(VERSION 3.28 FATAL_ERROR)
project(THIEF_CATCHER VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules)

message(STATUS "Generating project files for 'ThiefCatcher' version ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")

add_subdirectory(Kangaroo)
add_subdirectory(Core)

