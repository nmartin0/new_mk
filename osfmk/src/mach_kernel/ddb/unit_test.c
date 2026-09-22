/*
 * unit_test.c -- unit tests run by the KERNEL_TEST framework (K46).
 *
 * The framework in kernel_test.c starts long-running tests at boot; this
 * is its UNIT_TEST slot, which runs short tests that finish and report.
 * Each test lives beside the code it tests, as vm/vm_test.c does, and
 * returns 0 or a reason for failure. Results go to the console in
 * vm_test.c's style, one line per test and a total:
 *
 *	unit_test_zone: PASSED
 *	unit_test_kmem: FAILED: kmem_alloc failed
 *	unit_test: 3 passed, 1 failed
 *
 * Built in the PRODUCTION+TEST configuration; boot it with
 * KERNEL=.../mach_kernel.PRODUCTION+TEST sh tools/boot-ide.sh.
 */
#include <mach/boolean.h>

extern int	printf(const char *, ...);

extern const char	*unit_test_zone(void);
extern const char	*unit_test_kmem(void);
extern const char	*unit_test_vm_allocate(void);
extern const char	*unit_test_port_rights(void);
extern const char	*unit_test_ipc_null_rpc(void);	/* ipc/ipc_bench.c, X19 */
extern const char	*unit_test_ipc_inline_4k(void);
extern const char	*unit_test_ipc_port_set(void);

static struct {
	const char	*name;
	const char	*(*run)(void);
} unit_tests[] = {
	{ "zone",		unit_test_zone },
	{ "kmem",		unit_test_kmem },
	{ "vm_allocate",	unit_test_vm_allocate },
	{ "port_rights",	unit_test_port_rights },
	{ "ipc_null_rpc",	unit_test_ipc_null_rpc },
	{ "ipc_inline_4k",	unit_test_ipc_inline_4k },
	{ "ipc_port_set",	unit_test_ipc_port_set },
};

void
unit_test_init(boolean_t startup)
{
	int		i, failed = 0;
	int		n = sizeof (unit_tests) / sizeof (unit_tests[0]);
	const char	*why;

	for (i = 0; i < n; i++) {
		if ((why = (*unit_tests[i].run)()) == 0)
			printf("unit_test_%s: PASSED\n", unit_tests[i].name);
		else {
			printf("unit_test_%s: FAILED: %s\n", unit_tests[i].name, why);
			failed++;
		}
	}
	printf("unit_test: %d passed, %d failed\n", n - failed, failed);
}
