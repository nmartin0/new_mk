#
# Mach Operating System
# Copyright (c) 1992,1991,1990,1989 Carnegie Mellon University
# All Rights Reserved.
# 
# Permission to use, copy, modify and distribute this software and its
# documentation is hereby granted, provided that both the copyright
# notice and this permission notice appear in all copies of the
# software, derivative works or modified versions, and any portions
# thereof, and that both notices appear in supporting documentation.
# 
# CARNEGIE MELLON ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS"
# CONDITION.  CARNEGIE MELLON DISCLAIMS ANY LIABILITY OF ANY KIND FOR
# ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
# 
# Carnegie Mellon requests users of this software to return to
# 
#  Software Distribution Coordinator  or  Software.Distribution@CS.CMU.EDU
#  School of Computer Science
#  Carnegie Mellon University
#  Pittsburgh PA 15213-3890
# 
# any improvements or extensions that they make and grant Carnegie Mellon
# the rights to redistribute these changes.
#
#
# HISTORY
# $Log: Makefile,v $
# Revision 1.1.1.1  1995/03/02  21:49:41  mike
# Initial Lites release from hut.fi
#
# $EndLog$
# 
#	File:	conf/Makefile
#	Author:	Mary Thompson
#	Date:	1992
#

MASTER		= MASTER
target_cpu	?= ${MACHINE}
MASTER_TM	= ${target_cpu}/MASTER
MASTER_LOCAL	= MASTER.local
MASTER_TM_LOCAL	= ${target_cpu}/MASTER.local

LITES_CONFIG	?= STD+WS+osfmach3+ext2fs
CONFIG		?=${LITES_${TARGET_MACHINE}_CONFIG:U${LITES_CONFIG:UDEFAULT}}

.if defined (PROFILING)
_CONFIG_	= ${CONFIG:S/+gprof//}+gprof
.else
_CONFIG_	= ${CONFIG}
.endif

LITES_TOP	= ${MAKETOP}mach_services/servers/lites/
.if exists( ${LITES_TOP}Makefile-version)
.include "${LITES_TOP}Makefile-version"
.endif
VMUNIX		= startup.${VERSION}.${_CONFIG_}
OTHERS		= ../${_CONFIG_}/Makefile

#
# LITES's configuration, run in ODE's export pass (FIRST) so that
# everything built after it -- liblites in the SECOND pass, the server
# and the emulator in COMPILE -- can use what it produces: the option
# headers and the configured compiler flags (Makevar). The GNU route's
# configure runs this same step before anything compiles, and compiles
# everything with -I../server; here the results are published to
# ${EXPORTBASE}/lites/server/ instead, which is how OSF's tree shares
# what one component generates, and is what Helander's own template.mk
# describes as "the EXPORTBASE/server directory [that] contains the
# include files".
#
# It uses the maintained configuration -- conf/MASTER, conf/files and
# conf/doconfig.sh, from the GNU layer, read and not modified (D28) --
# not this directory's own MASTER and files, which are Helander's
# 1994-95 versions: they have no osfmach3 option and none of the ext2fs
# sources, so they cannot describe the configuration that boots.
#
# Hooked on EXPINC_TARGETS, as libpthreads hooks its host-generated
# pthread_impl.h onto the export pass. The single bsd_types_gen.h will
# be made here as well, once the two generated headers its compilation
# needs -- vnode_if.h and sys/syscall.h -- are.
#
VPATH		= ${LITES_TOP}
EXPINC_TARGETS	= lites_configured
LITES_MASTER	= conf/${target_cpu}/MASTER
LITES_SERVER_EXPDIR = ${EXPORTBASE}/lites/server
ansi_CPP	?= ${ANSI_CC} -E
INCFLAGS	= -I${LITES_TOP}server
INCDIRS		:= -I. -I${EXPORTBASE}/lites ${INCDIRS}

.include <${RULES_MK}>

lites_configured: ${LITES_MASTER} conf/MASTER conf/files conf/${target_cpu}/files
	# -x c: gcc -E, unlike a standalone cpp, takes a file named MASTER
	# for linker input and preprocesses nothing. The check after
	# Doopt.sh makes that failure, or any like it, stop here.
	@echo "[ configuring LITES ${CONFIG} from ${LITES_MASTER} ]"
	top=${${LITES_MASTER}:P:H:H:H}; \
	${ansi_CPP} -x c -P -undef -nostdinc -I$$top -DCONFIG=${CONFIG} \
	    ${${LITES_MASTER}:P} | \
	    /bin/sh $$top/conf/doconfig.sh $$top/conf/move-if-change && \
	/bin/sh Doopt.sh
	@set -- *.h; [ -f "$$1" ] || { \
	    echo "LITES configuration produced no option headers" >&2; exit 1; }
	${MAKEPATH} ${LITES_SERVER_EXPDIR}/.
	${CP} *.h Makevar ${LITES_SERVER_EXPDIR}/
	touch ${.TARGET}


${_CONFIG_}:	${MASTER} ${MASTER_TM} \
		${MASTER_LOCAL} ${MASTER_TM_LOCAL} 
	@echo "[ generating ${.TARGET} from {,${target_cpu}/}MASTER{,.local} ]"
	@doconf="`wh -q doconf`"; \
	echo "${.TARGET}: $${doconf}" >> ${.TARGET}.d; \
	$${doconf} ${_CONFIG_}\
		${${MASTER}:P}\
		${${MASTER_TM}:P}\
		${${MASTER_LOCAL}:P}\
		${${MASTER_TM_LOCAL}:P} >${_CONFIG_}.tmp
	@-if [ -s ${_CONFIG_}.tmp ]; then \
	    if [ -f ${_CONFIG_} ]; then \
		diff ${_CONFIG_} ${_CONFIG_}.tmp; \
		mv ${_CONFIG_} ${_CONFIG_}.old; \
	    fi; \
	    mv ${_CONFIG_}.tmp ${_CONFIG_}; \
	else \
	    ${RM} -f ${_CONFIG_}.tmp; \
	fi

../${_CONFIG_}/Makefile:	${_CONFIG_} \
			files \
			${target_cpu}/files \
			template.mk \
			${target_cpu}/template.mk 
	@echo "[ configuring ${_CONFIG_} ]"
	@-if [ -d ../${_CONFIG_} ]; then true; else mkdir ../${_CONFIG_}; fi
	@config="`wh -q config`"; \
	echo "${.TARGET}: $${config}" >> ${.TARGET}.d; \
	$${config} `genpath -I.` -c . ${_CONFIG_}
	@${RM} -f ../${_CONFIG_}/Makefile
	@ln -s Makefile.internal ../${_CONFIG_}/Makefile
	@echo ${_CONFIG_} >../${_CONFIG_}/vers.config
	@${RM} -f ../${_CONFIG_}/${VMUNIX}


