# STM32 CMake Template with GoogleTest support

[![Build Status](https://travis-ci.org/tfazli/stm_cmake_template.svg?branch=master)](https://travis-ci.org/tfazli/stm_cmake_template) [![License: MIT](https://img.shields.io/github/license/tfazli/stm_cmake_template)](https://github.com/tfazli/stm_cmake_template/blob/master/LICENSE)

---

## Description

This basic template repository can be used as a quick start for any new C++ ARM firmware project (STM32, NXP, etc.). Included CMake and GoogleTest framework support allow you to quickly build, test, and package your software.

For example, this template was successfully used to create a software (and unit tests) for the STM32F407VGT6 (ARM Cortex-M4f) microcontroller from scratch.

## Important notice:

> **`NOTE 1:`**  As an example, this project includes _**the libraries for the STM32F4xx series**_ of microcontrollers added as a submodule repository. In particular, such libraries are _**CMSIS and SPL**_ for this revision of microcontrollers, as well as a _**third-party USB device library**_. The sections below indicate in which directories these libraries are located so that you can reconfigure or replace them in your applications as needed.

> **`NOTE 2:`**  GoogleTest framework is added as a submodule repository linking [to my google test fork](https://github.com/tfazli/gtest), because in this fork _**arm-none-eabi support**_ is implemented. You can always fork this repo in case you need it. A more detailed description of the unit tests support on a microcontroller using this framework, as well as a description of obtaining test results, is described in the sections below.

> **`NOTE 3:`**  In the last section below you can find basic description of this project directory structure.

## CMake and compiling in release mode

The CMake file in this project (Project/CMakeLists.txt) sets the settings for building the project in release mode as follows:
   - Maximum optimization (-O3 flag);
   - No debugging information (-g0 flag).

As you know, in applications for some embedded systems and microcontrollers, maximum optimization can (in some cases) lead to inoperability of the code. For example, this is possible if the compiler optimizations consider the call to the external interrupt handler to be a function that is never called. Therefore, **`be careful when using optimization flags`** and always take appropriate action if you think the compiler is optimizing your code incorrectly.

> **`NOTE 4:`**  You can always change the flags of optimization for the release build in the CMake file by your decision.

## How this template works

This template project is designed in such a way that the build process is done in 4 stages - preparatory stage (1) and three main stages (2-4). Upon completion of the build process you will find two firmware files, each of them can be flashed into your device. The stages are as follows:

1. All **third-party** sources are build as static libraries (in particular, the peripheral library and the GoogleTest library).
2. All sources from the **application** folder are build as a static library. This library is the basis for each of the next two steps.
3. The **main firmware** of the microcontroller is being assembled (*.hex, *.elf and *.bin files are created).
4. The **firmware with unit tests** is being assembled (*.hex, *.elf and *.bin files with the "-test" postfix are created). This firmware only includes unit tests and ITM tracer.

The firmware with unit tests is designed in such a way that it outputs the tests result through the in-circuit debugger to the console on your PC via **ITM (Instrumentation Trace Macrocell)**. You can read more [about ITM here](https://interrupt.memfault.com/blog/profiling-firmware-on-cortex-m). As an in-circuit debugger, you can use, for example, a one that is built-in to STM32F4Discovery board or any similar.

> **`NOTE 5:`**  The firmware with unit tests may be too large for your target device, therefore it is recommended to generate several separate firmwares (with part of the tests) or to use emulators, such as QEMU.

> **`NOTE 6:`**  If you do not want to use ITM for displaying test results, you can change output interface in the sources to any other convenient for you (UART, etc.), or simply turn on some LED after testing is complete - it's up to you.


# Sources fine tuning process

This project is a template, so you can change its content as you like. `For the first build, this step is not necessary, so you can simply jump into the build process according to the instructions in the section below (before making any changes) to make sure it works.`

## Highlighting some parts of the project

Here is a list of the most important parts of this project that you may need to modify to suit your needs:

1. **`Project/CMakeLists.txt`** - is the most interesting part of this progect. It is located in the Project directory. Here you can set up your project name, compiler flags for debug and release, paths to all your sources and headers directories (both main and third-party), and fine tune all the firmwareassemble process.
2. **`/third-party/src/peripheral_libs`** - is the folder wit all the ST peripheral libraries, CMSIS files and the **custom made CMake file** to build it as a single static library. You can use any peripheral sources that you need here. Removal of the CMake file is not recomended, as well as folder renaming.
3. **`/third-party/src/custom_environment.template`** - is a template with environment variables. You can set up all the common flags or defines for third-party building process here.
4. **`/third-party/src/environment`** - is a file with environment variables, almost the same as previous one. It can be used for CI pipelines.
4. **`Project/application`** - put all your app sources and headers here. Do not delete System file. You can use any folder hierarchy inside this directory.
5. **`Project/main_firmware`** - put here your main.cpp, Startup and System files for the main firmware.
6. **`Project/test_firmware`** - put here your main.cpp, Startup and System files for the test firmware, as well as your unit tests sources and headers. You can use any folder hierarchy inside this directory.
7. **`Project/STM32F407.ld`** - here could be any linker file for your firmware.
8. **`/third-party/src/peripheral_libs/adjust_sys.h`** - this is the file for fine tuning SPL to your desired microcontroller settings (clock, etc.).

> **`NOTE 7:`** "main_firmware" and "test_firmware" folders (both) should contain the same Startup and System files. **The same System file** (if we are talking about STM32) should be placed to `/third-party/src/peripheral_libs` filder and to `Project/application` folder.

> **`NOTE 8:`** Each of the "environment" and "custom_environment" files contain `MCFLAGS` - compiler flags for building third-party sources. These flags are **microcontroller specific** and should be updated in the context of the microcontroller you use.


# Build process

## Build dependencies

1. gcc-arm-none-eabi (GNU Arm Embedded Toolchain) - can be downloaded from [ARM Developer web site](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads). It can be installed on your system or downloaded to any location of your choise.

> **`NOTE 9:`** these packages are required to be installed/downloaded on your pc. Without them you can not build stm_firmware package.

## Build procedure

1. Clone the repo and follow the steps from the fine tuning section above.
2. Check if the folder `/third-party/src/gtest` exists and **delete it**! Otherwise there will be an error on the next step.
3. Clone all the submodules by running this commands:
```bash
git submodule sync --recursive
git submodule update --init --recursive
git submodule update --init --recursive --remote
```
4. Go to /third-party/src and make a copy of ***"custom_environment.template"*** file with ***"custom_environment"*** name (without ".template" postfix)
5. Inside this new file modify `GCC_CUSTOM` variable to your compiler route and `MCFLAGS` with the compiler flags needed for your specific microcontroller (if needed).
6. Go one directory up and run `build_third_party.sh` script
7. Create /BUILD directory near /Project directory
8. Import CMakeLists.txt file from /Project directory into your IDE. This should create a new project.
9. Import the route to /BUILD directory location as your build location inside project settings
10. Add `VERSION` variable equals `x.x.x` (for example) into your build environment variables. If you will run CMake manually at this step, this should change the name of your project into "stm-firmware-x.x.x". Needed only for apropriate testing and debug process
11. Import or update some of your cmake variables inside project settings:
   - CMAKE_TRY_COMPILE_TARGET_TYPE=**`STATIC_LIBRARY`**
   - CMAKE_BUILD_TYPE=**`Debug`** (you can set this to **Release** if you need)
   - CMAKE_SYSROOT=**`path to arm-none-eabi-gcc /.content/bin`**
   - CMAKE_INSTALL_RPATH=**`path to arm-none-eabi-gcc /.content/lib folder`**
   - CMAKE_SIZE=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-size`**
   - CMAKE_OBJCOPY=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-objcopy`**
   - CMAKE_LINKER=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-ld`**
   - CMAKE_AR=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-gcc-ar`**
   - CMAKE_ASM_COMPILER=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-gcc`**
   - CMAKE_ASM_COMPILER_AR=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-gcc-ar`**
   - CMAKE_ASM_COMPILER_RANLIB=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-gcc-ranlib`**
   - CMAKE_CXX_COMPILER=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-g++`**
   - CMAKE_CXX_COMPILER_AR=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-ar`**
   - CMAKE_CXX_COMPILER_RANLIB=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-ranlib`**
   - CMAKE_C_COMPILER=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-gcc`**
   - CMAKE_C_COMPILER_AR=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-ar`**
   - CMAKE_C_COMPILER_RANLIB=**`path to arm-none-eabi-gcc /.content/bin/arm-none-eabi-ranlib`**
12. You are ready to build the project


# Directory Structure

Below is a partial directory structure for this project to understand the general location of the files.

> **`NOTE 10:`**  BUILD directory should be created by user!

```bash
├── BUILD (user created)
├── Project
│   ├── application
│   │   └── All user  application sources and System file
│   ├── main_firmware
│   │   └── Mainfile, Startup and System files for the main firmware
│   ├── test_firmware
│   │   └── Mainfile, Startup, System files, ITM rerouter and sources for the UnitTests firmware
│   ├── STM32F407.ld (any user defined linker file)
│   └── CMakeLists.txt
├── third-party
│   ├── src
│   │   ├── gtest (submodule)
│   │   ├── peripheral_libs (submodule, depends on the user application)
│   │   ├── build_gtest.sh
│   │   ├── build_peripheral.sh
│   │   ├── custom_environment.template
│   │   └── environment
│   └── build_third_party.sh
├── LICENSE
├── README.md
├── VERSION
└── .gitignore
```

