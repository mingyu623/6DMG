cmake_minimum_required (VERSION 2.8.11)
project(6DMG_loader)

# Find sqlite3 library
set(SQLITE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/sqlite3)
find_library(SQLITE_LIB sqlite3 PATHS ${SQLITE_PATH})

# Handle include directories and linking path
target_include_directories(${PROJECT_NAME} PUBLIC
 ${CMAKE_CURRENT_SOURCE_DIR}/include
 ${CMAKE_CURRENT_SOURCE_DIR}/sqlite3
)
target_link_libraries(${PROJECT_NAME}
 ${SQLITE_LIB}
)

# The 6DMG_loader executable
add_executable(6DMG_loader
 src/Database.cpp
 src/examples.cpp
 src/GestureDef.cpp
 src/main.cpp
 src/util.cpp
)