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
# 25-Oct-94  Johannes Helander (jvh) at Helsinki University of Technology
#	Merged in PA RISC support from Mike Hibler and PC532 support from
#	Ian Dall.
#
#  $Log: Makefile,v $
# Revision 1.3  1995/03/23  01:38:13  law
# Update to 950323 snapshot + utah changes
#
# Revision 1.2  1995/03/02  23:27:39  mike
# Utah fast RPC support
#
# Revision 1.3  1995/03/02  23:06:16  mike
# hack support for LRRPC path
#
# Revision 1.2  1995/02/21  23:37:40  mike
# 0.7 version
#
#
#	File:	emulator/Makefile
#	Author:	Johannes Helander, Helsinki University of Technology, 1994.
#	Date:	May 1994
#

target_cpu	?= ${MACHINE}
# VPATH carries the INCFLAGS directories too, in the same order, so that
# make finds each header by the name md recorded for it (Q9).
VPATH		= ${target_cpu}:extra:programs:../server:${LITES_TOP}include:${EXPORTBASE}/lites/server:${EXPORTBASE}/lites

# EXPLIB_SUBDIRS	= libsyscall

OTHERS		= ${EMULATOR}
DEPENDENCIES	=
MIG_HDRS	=
PROGRAMS	=
# zprintbsd testprog runit
ILIST		= ${EMULATOR}
IDIR		= /special/
NO_STRIP	=

LITES_TOP	= ${MAKETOP}mach_services/servers/lites/
INCFLAGS	= -I${LITES_TOP}emulator -I${LITES_TOP}server -I${LITES_TOP}include
# md records a header as a dependency only if it was found through an
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

INCDIRS		:= -I. -I${EXPORTBASE}/lites/server -I${EXPORTBASE}/lites ${INCDIRS}

# Makefile-version defines VERSION

.if exists( ${LITES_TOP}Makefile-version)
.include "${LITES_TOP}Makefile-version"
.endif

EMULATOR        = emulator.${VERSION}

parisc_DEFINES	= -DUSENRPC

DEFINES		= -DCMU=1 -DTypeCheck=0 -DMACH_IPC_COMPAT=0 -DCOMPAT_43 -DEMULATOR -DMAP_UAREA -DNFS -DLITES -DASYNCH_SIGNALS ${${target_cpu}_DEFINES}
#
# The configured compiler flags -- -DUNTYPED_IPC=1 among them, without
# which LITES's typed-IPC declarations are compiled in -- come from the
# Makevar that LITES's export-pass configuration step publishes, as the
# GNU route applies its conf/Makevar to every compile.
#
.if exists(${EXPORTBASE}/lites/server/Makevar)
.include "${EXPORTBASE}/lites/server/Makevar"
.endif
CFLAGS		= ${DEFINES} ${TARGET_CFLAGS} -g -nostdinc
PC532_CFLAGS	= -mhimem -DGNU_LD2 -Dns532

MIGFLAGS 	= ${DEFINES}
ASFLAGS		= ${${TARGET_MACHINE}ASFLAGS}

${EMULATOR}_LIBS= -nostdlib -llites ${LIBGCC} ${LIBTHREADS} ${LIBMACH_SA}
testprog_LIBS	= -nostdlib ${LIBGCC} -lsyscall ${LIBTHREADS} ${LIBMACH_SA}
runit_LIBS	= -nostdlib ${LIBGCC} -lsyscall ${LIBTHREADS} ${LIBMACH_SA}
zprintbsd_LIBS	= ${LIBCMUCS} ${LIBTHREADS} ${LIBMACH}


ecrt0.o_CFLAGS	+= -DCRT0
strtol.o_CFLAGS += -I${_MAKECONF:H}/emulator/extra
atoi.o_CFLAGS 	+= -I${_MAKECONF:H}/emulator/extra
ctype_.o_CFLAGS += -I${_MAKECONF:H}/emulator/extra
quit.o_CFLAGS += -I${_MAKECONF:H}/emulator/extra
zprintbsd.o_CFLAGS += -I${_MAKECONF:H}/emulator/extra

