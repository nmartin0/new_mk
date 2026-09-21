# 
# Mach Operating System
# Copyright (c) 1992 Carnegie Mellon University
# Copyright (c) 1994 Johannes Helander
# All Rights Reserved.
# 
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright
# notice and this permission notice appear in all copies of the
# software, derivative works or modified versions, and any portions
# thereof, and that both notices appear in supporting documentation.
# 
# CARNEGIE MELLON AND JOHANNES HELANDER ALLOW FREE USE OF THIS
# SOFTWARE IN ITS "AS IS" CONDITION.  CARNEGIE MELLON AND JOHANNES
# HELANDER DISCLAIM ANY LIABILITY OF ANY KIND FOR ANY DAMAGES
# WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
#
# HISTORY
# $Log: template.mk,v $
# Revision 1.1.1.1  1995/03/02  21:49:41  mike
# Initial Lites release from hut.fi
#
# $EndLog$
#
#	File:	 conf/template.mk
#	Authors: Mary Thompson, Johannes Helander
#	Date:	 1992, 1994
#


# ${EXPORTBASE}/lites has the machine link.
VPATH		= ..:${EXPORTBASE}/lites/server:${EXPORTBASE}/lites

# We want the LITES version & configuration to be part of this name.
# Makeconf defined LITES_CONFIG and
# Makefile-version defined VERSION.

LITES_CONFIG	?= STD+WS+osfmach3+ext2fs
CONFIG          ?=${LITES_${TARGET_MACHINE}_CONFIG:U${LITES_CONFIG:UDEFAULT}}

LITES_TOP	= ${MAKETOP}mach_services/servers/lites/
.if exists( ${LITES_TOP}Makefile-version)
.include "${LITES_TOP}Makefile-version"
.endif

# set BINARIES to get the osf.obj.mk rules included
BINARIES        =

# The server's name as LITES's own builds give it (D29), not vmunix.
VMUNIX          = startup.${VERSION}.${CONFIG}
OTHERS          = ${VMUNIX}

ILIST           = ${VMUNIX}
IDIR            = /special/

# We are going to use xstrip, so we don't want release to try to strip it again
NOSTRIP         =

DEPENDENCIES	=
SAVE_D		=
MIG_HDRS	= 

# directories that must be created in the object area
MKODIRS 	= serv/


#  Pre-processor environment.
#  config outputs a definition of IDENT.
#  LOCAL_DEFINES can be set by makeoptions in MASTER.local.
#  (eg. -DTIMEZONE=-120)
#  LINENO is (optionally) set from the config file
#  (VOLATILE should be defined as "-Dvolatile=" if your
#  compiler doesn't support volatile declarations.)

VOLATILE        ?=
#XX		= -DBSD=44 -DMACH_IPC_COMPAT=0
#
# -DMACH -DLITES: the GNU route adds them to every compile
# (conf/Makerules: DEFINES += -DMACH -DLITES). LITES's headers depend
# on them -- struct buf's b_reply_port and the kernel's errno values
# sit under #ifdef LITES -- and without them serv/block_io.c does not
# compile. -Ulinux: the GNU route's build script passed it because gnu89
# predefines linux=1, and LITES tests that name.
#
# -I- stays here, where Helander put it: this template sets
# _CC_GENINC_=-I., replacing the osf.osc.mk rule that adds -I- to every
# other compile, so DEFINES is the only place the server gets it.
# Without it GCC searches each source's own directory first, and
# ufs/ufs/ufs_inode.c's "quota.h" finds ufs/ufs/quota.h instead of the
# option header of that name.
#
DEFINES		= -nostdinc -I- -DMACH -DLITES -Ulinux ${MASTER_DEFINES} ${LOCAL_DEFINES} ${IDENT} -DKERNEL ${XX} $(VOLATILE)
#
# The line below should not be here; it overrides the external default.
# BUT ... ux is known not to build with -O2 ...
# Someday this should be fixed.
#CC_OPT_LEVEL	= -O
#
CC_OPT_EXTRA	?= ${LINENO}


