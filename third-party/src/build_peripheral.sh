#!/bin/bash
source environment

cd peripheral
if [ -d BUILD ]; then rm -rf BUILD; fi
mkdir BUILD
cd BUILD
unamestr=`uname`
if [[ $unamestr == 'Linux' ]]; then 
    cmake ${COMMON_DEFS} -DCMAKE_SHARED_LINKER_FLAGS="${MCFLAGS} --specs=nosys.specs --specs=nano.specs" -DCMAKE_C_FLAGS="${MCFLAGS} -Os" -DCMAKE_CXX_FLAGS="${MCFLAGS} -Os" ..

elif [[ $unamestr =~ 'Darwin' ]]; then
    cmake ${COMMON_DEFS} -DCMAKE_RANLIB=${RANLIB} -DCMAKE_AR=${AR} -DCMAKE_SHARED_LINKER_FLAGS="${MCFLAGS} --specs=nosys.specs --specs=nano.specs" -DCMAKE_C_FLAGS="${MCFLAGS} -Os" -DCMAKE_CXX_FLAGS="${MCFLAGS} -Os" ..
fi

make -j4
make install

