#!/bin/sh
# ci-boot.sh -- boot the built system under QEMU and check it (R30).
#
# Usage, after a full build (notes/ENVIRONMENT.md, Quick start):
#
#   MK_BUILD=... MIRROR=file:///path/to/netbsd-1.0-i386/binary \
#       sh tools/ci-boot.sh
#
# Two boots, each check reported as one line:
#
#   ci-boot: PASS <check>
#   ci-boot: FAIL <check>: <reason>
#
# and the exit status is the number of failures. Boot A comes up
# multi-user with -i /init and runs the acceptance checks and the
# regression tests for the defects fixed so far; boot B starts without
# it and checks that the resulting panic says why (L49).
#
#   acceptance   login; a file written in the guest is read back from
#                the host; the documented halt ("none unwritten");
#                e2fsck finds the root clean; the emulator in the image
#                is the one just built
#   clock        the guest's date -u is within ten minutes of the
#                host's UTC (L48: it was once exactly a day behind)
#   foreign-exe  a NetBSD a.out executable for another machine is
#                refused as an unknown format (L47)
#   burst        60 lines typed as bursts all arrive intact (L43: one
#                in thirty once reordered a character)
#   panic-text   booted without -i /init, the panic names the missing
#                /mach_servers/mach_init (L49: panics printed nothing)
#
# The console logs are kept in $CI_LOGDIR (default /tmp/ci-boot) for a
# CI job to publish when something fails.

cd "$(dirname "$0")/.." || exit 99
: "${MK_BUILD:?set MK_BUILD, as for boot-ide.sh}"
: "${MIRROR:?set MIRROR, as for mkroot-netbsd.sh}"
export MK_BUILD MIRROR
LOGDIR=${CI_LOGDIR:-/tmp/ci-boot}
BOOT_TIMEOUT=${BOOT_TIMEOUT:-400}	# seconds to the login prompt; TCG is slow
BURSTS=${BURSTS:-60}
mkdir -p "$LOGDIR"
FAILS=0

pass() { echo "ci-boot: PASS $1"; }
fail() { echo "ci-boot: FAIL $1: $2"; FAILS=$((FAILS + 1)); }

stop_guest() {
	pkill -x qemu-system-i38 2>/dev/null
	for p in $(pgrep -f 'tools/console.py --attach'); do kill $p 2>/dev/null; done
	sleep 2
}

# boot LABEL [STARTUP_ARGS] -- a fresh root image, then boot it with the
# serial console on a socket and console.py recording /tmp/console.log.
boot() {
	stop_guest
	rm -f /tmp/root.img /tmp/console.log /tmp/serial.sock
	sh tools/mkroot-netbsd.sh > "$LOGDIR/$1-mkroot.log" 2>&1 ||
		{ fail "$1" "mkroot-netbsd.sh failed"; return 1; }
	if [ "$1" = boot-a ]; then
		# The foreign executable for L47: ZMAGIC, machine id 137
		# (ns32532), header only.
		python3 -c "import struct,sys; h=struct.pack('>I',(137<<16)|0o413)+bytes(28); sys.stdout.buffer.write(h+bytes(4096-len(h)))" > /tmp/ci-foreign
		debugfs -w -R 'write /tmp/ci-foreign /foreign' /tmp/root.img > /dev/null 2>&1
		debugfs -w -R 'sif /foreign mode 0100755' /tmp/root.img > /dev/null 2>&1
	fi
	CONSOLE=socket STARTUP_ARGS="$2" setsid nohup sh tools/boot-ide.sh \
		> "$LOGDIR/$1-boot.log" 2>&1 < /dev/null &
	sleep 4
	setsid nohup python3 tools/console.py --attach \
		> "$LOGDIR/$1-attach.log" 2>&1 < /dev/null &
	sleep 3
}

# wait_for PATTERN SECONDS -- poll the console log for a pattern.
wait_for() {
	t=0
	while [ $t -lt "$2" ]; do
		grep -q "$1" /tmp/console.log 2>/dev/null && return 0
		sleep 5; t=$((t + 5))
	done
	return 1
}

send() {	# send TEXT [WAITFOR]
	timeout 60 python3 tools/console.py ${2:+--wait-for "$2"} --send "$1" \
		> /dev/null 2>&1
}

# ---- boot A: multi-user ------------------------------------------------