# CFLAGS are for all normal files
# DRIVER_CFLAGS are for files marked as device-driver
# NPROFILING_CFLAGS are for files which support profile and thus
#       should not be compiled with the profiling flags

#
# The configured compiler flags, -DUNTYPED_IPC=1 among them, come from
# the Makevar that LITES's export-pass configuration step publishes, as
# the GNU route applies its conf/Makevar to every compile.
#
.if exists(${EXPORTBASE}/lites/server/Makevar)
.include "${EXPORTBASE}/lites/server/Makevar"
.endif
CFLAGS		= ${DEFINES} ${TARGET_CFLAGS} ${PROFILING:D-pg -DGPROF}
DRIVER_CFLAGS	=${CFLAGS}
NPROFILING_CFLAGS=${DEFINES} -DGPROF

#INCFLAGS are procesed by genpath and expanded relative to all the 
# sourcedirs, INCDIRS is not expanded.

INCFLAGS	= -I.. -I../../include

# The EXPORTBASE/server directory contains the include files
# in machine

INCDIRS         := -I. -I${EXPORTBASE}/lites/server -I${EXPORTBASE}/lites ${INCDIRS}

target_cpu	?= ${MACHINE}
.if (${target_cpu} == "mips" || ${target_cpu} == "i386" || ${target_cpu} == "ns532")
USE_LIBPROF = ${LIBPROF1}
.else
USE_LIBPROF =
.endif 

.if 	defined(PROFILING)
LIBS		= ${USE_LIBPROF} ${LIBMACHID} ${LIBNETNAME} ${LIBTHREADS_P} ${LIBMACH_SA_P}
.else
LIBS		= ${LIBMACHID} ${LIBNETNAME} ${LIBTHREADS} ${LIBMACH_SA}
.endif

#
#  LDOBJS is the set of object files which comprise the server.
#  LDOBJS_PREFIX and LDOBJS_SUFFIX are defined in the machine
#  dependent Makefile (if necessary).
#
LDOBJS=${LDOBJS_PREFIX} ${OBJS} ${LDOBJS_SUFFIX}

#
#  LDDEPS is the set of extra dependencies associated with
#  loading the server
#
#  LDDEPS_PREFIX is defined in the machine 
#  dependent Makefile (if necessary).
#

LDDEPS=${LDDEPS_PREFIX} 

#
#  PRELDDEPS is another set of extra dependencies associated with
#  loading the server.
#  It is defined in the machine dependent Makefile (if necessary).
#

#
#  These macros are filled in by the config program depending on the
#  current configuration.  The MACHDEP macro is replaced by the
#  contents of the machine dependent makefile template and the others
#  are replaced by the corresponding symbol definitions for the
#  configuration.
#

%OBJS

%CFILES

%CFLAGS

%SFILES

%BFILES

%ORDERED

#  All macro definitions should be before this point,
#  so that the machine dependent fragment can redefine the macros.
#  All rules (that use macros) should be after this point,
#  so that they pick up any redefined macro values.

%MACHDEP

ansi_CPP	?= ${ANSI_CC} -E
.include <${RULES_MK}>

_CC_GENINC_=-I.

.PRECIOUS: Makefile

# Make all the directories in the object directory

.BEGIN:
	-makepath ${MKODIRS}

UX_LDFLAGS	?= ${${TARGET_MACHINE}_LDFLAGS:U${LDFLAGS}}

NEWVERS_DEPS = \
	../../conf/newvers.sh \
	../../conf/copyright



# The libraries SERVER_LIBS links, as files, so that relinking follows
# them: -l names them only to the linker, and without this a rebuilt
# liblites left the server linked against the old one (L47). Defined
# here, above the rule, because make expands a rule's prerequisites
# when it reads the rule.
SERVER_LIBDEPS	= ${EXPORTBASE}/lib/liblites.a ${EXPORTBASE}/lib/libcthreads.a \
	${EXPORTBASE}/lib/libmach_sa.a ${EXPORTBASE}/lib/libsa_mach.a

