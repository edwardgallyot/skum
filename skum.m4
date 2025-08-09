dnl
dnl SKUM (Some Kind Useful m4) Macros
dnl
dnl Some kind of useful m4 for generating C code
dnl just create your file. AKA. SKUM macros.
dnl
dnl These are useful for generic C structures, arguably more sophisticated than C++ templates
dnl as we get strong type guarantees immediately once we're in C.
dnl
dnl First things first, turn off the comments! Since we're generating C
dnl it's going to get really complicated if we don't as all CPP (C Pre-Processor) directives
dnl begin with a hash (I daren't even write it here!)
dnl
changecom(__BEGIN_COMMENT__, __END_COMMENT__) dnl
dnl
dnl Create CPP directives.
dnl ======================
dnl
dnl (function) C_PRAGMA
dnl (description) Does a C #pragma foo: C_PRAGMA(foo)
dnl (param) The name of the pragma.
dnl
define(`C_PRAGMA', `#pragma $1') dnl
dnl
dnl (function) C_INCLUDE
dnl (description) Does a C #include foo: C_INCLUDE(foo)
dnl (param) The name of the pragma.
dnl
define(`C_INCLUDE', `#include $1') dnl
dnl
dnl
dnl Create C structures.
dnl ====================
dnl
dnl (function) C_FORWARD_STRUCT
dnl (description) Forward declares a struct using C_FORWARD_STRUCT(foo)
dnl (param) The name of the struct.
dnl
define(`C_FORWARD_STRUCT', `dnl
define(`FORWARD_STRUCT_T', $1)dnl
define(`FORWARD_STRUCT_T_ANON', __`'FORWARD_STRUCT_T`'__)dnl
typedef struct FORWARD_STRUCT_T_ANON FORWARD_STRUCT_T`';dnl
undefine(`FORWARD_STRUCT_T', `FORWARD_STRUCT_T_ANON')dnl
')dnl
dnl
dnl (function) C_STRUCT_BEGIN
dnl (description) Begins a struct using C_STRUCT_BEGIN(foo)
dnl (param) The name of the struct.
dnl
define(`C_STRUCT_BEGIN', `dnl
define(`STRUCT_T', $1)dnl
define(`STRUCT_T_ANON', __`'STRUCT_T`'__)dnl
typedef struct STRUCT_T_ANON {dnl
undefine(`STRUCT_T', `STRUCT_T_ANON')dnl
') dnl
dnl
dnl (function) C_STRUCT_END
dnl (description) Ends a struct using C_STRUCT_END(foo)
dnl (param) The name of the struct.
dnl
define(`C_STRUCT_END', `dnl
define(`STRUCT_T', $1)dnl
} STRUCT_T`';dnl
undefine(`STRUCT_T')dnl
') dnl
dnl
define(`C_STRUCT_FIELD', `dnl
define(`FIELD_T', $1)dnl
define(`FIELD_V', $2)dnl
    FIELD_T FIELD_V`';dnl
undefine(`FIELD_T', `FIELD_V')dnl
') dnl
dnl
dnl Create a generic C result type for any T.
dnl ========================================
dnl 
define(`DEFINE_RESULT_TYPES', `dnl
define(`RESULT_T_RAW', $1)dnl
define(`RESULT_T', RESULT_T_RAW`'_result)dnl
define(`RESULT_DATA_T', RESULT_T_RAW)dnl
')dnl
dnl
define(`UNDEFINE_RESULT_TYPES', `dnl
undefine(`RESULT_T_RAW', `RESULT_T')dnl
')dnl
dnl
dnl
define(`RESULT_C_STRUCT', `dnl
DEFINE_RESULT_TYPES($1)dnl
C_FORWARD_STRUCT(RESULT_T)
C_STRUCT_BEGIN(RESULT_T)
C_STRUCT_FIELD(RESULT_DATA_T*, ok)
    union {
    C_STRUCT_FIELD(const char*, err) 
    C_STRUCT_FIELD(size_t, is_err) 
    };
C_STRUCT_END(RESULT_T)dnl
UNDEFINE_RESULT_TYPES`'dnl
')dnl
dnl
dnl
dnl Create a generic C list for any T.
dnl ==================================
dnl
dnl (function) DEFINE_LIST_TYPES
dnl (description) Defines all the types we need for a list
dnl (params) T the type you want to  
dnl
define(`DEFINE_LIST_TYPES',`dnl
define(`LIST_DATA_T', $1)dnl
define(`LIST_T', LIST_DATA_T`'_list)dnl
define(`LIST_NODE_T', LIST_T`'_node)dnl
')dnl
dnl
dnl (function) UNDEFINE_LIST_TYPES
dnl (description) Undefines all the types we need for a list. 
dnl               Should mirror a DEFINE_LIST_TYPES call.
dnl
define(`UNDEFINE_LIST_TYPES', `dnl
undefine(`LIST_DATA_T', `LIST_T', `LIST_NODE_T')dnl
')dnl
dnl 
dnl (function) LIST_C_STRUCT 
dnl (description) Creates a list for a type foo. LIST_C_STRUCT(foo)
dnl (param) T the type of the data in the list.
dnl
define(LIST_C_STRUCT, `dnl
DEFINE_LIST_TYPES($1)dnl
C_FORWARD_STRUCT(LIST_T)
C_STRUCT_BEGIN(LIST_T)
C_STRUCT_FIELD(LIST_NODE_T*, head)
C_STRUCT_END(LIST_T)dnl
UNDEFINE_LIST_TYPES`'dnl
')dnl
dnl
dnl (function) LIST_NODE_C_STRUCT
dnl (description) Creates a list for a type foo. LIST_NODE_C_STRUCT(foo)
dnl (param) T the type of the data in the list.
dnl
define(LIST_NODE_C_STRUCT, `dnl
DEFINE_LIST_TYPES($1)dnl
C_FORWARD_STRUCT(LIST_NODE_T)
C_STRUCT_BEGIN(`LIST_NODE_T')
C_STRUCT_FIELD(LIST_DATA_T*, data)
C_STRUCT_FIELD(LIST_NODE_T*, next)
C_STRUCT_END(`LIST_NODE_T')dnl
UNDEFINE_LIST_TYPES`'dnl
')dnl
dnl
dnl (function) LIST_WITH_NODE_C_STRUCTS
dnl (description) Combines LIST_NODE_C_STRUCT and LIST_C_STRUCT. LIST_WITH_NODE_C_STRUCTS(foo)
dnl (param) T the type of the data in the list.
dnl
define(LIST_WITH_NODE_C_STRUCTS, `dnl
LIST_NODE_C_STRUCT($1)dnl


LIST_C_STRUCT($1)dnl
')
dnl
dnl
dnl (function) LIST_NODE_ALLOC
dnl (description) Generates an allocator function for a list node of T. LIST_NODE_NEW(T).
dnl (param) T the type to generate for.
dnl 
define(LIST_NODE_C_ALLOC, 
DEFINE_LIST_TYPES($1)dnl

UNDEFINE_LIST_TYPES`'dnl
)
