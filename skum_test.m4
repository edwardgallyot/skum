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
dnl
RUN_TEST(`Create a C allocator function', C_ALLOC_FN_SIG(foo), `foo_alloc(allocator* alloc, size_t count)')dnl
dnl
dnl C structure definitions
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
dnl Result type definition
dnl
RUN_TEST(`Define result types',dnl
DEFINE_RESULT_TYPES(i32)dnl
RESULT_T, `i32_result')dnl
dnl
dnl
RUN_TEST(`Undefine result types',dnl
DEFINE_RESULT_TYPES(i32)dnl
UNDEFINE_RESULT_TYPES`'dnl
RESULT_T, `RESULT_T')dnl
dnl
dnl
RUN_TEST(`C foo Result Definition', RESULT_C_STRUCT(foo), 
`
typedef struct __foo_result__ foo_result;
typedef struct __foo_result__ {
    union {
        foo* ok;
        size_t is_ok; 
    };
    union {
        const char* err; 
        size_t is_err; 
    };
} foo_result;
')dnl
dnl
dnl
RUN_TEST(`C foo Result error function', RESULT_C_ERR_FN(foo), 
`
static inline foo_result foo_err(foo* t, const char* err)
{
    foo_result res;
    res.err = err;
    res.is_ok = 0;
    return res;
}
')dnl
dnl
dnl
RUN_TEST(`C foo Result ok function', RESULT_C_OK_FN(foo), 
`
static inline foo_result foo_ok(foo* t)
{
    foo_result res;
    res.ok = t;
    res.is_err = 0;
    return res;
}
')dnl
dnl
dnl
RUN_TEST(`C foo Result full definition', RESULT_C_FULL(foo), 
`
typedef struct __foo_result__ foo_result;
typedef struct __foo_result__ {
    union {
        foo* ok;
        size_t is_ok; 
    };
    union {
        const char* err; 
        size_t is_err; 
    };
} foo_result;

static inline foo_result foo_err(foo* t, const char* err)
{
    foo_result res;
    res.err = err;
    res.is_ok = 0;
    return res;
}

static inline foo_result foo_ok(foo* t)
{
    foo_result res;
    res.ok = t;
    res.is_err = 0;
    return res;
}
')dnl
dnl
dnl Linked list definitions
dnl
dnl We test for a generic list where T=i32
dnl
RUN_TEST(`C Linked i32 List Definition', LIST_C_STRUCT(i32), 
`
typedef struct __i32_list__ i32_list;
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

typedef struct __foo_list__ foo_list;
typedef struct __foo_list__ {
    foo_list_node* head;
} foo_list;')dnl
dnl
dnl
dnl
RUN_TEST(`C Linked List allocate node function', LIST_NODE_C_ALLOC(foo), 
`
static inline foo_list_node_result foo_list_node_alloc(allocator* alloc, size_t count)
{
    foo_list_node* res = allocator_alloc(alloc, sizeof(foo_list_node) * count);
    if (!res) return foo_list_node_err(res, "Failed to allocate memory for foo_list_node");
    return foo_list_node_ok(res);
}
')dnl
dnl
dnl