i386_COMMON_OFILES	= e_linux.o 
parisc_COMMON_OFILES	= 

COMMON_OFILES	= ecrt0.o e_mig_support.o emul_generic.o \
	error_codes.o emul_init.o emul_mapped.o \
	e_machinedep.o emul_misc_asm.o \
	e_bsd.o e_43ux.o bsd_1_user.o \
	emul_mach_user.o e_signal.o signal_server.o e_uname.o \
	e_mapped_time.o e_sysvipc.o \
	${${target_cpu}_COMMON_OFILES}

testprog_OFILES	= ${COMMON_OFILES} testprog.o libsys_support.o
runit_OFILES	= ${COMMON_OFILES} runit.o libsys_support.o
zprintbsd_OFILES= zprintbsd.o bsd_1_user.o process_self.o

i386_EMULATOR_OFILES	= e_linux_sysent.o e_linux_trampoline.o \
	e_isc4_sysent.o e_sysv.o e_cmu_43ux_sysent.o e_lite_sysent.o
ns532_EMULATOR_OFILES	= e_cmu_43ux_sysent.o e_lite_sysent.o
parisc_EMULATOR_OFILES	= e_hpbsd_sysent.o e_hpbsd.o e_lite_sysent.o \
	LRbsd_1_user.o LRmach_user.o

#
# The emulator's objects, in the order of Utah's maintained list,
# OBJFILES in emulator/Makerules, which the GNU route links. The set is
# the one Helander's lists produce (COMMON_OFILES and
# ${target_cpu}_EMULATOR_OFILES), less the dead e_readwrite.o; only the
# order is Utah's. Order matters: the same objects linked in
# Helander's order give different .text, .data and .rodata, and in
# this order give the GNU build's exactly. COMMON_OFILES stays for
# testprog and runit.
#
i386_LINK_OFILES = e_linux.o e_sysv.o e_exception.o e_signal.o \
	e_machinedep.o e_linux_trampoline.o e_linux_sysent.o \
	e_isc4_sysent.o e_cmu_43ux_sysent.o
EMULATOR_OFILES	= ecrt0.o e_mig_support.o emul_generic.o error_codes.o \
	emul_init.o emul_mapped.o emul_misc_asm.o \
	e_bsd.o e_43ux.o bsd_1_user.o emul_mach_user.o \
	e_mach_msg_server.o e_stat.o e_bnr.o emul_exec.o \
	signal_server.o e_uname.o e_mapped_time.o e_sysvipc.o \
	${${target_cpu}_LINK_OFILES} \
	e_lite_sysent.o emul_vector.o e_trampoline.o

# For dependencies
DEP_OFILES	= e_mig_support.o emul_generic.o error_codes.o emul_init.o \
	emul_mapped.o mvfs_interface.o e_machinedep.o emul_misc_asm.o atoi.o \
	strtol.o ctype_.o e_bsd.o e_43ux.o \
	e_linux.o emul_vector.o emul_exec.o \
	e_trampoline.o e_lite_sysent.o e_isc4_sysent.o e_linux_sysent.o \
	e_sysv.o e_linux_trampoline.o e_exception.o e_mach_msg_server.o \
	e_cmu_43ux_sysent.o zprintbsd.o process_self.o \
	testprog.o libsys_support.o e_signal.o e_bnr.o e_stat.o \
	e_uname.o e_mapped_time.o \
	e_hpbsd_sysent.o e_hpbsd.o e_sysvipc.o \
	LRbsd_1_user.o LRmach_user.o

ansi_CPP	?= ${ANSI_CC} -E
.include <${RULES_MK}>

