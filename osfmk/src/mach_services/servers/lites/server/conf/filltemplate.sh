#!/bin/sh
#
# filltemplate.sh -- make a configured server Makefile from template.mk
#
#   filltemplate.sh FILELIST SERVERDIR TEMPLATE MACHTEMPLATE GENDIR OUTDIR
#
# Does the job OSF's config program does for the kernel, and did for
# Helander's LITES: replaces template.mk's markers with the
# configuration's definitions. It reads the MAINTAINED configuration
# -- the Filelist that conf/doconfig.sh writes from conf/MASTER and
# conf/files -- rather than config's input, server/conf/files, which
# is Helander's 1994-95 list and cannot describe the configuration that
# boots (no osfmach3, no ext2fs).
#
# The markers are filled in config's own layout, as in the kernel's
# generated Makefiles:
#
#   %OBJS     OBJS=   every object: the C objects, then the assembler
#                     objects, each sorted -- the GNU route's order,
#                     since conf/Makerules builds its list with $(sort)
#                     "to eliminate duplicate files", and the same
#                     objects linked in another order give a different
#                     server
#   %CFILES   COBJS=  the C objects, then one x.o_SOURCE=path per object
#   %CFLAGS   (empty; the maintained list carries no per-file flags)
#   %SFILES   SOBJS=  the assembler objects, then their _SOURCE lines
#   %BFILES   BOBJS=
#   %ORDERED  ORDERED=
#   %MACHDEP  the machine template, inlined
#
# A Filelist entry may be listed twice (i386/second_syscalls.s is);
# it is linked once, as the GNU route's $(sort) links it once.
#
# An entry with no file under SERVERDIR is a generated source --
# kern/init_sysent.c, kern/syscalls.c, vnode_if.c -- made by LITES's
# export-pass configuration step. It is copied from GENDIR (or GENDIR's
# syscalls/ subdirectory) into OUTDIR and compiled from there, as the
# GNU route copies init_sysent.c and syscalls.c into its build. If it
# cannot be found, this stops: a missing source must not become a
# silently missing object.
#
# The configured Makefile is written to standard output.

set -eu

FILELIST=$1 SERVERDIR=$2 TEMPLATE=$3 MACHTEMPLATE=$4 GENDIR=$5 OUTDIR=$6

die() { echo "filltemplate: $*" >&2; exit 1; }
[ -r "$FILELIST" ] || die "no Filelist: $FILELIST"
[ -d "$SERVERDIR" ] || die "no server source directory: $SERVERDIR"
[ -r "$TEMPLATE" ] || die "no template: $TEMPLATE"

# The sources, in order, first occurrence only, without a leading "./".
# Words, not lines: doconfig.sh passes one comment-prefixed entry
# through whole -- "/* Notify handler */ fileif lites
# serv/notify_interface.c" -- and, like the GNU route's
# $(filter %.c,...), only the words that name a source are kept.
sources=$(grep -v '^#' "$FILELIST" | tr -s ' \t\\' '\n\n\n' |
          grep -E '\.[cs]$' | sed 's|^\./||' | awk '!seen[$0]++')
[ -n "$sources" ] || die "no sources in $FILELIST"

defs=$(mktemp)
trap 'rm -f "$defs" "$defs".*' EXIT
: > "$defs.c"; : > "$defs.s"; : > "$defs.cs"; : > "$defs.ss"; : > "$defs.all"
for src in $sources; do
    obj=$(basename "$src" | sed 's/\.[cs]$/.o/')
    if [ -f "$SERVERDIR/$src" ]; then
        path=$src
    else
        base=$(basename "$src")
        if [ -f "$GENDIR/$base" ]; then from=$GENDIR/$base
        elif [ -f "$GENDIR/syscalls/$base" ]; then from=$GENDIR/syscalls/$base
        else die "$src is neither in $SERVERDIR nor generated in $GENDIR"
        fi
        cp "$from" "$OUTDIR/$base"
        path=$base
    fi
    echo "$obj" >> "$defs.all"
    case $src in
    *.c) echo "$obj" >> "$defs.c"; echo "$obj""_SOURCE=$path" >> "$defs.cs" ;;
    *.s) echo "$obj" >> "$defs.s"; echo "$obj""_SOURCE=$path" >> "$defs.ss" ;;
    esac
done

# Byte order, as GNU make's $(sort) sorts; -u removes duplicates.
for k in c s cs ss; do LC_ALL=C sort -u -o "$defs.$k" "$defs.$k"; done
cat "$defs.c" "$defs.s" > "$defs.all"

list() { awk -v v="$1" 'BEGIN{printf "%s=", v} {printf " \\\n\t%s", $0} END{print ""}' "$2"; }

{
    list OBJS "$defs.all"
} > "$defs.OBJS"
{
    list COBJS "$defs.c"; echo; cat "$defs.cs"
} > "$defs.CFILES"
{
    list SOBJS "$defs.s"; echo; cat "$defs.ss"
} > "$defs.SFILES"

awk -v objs="$defs.OBJS" -v cfiles="$defs.CFILES" -v sfiles="$defs.SFILES" \
    -v machdep="$MACHTEMPLATE" '
function emit(f,   l) { while ((getline l < f) > 0) print l; close(f) }
/^%OBJS$/    { emit(objs); next }
/^%CFILES$/  { emit(cfiles); next }
/^%CFLAGS$/  { next }
/^%SFILES$/  { emit(sfiles); next }
/^%BFILES$/  { print "BOBJS="; next }
/^%ORDERED$/ { print "ORDERED="; next }
/^%MACHDEP$/ { emit(machdep); next }
/^%/         { print "filltemplate: unknown marker " $0 > "/dev/stderr"; exit 1 }
{ print }
' "$TEMPLATE"
