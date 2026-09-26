# Handoff

Read this first, then `RULES.md`, `WORKFLOW.md` and `PRECEDENT.md`.
Everything described here is committed and pushed; nothing is in
flight.

---

## What this branch is

`new_mach` carries the port forward under a chain of precedent that
ends in the modern BSDs, so that OSFMK 7.3 can be made to run on
current i386 hardware without inventing what someone has already
written.

Three branches sit behind it, none of them rewritten: `main` is the
vendor import, `junk` is the first effort, kept for reference, and
`dev` is the reviewed rebuild of that effort as far as it went.

How work is done here:

- Every source change is **proposed before it is written**, with the
  chain walked in order and the result reported including the empty
  rows (RULES 3.10, `notes/PRECEDENT.md`).
- The maintainer is the only one who commits and pushes. Patches
  arrive as a numbered series with a script that applies and verifies
  each one (RULES 6.8).
- Citations name the tree **and** the release.

## The chain, in one line each

1. OSFMK 7.3 itself, every port it carries. 2. OSFMK 6.1. 3. The CMU
Machs. 4. Utah Mach 4, OpenMach, xMach. 5. The contemporaries of 7.3:
NetBSD 1.3, FreeBSD 2.2.8, OpenBSD as of 1998-05-18. 6. Later BSDs in
historical order, stopping at the earliest release that has the thing.
7. Rhapsody and XNU, read-only: what and why, never a line. 8. Ours,
labelled, with the alternatives.

`notes/PRECEDENT.md` gives each tree's location and pinned commit.
`tools/sweep.sh` walks positions 1 to 5 and prints a line per tree.

## Where the work has got to

The tree builds itself and boots: the kernel initialises, probes its
devices, loads the bootstrap server through the rewritten ELF loader,
and the server runs and asks for its configuration file, which lives
on a boot disk that does not exist yet.

Landed so far: the layout and the methodology; LITES 1.1.u3 vendored
verbatim, 892 files; the vendor kernel compiling under a modern
toolchain; the bootstrap task and the ELF loaders; the IDE driver;
and `libmach_sa` with the build pointed at `osfmk/`.

## Next

Finish the rebuild to a system that reaches a login prompt -- the
LITES source fixes, then LITES under ODE, then the Stage 1 bugs and
the infrastructure. `junk` holds that work and is the reference for
it; each batch is re-derived under this chain rather than replayed.

After that, the hardware work, in this order, because each depends on
the one before:

  PCI      none is built for i386 today: a single busses/pci/pci.c,
           commented out in conf/AT386/files. Mechanism 1 first,
           ECAM after.
  ACPI     RSDP, RSDT, MADT, FADT, HPET, MCFG. No Mach tree and no
           contemporary BSD has any of it; later BSDs and ACPICA do.
  APIC/SMP driven by the MADT rather than the MP tables. Measured on
           QEMU q35 with -smp 4: the MADT lists all four processors
           and one I/O APIC, where the legacy MP table listed only
           the boot processor.
  AHCI     so a q35 machine has a disk.
  timers,  HPET or the local APIC timer where there is no 8254;
  console  framebuffer or serial.

Target: QEMU i386, BIOS boot, machine `pc` while the IDE driver is
the disk path, then `q35` as the modern target. No UEFI.

## Setting up from nothing

```sh
git clone https://github.com/nmartin0/new_mk && cd new_mk
git checkout new_mach

git clone https://github.com/andreiw/ode4linux ~/ode4linux
git -C ~/ode4linux checkout 7acc7dfbbd7a36e36e7a0c91930e555c076b2893

export ODE4LINUX=~/ode4linux
sh build/bootstrap-ode.sh        # once: build ODE's own tools
sh build/mksandbox.sh            # once: prepare the sandbox
sh build/ode.sh MAKEFILE_PASS=FIRST

for l in libcthreads libsa_mach libmach libmach_maxonstack libmach_sa; do
    sh build/ode.sh -here mach_services/lib/$l
done
sh build/ode.sh -here file_systems
sh build/ode.sh -here bootstrap
sh build/ode.sh -here default_pager
sh build/ode.sh -here mach_kernel MACH_KERNEL_CONFIG=PRODUCTION
```

The reference trees of the chain go under `~/refs`; their URLs and
pinned commits are in `notes/PRECEDENT.md`, and `tools/sweep.sh`
expects them there.

## Booting what exists today

```sh
K=$MK_BUILD/obj/at386/mach_kernel/PRODUCTION/mach_kernel.PRODUCTION
B=$MK_BUILD/obj/at386/bootstrap/bootstrap

qemu-system-i386 -kernel $K -initrd $B -append "-r" -m 128 \
    -display none -serial file:/tmp/boot.log -no-reboot
```

Expect the loader to report `Found text region`, `Found read-only
region`, `Found data region`, `task loaded`, and the bootstrap server
to ask for `/dev/boot_device/mach_servers/bootstrap.conf`. `-append
"-r -o"` selects OSF's own bootstrap path instead of the Hurd one.
`tools/boot-ide.sh` is the full boot and needs LITES built.

## Known, recorded, not yet fixed

- `mach_perf` does not assemble under a modern `as`: `mach_setjmp.s`
  uses 1990s `/` comments. Vendor code, untouched, and it is why
  `ode.sh -here mach_services/cmds` fails.
- CMU's `mach_init` server is not here and is not wanted: OSFMK's
  startup task is `src/bootstrap`, whose service.c registers the
  ports that libmach's `mach_init_ports()` reads back, and the naming
  service is `netname`, `machid` and `netmemoryserver`.
- `notes/docs/current-blocker.md`, `lites-survey.md` and
  `bootstrap-fork.md` describe the first effort and are carried
  verbatim until the work they describe is re-derived.
