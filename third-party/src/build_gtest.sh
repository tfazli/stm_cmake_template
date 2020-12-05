#!/bin/bash
source environment

cd gtest
if [ -d BUILD ]; then rm -rf BUILD; fi
mkdir BUILD
cd BUILD
autoreconf -fvi ..
unamestr=`uname`
if [[ $unamestr == 'Linux' ]]; then 
    ../configure --disable-shared --without-pthreads --disable-libtool-lock --prefix=${PREFIX} --host=arm-none-eabi LDFLAGS="${MCFLAGS} --specs=nosys.specs --specs=nano.specs" CFLAGS="${MCFLAGS} ${GTEST_DEFS} -std=c99 -Os" CXXFLAGS="${MCFLAGS} ${GTEST_DEFS} -std=gnu++11 -Os"

elif [[ $unamestr =~ 'Darwin' ]]; then
    ../configure  CC=$CC CXX=$CXX LD=$LD AR=$AR AS=$AS CP=$CP OD=$OD NM=$NM SIZE=$SIZE A2L=$A2L GCOV=$GCOV GPROF=$GPROF RANLIB=$RANLIB --disable-shared --without-pthreads --disable-libtool-lock --prefix=${PREFIX} --host=arm-none-eabi LDFLAGS="${MCFLAGS} --specs=nosys.specs --specs=nano.specs" CFLAGS="${MCFLAGS} ${GTEST_DEFS} -std=c99 -Os" CXXFLAGS="${MCFLAGS} ${GTEST_DEFS} -std=gnu++11 -Os"
fi

make -j4
mkdir -p ${PREFIX}/lib/gtest
mkdir -p ${PREFIX}/include/gtest_includes/gtest
mkdir -p ${PREFIX}/include/gtest_includes/gmock
cp ./googlemock/lib/.libs/*a ${PREFIX}/lib/gtest/
cp ./googletest/lib/.libs/*a ${PREFIX}/lib/gtest/
cp -r ../googlemock/include/gmock/* ${PREFIX}/include/gtest_includes/gmock/
cp -r ../googletest/include/gtest/* ${PREFIX}/include/gtest_includes/gtest/
