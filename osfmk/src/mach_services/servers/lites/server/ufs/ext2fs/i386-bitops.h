/*
 * this is mixture of i386/bitops.h and asm/string.h
 * taken from the Linux source tree 
 *
 * XXX replace with Mach routines or reprogram in C
 */
#ifndef _I386_BITOPS_H
#define _I386_BITOPS_H

/*
 * Copyright 1992, Linus Torvalds.
 */

/*
 * These have to be done with inline assembly: that way the bit-setting
 * is guaranteed to be atomic. All bit operations return 0 if the bit
 * was cleared before the operation and != 0 if it was not.
 *
 * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
 */

/*
 * Some hacks to defeat gcc over-optimizations..
 */
struct __dummy { unsigned long a[100]; };
#define ADDR (*(struct __dummy *) addr)

extern __inline__ int set_bit(int nr, void * addr)
{
	int oldbit;

	__asm__ __volatile__("btsl %2,%1\n\tsbbl %0,%0"
		:"=r" (oldbit),"=m" (ADDR)
		:"ir" (nr));
	return oldbit;
}

extern __inline__ int clear_bit(int nr, void * addr)
{
	int oldbit;

	__asm__ __volatile__("btrl %2,%1\n\tsbbl %0,%0"
		:"=r" (oldbit),"=m" (ADDR)
		:"ir" (nr));
	return oldbit;
}

extern __inline__ int change_bit(int nr, void * addr)
{
	int oldbit;

	__asm__ __volatile__("btcl %2,%1\n\tsbbl %0,%0"
		:"=r" (oldbit),"=m" (ADDR)
		:"ir" (nr));
	return oldbit;
}

/*
 * This routine doesn't need to be atomic, but it's faster to code it
 * this way.
 */
extern __inline__ int test_bit(int nr, void * addr)
{
	int oldbit;

	__asm__ __volatile__("btl %2,%1\n\tsbbl %0,%0"
		:"=r" (oldbit)
		:"m" (ADDR),"ir" (nr));
	return oldbit;
}

/*
 * Find-bit routines..
 */
extern inline int find_first_zero_bit(void * addr, unsigned size)
{
	int res;
	/*
	 * d0, d1, d2 exist only to declare ECX, EDI and EAX as
	 * read-write operands; see the constraint note below.
	 */
	int d0, d1, d2;

	if (!size)
		return 0;
	__asm__("\n\
		cld\n\
		movl $-1,%%eax\n\
		xorl %%edx,%%edx\n\
		repe; scasl\n\
		je 1f\n\
		xorl -4(%%edi),%%eax\n\
		subl $4,%%edi\n\
		bsfl %%eax,%%edx\n\
1:		subl %%ebx,%%edi\n\
		shll $3,%%edi\n\
		addl %%edi,%%edx"
		/*
		 * The original constraints named ECX and EDI as inputs
		 * ("c" and "D") *and* as clobbers ("cx", "di"). That is
		 * invalid: a register cannot be clobbered when the
		 * compiler must also set it up as an input, because the
		 * value has to survive until the asm reads it. The block
		 * really does modify both -- repe decrements ECX and
		 * scasl advances EDI -- so they are read-write operands,
		 * spelled as early-clobber outputs tied to matching
		 * inputs. EAX is written by the movl and so is an output
		 * too, rather than a clobber.
		 *
		 * Older GCC tolerated the original form. Modern GCC
		 * rejects it at -O2 with "asm operand has impossible
		 * constraints or there are not enough registers", while
		 * accepting it at -O0, which is the signature of a
		 * constraint bug rather than genuine register pressure.
		 */
		:"=d" (res), "=&c" (d0), "=&D" (d1), "=&a" (d2)
		:"1" ((size + 31) >> 5), "2" (addr), "b" (addr));
	return res;
}

extern inline int find_next_zero_bit (void * addr, int size, int offset)
{
	unsigned long * p = ((unsigned long *) addr) + (offset >> 5);
	int set = 0, bit = offset & 31, res;
	
	if (bit) {
		/*
		 * Look for zero in first byte
		 */
		__asm__("\n\
			bsfl %1,%0\n\
			jne 1f\n\
			movl $32, %0\n\
1:			"
			: "=r" (set)
			: "r" (~(*p >> bit)));
		if (set < (32 - bit))
			return set + offset;
		set = 32 - bit;
		p++;
	}
	/*
	 * No zero yet, search remaining full bytes for a zero
	 */
	res = find_first_zero_bit (p, size - 32 * (p - (unsigned long *) addr));
	return (offset + set + res);
}

/*
 * ffz = Find First Zero in word. Undefined if no zero exists,
 * so code should check against ~0UL first..
 */
extern inline unsigned long ffz(unsigned long word)
{
	__asm__("bsfl %1,%0"
		:"=r" (word)
		:"r" (~word));
	return word;
}

/* 
 * memscan() taken from linux asm/string.h
 */
/*
 * find the first occurrence of byte 'c', or 1 past the area if none
 */
extern inline char * memscan(void * addr, unsigned char c, int size)
{
        if (!size)
                return addr;
        __asm__("cld\n\
                repnz; scasb\n\
                jnz 1f\n\
                dec %%edi\n\
1:              "
                : "=D" (addr), "=c" (size)
                : "0" (addr), "1" (size), "a" (c));
        return addr;
}

#endif /* _I386_BITOPS_H */
