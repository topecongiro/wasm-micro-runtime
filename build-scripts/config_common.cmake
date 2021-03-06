# Copyright (C) 2019 Intel Corporation.  All rights reserved.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

string(TOUPPER ${WAMR_BUILD_TARGET} WAMR_BUILD_TARGET)


# Add definitions for the build target
if (WAMR_BUILD_TARGET STREQUAL "X86_64")
  add_definitions(-DBUILD_TARGET_X86_64)
elseif (WAMR_BUILD_TARGET STREQUAL "AMD_64")
  add_definitions(-DBUILD_TARGET_AMD_64)
elseif (WAMR_BUILD_TARGET STREQUAL "X86_32")
  add_definitions(-DBUILD_TARGET_X86_32)
elseif (WAMR_BUILD_TARGET MATCHES "ARM.*")
  if (WAMR_BUILD_TARGET MATCHES "(ARM.*)_VFP")
    add_definitions(-DBUILD_TARGET_ARM_VFP)
    add_definitions(-DBUILD_TARGET="${CMAKE_MATCH_1}")
  else ()
    add_definitions(-DBUILD_TARGET_ARM)
    add_definitions(-DBUILD_TARGET="${WAMR_BUILD_TARGET}")
  endif ()
elseif (WAMR_BUILD_TARGET MATCHES "THUMB.*")
  if (WAMR_BUILD_TARGET MATCHES "(THUMB.*)_VFP")
    add_definitions(-DBUILD_TARGET_THUMB_VFP)
    add_definitions(-DBUILD_TARGET="${CMAKE_MATCH_1}")
  else ()
    add_definitions(-DBUILD_TARGET_THUMB)
    add_definitions(-DBUILD_TARGET="${WAMR_BUILD_TARGET}")
  endif ()
elseif (WAMR_BUILD_TARGET MATCHES "AARCH64.*")
  add_definitions(-DBUILD_TARGET_AARCH64)
  add_definitions(-DBUILD_TARGET="${WAMR_BUILD_TARGET}")
elseif (WAMR_BUILD_TARGET STREQUAL "MIPS")
  add_definitions(-DBUILD_TARGET_MIPS)
elseif (WAMR_BUILD_TARGET STREQUAL "XTENSA")
  add_definitions(-DBUILD_TARGET_XTENSA)
else ()
   message (FATAL_ERROR "-- WAMR build target isn't set")
endif ()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-DBH_DEBUG=1)
endif ()

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
  if (WAMR_BUILD_TARGET STREQUAL "X86_64" OR WAMR_BUILD_TARGET STREQUAL "AMD_64" OR WAMR_BUILD_TARGET MATCHES "AARCH64.*")
    # Add -fPIC flag if build as 64-bit
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    set (CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "${CMAKE_SHARED_LIBRARY_LINK_C_FLAGS} -fPIC")
  else ()
    add_definitions (-m32)
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m32")
    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -m32")
  endif ()
endif ()

if (WAMR_BUILD_TARGET MATCHES "ARM.*")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -marm")
elseif (WAMR_BUILD_TARGET MATCHES "THUMB.*")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mthumb")
    set (CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Wa,-mthumb")
endif ()

if (NOT WAMR_BUILD_INTERP EQUAL 1)
if (NOT WAMR_BUILD_AOT EQUAL 1)
  message (FATAL_ERROR "-- WAMR Interpreter and AOT must be enabled at least one")
endif ()
endif ()

if (WAMR_BUILD_JIT EQUAL 1)
  if (WAMR_BUILD_AOT EQUAL 1)
    add_definitions("-DWASM_ENABLE_JIT=1")
    set (LLVM_SRC_ROOT "${WAMR_ROOT_DIR}/core/deps/llvm")
    if (NOT EXISTS "${LLVM_SRC_ROOT}/build")
      message (FATAL_ERROR "Cannot find LLVM dir: ${LLVM_SRC_ROOT}/build")
    endif ()
    set (CMAKE_PREFIX_PATH "${LLVM_SRC_ROOT}/build;${CMAKE_PREFIX_PATH}")
    find_package(LLVM REQUIRED CONFIG)
    include_directories(${LLVM_INCLUDE_DIRS})
    add_definitions(${LLVM_DEFINITIONS})
    message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
    message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
  else ()
    set (WAMR_BUILD_JIT 0)
    message ("-- WAMR JIT disabled due to WAMR AOT is disabled")
 endif ()
else ()
  unset (LLVM_AVAILABLE_LIBS)
endif ()

message ("-- Build Configurations:")
message ("     Build as target ${WAMR_BUILD_TARGET}")
message ("     CMAKE_BUILD_TYPE " ${CMAKE_BUILD_TYPE})
if (WAMR_BUILD_INTERP EQUAL 1)
  message ("     WAMR Interpreter enabled")
else ()
  message ("     WAMR Interpreter disabled")
endif ()
if (WAMR_BUILD_AOT EQUAL 1)
  message ("     WAMR AOT enabled")
else ()
  message ("     WAMR AOT disabled")
endif ()
if (WAMR_BUILD_JIT EQUAL 1)
  message ("     WAMR JIT enabled")
else ()
  message ("     WAMR JIT disabled")
endif ()
if (WAMR_BUILD_LIBC_BUILTIN EQUAL 1)
  message ("     Libc builtin enabled")
else ()
  message ("     Libc builtin disabled")
endif ()
if (WAMR_BUILD_LIBC_WASI EQUAL 1)
  message ("     Libc WASI enabled")
else ()
  message ("     Libc WASI disabled")
endif ()
if (WAMR_BUILD_FAST_INTERP EQUAL 1)
  add_definitions (-DWASM_ENABLE_FAST_INTERP=1)
  message ("     Fast interpreter enabled")
else ()
  add_definitions (-DWASM_ENABLE_FAST_INTERP=0)
  message ("     Fast interpreter disabled")
endif ()

