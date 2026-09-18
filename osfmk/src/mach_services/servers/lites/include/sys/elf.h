/* 
 * Copyright (c) 1994, The University of Utah and
 * the Computer Systems Laboratory at the University of Utah (CSL).
 *
 * Permission to use, copy, modify and distribute this software is hereby
 * granted provided that (1) source code retains these copyright, permission,
 * and disclaimer notices, and (2) redistributions including binaries
 * reproduce the notices in supporting documentation, and (3) all advertising
 * materials mentioning features or use of this software display the following
 * acknowledgement: ``This product includes software developed by the Computer
 * Systems Laboratory at the University of Utah.''
 *
 * THE UNIVERSITY OF UTAH AND CSL ALLOW FREE USE OF THIS SOFTWARE IN ITS "AS
 * IS" CONDITION.  THE UNIVERSITY OF UTAH AND CSL DISCLAIM ANY LIABILITY OF
 * ANY KIND FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
 *
 * CSL requests users of this software to return to csl-dist@cs.utah.edu any
 * improvements that they make and grant CSL redistribution rights.
 */
/*
 * HISTORY
 * $Log: elf.h,v $
 * Revision 1.1.1.1  1995/03/02  21:49:36  mike
 * Initial Lites release from hut.fi
 *
 */

#ifndef _SYS_ELF_H_
#define _SYS_ELF_H_

/* Just enough ELF information so we can exec files.  */

#define EI_NIDENT 16
#define ELFMAG0 0x7f
#define ELFMAG1 'E'
#define ELFMAG2 'L'
#define ELFMAG3 'F'

#define PT_LOAD 1

#define PF_X 0x1
#define PF_W 0x2
#define PF_R 0x4

typedef unsigned short	Elf32_Half;
typedef u_int32_t	Elf32_Word;
typedef unsigned long	Elf32_Addr;
typedef unsigned long	Elf32_Off;

typedef struct {
  unsigned char e_ident[EI_NIDENT];
  Elf32_Half	e_type;
  Elf32_Half	e_machine;
  Elf32_Word	e_version;
  Elf32_Addr	e_entry;
  Elf32_Off	e_phoff;
  Elf32_Off	e_shoff;
  Elf32_Word	e_flags;
  Elf32_Half	e_ehsize;
  Elf32_Half	e_phentsize;
  Elf32_Half	e_phnum;
  Elf32_Half	e_shentsize;
  Elf32_Half	e_shnum;
  Elf32_Half	e_shstrndx;
} Elf32_Ehdr;

typedef struct {
  Elf32_Word	p_type;
  Elf32_Off	p_offset;
  Elf32_Addr	p_vaddr;
  Elf32_Addr	p_addr;
  Elf32_Word	p_filesz;
  Elf32_Word	p_memsz;
  Elf32_Word    p_flags;
  Elf32_Word	p_align;
} Elf32_Phdr;

/* XXX Assumes the program headers will immediately follow the file header,
   which, while usually OK, isn't right according to the ELF spec.

   Also places a ceiling on the number of program headers.  */

/*
 * Raised from 4.
 *
 * Four was enough for the ELF a 1995 linker produced. Modern GNU ld
 * emits GNU_STACK and GNU_RELRO as well, so the emulator alone has six
 * program headers, and parse_exec_file() loops to e_phnum over this
 * array. Reading past it fed garbage into the loader: the real data and
 * bss segment set li->zero_start correctly and an out-of-bounds header
 * that happened to look like a writable PT_LOAD then overwrote it, so
 * the emulator's crt0 cleared the wrong page and left its BSS holding
 * whatever was there.
 *
 * parse_exec_file() also bounds its loop by this value now, so a binary
 * with more headers than this loses segments rather than reading past
 * the end of the struct. Sixteen is generous for the linkers in use.
 */
#define MAX_PHDRS 16
typedef struct {
  Elf32_Ehdr ehdr;
  Elf32_Phdr phdrs[MAX_PHDRS];
} elf_exec;

#endif /* !_SYS_ELF_H_ */
