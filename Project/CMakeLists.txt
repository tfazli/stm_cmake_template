PROJECT(stm-cmake-$ENV{VERSION})
enable_language(ASM)
CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -g0")
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

file(GLOB_RECURSE LINKER_PATH ${CMAKE_SOURCE_DIR}/Project/ *.ld)
set(LINKER_SPECS "--specs=nano.specs --specs=nosys.specs")
set(LINKER_SCRIPT ${LINKER_PATH})
set(LIBRARY_NAME "application")

set(APPLICATION_DIR ${CMAKE_SOURCE_DIR}/application)
set(MAIN_FIRMWARE_DIR ${CMAKE_SOURCE_DIR}/main_firmware)
set(TEST_FIRMWARE_DIR ${CMAKE_SOURCE_DIR}/test_firmware)

set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/../third-party/out)
set(GTEST_LIB_DIR ${THIRD_PARTY_DIR}/lib/gtest)
set(COMMON_LIB_DIR ${THIRD_PARTY_DIR}/lib)
set(COMMON_INCLUDE_DIR ${THIRD_PARTY_DIR}/include)

link_directories(${GTEST_LIB_DIR})
link_directories(${COMMON_LIB_DIR})

include_directories(${COMMON_INCLUDE_DIR}/gtest_includes)
include_directories(${COMMON_INCLUDE_DIR}/peripheral)

add_definitions(-DARM_MATH_CM4)
add_definitions(-D__FPU_USED)
add_definitions(-D__FPU_PRESENT)
add_definitions(-DHSE_VALUE=8000000UL)
add_definitions(-D__STACK_SIZE=0x00000f00) # overwrite default value from startup_STM32F40x.S file
add_definitions(-D__HEAP_SIZE=0x1000)      # overwrite default value from startup_STM32F40x.S file
add_definitions(-DGTEST_OS_NONE)
add_definitions(-DFIRMWARE_VERSION="$ENV{VERSION}")

