cmake_minimum_required(VERSION 3.19)
project(rat_game)
set(CMAKE_CXX_STANDARD 20)

### CMAKE FLAGS ###
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-volatile")

### VARS ###

set(DEPENDENCY_PREFIX ${CMAKE_SOURCE_DIR}/dependencies)
set(JULIA_INCLUDE_PATH ${CMAKE_SOURCE_DIR}/julia)

configure_file("${CMAKE_SOURCE_DIR}/resource_path.hpp.in" "${CMAKE_SOURCE_DIR}/resource_path.hpp" @ONLY)

### TARGETS ###

add_library(rat_game

    include/initialize.hpp
        include/initialize.hpp .src/initialize.cpp)

### INCLUDE DIRECTORIES ##

target_include_directories(rat_game PUBLIC
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/include
    ${DEPENDENCY_PREFIX}/jluna/
    ${DEPENDENCY_PREFIX}/SFML/include
    ${DEPENDENCY_PREFIX}/julia/include/julia
    ${DEPENDENCY_PREFIX}/box2d/include
)

### LIBRARIES ###

find_library(julia REQUIRED NAMES julia PATHS ${DEPENDENCY_PREFIX}/julia/lib)
find_library(jluna REQUIRED NAMES jluna PATHS ${DEPENDENCY_PREFIX}/jluna)
find_library(sfml-audio REQUIRED NAMES sfml-audio PATHS ${DEPENDENCY_PREFIX}/SFML/build/lib)
find_library(sfml-window REQUIRED NAMES sfml-window PATHS ${DEPENDENCY_PREFIX}/SFML/build/lib)
find_library(sfml-system REQUIRED NAMES sfml-system PATHS ${DEPENDENCY_PREFIX}/SFML/build/lib)
find_library(box2d REQUIRED NAMES box2d PATHS ${DEPENDENCY_PREFIX}/box2d/build/bin)

target_link_libraries(rat_game PUBLIC
    ${julia}
    ${jluna}
    ${sfml-audio}
    ${sfml-window}
    ${sfml-system}
)

### TESTS ###

add_executable(main main.cpp )
target_link_libraries(main PRIVATE rat_game)

include(CTest)

option(BUILD_TESTING "enable unit tests" ON)
if (BUILD_TESTING)

    add_executable(test_julia_side .test/julia_side.cpp)
    target_link_libraries(test_julia_side PRIVATE rat_game)
    add_test(NAME test_julia_side COMMAND test_julia_side)
endif()