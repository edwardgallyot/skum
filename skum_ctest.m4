C_PRAGMA(once)

C_INCLUDE(<stdint.h>)
C_INCLUDE(<stdlib.h>)

#define i32 int32_t
#define u8 uint8_t 

C_ALLOCATOR
C_SHARED_ALLOC

C_STRUCT_BEGIN(foo)
C_STRUCT_FIELD(i32, bar)
C_STRUCT_END(foo)

RESULT_C_FULL(foo)
RESULT_C_FULL(void)

LIST_WITH_NODE_C_STRUCTS(foo)
RESULT_C_FULL(foo_list_node)
C_ALLOC_FN(foo_list_node)
