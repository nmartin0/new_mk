#!/bin/bash
# check-deps.sh -- does editing a header rebuild exactly its dependents? (Q9)
#
# Usage, after a full build (notes/ENVIRONMENT.md, Quick start):
#
#   bash tools/check-deps.sh COMPONENT HEADER NAME [ode.sh args...]
#
#   COMPONENT  the directory ode.sh builds, relative to osfmk/src
#              (mach_kernel, mach_services/servers/lites, ...)
#   HEADER     the header to touch, relative to osfmk/src
#   NAME       the header as md records it in depend.mk -- relative to the
#              include directory it was found through (sys/tty.h,
#              device/tty.h)
#
# for example:
#
#   bash tools/check-deps.sh mach_kernel mach_kernel/device/tty.h device/tty.h \
#       MACH_KERNEL_CONFIG=PRODUCTION
#   bash tools/check-deps.sh mach_services/servers/lites \
#       mach_services/servers/lites/include/sys/tty.h sys/tty.h
#
# It builds twice so that nothing is stale, noting any objects that
# the second build recompiles all the same (ODE's library rules delete archived objects, so
# some always do); touches HEADER; rebuilds; and compares the objects
# recompiled with those the component's depend.mk files list for NAME,
# plus the always-rebuilt ones. Exit status 0 when they match exactly.
# The header's contents are not changed, only its time stamp.

[ $# -ge 3 ] || { sed -n '4,22p' "$0"; exit 2; }
comp=$1 hdr=$2 name=$3; shift 3
cd "$(dirname "$0")/.." || exit 2
: "${ODE4LINUX:?set ODE4LINUX}" "${MK_BUILD:?set MK_BUILD}"
obj=$MK_BUILD/obj/at386/$comp
[ -f "osfmk/src/$hdr" ] || { echo "check-deps: no such header: osfmk/src/$hdr"; exit 2; }

compiled() {	# the objects a build log shows compiled
	grep -E ' -c ' "$1" | grep -oE '[A-Za-z0-9_+-]+\.[cs]( |$)' |
		sed 's/\.[cs] *$/.o/' | sort -u
}

log=$(mktemp -d)
# Twice: the first brings everything up to date, and whatever the second
# still compiles is what recompiles when nothing has changed.
for i in 1 2; do
	sh build/ode.sh -here "$comp" "$@" > "$log/settle" 2>&1 ||
		{ echo "check-deps: a settling build failed ($log/settle)"; exit 2; }
done
compiled "$log/settle" > "$log/always"
{ find "$obj" -name depend.mk -exec grep -hE "^[A-Za-z0-9_+.-]+\.o: ${name//./\\.}\$" {} + |
	cut -d: -f1; cat "$log/always"; } | grep . | sort -u > "$log/expect"

touch "osfmk/src/$hdr"; sleep 1
sh build/ode.sh -here "$comp" "$@" > "$log/build" 2>&1 ||
	{ echo "check-deps: the build after touching failed ($log/build)"; exit 2; }
# vers.o is the version stamp, regenerated whenever a program relinks.
compiled "$log/build" | grep -vx vers.o > "$log/got"

missed=$(comm -23 "$log/expect" "$log/got")
extra=$(comm -13 "$log/expect" "$log/got")
echo "check-deps: $name: depend.mk lists $(grep -c . "$log/expect") objects" \
	"($(grep -c . "$log/always") rebuilt every time); recompiled" \
	"$(grep -c . "$log/got"); missed $(echo -n "$missed" | grep -c .);" \
	"extra $(echo -n "$extra" | grep -c .)"
[ -n "$missed" ] && echo "$missed" | head -10 | sed 's/^/  missed: /'
[ -n "$extra" ] && echo "$extra" | head -10 | sed 's/^/  extra:  /'
rm -rf "$log"
[ -z "$missed" ] && [ -z "$extra" ]
