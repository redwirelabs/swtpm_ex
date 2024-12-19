cmake_minimum_required(VERSION 3.20.0 FATAL_ERROR)

# dependency manager
set(CPM_VERSION 0.40.2)
set(CPM_SOURCE_CACHE ${CMAKE_CURRENT_SOURCE_DIR}/_build/cache/cpm)
set(CPM_USE_NAMED_CACHE_DIRECTORIES false)
set(CPM_PATH "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_VERSION}.cmake")
if(NOT EXISTS ${CPM_PATH})
    message(STATUS "Downloading CPM.cmake to ${CPM_PATH}")
    set(CPM_GH_URL https://github.com/cpm-cmake/cpm.cmake/releases/download)
    set(CPM_RELEASE_URL ${CPM_GH_URL}/v${CPM_VERSION}/CPM.cmake)
    file(DOWNLOAD ${CPM_RELEASE_URL} ${CPM_PATH})
endif()
include(${CPM_PATH})

# dependencies
set(LIBTPMS_VER v0.10.0)
set(SWTPM_VER   v0.10.0)

if(DEFINED ENV{LIBTPMS_VER})
    set(LIBTPMS_VER $ENV{LIBTPMS_VER})
endif()

if(DEFINED ENV{SWTPM_VER})
    set(SWTPM_VER $ENV{SWTPM_VER})
endif()

CPMFindPackage(
    NAME libtpms
    GITHUB_REPOSITORY stefanberger/libtpms
    GIT_TAG ${LIBTPMS_VER})

CPMFindPackage(
    NAME swtpm
    GITHUB_REPOSITORY stefanberger/swtpm
    GIT_TAG ${SWTPM_VER})

# build
project(swtpm_ex)

include(ExternalProject)
include(ProcessorCount)

find_program(MAKE make REQUIRED)

ProcessorCount(NPROC)

ExternalProject_Add(libtpms
    SOURCE_DIR ${libtpms_SOURCE_DIR}
    CONFIGURE_COMMAND ${libtpms_SOURCE_DIR}/autogen.sh
                        --with-tpm2
                        --with-openssl
                        --prefix=$ENV{MIX_APP_PATH}/priv
    BUILD_COMMAND ${MAKE} -j ${NPROC})

ExternalProject_Add(swtpm
    SOURCE_DIR ${swtpm_SOURCE_DIR}
    CONFIGURE_COMMAND ${swtpm_SOURCE_DIR}/autogen.sh
                        --disable-tests
                        --with-openssl
                        --prefix=$ENV{MIX_APP_PATH}/priv
    BUILD_COMMAND ${MAKE} -j ${NPROC})