boot boot-a '-i /init'
if ! wait_for 'login: ' "$BOOT_TIMEOUT"; then
	fail acceptance "no login prompt within ${BOOT_TIMEOUT}s"
	cp /tmp/console.log "$LOGDIR/boot-a-console.log" 2>/dev/null
	stop_guest
else
	send root
	# csh is root's shell; sh -c keeps the commands in sh's syntax.
	send "sh -c 'date -u; echo ci-verified > /verify.txt; sync; /foreign && echo FOREIGN-RAN || echo FOREIGN-REFUSED'; echo CI-MARK-1" '# '
	wait_for 'CI-MARK-1$' 60
	host_utc=$(date -u +%s)
	i=1
	while [ $i -le "$BURSTS" ]; do
		send "echo R$(printf '%02d' $i)-ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" '# '
		i=$((i + 1))
	done
	sleep 3
	send '/sbin/halt' '# '
	wait_for 'none unwritten' 60
	sleep 3
	stop_guest
	cp /tmp/console.log "$LOGDIR/boot-a-console.log"

	python3 - "$host_utc" "$BURSTS" > "$LOGDIR/boot-a-checks.txt" <<'PY'
import sys, re, calendar, time
host, n = int(sys.argv[1]), int(sys.argv[2])
log = open('/tmp/console.log', errors='replace').read().replace('\r', '')
# clock: the first "date -u" output after the command was sent
m = re.search(r'^\w{3} (\w{3}) +(\d+) (\d+):(\d+):(\d+) GMT (\d{4})$', log, re.M)
if not m:
    print('clock FAIL no date -u output')
else:
    mon = time.strptime(m.group(1), '%b').tm_mon
    g = calendar.timegm((int(m.group(6)), mon, int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5))))
    d = g - host
    print(f'clock {"PASS" if abs(d) < 600 else "FAIL"} guest-host = {d} s')
# foreign-exe
ok = 'Unknown binary format: /foreign' in log and 'FOREIGN-REFUSED' in log
print(f'foreign-exe {"PASS" if ok else "FAIL"} ' + ('refused as an unknown format' if ok else 'not refused'))
# burst: each output line exact, allowing only the shell's "# " prompt before it
bad = [i for i in range(1, n + 1)
       if not re.search(r'^(# )?' + re.escape(f'R{i:02d}-ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') + r'$', log, re.M)]
print(f'burst {"PASS" if not bad else "FAIL"} {n - len(bad)}/{n} intact' + (f'; wrong: {bad}' if bad else ''))
print(f'halt {"PASS" if "none unwritten" in log else "FAIL"}')
PY
	while read -r name verdict rest; do
		[ "$name" = halt ] && continue
		[ "$verdict" = PASS ] && pass "$name ($rest)" || fail "$name" "$rest"
	done < "$LOGDIR/boot-a-checks.txt"

	why=
	grep -q '^halt PASS' "$LOGDIR/boot-a-checks.txt" || why="no clean halt"
	[ -z "$why" ] && [ "$(debugfs -R 'cat /verify.txt' /tmp/root.img 2>/dev/null)" != ci-verified ] &&
		why="file written in the guest not read back"
	if [ -z "$why" ]; then
		e2fsck -fn /tmp/root.img > "$LOGDIR/e2fsck.log" 2>&1 || why="e2fsck exit status $?"
	fi
	if [ -z "$why" ]; then
		rm -f /tmp/ci-emulator
		debugfs -R 'dump /mach_servers/emulator /tmp/ci-emulator' /tmp/root.img > /dev/null 2>&1
		cmp -s /tmp/ci-emulator "$MK_BUILD/obj/at386/mach_services/servers/lites/emulator/emulator.Lites.1.1.u3" ||
			why="the emulator in the image is not the one built"
	fi
	[ -z "$why" ] && pass acceptance || fail acceptance "$why"
fi

# ---- boot B: no -i /init -----------------------------------------------

boot boot-b ''
if wait_for 'panic args: first program (/mach_servers/mach_init) exec failed' "$BOOT_TIMEOUT"; then
	pass "panic-text (names /mach_servers/mach_init)"
else
	if grep -q '^panic' /tmp/console.log 2>/dev/null; then
		fail panic-text "a panic, but not naming the missing mach_init"
	else
		fail panic-text "no panic within ${BOOT_TIMEOUT}s"
	fi
fi
stop_guest
cp /tmp/console.log "$LOGDIR/boot-b-console.log" 2>/dev/null

echo "ci-boot: $FAILS failure(s); logs in $LOGDIR"
exit $FAILS
