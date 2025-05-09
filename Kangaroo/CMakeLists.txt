cmake_minimum_required(VERSION 3.28 FATAL_ERROR)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules)

set(KANGAROO_LIB_NAME kangaroo)

project(${KANGAROO_LIB_NAME} VERSION 0.9.9 LANGUAGES CXX)

find_package(SDL2 REQUIRED)
find_package(SDL2_ttf REQUIRED)
find_package(SDL2_mixer REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(SDL2_gfx REQUIRED)
find_package(SDL2_gfx REQUIRED)
find_package(Gettext REQUIRED)

execute_process(COMMAND pkg-config --cflags gettext OUTPUT_VARIABLE GETTEXT_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT GETTEXT_CFLAGS)
    set(GETTEXT_INCLUDE_DIR "/opt/homebrew/Cellar/gettext/0.24/include")
else()
    string(REPLACE "-I" "" GETTEXT_INCLUDE_DIR "${GETTEXT_CFLAGS}")
endif()
execute_process(COMMAND "pkg-config" "--libs" "gettext" OUTPUT_VARIABLE GETTEXT_LIBRARY_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT GETTEXT_LIBRARY_DIR)
    set(GETTEXT_LIBRARY_DIR "/opt/homebrew/Cellar/gettext/0.24/lib")
endif()

message("GETTEXT_INCLUDE_DIR: ${GETTEXT_INCLUDE_DIR}")
message("GETTEXT_LIBRARY_DIR: ${GETTEXT_LIBRARY_DIR}")

file(GLOB_RECURSE KANGAROO_SOURCES "src/*.cpp")
add_library(${KANGAROO_LIB_NAME} STATIC ${KANGAROO_SOURCES})

target_include_directories(
	${KANGAROO_LIB_NAME}
	PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
	PRIVATE ${SDL2_INCLUDE_DIRS} ${SDL2_TTF_INCLUDE_DIRS} ${SDL2_MIXER_INCLUDE_DIR} ${SDL2_IMAGE_INCLUDE_DIR} ${SDL2_GFX_INCLUDE_DIR} ${GETTEXT_INCLUDE_DIR}
)
target_link_libraries(${KANGAROO_LIB_NAME} ${SDL2_LIBRARIES} ${SDL2_TTF_LIBRARIES} ${SDL2_MIXER_LIBRARY} ${SDL2_IMAGE_LIBRARY} ${SDL2_GFX_LIBRARY})
set_property(TARGET ${KANGAROO_LIB_NAME} PROPERTY CXX_STANDARD 14)

if(UNIX)
	add_definitions(-pedantic -pedantic-errors -Wall -Werror -Werror)
else()
	add_definitions(-Wall)
endif()

