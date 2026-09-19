/*
 * quaddiv.c -- the four 64-bit division entry points gcc expects.
 *
 * WHY THIS FILE EXISTS
 *
 * Compiling 64-bit integer division on i386 makes gcc emit calls to
 * __divdi3, __udivdi3, __moddi3 and __umoddi3. They are not part of the
 * C library; they are the compiler's runtime, normally satisfied by
 * linking libgcc.a. This tree links no compiler-supplied file, so they
 * have to come from somewhere -- and almost all of them were already
 * here.
 *
 * libkern/qdivrem.c is the hard part, the Berkeley/LBL long division
 * that does the work, and LITES ships it. What it never shipped are the
 * four thin wrappers around it, which is why qdivrem.c is absent from
 * conf/files and has never been built: nothing referenced it. 4.4BSD
 * keeps them as sys/libkern/divdi3.c, moddi3.c, udivdi3.c and
 * umoddi3.c; they are not in this source tree, nor in any of the LITES
 * copies in the reference collection, all of which have qdivrem.c and
 * no wrappers.
 *
 * So these are written against quad.h's declaration of __qdivrem rather
 * than copied:
 *
 *	extern u_quad_t __qdivrem __P((u_quad_t u, u_quad_t v,
 *				       u_quad_t *rem));
 *
 * The signed forms divide the magnitudes and fix the sign afterwards,
 * which is what C requires: division truncates toward zero, and the
 * remainder takes the sign of the dividend.
 *
 * WHERE IT MATTERS. The callers are ext2_balloc.c, ext2_lookup.c and
 * ext2_vfsops.c, which divide 64-bit file offsets to get block numbers.
 * An error here would not announce itself; it would address the wrong
 * block. That is why the change is verified by reading files back and
 * by e2fsck rather than by the build succeeding.
 */

#include <sys/param.h>
#include <sys/types.h>

#include <libkern/quad.h>

quad_t	__divdi3 __P((quad_t, quad_t));
quad_t	__moddi3 __P((quad_t, quad_t));
u_quad_t __udivdi3 __P((u_quad_t, u_quad_t));
u_quad_t __umoddi3 __P((u_quad_t, u_quad_t));

/*
 * Divide two unsigned quads. The remainder is discarded.
 */
u_quad_t
__udivdi3(a, b)
	u_quad_t a, b;
{

	return (__qdivrem(a, b, (u_quad_t *)0));
}

/*
 * Remainder of an unsigned quad division.
 */
u_quad_t
__umoddi3(a, b)
	u_quad_t a, b;
{
	u_quad_t rem;

	(void)__qdivrem(a, b, &rem);
	return (rem);
}

/*
 * Divide two signed quads. Truncation is toward zero, so the magnitudes
 * are divided and the sign applied afterwards; the result is negative
 * exactly when the operands' signs differ.
 */
quad_t
__divdi3(a, b)
	quad_t a, b;
{
	u_quad_t ua, ub, uq;
	int neg;

	if (a < 0)
		ua = -(u_quad_t)a, neg = 1;
	else
		ua = a, neg = 0;
	if (b < 0)
		ub = -(u_quad_t)b, neg ^= 1;
	else
		ub = b;

	uq = __qdivrem(ua, ub, (u_quad_t *)0);
	return (neg ? -(quad_t)uq : (quad_t)uq);
}

/*
 * Remainder of a signed quad division. C requires the remainder to take
 * the sign of the DIVIDEND, not the divisor, so only a's sign is
 * consulted when fixing it up.
 */
quad_t
__moddi3(a, b)
	quad_t a, b;
{
	u_quad_t ua, ub, ur;
	int neg;

	if (a < 0)
		ua = -(u_quad_t)a, neg = 1;
	else
		ua = a, neg = 0;
	if (b < 0)
		ub = -(u_quad_t)b;
	else
		ub = b;

	(void)__qdivrem(ua, ub, &ur);
	return (neg ? -(quad_t)ur : (quad_t)ur);
}
