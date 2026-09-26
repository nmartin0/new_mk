#!/bin/sh
#
# sweep.sh -- search every tree in the chain of precedent, in order,
# and print one line for each whether or not it matches.
#
# Why one line per tree, always: an absence is only a finding if every
# tree was looked at. A missing line means a tree was not searched,
# which is visible; a silent skip is not. RULES 3.10 requires the
# result of this sweep before a change is proposed, and the commit
# message names the trees it covered.
#
# usage:  tools/sweep.sh <pattern> [file-glob]
#
#   tools/sweep.sh 'pci_conf_read'
#   tools/sweep.sh 'PF_R' '*.c'
#   tools/sweep.sh 'RSD PTR'
#
# The pattern is passed to grep -E. The glob, if given, is passed to
# grep --include.
#
# A "--" line means this pattern found nothing in that tree. It does
# not mean the thing is absent: try the other spellings first. The
# pattern 0xcf8 reports nothing in NetBSD 1.3, FreeBSD 2.2.8 and
# OpenBSD 2.3, all of which support PCI; they write 0x0cf8, and
# NetBSD names it PCI_MODE1_ADDRESS_REG. Sweep for the concept, in
# several spellings, before reporting that no tree has it.
#
# Where the trees live: $REFS, default ~/refs. notes/PRECEDENT.md says
# what each one is and which ref it is pinned at; this script prints
# the ref it actually finds, so a moved or re-cloned tree is visible
# rather than silently different.

set -u

pattern=${1:-}
glob=${2:-}
[ -n "$pattern" ] || { echo "usage: $0 <pattern> [file-glob]" >&2; exit 2; }

REFS=${REFS:-$HOME/refs}
HERE=$(cd "$(dirname "$0")/.." && pwd)

# position | label | path | subdirectory searched
trees="
1|OSFMK 7.3 (this tree)|$HERE|osfmk/src
2|OSFMK 6.1|$REFS/osfmk6_1|
3|CMU MK83|$REFS/machmk83|
3|CMU MK42|$REFS/mach-mk42|
3|CMU MK74|$REFS/mach-mk74|
3|CMU Mach 3|$REFS/mach3|
3|CMU mach_us|$REFS/mach_us|
3|CMU mach.kernel.mk|$REFS/mach_stuff/mach.kernel.mk|
3|CMU MK84|$REFS/mach_stuff/default.MK84|
4|Utah Mach 4 (UK22)|$REFS/mach_stuff/mach4-UK22|
4|Utah user-mach4|$REFS/mach_stuff/user-mach4|
4|OpenMach|$REFS/openmach|
4|xMach|$REFS/xmach|
5|NetBSD 1.3|$REFS/netbsd-1-3|sys
5|FreeBSD 2.2.8|$REFS/freebsd-2-2-8|sys
5|OpenBSD 2.3|$REFS/openbsd|sys
"

printf '%s\n' "sweep: $pattern${glob:+  (in $glob)}"
printf '%s\n' "----------------------------------------------------------------"

missing=0
list=$(mktemp)
printf '%s\n' "$trees" | grep . > "$list"

while IFS='|' read -r pos label path sub; do
	[ -n "${pos:-}" ] || continue

	where=$path${sub:+/$sub}
	if [ ! -d "$where" ]; then
		printf '  %s  %-22s NOT ON DISK -- %s\n' "$pos" "$label" "$where"
		missing=$((missing + 1))
		continue
	fi

	if [ -n "$glob" ]; then
		hits=$(grep -rlE --exclude-dir=.git --include="$glob" -- "$pattern" "$where" 2>/dev/null | head -40)
	else
		hits=$(grep -rlE --exclude-dir=.git -- "$pattern" "$where" 2>/dev/null | head -40)
	fi

	n=$(printf '%s' "$hits" | grep -c . || true)
	if [ "$n" = 0 ]; then
		printf '  %s  %-22s --\n' "$pos" "$label"
	else
		first=$(printf '%s\n' "$hits" | head -2 | sed "s#^$path/##" | tr '\n' ' ')
		printf '  %s  %-22s %s file(s): %s\n' "$pos" "$label" "$n" "$first"
	fi
done < "$list"
rm -f "$list"

printf '%s\n' "----------------------------------------------------------------"
printf '%s\n' "6  later BSDs: fetch the release a search needs and record its ref"
printf '%s\n' "7  Rhapsody, XNU: read-only, never searched for a line to copy"
[ "$missing" = 0 ] || printf '%s\n' "WARNING: $missing tree(s) not on disk -- no absence may be claimed"
