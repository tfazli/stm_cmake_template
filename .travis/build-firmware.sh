#! /bin/bash

export CC=/usr/bin/arm-none-eabi-gcc
export CPP=/usr/bin/arm-none-eabi-g++
export CXX=/usr/bin/arm-none-eabi-g++
export SYSROOT=/usr/bin/arm-none-eabi
export CMAKE_OBJCOPY=/usr/bin/arm-none-eabi-objcopy
export CMAKE_SIZE=/usr/bin/arm-none-eabi-size
mkdir -p ./BUILD
cd ./BUILD
/usr/bin/cmake -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY -DCMAKE_BUILD_TYPE=Release -DCMAKE_OBJCOPY=/usr/bin/arm-none-eabi-objcopy -DCMAKE_SIZE=/usr/bin/arm-none-eabi-size ../Project
cmake --build . --target all

