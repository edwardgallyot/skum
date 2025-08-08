## SKUM (Some Kinda Useful m4) Macros

The goal of this project is to generate generic types in C so we
can use the type safety of C++ templates _but_ generated in plain C so 
it is nice to read, write and debug.

SKUM is implemented in the m4 language that is included in most Linux distros
and is intended to generate generic types for use in C.

### Usage

`m4 skum.m4 your_file.m4 > your_header.h`

### Tests

To test the macros themselves I use:

`m4 skum.m4 skum_test.m4`

This runs tests in m4 to check that the macros themselves are generated.

To test the generated c code I use:

`m4 skum.m4 skum_ctest.m4 > skum.h`

`gcc skum_test.c -o test && ./test`
