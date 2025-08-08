dnl
dnl
dnl These tests are for the skum.m4 file and check each macro expands to
dnl what we're expecting.
dnl
dnl 
define(`RUN_TEST',`dnl
define(GEN_TEST, `dnl
define(`TEST_MACRO', `dnl
define(`TEST_NAME', $1) dnl
define(`IN', $2) dnl
define(`OUT', $3) dnl
ifelse(IN, OUT, 
`define(`RES', `[PASS] TEST_NAME.
Got expected output: 
OUT')', 
`define(`RES', `[FAIL] TEST_NAME.
Unexpected output: 
IN 

Expected output:
OUT`'')') dnl
')') dnl
GEN_TEST($1, $2, $3) dnl
TEST_MACRO 
RES dnl
undefine(`GEN_TEST', `TEST_MACRO' `TEST_NAME', `IN', `OUT', `RES')
')dnl
dnl
dnl Make sure m4 comments don't mess with sections.
dnl
RUN_TEST(`Check comments are turned off', `###', `###') dnl
dnl
dnl C pre processor directives.
dnl
RUN_TEST(`Pragma once for C', C_PRAGMA(once), `#pragma once') dnl
dnl
RUN_TEST(`Include stdio for C', C_INCLUDE(<stdio.h>), `#include <stdio.h>') dnl
dnl
RUN_TEST(`Include third-party for C', C_INCLUDE("./cool.h"), `#include "./cool.h"') dnl
dnl
RUN_TEST(`Define for C', C_DEFINE(i32, int32_t), `#define i32 int32_t') dnl
dnl
dnl C structure definitions
dnl
dnl
RUN_TEST(`C struct forward declare', C_FORWARD_STRUCT(`foo'), `typedef struct __foo__ foo;') dnl
dnl
RUN_TEST(`C struct begin', C_STRUCT_BEGIN(`foo'), `typedef struct __foo__ {') dnl
dnl
RUN_TEST(`C struct end', C_STRUCT_END(`foo'), `} foo;') dnl
dnl
RUN_TEST(`C struct field', C_STRUCT_FIELD(`i32', `bar'), `  i32 bar;') dnl
dnl
RUN_TEST(`C struct inline definition',
C_STRUCT_BEGIN(foo)
C_STRUCT_FIELD(i32, bar)
C_STRUCT_END(foo),
`
typedef struct __foo__ {
    i32 bar;
} foo;')dnl
dnl
dnl
dnl Linked list definitions
dnl
dnl We test for a generic list where T=i32
dnl
RUN_TEST(`C Linked i32 List Definition', LIST_C_STRUCT(i32), 
`
typedef struct __i32_list__ {
    i32_list_node* head;
} i32_list;')dnl
dnl
dnl
RUN_TEST(`C Linked List i32 Node Definition', LIST_NODE_C_STRUCT(i32), 
`
typedef struct __i32_list_node__ i32_list_node;
typedef struct __i32_list_node__ {
    i32* data;
    i32_list_node* next;
} i32_list_node;')dnl
dnl
dnl
dnl
dnl
RUN_TEST(`C Linked List foo Full Definition', LIST_WITH_NODE_C_STRUCTS(foo), 
`
typedef struct __foo_list_node__ foo_list_node;
typedef struct __foo_list_node__ {
    foo* data;
    foo_list_node* next;
} foo_list_node;

typedef struct __foo_list__ {
    foo_list_node* head;
} foo_list;')dnl
dnl
dnl
