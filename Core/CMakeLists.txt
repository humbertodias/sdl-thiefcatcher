
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
#find_package(SQLITE3 REQUIRED)
find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)
find_package(SDL2_image REQUIRED)
#find_package(SDL2_gfx REQUIRED)
find_package(SDL2_ttf REQUIRED)
#find_package(FMT REQUIRED)
#find_package(tinyxml2 REQUIRED)
#find_package(Gettext REQUIRED)

#include(${CMAKE_CURRENT_SOURCE_DIR}/conan_toolchain.cmake)

file(GLOB_RECURSE GAME_SOURCES "src/*.cpp" )
file(GLOB_RECURSE VENDOR_SOURCES "vendor/*.cpp" "vendor/*.cc" )
list(APPEND GAME_SOURCES ${VENDOR_SOURCES})

configure_file(
	"${CMAKE_CURRENT_SOURCE_DIR}/src/Version.hpp.in"
	"${CMAKE_CURRENT_SOURCE_DIR}/src/Version.hpp"
)


execute_process(COMMAND "pkg-config" "--cflags" "fmt" OUTPUT_VARIABLE FMT_INCLUDE_DIR)
message("FMT_INCLUDE_DIR: ${FMT_INCLUDE_DIR}")
# TODO: should be dynamic
set(FMT_INCLUDE_DIR "/opt/homebrew/Cellar/fmt/11.1.3/include")
set(TINYXML2_INCLUDE_DIR "/opt/homebrew/Cellar/tinyxml2/10.0.0/include")
set(GETTEXT_INCLUDE_DIR "/opt/homebrew/Cellar/gettext/0.23.1/include")
set(GETTEXT_LIBRARY_DIR "/opt/homebrew/Cellar/gettext/0.23.1/lib")

add_executable(ThiefCatcher WIN32 MACOSX_BUNDLE ${GAME_SOURCES})
set_property(TARGET ThiefCatcher PROPERTY CXX_STANDARD 23)

target_include_directories(ThiefCatcher PRIVATE "src/" "vendor/" "/usr/local/include/" ${CMAKE_INCLUDE_PATH} ${FMT_INCLUDE_DIR} ${TINYXML2_INCLUDE_DIR} ${GETTEXT_INCLUDE_DIR})

if(WIN32)
	target_link_libraries(ThiefCatcher PUBLIC kangaroo PRIVATE sqlite3 curl SDL2main SDL2 SDL2_image SDL2_gfx SDL2_mixer SDL2_ttf tinyxml2 libintl)
elseif(UNIX)
	execute_process(COMMAND "sdl2-config" "--libs" OUTPUT_VARIABLE SDLCONFIG_LIBS)
	string(STRIP ${SDLCONFIG_LIBS} SDLCONFIG_LIBS) 
	target_link_libraries(ThiefCatcher PUBLIC kangaroo PRIVATE ${SDLCONFIG_LIBS} sqlite3 curl SDL2_image SDL2_gfx SDL2_mixer SDL2_ttf tinyxml2 fmt)
elseif(APPLE)
	execute_process(COMMAND "sdl2-config" "--libs" OUTPUT_VARIABLE SDLCONFIG_LIBS)
	string(STRIP ${SDLCONFIG_LIBS} SDLCONFIG_LIBS) 
	target_link_libraries(ThiefCatcher PUBLIC kangaroo PRIVATE ${SDLCONFIG_LIBS} sqlite3 curl SDL2_image SDL2_gfx SDL2_mixer SDL2_ttf tinyxml2 intl)
endif()

#set_target_properties(ThiefCatcher PROPERTIES OUTPUT_NAME "ThiefCatcher")

set(INSTALL_FOLDER ".")

#file(GLOB dataFiles "${CMAKE_CURRENT_SOURCE_DIR}/data/**/*")
set(CPACK_SOURCE_IGNORE_FILES "/\\\\\\\\.git/;\\\\\\\\.swp$;")

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

