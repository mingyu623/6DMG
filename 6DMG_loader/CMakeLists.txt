cmake_minimum_required (VERSION 2.8.11)
project(6DMG_loader)

# Find sqlite3 library (can be installed via apt-get)
find_library(SQLITE_LIB sqlite3 PATHS)
find_path(SQLITE_INCLUDE_DIR "sqlite3.h")
if (NOT (SQLITE_LIB AND SQLITE_INCLUDE_DIR))
 message(FATAL_ERROR "Cannot find sqlite3 lib at ${SQLITE_PATH}")
endif()

# Find Matlab MRC
# We need three files: mat.h, libmat.so, and libmx.so
# The findMatlab.cmake of cmake-2.8 isn't smart enough, so let's do it manually
# Need to currectly set MATLAB_ROOT_DIR here
set(MATLAB_ROOT_DIR /usr/local/MATLAB/MATLAB_Runtime/v91)
find_library(MATLAB_MX_LIB mx ${MATLAB_ROOT_DIR}/bin/glnxa64)
find_library(MATLAB_MAT_LIB mat ${MATLAB_ROOT_DIR}/bin/glnxa64)
find_path(MATLAB_INCLUDE_DIR "mat.h" ${MATLAB_ROOT_DIR}/extern/include)
if (NOT (MATLAB_MX_LIB AND MATLAB_MAT_LIB AND MATLAB_INCLUDE_DIR))
 message(FATAL_ERROR "Cannot find Matlab lib at ${MATLAB_ROOT_DIR}")
endif()

# The 6DMG library
add_library(6DMG
 src/GestureDef.cpp
 src/Database.cpp
 src/util.cpp
)
target_include_directories(6DMG PUBLIC
 ${CMAKE_CURRENT_SOURCE_DIR}/include
 ${SQLITE_INCLUDE_DIR}
 ${MATLAB_INCLUDE_DIR}
)
target_link_libraries(6DMG
 ${SQLITE_LIB}
 ${MATLAB_MX_LIB}
 ${MATLAB_MAT_LIB}
)

# The 6DMG_loader executable
add_executable(6DMG_loader
 src/examples.cpp
 src/main.cpp
)
target_include_directories(6DMG_loader PUBLIC
 ${CMAKE_CURRENT_SOURCE_DIR}/include
)
target_link_libraries(6DMG_loader
 6DMG
)
