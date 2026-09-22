# 
# Mach Operating System
# Copyright (c) 1994 Johannes Helander
# All Rights Reserved.
# 
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright
# notice and this permission notice appear in all copies of the
# software, derivative works or modified versions, and any portions
# thereof, and that both notices appear in supporting documentation.
# 
# JOHANNES HELANDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS"
# CONDITION.  JOHANNES HELANDER DISCLAIMS ANY LIABILITY OF ANY KIND
# FOR ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
#
# 
#  HISTORY
#  $Log: Makefile,v $
# Revision 1.1.1.1  1995/03/02  21:49:39  mike
# Initial Lites release from hut.fi
#
#
#	File:	emulator/Makefile
#	Author:	Johannes Helander, Helsinki University of Technology, 1994.
#

LIBNAME=lites

target_cpu	?= ${MACHINE}
# AI-ONLY NOTE: VPATH carries the INCFLAGS directories too, in the same order, so that
# make finds each header by the name md recorded for it (Q9).
VPATH		= ${target_cpu}:${LITES_TOP}server:${LITES_TOP}include

LIBRARIES	= lib${LIBNAME}.a
DEPENDENCIES	=
MIG_HDRS	=

EXPLIB_TARGETS  = ${LIBRARIES:S/^/export_&/g}
ILIST		= lib${LIBNAME}.a
IDIR		= /lib/
NO_STRIP	=

LITES_TOP	= ${MAKETOP}mach_services/servers/lites/
INCFLAGS	= -I${LITES_TOP}server -I${LITES_TOP}include
# AI-ONLY NOTE: md records a header as a dependency only if it was found through an
# include directory listed before -I- in its command line; headers found
# through the rest -- every -I the compiler is given -- it treats as
# standard and writes, at most, as comments. ODE lists each component's
# own directory there, but LITES's sibling source directories were
# standard, so no LITES header was ever recorded and editing one rebuilt
# nothing (Q9). MDINCFLAGS is ODE's hook for adding directories there;
# _MDFLAGS_ expands it with GENPATH exactly as it does INCFLAGS, and a
# directory in both lists stays current. Exports stay standard.
MDINCFLAGS	+= ${INCFLAGS}

# The EXPORTBASE/bsdss directory contains the include files
# in machine

INCDIRS		:= -I${EXPORTBASE}/lites/server -I${EXPORTBASE}/lites ${INCDIRS}

# Makefile-version defines VERSION

.if exists( ${LITES_TOP}Makefile-version)
.include "${LITES_TOP}Makefile-version"
.endif

DEFINES		= -DTypeCheck=0 -DMACH_IPC_COMPAT=0 -DLITES
CFLAGS		= ${DEFINES} -g -nostdinc
PC532_CFLAGS	= -mhimem -DGNU_LD2 -Dns532

MIGFLAGS 	= ${DEFINES}
ASFLAGS		= ${${TARGET_MACHINE}ASFLAGS}

i386_OFILES = ntoh.o memcmp.o in_cksum.o
parisc_OFILES =
ns532_OFILES = misc_asm.s memcmp.o in_cksum.o bcmp.o
mips_OFILES = ntoh.o memcmp.o
alpha_OFILES =

lib${LIBNAME}.a_OFILES = ${${target_cpu}_OFILES} exec_file.o

.include <${RULES_MK}>

#
# ODE's rules clear .SUFFIXES (osf.std.mk) and define no .s.o
# transformation in its place, so the tree's components compile their
# assembler with explicit rules. This is libmach's, from
# AT386/machdep.mk, as written: copy x.s to x.S so the compiler
# preprocesses it, then compile with -DASSEMBLER -- the same thing the
# GNU route does with -x assembler-with-cpp -DASSEMBLER.
#
i386_SFILES	= ntoh.o
SFILES		= ${${target_cpu}_SFILES}

${SFILES:.o=.S}: $${.TARGET:.S=.s}
	${RM} ${_RMFLAGS_} ${.TARGET}
	${CP} ${${.TARGET:.S=.s}:P} ${.TARGET}

${SFILES}: $${.TARGET:.o=.S}
	${_CC_} -DASSEMBLER ${_CCFLAGS_} -c ${.TARGET:.o=.S}

# AI-ONLY NOTE: the dependencies md collected (MDINCFLAGS above); every ODE component
# includes them this way, and LITES never did (Q9).
.if exists(depend.mk)
.include "depend.mk"
.endif
