cmake_minimum_required(VERSION 4.0.0)
project(Tetrix)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(SOURCE_DIR src)
set(INCLUDE_DIR include)
file(GLOB_RECURSE SOURCES "${SOURCE_DIR}/*.cpp" "${INCLUDE_DIR}/*.h" CONFIGURE_DEPENDS)

add_subdirectory("thirdparty/glfw" glfw)
include_directories("thirdparty/glfw/include")

include_directories("thirdparty/glm")

include_directories("thirdparty/glad/include")
add_library(glad_lib STATIC "thirdparty/glad/src/glad.c")

add_executable(Tetrix ${SOURCES})

target_link_libraries(Tetrix PRIVATE glfw glad_lib)

install(TARGETS Tetrix DESTINATION bin)
install(DIRECTORY "${SOURCE_DIR}" DESTINATION include)