#pragma once
dnl
dnl This is all the system dependencies
dnl we need.
dnl
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define i32 int32_t
#define u8 uint8_t 
dnl
C_ALLOCATOR()dnl
C_SHARED_ALLOC()dnl
dnl
C_STRUCT_BEGIN(foo)dnl
        i32 bar;
C_STRUCT_END(foo)dnl
dnl
RESULT_C_FULL(foo)dnl
RESULT_C_FULL(void)dnl
dnl
LIST_WITH_NODE_C_STRUCTS(foo)dnl
RESULT_C_FULL(foo_list_node)dnl
RESULT_C_FULL(foo_list)dnl
C_ALLOC_FN(foo_list_node)dnl
LIST_C_ADD_FN(foo)dnl
dnl
LIST_WITH_NODE_C_STRUCTS(char)dnl
dnl
dnl
ARRAY_C_STRUCT(i32)dnl
RESULT_C_FULL(i32)dnl
C_ALLOC_FN(i32)dnl
dnl
RESULT_C_FULL(i32_array)dnl
dnl
ARRAY_C_NEW(i32)dnl
ARRAY_C_ADD(i32)dnl
ARRAY_C_ADD_BLOCK(i32)dnl
ARRAY_C_POP(i32)dnl
dnl
