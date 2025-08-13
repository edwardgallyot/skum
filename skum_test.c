#include <stdbool.h>
#include <stdio.h>
#include <sys/mman.h>

#include "skum.h"      

void_result init_allocator(allocator* alloc, size_t size)
{
        if (alloc->mem != NULL) munmap(alloc->mem, alloc->capacity);
        alloc->mem = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (alloc->mem == MAP_FAILED) return void_err("Failed to map memory");
        alloc->count = 0;
        alloc->capacity = size;
        return void_ok(NULL);
}

void_result test_result_ok()
{
        static foo valid_foo;
        foo_result result = foo_ok(&valid_foo);
        if (result.is_err) return void_err("result.is_err failed");
        return void_ok(&valid_foo);
};

void_result test_result_err()
{
        static foo invalid_foo;
        foo_result result = foo_err("Error in the foorce");
        if (!result.is_err) return void_err("result.is_err failed");
        return void_ok(NULL);
};

void_result test_list_add()
{
        allocator alloc;
        void_result res = init_allocator(&alloc, 1024);
        if (res.is_err) return res;
        #define num_foos 3
        foo foos[3] = {
                { .bar = 1 },
                { .bar = 2 },
                { .bar = 3 }
        };
        foo_list_node* list_nodes;
        foo_list_node_result node_result = foo_list_node_alloc(&alloc, 3);
        if (node_result.is_err) return void_err(node_result.err);
        list_nodes = node_result.ok;
        foo_list list;
        for (size_t i = 0; i < num_foos; ++i) {
                list_nodes[i].data = &foos[i];
                foo_list_result add_res = foo_list_add(&list, &list_nodes[i]);
                if (add_res.is_err) return void_err(add_res.err);
        }

        size_t i = 0;
        for (foo_list_node* tmp = list.head; tmp; tmp = tmp->next) {
                if (tmp->data->bar !=  foos[i].bar) return void_err("Mismatch");
                i++;
        }
        return void_ok(NULL);
        #undef num_foos
}

void_result test_array_init()
{
#define ARRAY_SIZE 4 
        allocator alloc;
        void_result res = init_allocator(&alloc, 1024);
        if (res.is_err) return res;
        i32_array array;        
        i32_array_result init_res = i32_array_init(&array, &alloc, ARRAY_SIZE);
        if (init_res.is_err) return void_err(init_res.err);
        if (array.capacity != ARRAY_SIZE) return void_err("Incorrect capacity");
        for (size_t i = 0; i < ARRAY_SIZE; ++i) 
                array.data[i] = i;

        return void_ok(NULL);
#undef ARRAY_SIZE
}

void_result test_array_add()
{
#define ARRAY_SIZE 4 
        allocator alloc;
        void_result res = init_allocator(&alloc, 1024);
        if (res.is_err) return res;
        i32_array array;        
        i32_array_result init_res = i32_array_init(&array, &alloc, ARRAY_SIZE);
        if (init_res.is_err) return void_err(init_res.err);
        if (array.capacity != ARRAY_SIZE) return void_err("Incorrect capacity");
        for (size_t i = 0; i < 4; ++i) {
                i32_array_result add_res = i32_array_add(&array, i);
                if (add_res.is_err) return void_err(add_res.err);
        }
        if (array.count != ARRAY_SIZE) return void_err("Incorrect count after adding ARRAY_SIZE");
        for (size_t i = 0; i < array.count; ++i) {
                if (array.data[i] != i) return void_err("Array value error");
        }
        return void_ok(NULL);
#undef ARRAY_SIZE
}

