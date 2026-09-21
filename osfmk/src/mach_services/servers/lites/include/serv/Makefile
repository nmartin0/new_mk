# 
# Mach Operating System
# Copyright (c) 1993,1992 Carnegie Mellon University
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
# Revision 1.1.1.1  1995/03/02  21:49:37  mike
# Initial Lites release from hut.fi
#
# Revision 2.4  93/08/10  18:22:21  mrt
# 	Added dependencies on bsd_types_gen.h for proxy_socket.h
# 	and net_proxy.h
# 	[93/08/09            mrt]
# 
# Revision 2.3  93/08/07  16:49:34  mrt
# 	Exported files for proxy networking.
# 	[93/06/13            cmaeda]
# 
# Revision 2.2  93/02/16  15:56:04  mrt
# 	Updated for ODE make.
# 	[92/12/25            mrt]
# 

DEPENDENCIES	=

IDIR		= /include/serv/
EXPDIR		= /lites/serv/
LITES_TOP	= ${MAKETOP}mach_services/servers/lites/
VPATH		= ${LITES_TOP}server/serv
INCFLAGS	+= -I.. -I${LITES_TOP}server -I${LITES_TOP}
INCDIRS		:= -I${EXPORTBASE}/lites ${INCDIRS}

#
# This directory exports the interface's static files only. It used
# also to generate bsd_types_gen.h and, from it, a MIG header bsd_1.h
# to export -- one of three places the tree generated bsd_types_gen.h,
# with the server and the emulator each making their own as well, a
# pattern inherited from UX 28. The header is now generated once, in
# the server's configured build, which is the only place that has the
# configured option headers its compilation needs, and published from
# there; this is how OSF's own tree shares a generated header
# (mach_kernel/mach's MIG_HDRS; libpthreads's pthread_impl.h, made by
# a host program as this one is). Nothing in LITES used the exported
# bsd_1.h: the emulator's own MIG step writes one, as MIG always does.
#
INCLUDES	= bsd_types.h bsd_types.defs bsd_1.defs
ILIST		= ${INCLUDES}

.include <${RULES_MK}>
