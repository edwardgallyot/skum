#!/usr/bin/sh

m4 skum.m4 skum_test.m4
m4 skum.m4 skum_ctest.m4 > skum.h
gcc skum_test.c -o test
./test 
