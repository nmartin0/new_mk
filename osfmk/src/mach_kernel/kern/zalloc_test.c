/*
 * zalloc_test.c -- unit test for the zone allocator.
 *
 * Part of the unit tests the KERNEL_TEST framework runs at boot in the
 * PRODUCTION+TEST configuration (K46; see ddb/unit_test.c). Returns 0
 * on success or a short reason for failure.
 */

#include <mach/vm_param.h>
#include <kern/zalloc.h>

#define ZT_ELEM	64
#define ZT_N	32

const char *
unit_test_zone(void)
{
	static zone_t	zone = ZONE_NULL;
	vm_offset_t	e[ZT_N];
	int		i, j;

	if (zone == ZONE_NULL)
		zone = zinit(ZT_ELEM, 4 * ZT_N * ZT_ELEM, PAGE_SIZE, "unit_test_zone");
	if (zone == ZONE_NULL)
		return "zinit returned no zone";
	for (i = 0; i < ZT_N; i++) {
		if ((e[i] = zalloc(zone)) == 0)
			return "zalloc returned 0";
		if (e[i] % sizeof (long))
			return "an element is misaligned";
		for (j = 0; j < ZT_ELEM; j++)
			((unsigned char *)e[i])[j] = (unsigned char)i;
	}
	for (i = 0; i < ZT_N; i++)
		for (j = 0; j < ZT_ELEM; j++)
			if (((unsigned char *)e[i])[j] != (unsigned char)i)
				return "elements overlap";
	for (i = 0; i < ZT_N; i++)
		zfree(zone, e[i]);
	if ((e[0] = zalloc(zone)) == 0)
		return "zalloc after zfree returned 0";
	zfree(zone, e[0]);
	return 0;
}