SET(CMAKE_C_FLAGS "-nostdlib -mthumb -fno-builtin -fmessage-length=0 -fsigned-char -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mlittle-endian -mfloat-abi=hard -Wall -std=gnu11 -ffunction-sections -fdata-sections -fno-common -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
SET(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -fmessage-length=0 -fsigned-char -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mlittle-endian -mfloat-abi=hard -Wall -std=gnu++17 -ffunction-sections -fdata-sections -fno-common -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
SET(CMAKE_ASM_FLAGS "-nostdlib -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mabi=aapcs" CACHE INTERNAL "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mabi=aapcs" CACHE INTERNAL "shared linker flags")


# Adaptation for OS X
if (APPLE)
    string (REPLACE "-Wl,-search_paths_first" "" CMAKE_C_LINK_FLAGS ${CMAKE_C_LINK_FLAGS})
    string (REPLACE "-Wl,-search_paths_first" "" CMAKE_CXX_LINK_FLAGS ${CMAKE_CXX_LINK_FLAGS})
endif ()

####################################################################
##                 ASSEMBLE STM STATIC LIBRARY                    ##
####################################################################

MACRO(HEADER_DIRECTORIES return_list)
    FILE(GLOB_RECURSE new_list ${APPLICATION_DIR} *.h)
    SET(dir_list "")
    FOREACH(file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list ${dir_list} ${dir_path})
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${return_list} ${dir_list})
ENDMACRO()

HEADER_DIRECTORIES(header_dir_list)
include_directories(${header_dir_list})

file(GLOB_RECURSE SOURCES_CPP_LIBRARY ${APPLICATION_DIR}/*.cpp)
file(GLOB_RECURSE SOURCES_C_LIBRARY ${APPLICATION_DIR}/*.c)
file(GLOB_RECURSE HEADERS_LIBRARY ${CMAKE_SOURCE_DIR} *.h)

list(APPEND SOURCES_LIBRARY ${SOURCES_C_LIBRARY})
list(APPEND SOURCES_LIBRARY ${SOURCES_CPP_LIBRARY})
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LINKER_SPECS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -mcpu=cortex-m4 -mthumb -mlittle-endian -mfloat-abi=hard -mfpu=fpv4-sp-d16 -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -ffreestanding  -fno-builtin  -g3 -Xlinker --gc-sections -Wl,--undefined=uxTopUsedPriority -Wl,-Map -T \"${LINKER_SCRIPT}\"" CACHE INTERNAL "Linker options")

add_library(${LIBRARY_NAME} STATIC ${SOURCES_LIBRARY})
set_target_properties(${LIBRARY_NAME} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)

####################################################################
##                  ASSEMBLE MAIN STM FIRMWARE                    ##
####################################################################

file(GLOB_RECURSE SOURCES_C_APPLICATION ${MAIN_FIRMWARE_DIR}/*.c)
file(GLOB_RECURSE SOURCES_S_APPLICATION ${MAIN_FIRMWARE_DIR}/*.S)
file(GLOB_RECURSE SOURCES_CPP_APPLICATION ${MAIN_FIRMWARE_DIR}/*.cpp)

list(APPEND SOURCES_APPLICATION ${SOURCES_C_APPLICATION})
list(APPEND SOURCES_APPLICATION ${SOURCES_S_APPLICATION})
list(APPEND SOURCES_APPLICATION ${SOURCES_CPP_APPLICATION})

add_executable(${CMAKE_PROJECT_NAME}.elf ${SOURCES_APPLICATION})
set_target_properties(${CMAKE_PROJECT_NAME}.elf PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)
target_link_libraries(${CMAKE_PROJECT_NAME}.elf ${LIBRARY_NAME} ${COMMON_LIB_DIR}/libperipheral.a)

add_custom_target("Hex_file" ALL DEPENDS ${CMAKE_PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Oihex ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.hex)
add_custom_target("Binary_file" ALL DEPENDS ${CMAKE_PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Obinary ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.bin)
add_custom_target("Size_calculatiion" ALL DEPENDS ${CMAKE_PROJECT_NAME}.elf COMMAND ${CMAKE_SIZE} --format=berkeley ${CMAKE_PROJECT_NAME}.elf)

####################################################################
##              ASSEMBLE FIRMWARE WITH GOOGLE TESTS               ##
####################################################################

file(GLOB_RECURSE SOURCES_C_TEST ${TEST_FIRMWARE_DIR}/*.c)
file(GLOB_RECURSE SOURCES_S_TEST ${TEST_FIRMWARE_DIR}/*.S)
file(GLOB_RECURSE SOURCES_CPP_TEST ${TEST_FIRMWARE_DIR}/*.cpp)

list(APPEND SOURCES_TEST ${SOURCES_C_TEST})
list(APPEND SOURCES_TEST ${SOURCES_S_TEST})
list(APPEND SOURCES_TEST ${SOURCES_CPP_TEST})

set(TEST_PROJECT ${CMAKE_PROJECT_NAME}-test)

add_executable(${TEST_PROJECT}.elf ${SOURCES_TEST})
set_target_properties(${TEST_PROJECT}.elf PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)
target_link_libraries(${TEST_PROJECT}.elf ${LIBRARY_NAME} ${GTEST_LIB_DIR}/libgtest.a ${GTEST_LIB_DIR}/libgmock.a ${COMMON_LIB_DIR}/libperipheral.a)

add_custom_target("Test_Hex_file" ALL DEPENDS ${TEST_PROJECT}.elf COMMAND ${CMAKE_OBJCOPY} -Oihex ${TEST_PROJECT}.elf ${TEST_PROJECT}.hex)
add_custom_target("Test_Binary_file" ALL DEPENDS ${TEST_PROJECT}.elf COMMAND ${CMAKE_OBJCOPY} -Obinary ${TEST_PROJECT}.elf ${TEST_PROJECT}.bin)
add_custom_target("Test_Size_calculatiion" ALL DEPENDS ${TEST_PROJECT}.elf COMMAND ${CMAKE_SIZE} --format=berkeley ${TEST_PROJECT}.elf)
