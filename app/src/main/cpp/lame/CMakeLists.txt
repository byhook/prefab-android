cmake_minimum_required(VERSION 3.18.1)

file(GLOB_RECURSE SRC_LIST ${CMAKE_CURRENT_SOURCE_DIR}/*.cc)

add_library(
        native-lame
        SHARED
        ${SRC_LIST}
)

target_link_libraries(
        native-lame
        android
        log
)