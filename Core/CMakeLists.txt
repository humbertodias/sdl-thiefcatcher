cmake_minimum_required(VERSION 3.28 FATAL_ERROR)

if(UNIX)
    execute_process(COMMAND "sdl2-config" "--cflags" OUTPUT_VARIABLE SDLCONFIG_FLAGS)
    add_definitions(-pedantic -pedantic-errors -Wall -Werror -Wextra ${SDLCONFIG_FLAGS})
else()
    add_definitions(-Wall)
endif()

cmake_policy(SET CMP0003 NEW)

message(STATUS "Compiling under ${CMAKE_SYSTEM_NAME}")

find_package(CURL REQUIRED)
find_package(TinyXML2 REQUIRED)
find_package(SQLITE3 REQUIRED)
find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(SDL2_gfx REQUIRED)
find_package(SDL2_ttf REQUIRED)
find_package(FMT REQUIRED)
find_package(Gettext REQUIRED)

execute_process(COMMAND pkg-config --cflags fmt OUTPUT_VARIABLE FMT_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
if(FMT_CFLAGS)
    string(REPLACE "-I" "" FMT_INCLUDE_DIR "${FMT_CFLAGS}")
endif()

execute_process(COMMAND pkg-config --cflags tinyxml2 OUTPUT_VARIABLE TINYXML2_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
if(TINYXML2_CFLAGS)
    string(REPLACE "-I" "" TINYXML2_INCLUDE_DIR "${TINYXML2_CFLAGS}")
endif()

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

message("FMT_INCLUDE_DIR: ${FMT_INCLUDE_DIR}")
message("TINYXML2_INCLUDE_DIR: ${TINYXML2_INCLUDE_DIR}")
message("GETTEXT_INCLUDE_DIR: ${GETTEXT_INCLUDE_DIR}")
message("GETTEXT_LIBRARY_DIR: ${GETTEXT_LIBRARY_DIR}")

file(GLOB_RECURSE GAME_SOURCES "src/*.cpp" )
file(GLOB_RECURSE VENDOR_SOURCES "vendor/*.cpp" "vendor/*.cc" )
list(APPEND GAME_SOURCES ${VENDOR_SOURCES})

configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Version.hpp.in"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/Version.hpp"
)

set(KANGOROO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../Kangaroo")
set(KANGOROO_LIBRARY_DIR "${KANGOROO_DIR}")
set(KANGOROO_INCLUDE_DIR "${KANGOROO_DIR}/include")
set(KANGOROO_SRC_DIR "${KANGOROO_DIR}/src")

message("KANGOROO_DIR: ${KANGOROO_DIR}")
message("KANGOROO_INCLUDE_DIR: ${KANGOROO_INCLUDE_DIR}")
message("KANGOROO_SRC_DIR: ${KANGOROO_SRC_DIR}")

add_executable(ThiefCatcher WIN32 MACOSX_BUNDLE ${GAME_SOURCES} ${KANGOROO_SRC_DIR})
set_property(TARGET ThiefCatcher PROPERTY CXX_STANDARD 23)

target_include_directories(ThiefCatcher PRIVATE 
    "src/" "vendor/" "/usr/local/include/" 
    ${FMT_INCLUDE_DIR} 
    ${TINYXML2_INCLUDE_DIR} 
    ${GETTEXT_INCLUDE_DIR} 
    ${KANGOROO_INCLUDE_DIR})

if(WIN32)
    target_link_libraries(ThiefCatcher PUBLIC ${KANGOROO_LIBRARY_DIR} kangaroo 
        PRIVATE sqlite3 curl SDL2main SDL2 SDL2_image SDL2_gfx SDL2_mixer SDL2_ttf 
        tinyxml2 intl)
elseif(UNIX OR APPLE)
    execute_process(COMMAND "sdl2-config" "--libs" OUTPUT_VARIABLE SDLCONFIG_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
    target_link_libraries(ThiefCatcher PUBLIC ${KANGOROO_LIBRARY_DIR} kangaroo 
        PRIVATE ${SDLCONFIG_LIBS} sqlite3 curl SDL2_image SDL2_gfx SDL2_mixer SDL2_ttf 
        tinyxml2 fmt intl)
endif()

set(INSTALL_FOLDER ".")

install(
    DIRECTORY data resources DESTINATION "${INSTALL_FOLDER}"
    PATTERN ".git" EXCLUDE
)
install(FILES config.ini ../LICENSE ../README.md ../CREDITS DESTINATION "${INSTALL_FOLDER}")

install(
    TARGETS ThiefCatcher
    RUNTIME DESTINATION "${INSTALL_FOLDER}"
    BUNDLE DESTINATION "${INSTALL_FOLDER}"
)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Thief Catcher")
set(CPACK_PACKAGE_VENDOR "Ponup Games")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/../LICENSE")
set(CPACK_PACKAGE_EXECUTABLES "ThiefCatcher;Thief Catcher")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

set(CPACK_NSIS_HELP_LINK "http://ponup.com/thief-catcher.html")
set(CPACK_NSIS_URL_INFO_ABOUT "http://ponup.com/thief-catcher.html")
set(CPACK_NSIS_CONTACT "https://docs.google.com/forms/d/1MnEaBXmTZvtJsE-efQpxuSsYSxfHJLLjKVlil7Jb7P8/viewform?c=0&w=1")
set(CPACK_NSIS_MODIFY_PATH ON)

include(CPack)