${VMUNIX} : ${PRELDDEPS} ${LDOBJS} ${LDDEPS} ${SERVER_LIBDEPS} \
		${CC_DEPS_NORMAL} ${NEWVERS_DEPS} LINKSERVER

# The relink rule allows you to relink the server without checking
#  all the dependencies. 

relink: ${VMUNIX}.relink

${VMUNIX}.relink: ${LDDEPS} ${NEWVERS_DEPS} LINKSERVER

#  We create vers.c/vers.o right here so that the timestamp in vers.o
#  always reflects the time that the vmunix binary is actually created.
#  We link the vmunix binary to "vmunix" so that there is a short name
#  for the most recently created binary in the object directory.

#Need to use MONCRT0 instead of CRT0 when the libraries are profiled.

#.if 	defined(PROFILING)
#CRT 	= ${MONCRT0}
#.else
#
# The link is the GNU route's own command, keeping Helander's shape
# around it. Each flag is one the GNU route's build script,
# tools/lites/build-lites.sh (retired; see its history), documented:
#
#   -m elf_i386        a 32-bit link on a 64-bit host's ld
#   -z muldefs         LITES defines its own printf, vsprintf, sprintf
#   --defsym __start=__start_mach
#                      LITES links -e __start (${TARGET_LDFLAGS}, from
#                      Makevar); this crt0 defines __start_mach, and
#                      without the alias the server dies before crt0
#                      runs
#   crt0.o             OSFMK keeps it inside libsa_mach.a, not as a
#                      standalone file, so it is extracted here
#   the libraries      liblites; cthreads (the GNU route's -lthreads);
#                      mach_sa and sa_mach, which reference each other
#
# crt0.o and vers.o come before the objects, as in the GNU link. size
# and strip are the host's, as the GNU route uses them: XSTRIP and
# SIZE, which the vendor rule used, are defined nowhere in this tree's
# makedefs, and ${XSTRIP} ${VMUNIX}.out would have run the server's
# own name as a command. The copy to ${EXPORTBASE}/special/ goes: no
# OSF component copies a program into the export tree, and binaries
# stay in the object tree (D29).
#
SERVER_LDFLAGS	= -m elf_i386 -z muldefs --defsym __start=__start_mach
SERVER_LIBS	= -L${EXPORTBASE}/lib -llites -lcthreads -lmach_sa -lsa_mach -lmach_sa
#.endif

LINKSERVER: .USE
	@echo "creating vers.o"
	@${RM} ${_RMFLAGS_} vers.c vers.o
	@# The maintained conf/newvers.sh, from LITES's top -- ../../conf/,
	@# since ODE resolves a relative name against this directory's source
	@# counterpart, server/<config>, as Helander's emulator Makefile
	@# reaches ../server/kern/ -- with the GNU route's arguments. Not
	@# server/conf/newvers.sh: Helander's own script, which takes other
	@# arguments and writes a version string the port's compiler rejects.
	@sh ${../../conf/newvers.sh:P} ${../../conf/copyright:P} Lites ${VERSION} ${CONFIG}
	@${_CC_} -c ${_CCFLAGS_} vers.c
	@${RM} -f ${VMUNIX} ${VMUNIX}.out ${VMUNIX}.unstripped crt0.o
	@echo "loading ${VMUNIX}"
	ar x ${EXPORTBASE}/lib/libsa_mach.a crt0.o
	ld -o ${VMUNIX}.out ${SERVER_LDFLAGS} ${TARGET_LDFLAGS} \
		crt0.o vers.o ${LDOBJS} ${SERVER_LIBS} && \
		${MV} ${VMUNIX}.out ${VMUNIX}.unstripped
	-size ${VMUNIX}.unstripped
	${CP} ${VMUNIX}.unstripped ${VMUNIX}.out
	strip ${VMUNIX}.out && ${MV} ${VMUNIX}.out ${VMUNIX}
	@${RM} -f vmunix
	ln ${VMUNIX} vmunix


#
#  OBJSDEPS is the set of files (defined in the machine dependent
#  template if necessary) which all objects depend on (such as an
#  in-line assembler expansion filter
#