void_result test_array_add_block()
{
#define ARRAY_SIZE 8
        allocator alloc;
        void_result res = init_allocator(&alloc, 1024);
        if (res.is_err) return res;
        i32_array array;        
        i32_array_result init_res = i32_array_init(&array, &alloc, ARRAY_SIZE);
        if (init_res.is_err) return void_err(init_res.err);
        i32 to_add[ARRAY_SIZE] = {
                0, 1, 2, 3, 4, 5, 6, 7
        };
        if (array.capacity != ARRAY_SIZE) return void_err("Incorrect capacity");
        i32_array_add_block(&array, to_add, ARRAY_SIZE);
        if (array.count != ARRAY_SIZE) return void_err("Incorrect count after adding ARRAY_SIZE");
        for (size_t i = 0; i < array.count; ++i) {
                if (array.data[i] != i) return void_err("Array value error");
        }
        return void_ok(NULL);
#undef ARRAY_SIZE
}

void_result test_array_pop()
{
#define ARRAY_SIZE 8
        allocator alloc;
        void_result res = init_allocator(&alloc, 1024);
        if (res.is_err) return res;
        i32_array array;        
        i32_array_result init_res = i32_array_init(&array, &alloc, ARRAY_SIZE);
        if (init_res.is_err) return void_err(init_res.err);
        i32 to_add[ARRAY_SIZE] = {
                1, 2, 3, 4, 5, 6, 7, 8
        };
        if (array.capacity != ARRAY_SIZE) return void_err("Incorrect capacity");
        i32_array_add_block(&array, to_add, ARRAY_SIZE);
        if (array.count != ARRAY_SIZE) return void_err("Incorrect count after adding ARRAY_SIZE");
        for (size_t i = ARRAY_SIZE; i != 0 ; --i) {
                i32_result pop_res = i32_array_pop(&array);
                if (pop_res.is_err) return void_err(pop_res.err);
                if (*pop_res.ok != i) return void_err("Invalid value");
        }
        return void_ok(NULL);
#undef ARRAY_SIZE
}

void_result test_array_slice()
{
#define ARRAY_SIZE 8
        allocator alloc;
        void_result res = init_allocator(&alloc, 1024);
        if (res.is_err) return res;
        i32_array array;        
        i32_array_result init_res = i32_array_init(&array, &alloc, ARRAY_SIZE);
        if (init_res.is_err) return void_err(init_res.err);
        i32 to_add[ARRAY_SIZE] = {
                1, 2, 3, 4, 5, 6, 7, 8
        };
        if (array.capacity != ARRAY_SIZE) return void_err("Incorrect capacity");
        i32_array_add_block(&array, to_add, ARRAY_SIZE);
        if (array.count != ARRAY_SIZE) return void_err("Incorrect count after adding ARRAY_SIZE");
        i32_slice slice;
        i32_slice_result slice_res = i32_array_slice(&array, &slice, 1, 3);
        if (slice_res.is_err) return void_err(slice_res.err);
        for (size_t i = 0; i < slice.size; ++i) {
                if (slice.data[i] != (i + 2)) return void_err("Incorrect data");
        }
        return void_ok(NULL);
#undef ARRAY_SIZE
}

typedef struct __test__ {
        void_result (*func)();
        const char* name;
} test;

// Incre
#define NUM_TESTS (8)
test tests[NUM_TESTS] = {
        { test_result_err, "Testing if result err works"},
        { test_result_ok, "Testing if result ok works"},
        { test_list_add, "Testing if list add works"},
        { test_array_init, "Testing if array init works"},
        { test_array_add, "Testing if array add works"},
        { test_array_add_block, "Testing if array add block works"},
        { test_array_pop, "Testing if array pop works"},
        { test_array_slice, "Testing if array slice works"}
};

void print_test_result(const char* name, void_result res)
{
        if (!res.is_err) {
                printf("\n[PASS] %s\n", name);
        } else {
                printf("\n[FAIL] %s \nOutput:\n %s \n", name, res.err);
        }
}

void run_tests()
{
        printf("\nC tests\n");
        printf("=======\n");
        for (int t = 0; t < NUM_TESTS; ++t) {
                const char* name = tests[t].name;
                void_result res = tests[t].func();
                print_test_result(name, res);
        }
}

int main(void)
{
        run_tests();
}
