C_PRAGMA(once)

C_INCLUDE(<stdint.h>)
C_INCLUDE(<stdlib.h>)

#define i32 int32_t

C_STRUCT_BEGIN(foo)
C_STRUCT_FIELD(i32, bar)
C_STRUCT_END(foo)

LIST_WITH_NODE_C_STRUCTS(foo)