#
# ODE's rules define no .s.o transformation, so the emulator's two
# assembler sources are compiled with the tree's own explicit rule, as
# libmach's AT386/machdep.mk writes it and as liblites uses it: copy
# x.s to x.S so the compiler preprocesses it, then compile with
# -DASSEMBLER. The GNU route also passes -D__LANGUAGE_ASSEMBLY; nothing
# in LITES or in OSF's exported headers tests it.
#
i386_SFILES	= emul_misc_asm.o emul_vector.o
SFILES		= ${${target_cpu}_SFILES}

${SFILES:.o=.S}: $${.TARGET:.S=.s}
	${RM} ${_RMFLAGS_} ${.TARGET}
	${CP} ${${.TARGET:.S=.s}:P} ${.TARGET}

${SFILES}: $${.TARGET:.o=.S}
	${_CC_} -DASSEMBLER ${_CCFLAGS_} -c ${.TARGET:.o=.S}

#
# Unquoted: emulator_base prints several ld options, which must reach
# ld as separate words. Quoted -- as vendored, for an older
# emulator_base that printed one address -- ld receives "-e" followed
# by the whole string, sets a nonsense entry symbol, and links at its
# default address without complaint.
#
BASE=`./emulator_base`

#
# The emulator links with ld directly, as the GNU route does:
# emulator_base prints ld's own options -- "-e __start -qmagic -static
# -Ttext 0xa0001000" -- which the gcc driver would reject. So the link
# does not use ${_LDFLAGS_}, which in this tree carries gcc-driver
# options such as -nostartfiles, nor the old -z -T ${BASE} wrapping,
# written for an emulator_base that printed only an address. Each flag
# is one the GNU route's build script, tools/lites/build-lites.sh
# (retired; see its history), documented:
#
#   -m elf_i386        a 32-bit link on a 64-bit host's ld
#   -z muldefs         LITES defines its own printf, vsprintf, sprintf
#   ${TARGET_LDFLAGS}  the configured -e __start, from Makevar
#   the libraries      liblites; cthreads (the GNU route's -lthreads);
#                      then mach_sa and sa_mach, which reference each
#                      other, so mach_sa is named twice
#   no --defsym        unlike the server: ecrt0.c defines __start
#
# LIBTHREADS, LIBMACH_SA and LIBGCC, which the vendor rule used, are
# defined nowhere in this tree's makedefs.
#
# The result stays in the object tree, where boot-ide.sh finds
# bootstrap and default_pager (D29). The vendor rule also copied it to
# ${EXPORTBASE}/special/, POE's convention; no OSF component copies a
# program into the export tree.
#
EMULATOR_LDFLAGS = -m elf_i386 -z muldefs
EMULATOR_LIBS	= -L${EXPORTBASE}/lib -llites -lcthreads -lmach_sa -lsa_mach -lmach_sa
# The libraries as files, so that relinking follows them: -l names them
# only to the linker, and without this a rebuilt liblites left the
# emulator and server linked against the old one (L47).
EMULATOR_LIBDEPS = ${EXPORTBASE}/lib/liblites.a ${EXPORTBASE}/lib/libcthreads.a \
	${EXPORTBASE}/lib/libmach_sa.a ${EXPORTBASE}/lib/libsa_mach.a

${EMULATOR}: ${EMULATOR_OFILES} emulator_base ${EMULATOR_LIBDEPS}
	@echo emulator base is \"${BASE}\"
	${_LD_} -o ${.TARGET}.out ${BASE} ${EMULATOR_LDFLAGS} ${TARGET_LDFLAGS} \
	    ${EMULATOR_OFILES} ${EMULATOR_LIBS} && \
	${MV} ${.TARGET}.out ${.TARGET}

# Some dependencies