${OBJS}: ${OBJSDEPS}

# Use the standard rules with slightly non-standard .IMPSRC

#
# Each object's source is named by its x.o_SOURCE line, which
# filltemplate.sh writes as config does. OSF's rules compile from it
# only through a recipe; the dependency alone lets make's .c.o rule
# find a source of the same name, which here means only the generated
# files copied into this directory. So the C objects get the kernel
# template's recipe (mach_kernel/conf/template.mk), with ODE's ${_CC_}
# for the kernel's ${KCC}; the assembler objects get the tree's own
# assembler rule, libmach's -- copy to .S so the compiler preprocesses
# it, then compile with -DASSEMBLER -- finding their source the same
# way.
#
${COBJS}: $${$${.TARGET}_SOURCE}
	${_CC_} -c ${_CCFLAGS_} ${${${.TARGET}_SOURCE}:P}

${SOBJS}: $${$${.TARGET}_SOURCE}
	${RM} ${_RMFLAGS_} ${.TARGET:.o=.S}
	${CP} ${${${.TARGET}_SOURCE}:P} ${.TARGET:.o=.S}
	${_CC_} -DASSEMBLER ${_CCFLAGS_} -c ${.TARGET:.o=.S}

${BOBJS}: $${$${.TARGET}_SOURCE}

#
#  Rules for components which are not part of the kernel proper or that
#  need to be built in a special manner.
#


#  The Mig-generated files go into subdirectories.
#  This target makes sure they exist

.BEGIN : 
	-makepath ${MKODIRS}


#
#  Mach IPC-based interfaces
#

#  Explicit dependencies on generated files,
#  to ensure that Mig has been run by the time
#  these files are compiled.

bsd_server.o: bsd_1_server.c bsd_types_gen.h 

bsd_server_side.o: bsd_types_gen.h bsd_1_server.h
# serv_syscalls.c includes bsd_1_server.h as well. Undeclared, make
# could compile it before MIG had written that header -- the failure
# the GNU route answers by running make twice. Declared, one pass does.
serv_syscalls.o: bsd_1_server.h

BSD_1_FILES = bsd_1_server.c

serv/bsd_server_side.o : bsd_1.server.h

$(BSD_1_FILES) bsd_1_server.h: bsd_types_gen.h serv/bsd_1.defs
	 ${_MIG_} $(_MIGFLAGS_) ${DEFINES} -UKERNEL \
		-header /dev/null \
		-user /dev/null \
		-server bsd_1_server.c \
		-sheader bsd_1_server.h \
		 ${serv/bsd_1.defs:P}

SIG_FILES = signal_user.h
# serv/signal_user.c

sendsig.o : signal_user.h

# The C file is patched by hand as I wasn't able to figure out how to
# get MiG to produce the correct code.
$(SIG_FILES): bsd_types_gen.h serv/signal.defs
	${_MIG_} $(_MIGFLAGS_) ${DEFINES} -UKERNEL \
		-header signal_user.h \
		-user /dev/null \
		-server /dev/null \
		${serv/signal.defs:P}

# Make syscall.h before any objects
# The kern/* deps are here so that makesyscalls is executed only once.
${OBJS} kern/init_sysent.c kern/syscalls.c : sys/syscall.h
${OBJS} ${BSD_1_FILES} ${SIG_FILES} : bsd_types_gen.h
${OBJS} : vnode_if.h

#
# vnode_if.h, sys/syscall.h and bsd_types_gen.h are generated once, by
# LITES's export-pass configuration step, and published to
# ${EXPORTBASE}/lites/server/ and ${EXPORTBASE}/lites/sys/; the
# generated sources kern/init_sysent.c, kern/syscalls.c and vnode_if.c
# are copied into this directory by filltemplate.sh. This template used
# to generate all of them itself: makesyscalls.sh a second time,
# vnode_if.sh with gawk, and bsd_types_gen by running a host program.
#




ALWAYS:


printenv:
	@echo VPATH=${VPATH}
	@echo INCDIRS=${INCDIRS}

