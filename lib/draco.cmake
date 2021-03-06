# Draco dependency

set(DRACO_VERSION "1.3.5")
set(DRACO_HASH "06ea419bc9e70813d4c308b960e63fa9713c9ee0")

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/lib/src/draco-${DRACO_VERSION}")
    message("Downloading draco ${DRACO_VERSION} sources")
    set(draco_url "https://github.com/google/draco/archive/${DRACO_VERSION}.tar.gz")
    file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/lib/src")
    file(DOWNLOAD "${draco_url}" "${CMAKE_SOURCE_DIR}/lib/src/draco.tar.gz" EXPECTED_HASH "SHA1=${DRACO_HASH}")
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf "${CMAKE_SOURCE_DIR}/lib/src/draco.tar.gz" WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/lib/src")
endif()

set(ENABLE_JS_GLUE OFF CACHE BOOL "Draco option" FORCE)
set(BUILD_FOR_GLTF ON CACHE BOOL "Draco option" FORCE)
set(BUILD_SHARED_LIBS ON CACHE BOOL "Draco option" FORCE)

add_subdirectory("lib/src/draco-${DRACO_VERSION}" "${CMAKE_BINARY_DIR}/lib/draco")
set_target_properties(draco PROPERTIES COMPILE_FLAGS "-w") # Ignoring warnings from the dependency

# Strip binary for release builds
if(CMAKE_BUILD_TYPE STREQUAL Release)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_STRIP} $<TARGET_FILE:draco>)
endif()

if(ANDROID)
    list(APPEND CUSTOM_ANDROID_EXTRA_LIBS "${draco_BINARY_DIR}/libdraco.so")
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE draco)
include_directories(AFTER "${draco_SOURCE_DIR}/src" "${draco_BINARY_DIR}/draco")
