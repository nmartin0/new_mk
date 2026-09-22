/*
 * vm_kern_test.c -- unit tests for kmem_alloc and vm_allocate.
 *
 * Part of the unit tests the KERNEL_TEST framework runs at boot in the
 * PRODUCTION+TEST configuration (K46; see ddb/unit_test.c). Returns 0
 * on success or a short reason for failure.
 */

#include <mach/boolean.h>
#include <mach/kern_return.h>
#include <mach/vm_param.h>
#include <vm/vm_map.h>
#include <vm/vm_kern.h>

extern kern_return_t	vm_allocate(vm_map_t, vm_offset_t *, vm_size_t, boolean_t);
extern kern_return_t	vm_deallocate(vm_map_t, vm_offset_t, vm_size_t);

const char *
unit_test_kmem(void)
{
	vm_size_t	size = 3 * PAGE_SIZE;
	vm_offset_t	a;
	unsigned int	*p, i, n = size / sizeof (unsigned int);

	if (kmem_alloc(kernel_map, &a, size) != KERN_SUCCESS)
		return "kmem_alloc failed";
	if (a & PAGE_MASK) {
		kmem_free(kernel_map, a, size);
		return "kmem_alloc memory is not page aligned";
	}
	p = (unsigned int *)a;
	for (i = 0; i < n; i++)
		p[i] = i ^ 0x5a5a5a5a;
	for (i = 0; i < n; i++)
		if (p[i] != (i ^ 0x5a5a5a5a)) {
			kmem_free(kernel_map, a, size);
			return "kmem_alloc memory did not hold a pattern";
		}
	kmem_free(kernel_map, a, size);
	return 0;
}

const char *
unit_test_vm_allocate(void)
{
	vm_size_t	size = 4 * PAGE_SIZE;
	vm_offset_t	a = 0;
	unsigned int	*p, i, n = size / sizeof (unsigned int);

	if (vm_allocate(kernel_map, &a, size, TRUE) != KERN_SUCCESS)
		return "vm_allocate failed";
	if (a == 0 || (a & PAGE_MASK))
		return "vm_allocate returned a bad address";
	p = (unsigned int *)a;
	for (i = 0; i < n; i++)
		if (p[i] != 0) {
			(void) vm_deallocate(kernel_map, a, size);
			return "new memory is not zero-filled";
		}
	p[0] = 1;
	p[n - 1] = 2;
	if (vm_deallocate(kernel_map, a, size) != KERN_SUCCESS)
		return "vm_deallocate failed";
	return 0;
}
