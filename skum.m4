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
changecom(__BEGIN_COMMENT__, __END_COMMENT__)dnl
changequote(`[[', `]]')dnl
dnl
dnl Create C structures.
dnl ====================
dnl
dnl (function) C_FORWARD_STRUCT
dnl (description) Forward declares a struct using C_FORWARD_STRUCT(foo)
dnl (param) The name of the struct.
dnl
define([[C_FORWARD_STRUCT]], 
[[define([[FORWARD_STRUCT_T]], $1)dnl
define([[FORWARD_STRUCT_T_ANON]], __[[]]FORWARD_STRUCT_T[[]]__)dnl
typedef struct FORWARD_STRUCT_T_ANON FORWARD_STRUCT_T[[]];dnl
undefine([[FORWARD_STRUCT_T]], [[FORWARD_STRUCT_T_ANON]])dnl
]])dnl
dnl
dnl (function) C_STRUCT_BEGIN
dnl (description) Begins a struct using C_STRUCT_BEGIN(foo)
dnl (param) The name of the struct.
dnl
define([[C_STRUCT_BEGIN]], [[dnl
define([[STRUCT_T]], $1)dnl
define([[STRUCT_T_ANON]], __[[]]STRUCT_T[[]]__)dnl
typedef struct STRUCT_T_ANON {dnl
undefine([[STRUCT_T]], [[STRUCT_T_ANON]])dnl
]])dnl
dnl
dnl (function) C_STRUCT_END
dnl (description) Ends a struct using C_STRUCT_END(foo)
dnl (param) The name of the struct.
dnl
define([[C_STRUCT_END]], 
[[define([[STRUCT_T]], $1)dnl
} STRUCT_T[[]];dnl
undefine([[STRUCT_T]])dnl
]]) dnl
dnl
dnl Create a generic C result type for any T.
dnl ========================================
dnl 
dnl (function) DEFINE_RESULT_TYPES
dnl (description) Defines all the types we need for a result
dnl (params) T the data in the result.
dnl
define([[DEFINE_RESULT_TYPES]], 
[[define([[RESULT_T_RAW]], $1)dnl
define([[RESULT_T]], RESULT_T_RAW[[]]_result)dnl
define([[RESULT_DATA_T]], RESULT_T_RAW)dnl
define([[ERR_FN]], RESULT_DATA_T[[]]_err)dnl
define([[OK_FN]], RESULT_DATA_T[[]]_ok)dnl
]])dnl
dnl
dnl (function) UNDEFINE_RESULT_TYPES
dnl (description) Undefines all the types we need for a list. 
dnl                           Should mirror a DEFINE_RESULT_TYPES call.
dnl
define([[UNDEFINE_RESULT_TYPES]], [[dnl
undefine([[RESULT_T_RAW]], [[RESULT_T]], [[RESULT_DATA_T]], [[ERR_FN]], [[OK_FN]])dnl
]])dnl
dnl
dnl (function) RESULT_C_STRUCT 
dnl (description) Creates the result struct for a T 
dnl (param) T the type of the data in the result.
dnl
define([[RESULT_C_STRUCT]], [[dnl
DEFINE_RESULT_TYPES($1)dnl
C_FORWARD_STRUCT(RESULT_T)
C_STRUCT_BEGIN(RESULT_T)
        RESULT_DATA_T[[]]* ok;
        union {
                const char* err;
                size_t is_err;
        };
C_STRUCT_END(RESULT_T)
UNDEFINE_RESULT_TYPES[[]]dnl
]])dnl
dnl
dnl (function) RESULT_C_ERR_FN
dnl (description) Creates the error function for a T.
dnl (param) T the type of the data in the result.
dnl
define([[RESULT_C_ERR_FN]], [[dnl
DEFINE_RESULT_TYPES($1)dnl
static inline RESULT_T ERR_FN()(RESULT_DATA_T* t, const char* err)
{
        RESULT_T res;
        res.err = err;
        return res;
}
UNDEFINE_RESULT_TYPES[[]]dnl
]])dnl
dnl
dnl (function) RESULT_C_OK_FN
dnl (description) Creates the ok function for a T.
dnl (param) T the type of the data in the result.
dnl
define([[RESULT_C_OK_FN]], [[dnl
DEFINE_RESULT_TYPES($1)dnl
static inline RESULT_T RESULT_DATA_T[[]]_ok(RESULT_DATA_T* t)
{
        RESULT_T res;
        res.ok = t;
        res.is_err = 0;
        return res;
}
UNDEFINE_RESULT_TYPES()dnl
]])
dnl
dnl (function) RESULT_C_FULL
dnl (description) Simply combines RESULT_C_STRUCT, RESULT_C_ERR_FN and RESULT_C_OK_FN.
dnl (param) T the type of the data in the result.
dnl
define(RESULT_C_FULL, [[dnl
RESULT_C_STRUCT($1)
RESULT_C_ERR_FN($1)
RESULT_C_OK_FN($1)dnl
]])
dnl
dnl Create C allocator functions for any T
dnl ======================================
dnl
dnl (function) DEFINE_ALLOC_TYPES
dnl (description) Defines allocation types for C
dnl (params) T  
dnl
define([[DEFINE_ALLOC_TYPES]], [[dnl
define([[C_ALLOC_T]], $1)dnl
]])dnl
dnl
define([[UNDEFINE_ALLOC_TYPES]], [[dnl
undefine([[C_ALLOC_T]])dnl
]])dnl
dnl
define([[C_ALLOCATOR]], [[
C_FORWARD_STRUCT(allocator)
C_STRUCT_BEGIN(allocator)
        void* mem;
        size_t count;
        size_t capacity;
C_STRUCT_END(allocator)
]])
dnl
dnl
define([[C_SHARED_ALLOC]], 
[[static inline void* allocator_alloc(allocator* alloc, size_t num_bytes)
{
        if (!alloc) return NULL;
        size_t req_count = alloc->count + num_bytes;
        if (req_count > alloc->capacity) return NULL;
        void* result = ((u8*)alloc->mem) + alloc->count;
        alloc->count = req_count;
        return result;
}]])dnl
dnl
dnl (function) C_ALLOC_FN
dnl (description)
dnl (param) T, the type to alloc
dnl
define([[C_ALLOC_FN]], [[dnl
DEFINE_ALLOC_TYPES($1)
DEFINE_RESULT_TYPES($1)
static inline RESULT_T C_ALLOC_T[[]]_alloc(allocator* alloc, size_t count)
{
        RESULT_DATA_T* res = (RESULT_DATA_T*)allocator_alloc(alloc, sizeof(RESULT_DATA_T) * count);
        if (!res) return ERR_FN[[]](res, "Failed to allocate memory for RESULT_DATA_T");
        return OK_FN[[]](res);
}
UNDEFINE_ALLOC_TYPES[[]]dnl
UNDEFINE_RESULT_TYPES[[]]dnl
]])dnl
dnl
dnl Create a generic slice for any T
dnl ======================================
define([[DEFINE_SLICE_TYPES]], 
[[define(SLICE_DATA_T, $1)dnl
define(SLICE_T, SLICE_DATA_T[[]]_slice)dnl
]])dnl
dnl
define([[UNDEFINE_SLICE_TYPES]], 
[[undefine([[SLICE_T]], [[SLICE_DATA_T]])]])dnl
dnl
define([[SLICE_C_STRUCT]],
[[DEFINE_SLICE_TYPES($1)
C_FORWARD_STRUCT(SLICE_T)
C_STRUCT_BEGIN(SLICE_T)
        SLICE_DATA_T* data;
        size_t len;
C_STRUCT_END(SLICE_T)
UNDEFINE_SLICE_TYPES()dnl
]])dnl
dnl
dnl Create a generic C array for any T
dnl ======================================
dnl
define([[DEFINE_ARRAY_TYPES]],[[dnl
define([[ARRAY_DATA_T]], $1)dnl
define([[ARRAY_T]], ARRAY_DATA_T[[]]_array)
]])dnl
dnl
define([[UNDEFINE_ARRAY_TYPES]],[[dnl
undefine([[ARRAY_DATA_T]])dnl
]])dnl
dnl
define([[ARRAY_C_STRUCT]], 
[[
DEFINE_ARRAY_TYPES($1)dnl
C_FORWARD_STRUCT(ARRAY_T)
C_STRUCT_BEGIN(ARRAY_T)
        ARRAY_DATA_T* data;
        size_t count;
        size_t capacity;
C_STRUCT_END(ARRAY_T)dnl
UNDEFINE_ARRAY_TYPES[[]]dnl
]])dnl
dnl
dnl
define([[ARRAY_C_NEW]], 
[[DEFINE_ARRAY_TYPES($1)
DEFINE_RESULT_TYPES($1)
define([[DATA_RESULT_T]], RESULT_T)dnl
UNDEFINE_RESULT_TYPES
DEFINE_RESULT_TYPES(ARRAY_T)dnl
static inline RESULT_T ARRAY_T[[]]_init(ARRAY_T* array, allocator* alloc, size_t size)
{
        if (!array) return ERR_FN[[]](NULL, "no array passed");
        if (!alloc) return ERR_FN[[]](NULL, "no alloc passed");
        DATA_RESULT_T data_res = ARRAY_DATA_T[[]]_alloc(alloc, size);
        if (data_res.is_err) return ERR_FN[[]](NULL, data_res.err);
        array->data = data_res.ok;
        array->capacity = size;
        array->count = 0;
        return OK_FN[[]](array);
}
undefine([[DATA_RESULT_T]])dnl
UNDEFINE_RESULT_TYPES()dnl
UNDEFINE_ARRAY_TYPES()dnl
]])
dnl
define([[ARRAY_C_ADD]], 
[[DEFINE_ARRAY_TYPES($1)
DEFINE_RESULT_TYPES($1)
define([[DATA_RESULT_T]], RESULT_T)dnl
UNDEFINE_RESULT_TYPES
DEFINE_RESULT_TYPES(ARRAY_T)dnl
static inline RESULT_T ARRAY_T[[]]_add(ARRAY_T* array, ARRAY_DATA_T to_add)
{
        if (!array) return ERR_FN[[]](NULL, "no array passed");
        if (array->count >= array->capacity) return ERR_FN[[]](NULL, "out of capacity");
        array->data[array->count] = to_add;
        array->count++;
        return OK_FN[[]](array);
}
undefine([[DATA_RESULT_T]])dnl
UNDEFINE_RESULT_TYPES()dnl
UNDEFINE_ARRAY_TYPES()dnl
]])dnl
dnl
dnl
define([[ARRAY_C_ADD_BLOCK]], 
[[DEFINE_ARRAY_TYPES($1)dnl
DEFINE_RESULT_TYPES($1)dnl
define([[DATA_RESULT_T]], RESULT_T)dnl
UNDEFINE_RESULT_TYPES()dnl
DEFINE_RESULT_TYPES(ARRAY_T)dnl
static inline RESULT_T ARRAY_T[[]]_add_block(ARRAY_T* array, ARRAY_DATA_T* to_add, size_t count)
{
        if (!array) return ERR_FN[[]](NULL, "no array passed");
        if ((array->count + count) > array->capacity) return ERR_FN[[]](NULL, "out of capacity");
        memcpy(array->data + array->count, to_add, count * sizeof(ARRAY_DATA_T));
        array->count += count;
        return OK_FN[[]](array);
}
undefine([[DATA_RESULT_T]])dnl
UNDEFINE_RESULT_TYPES()dnl
UNDEFINE_ARRAY_TYPES()dnl
]])dnl
dnl
dnl
define([[ARRAY_C_POP]],
[[DEFINE_ARRAY_TYPES($1)
DEFINE_RESULT_TYPES($1)dnl
static inline RESULT_T ARRAY_T[[]]_pop(ARRAY_T* array)
{
        if (!array) return ERR_FN()(NULL, "no array passed");
        if (array->count == 0) return ERR_FN()(NULL, "nothing in the array");
        ARRAY_DATA_T()* to_return = &array->data[--array->count];
        return OK_FN()(to_return);
}
UNDEFINE_ARRAY_TYPES()dnl
UNDEFINE_RESULT_TYPES()dnl
]])
dnl 
dnl
dnl Create a generic C list for any T.
dnl ==================================
dnl
dnl (function) DEFINE_LIST_TYPES
dnl (description) Defines all the types we need for a list
dnl (param) T the type of the data in the list.
dnl
define([[DEFINE_LIST_TYPES]],[[dnl
define([[LIST_DATA_T]], $1)dnl
define([[LIST_T]], LIST_DATA_T[[]]_list)dnl
define([[LIST_NODE_T]], LIST_T[[]]_node)dnl
]])dnl
dnl
dnl (function) UNDEFINE_LIST_TYPES
dnl (description) Undefines all the types we need for a list. 
dnl               Should mirror a DEFINE_LIST_TYPES call.
dnl
define([[UNDEFINE_LIST_TYPES]], [[dnl
undefine([[LIST_DATA_T]], [[LIST_T]], [[LIST_NODE_T]])]])dnl
dnl 
dnl (function) LIST_C_STRUCT 
dnl (description) Creates a list for a type foo. LIST_C_STRUCT(foo)
dnl (param) T the type of the data in the list.
dnl
define(LIST_C_STRUCT, [[dnl
DEFINE_LIST_TYPES($1)dnl
ifelse($2, [[V]], define([[PTR]], [[*]]), define(PTR, [[]]))
C_FORWARD_STRUCT(LIST_T)
C_STRUCT_BEGIN(LIST_T)
        LIST_NODE_T[[]]PTR head;
C_STRUCT_END(LIST_T)dnl
UNDEFINE_LIST_TYPES[[]]dnl
]])dnl
dnl
dnl (function) LIST_NODE_C_STRUCT
dnl (description) Creates a list for a type foo. LIST_NODE_C_STRUCT(foo)
dnl (param) T the type of the data in the list.
dnl
define(LIST_NODE_C_STRUCT, [[dnl
DEFINE_LIST_TYPES($1)dnl
ifelse($2, [[V]], 
[[define([[PTR]], [[]])]],
[[define([[PTR]], [[*]])]])dnl
C_FORWARD_STRUCT(LIST_NODE_T)
C_STRUCT_BEGIN([[LIST_NODE_T]])
        LIST_DATA_T[[]]PTR data;
        LIST_NODE_T* next;
C_STRUCT_END([[LIST_NODE_T]])dnl
UNDEFINE_LIST_TYPES[[]]dnl
]])dnl
dnl
dnl (function) LIST_WITH_NODE_C_STRUCTS
dnl (description) Combines LIST_NODE_C_STRUCT and LIST_C_STRUCT. LIST_WITH_NODE_C_STRUCTS(foo)
dnl (param) T the type of the data in the list.
dnl
define(LIST_WITH_NODE_C_STRUCTS, [[dnl
LIST_NODE_C_STRUCT($1,$2)
LIST_C_STRUCT($1,$2)]])dnl
dnl
dnl
define([[LIST_C_ADD_FN]], 
[[DEFINE_LIST_TYPES($1)
DEFINE_RESULT_TYPES(LIST_T)
static inline RESULT_T LIST_T[[]]_add(LIST_T* list, LIST_NODE_T* node)
{
        if (!list) return ERR_FN[[]](list, "No list passed");
        if (!node) return ERR_FN[[]](list, "No node passed");
        if (!list->head) {
                list->head = node;
                return OK_FN[[]](list);
        }
        LIST_NODE_T* tmp = list->head;
        for (; tmp; tmp = tmp->next) if (!tmp->next) break;
        tmp->next = node;
        return OK_FN[[]](list);
}
UNDEFINE_RESULT_TYPES[[]]dnl
UNDEFINE_LIST_TYPES[[]]dnl
]])
dnl
dnl
dnl
