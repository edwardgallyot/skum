dnl
dnl
dnl These tests are for the skum.m4 file and check each macro expands to
dnl what we're expecting.
dnl
dnl 
define([[RUN_TEST]],[[dnl
        define(GEN_TEST, [[dnl
        define([[TEST_MACRO]], [[dnl
        define([[TEST_NAME]], $1) dnl
        define([[IN]], $2) dnl
        define([[OUT]], $3) dnl
        ifelse(IN, OUT, 
                [[define([[RES]], [[[PASS] TEST_NAME.]])]], 
                [[define([[RES]], [[[FAIL] TEST_NAME.
Unexpected output: 
IN 

Expected output:
OUT[[]]
]])]]) dnl
]])]]) dnl
GEN_TEST($1, $2, $3) dnl
TEST_MACRO 
RES dnl
undefine([[GEN_TEST]], [[TEST_MACRO]] [[TEST_NAME]], [[IN]], [[OUT]], [[RES]])
]])dnl
dnl
dnl Make sure m4 comments don]]t mess with sections.

C structure definitions
=======================
dnl
RUN_TEST([[C struct forward declare]], C_FORWARD_STRUCT([[foo]]), [[typedef struct __foo__ foo;]]) dnl
dnl
RUN_TEST([[C struct begin]], C_STRUCT_BEGIN([[foo]]), [[typedef struct __foo__ {]]) dnl
dnl
RUN_TEST([[C struct end]], C_STRUCT_END([[foo]]), [[} foo;]]) dnl
dnl
RUN_TEST([[C struct inline definition]],
C_STRUCT_BEGIN(foo)
        i32 bar;
C_STRUCT_END(foo),
[[
typedef struct __foo__ {
        i32 bar;
} foo;]])dnl
dnl

C allocator definitions
=======================
dnl
dnl
RUN_TEST([[C allocator definition]], C_ALLOCATOR,
[[
typedef struct __allocator__ allocator;
typedef struct __allocator__ {
        void* mem;
        size_t count;
        size_t capacity;
} allocator;
]])dnl
dnl
RUN_TEST([[C allocator void* function]], C_SHARED_ALLOC,
[[
static inline void* allocator_alloc(allocator* alloc, size_t num_bytes)
{
        if (!alloc) return NULL;
        size_t req_count = alloc->count + num_bytes;
        if (req_count > alloc->capacity) return NULL;
        void* result = ((u8*)alloc->mem) + alloc->count;
        alloc->count = req_count;
        return result;
}]])dnl
dnl
RUN_TEST([[Create a C allocator function]], C_ALLOC_FN(foo), 
[[
static inline foo_result foo_alloc(allocator* alloc, size_t count)
{
        foo* res = (foo*)allocator_alloc(alloc, sizeof(foo) * count);
        if (!res) return foo_err("Failed to allocate memory for foo");
        return foo_ok(res);
}
]])dnl
dnl
dnl
dnl

Result type definition
======================
dnl
RUN_TEST([[Define result types]],dnl
DEFINE_RESULT_TYPES(i32)dnl
RESULT_T, [[i32_result]])dnl
dnl
dnl
RUN_TEST([[Undefine result types]],dnl
DEFINE_RESULT_TYPES(i32)dnl
UNDEFINE_RESULT_TYPES[[]]dnl
RESULT_T, [[RESULT_T]])dnl
dnl
dnl
RUN_TEST([[C foo Result Definition]], RESULT_C_STRUCT(foo), 
[[
typedef struct __foo_result__ foo_result;
typedef struct __foo_result__ {
        foo* ok;
        union {
                const char* err;
                size_t is_err;
        };
} foo_result;
]])dnl
dnl
dnl
RUN_TEST([[C foo Result error function]], RESULT_C_ERR_FN(foo), 
[[
static inline foo_result foo_err(const char* err)
{
        foo_result res;
        res.err = err;
        return res;
}
]])dnl
dnl
dnl
RUN_TEST([[C foo Result ok function]], RESULT_C_OK_FN(foo), 
[[
static inline foo_result foo_ok(foo* t)
{
        foo_result res;
        res.ok = t;
        res.is_err = 0;
        return res;
}
]])dnl
dnl
dnl
RUN_TEST([[C foo Result full definition]], RESULT_C_FULL(foo), 
[[
typedef struct __foo_result__ foo_result;
typedef struct __foo_result__ {
        foo* ok;
        union {
                const char* err;
                size_t is_err;
        };
} foo_result;

static inline foo_result foo_err(const char* err)
{
        foo_result res;
        res.err = err;
        return res;
}

static inline foo_result foo_ok(foo* t)
{
        foo_result res;
        res.ok = t;
        res.is_err = 0;
        return res;
}
]])dnl
dnl

Slice definitions
=======================
dnl
dnl Slice definition
dnl
RUN_TEST([[Define slice types]],dnl
DEFINE_SLICE_TYPES(u32)dnl
SLICE_T SLICE_DATA_T, [[u32_slice u32]])dnl
dnl
dnl
RUN_TEST([[Undefine slice types]],dnl
UNDEFINE_SLICE_TYPES(u32)dnl
SLICE_T SLICE_DATA_T, [[SLICE_T SLICE_DATA_T]])dnl
dnl
dnl
RUN_TEST([[C slice definition u32]], SLICE_C_STRUCT(u32),
[[
typedef struct __u32_slice__ u32_slice;
typedef struct __u32_slice__ {
        u32* data;
        size_t size;
} u32_slice;
]])dnl
dnl
dnl

