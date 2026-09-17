/*-
 * Copyright (c) 1991, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)stdarg.h	8.1 (Berkeley) 6/10/93
 */

#ifndef _STDARG_H_
#define	_STDARG_H_

/*
 * AI-ONLY NOTE: use the compiler's own varargs builtins.
 *
 * The original definitions computed the argument pointer by taking the
 * address of the last named parameter and stepping past it:
 *
 *	typedef char *va_list;
 *	#define va_start(ap, last) (ap = ((char *)&(last) + __va_promote(last)))
 *
 * That assumes a stack layout the compiler is not obliged to provide.
 * Modern GCC at -O2 does not, and the result is that named parameters
 * read correctly while every variadic argument is garbage. The symptom
 * here was printf printing a valid string pointer as the bytes of an
 * unrelated function -- "panic: UWVS..." where UWVS is the i386
 * prologue push ebp, push edi, push esi, push ebx -- while a format
 * string with no arguments printed perfectly.
 *
 * __builtin_va_list and friends are what GCC uses for its own <stdarg.h>
 * and are correct for whatever calling convention and optimisation
 * level are in effect.
 */
typedef __builtin_va_list va_list;

#define	va_start(ap, last)	__builtin_va_start((ap), (last))
#define	va_arg(ap, type)	__builtin_va_arg((ap), type)
#define	va_end(ap)		__builtin_va_end(ap)

#endif /* !_STDARG_H_ */