${DEP_OFILES} : bsd_1.h
${DEP_OFILES} : sys/syscall.h
#
# sys/syscall.h is generated once, by LITES's export-pass configuration
# step, and published to ${EXPORTBASE}/lites/sys/, where VPATH and
# INCDIRS find it. This directory used to run makesyscalls.sh itself,
# and its sys/ subdirectory ran it a second time to export the result
# -- with no EXPDIR, into a placeholder _MISSING_EXPDIR_. Neither run
# is needed; nothing here used emul_sysent.c except as a target name.
#
MAKE_SERV = [ -d serv ] || mkdir serv

BSD_FILES = bsd_1.h serv/bsd_1_user.c

$(BSD_FILES): bsd_types_gen.h serv/bsd_1.defs
	-$(MAKE_SERV)
	${_MIG_} $(_MIGFLAGS_) ${DEFINES} -UKERNEL \
		-header bsd_1.h \
		-user serv/bsd_1_user.c \
		-server /dev/null \
		${serv/bsd_1.defs:P}

bsd_1_user.o: serv/bsd_1_user.c
	$(_CC_) $(_CCFLAGS_) -Iserv -c -o bsd_1_user.o ${serv/bsd_1_user.c:P}

SIG_FILES = signal_server.h serv/signal_server.c

$(SIG_FILES): bsd_types_gen.h serv/signal.defs
	-$(MAKE_SERV)
	${_MIG_} $(_MIGFLAGS_) ${DEFINES} -UKERNEL \
		-sheader signal_server.h \
		-user /dev/null \
		-server serv/signal_server.c \
		${serv/signal.defs:P}

signal_server.o: serv/signal_server.c
	$(_CC_) $(_CCFLAGS_) -c -o signal_server.o ${serv/signal_server.c:P}

#
# We have to tell Mig to generate a header file, even though we don't really
# want it, because the user file includes the header file from the current
# directory.
#

mach_user.c: mach/mach.defs
	${_MIG_} $(_MIGFLAGS_) -DEMULATOR \
		-header mach_interface.h \
		-user mach_user.c \
		-server /dev/null \
		${mach/mach.defs:P}

# Generate a special version of task_suspend
emul_mach_user.c: emul_mach.defs
	${_MIG_} ${_MIGFLAGS_} \
		-header emul_mach_interface.h \
		-user emul_mach_user.c \
		-server /dev/null \
		${emul_mach.defs:P}

#
# bsd_types_gen.h is generated once, by LITES's export-pass
# configuration step, the way OSFMK 7.3 makes assym, and published to
# ${EXPORTBASE}/lites/server/. This directory used to build its own copy
# by running a host program, as UX 28's emulator did.
#
HOST_CFLAGS		= ${DEFINES}
HOST_LDFLAGS		= ${LDFLAGS}

emulator_base_CCTYPE	= host
xxx_emulator_base.o_CCTYPE	= host
emulator_base_OFILES	= xxx_emulator_base.o
emulator_base_LIBS	= 

# even though we preprocess emulator_base with the target cpp,
# to get appropriate predefines, we need to define ${TARGET_MACHINE},
# because it isn't always predefined.

# The -P switch is supposed to eliminate the #line and #define directives
# from the cpp output.

xxx_emulator_base.c: emulator_base.c
	${ansi_CPP} -P ${_CCFLAGS_} -D${TARGET_MACHINE} -DTARGET_${target_cpu} ${emulator_base.c:P} > xxx_emulator_base.c
	cat /dev/null >> emulator_base.d
	sed 's/emulator_base\.o/xxx_emulator_base.c/' \
			emulator_base.d > xxx_emulator_base.c.d
	${RM} emulator_base.d

emulator_base: xxx_emulator_base.c
	( LPATH="${_host_LPATH_}"; export LPATH; \
	${HOST_CC} ${_host_FLAGS_} -o emulator_base.out xxx_emulator_base.c)
	${MV} emulator_base.out emulator_base

# The dependencies md collected (MDINCFLAGS above); every ODE component
# includes them this way, and LITES never did (Q9).
.if exists(depend.mk)
.include "depend.mk"
.endif