Array definitions
=========================
dnl
dnl Array definition
dnl
RUN_TEST([[Define array types]],dnl
DEFINE_ARRAY_TYPES(i32)dnl
ARRAY_T ARRAY_DATA_T, [[i32_array i32]])dnl
dnl
dnl
RUN_TEST([[Undefine array types]],dnl
UNDEFINE_ARRAY_TYPES(i32)dnl
ARRAY_T ARRAY_DATA_T, [[ARRAY_T ARRAY_DATA_T]])dnl
dnl
dnl
RUN_TEST([[C array definition i32]], ARRAY_C_STRUCT(i32),
[[
typedef struct __i32_array__ i32_array;
typedef struct __i32_array__ {
        i32* data;
        size_t count;
        size_t capacity;
} i32_array;]])dnl
dnl
dnl
RUN_TEST([[C array new i32]], ARRAY_C_NEW(i32),
[[
static inline i32_array_result i32_array_init(i32_array* array, allocator* alloc, size_t size)
{
        if (!array) return i32_array_err("no array passed");
        if (!alloc) return i32_array_err("no alloc passed");
        i32_result data_res = i32_alloc(alloc, size);
        if (data_res.is_err) return i32_array_err(data_res.err);
        array->data = data_res.ok;
        array->capacity = size;
        array->count = 0;
        return i32_array_ok(array);
}
]])dnl
dnl
dnl
dnl
RUN_TEST([[C array add i32]], ARRAY_C_ADD(i32),
[[
static inline i32_array_result i32_array_add(i32_array* array, i32 to_add)
{
        if (!array) return i32_array_err("no array passed");
        if (array->count >= array->capacity) return i32_array_err("out of capacity");
        array->data[array->count] = to_add;
        array->count++;
        return i32_array_ok(array);
}
]])dnl
dnl
dnl
RUN_TEST([[C array block add i32]], ARRAY_C_ADD_BLOCK(i32),
[[
static inline i32_array_result i32_array_add_block(i32_array* array, i32* to_add, size_t count)
{
        if (!array) return i32_array_err("no array passed");
        if ((array->count + count) > array->capacity) return i32_array_err("out of capacity");
        memcpy(array->data + array->count, to_add, count * sizeof(i32));
        array->count += count;
        return i32_array_ok(array);
}
]])dnl
dnl
dnl
dnl
RUN_TEST([[C array pop foo]], ARRAY_C_POP(foo),
[[
static inline foo_result foo_array_pop(foo_array* array)
{
        if (!array) return foo_err("no array passed");
        if (array->count == 0) return foo_err("nothing in the array");
        foo* to_return = &array->data[--array->count];
        return foo_ok(to_return);
}
]])dnl
dnl
dnl
dnl
RUN_TEST([[C array slice]], ARRAY_C_SLICE(foo),
[[
static inline foo_slice_result foo_array_slice(foo_array* array, foo_slice* slice, size_t begin, size_t end)
{
        if (!slice) return foo_slice_err("no slice passed");
        if (!array) return foo_slice_err("no array passed");
        if (begin > array->count) return foo_slice_err("begin out of range");
        if (end > array->count) return foo_slice_err("end out of range");
        slice->data = array->data + begin;
        slice->size = end - begin;
        return foo_slice_ok(slice);
}
]])dnl
dnl


Linked list definitions
=======================
dnl
dnl We test for a generic list where T=i32
dnl
RUN_TEST([[C Linked i32 List Definition]], LIST_C_STRUCT(i32, V), 
[[
typedef struct __i32_list__ i32_list;
typedef struct __i32_list__ {
        i32_list_node* head;
} i32_list;]])dnl
dnl
dnl
RUN_TEST([[C Linked List i32 Node Definition]], LIST_NODE_C_STRUCT(i32, V), 
[[
typedef struct __i32_list_node__ i32_list_node;
typedef struct __i32_list_node__ {
        i32 data;
        i32_list_node* next;
} i32_list_node;]])dnl
dnl
dnl
dnl
dnl
RUN_TEST([[C Linked List foo Full Definition]], LIST_WITH_NODE_C_STRUCTS(foo), 
[[
typedef struct __foo_list_node__ foo_list_node;
typedef struct __foo_list_node__ {
        foo* data;
        foo_list_node* next;
} foo_list_node;

typedef struct __foo_list__ foo_list;
typedef struct __foo_list__ {
        foo_list_node* head;
} foo_list;]])dnl
dnl
dnl
dnl
RUN_TEST([[C Linked List allocate node function]], C_ALLOC_FN(foo_list_node), 
[[
static inline foo_list_node_result foo_list_node_alloc(allocator* alloc, size_t count)
{
        foo_list_node* res = (foo_list_node*)allocator_alloc(alloc, sizeof(foo_list_node) * count);
        if (!res) return foo_list_node_err("Failed to allocate memory for foo_list_node");
        return foo_list_node_ok(res);
}
]])dnl
dnl
dnl
RUN_TEST([[C Linked List add node function]], LIST_C_ADD_FN(foo), 
[[
static inline foo_list_result foo_list_add(foo_list* list, foo_list_node* node)
{
        if (!list) return foo_list_err("No list passed");
        if (!node) return foo_list_err("No node passed");
        if (!list->head) {
                list->head = node;
                return foo_list_ok(list);
        }
        foo_list_node* tmp = list->head;
        for (; tmp; tmp = tmp->next) if (!tmp->next) break;
        tmp->next = node;
        return foo_list_ok(list);
}
]])dnl
dnl
