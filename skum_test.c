#include <stdbool.h>
#include <stdio.h>

#include "skum.h"      

void_result test_result_ok()
{
        static foo valid_foo;
        foo_result result = foo_ok(&valid_foo);
        if (result.is_err)
        {
                return void_err(NULL, "result.is_err failed");
        }
        return void_ok(&valid_foo);
};

void_result test_result_err()
{
        static foo invalid_foo;
        foo_result result = foo_err(NULL, "Error in the foorce");
        if (result.is_ok)
        {
                return void_err(NULL, "result.is_err failed");
        }
        return void_ok(NULL);
};

typedef struct __test__ {
        void_result (*func)();
        const char* name;
} test;

#define NUM_TESTS (2)
test tests[NUM_TESTS] = {
        { test_result_err, "Testing if result err works"},
        { test_result_ok, "Testing if result ok works"}
};

void run_tests()
{
        for (int t = 0; t < NUM_TESTS; ++t)
        {
                const char* name = tests[t].name;
                void_result res = tests[t].func();
                if (!res.is_err) {
                        printf("[PASS] %s\n", name);
                } else {
                        printf("[FAIL] %s \nOutput:\n %s \n", name, res.err);
                }
        }
}

int main(void)
{
        run_tests();
}
