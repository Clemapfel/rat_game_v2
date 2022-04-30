cmake_minimum_required(VERSION 3.19)
project(rat_game)
set(CMAKE_CXX_STANDARD 20)

### VARS ###

set(DEPENDENCY_PREFIX ${CMAKE_SOURCE_DIR}/dependencies)

### TARGETS ###

add_executable(rat_game main.cpp)

### INCLUDE DIRECTORIES ##

target_include_directories(rat_game PRIVATE
    ${DEPENDENCY_PREFIX}/jluna/
    ${DEPENDENCY_PREFIX}/SFML/include
    ${DEPENDENCY_PREFIX}/julia/include/julia
)

### LIBRARIES ###

find_library(julia REQUIRED NAMES julia PATHS ${DEPENDENCY_PREFIX}/julia/lib)
find_library(jluna REQUIRED NAMES jluna PATHS ${DEPENDENCY_PREFIX}/jluna)
find_library(sfml-audio REQUIRED NAMES sfml-audio PATHS ${DEPENDENCY_PREFIX}/SFML/build/lib)
find_library(sfml-window REQUIRED NAMES sfml-window PATHS ${DEPENDENCY_PREFIX}/SFML/build/lib)
find_library(sfml-system REQUIRED NAMES sfml-system PATHS ${DEPENDENCY_PREFIX}/SFML/build/lib)

target_link_libraries(rat_game
    ${julia}
    ${jluna}
    ${sfml-audio}
    ${sfml-window}
    ${sfml-system}
)