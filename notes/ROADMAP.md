# ROADMAP

Two phases, and the second does not start on this branch.

`HANDOFF.md` says where the work stands today; this says what the
shape is and why it is in that order.

---

## Phase 1, here: a period-correct OSFMK 7.3 that boots

The goal is a tree that a stranger can clone, build and boot, and then
read to find out what OSF wrote in 1998 -- with our changes visible as
a short, annotated list rather than mixed into the source.

**Donors are positions 1 to 5 only**: OSFMK 7.3 itself, OSFMK 6.1, the
CMU Machs, Utah Mach 4 and its descendants, and the contemporaries of
7.3 -- NetBSD 1.3, FreeBSD 2.2.8, OpenBSD as of 1998-05-18. Position 6,
the later BSDs, is anachronistic here and belongs to phase 2. See
`PRECEDENT.md`.

The exceptions are not features but the cost of building 1998 source
with a 2026 toolchain: an assembler that rejects `movl %ss,%ax`, a
compiler that needs `volatile` on a hardware register, a linker that
emits read-only program segments. Each is annotated at its site and
appears in `DEVIATIONS.md`.

### What is left

| | |
|---|---|
| LITES source fixes | the bring-up fixes: ext2 inline assembly, panic, varargs, the console, `emul_save_state`, priorities |
| LITES under ODE | the library, then the emulator, then the server: header export, generated headers, include paths, flags, MIG, linking in Utah's order |
| Stage 1 bugs | the clock a day behind, the console losing characters, the foreign binary accepted, the empty panic message |
| infrastructure | CI, dependency tracking, in-kernel unit tests, `DEVIATIONS.md`, the IPC baseline, the MK84 manual pages |

`junk` holds this work and is the reference for it. Each batch is
re-derived under the chain rather than replayed: the citations there
were made against a different ordering of trees.

### Done means

- boots to a login prompt on QEMU `pc`, from a disk the tree builds
- `tools/ci-boot.sh` passes all five checks
- every deviation from the vendor import annotated at its site and
  listed in `DEVIATIONS.md`
- `git diff <import>..HEAD -- osfmk/` is the whole of our divergence

Then the tree is tagged, and that tag is the base phase 2 branches
from. It is also the thing worth handing to anyone who wants a 1998
microkernel rather than our modernisation of one.

---

## Phase 2, on a branch taken from that tag: modern i386

Target: QEMU i386, BIOS boot, machine `pc` while the IDE driver is the
disk path, then `q35`. No UEFI.

The research is recorded here so that it is not re-derived. Each donor
was dated from the tree itself, not from memory.

| stage | what | earliest donor, with its date |
|---|---|---|
| PCI, mechanism 1 | nothing is built for i386 today: one `busses/pci/pci.c`, commented out in `conf/AT386/files` | **the contemporaries already have it.** OpenBSD's `sys/arch/i386/pci/pci_machdep.c` is in the repository's first commit, 1995-10-18; NetBSD 1.3 and FreeBSD 2.2.8 carry PCI |
| a `bus_space` shim | BSD drivers from 2004 on are written against `bus_space`, `bus_dma` and `pci_attach_args`; OSFMK has `autoconf`, `take_irq` and device operations | **ours.** No tree in the chain has one for Mach. OpenMach and xMach carry Linux drivers behind a glue layer, which is precedent for the approach and unusable as code, being GPL |
| ACPI: RSDP, RSDT, MADT, FADT, MCFG | nothing in positions 1 to 5 | **NetBSD 1.6**: `sys/dev/acpi/acpi.c` is present there and absent at 1.5. FreeBSD has none before 5.0; OpenBSD's `sys/dev/acpi/acpi.c` arrives 2005-06-02. NetBSD's is ACPICA-derived, so the licence is checked per file |
| APIC and SMP from the MADT | `MP_V1_1` already programs the I/O APIC; discovery is what fails on modern firmware | **NetBSD 2.0**: `sys/arch/x86/x86/mpacpi.c`, absent at 1.6. OpenBSD's `mpbios.c` and `ioapic.c` arrive 2004-06-13, `acpimadt.c` not until 2006-11-15 |
| AHCI | no SATA anywhere in our tree | **OpenBSD, 2006-12-09**, `sys/dev/pci/ahci.c`. NetBSD 4.0 follows in 2007 with `ahcisata_core.c`; FreeBSD not until 8.0 |
| timers | the 8254 and the RTC may be absent | HPET: **OpenBSD 4.0**, `sys/dev/acpi/acpihpet.c`, 2006-03-06 |
| console | VGA text mode may be absent | `wscons` is in NetBSD 2.0 and absent at 1.3. Serial-only costs nothing and works today |

### Why that order

PCI first: nothing is discoverable without it. The shim next: every
stage after attaches through it. ACPI before the APIC work, because
the MADT is what discovery needs -- measured on QEMU `q35` with
`-smp 4`, the MADT lists all four processors and one I/O APIC, where
the legacy MP table listed only the boot processor. AHCI after both,
being a PCI device found through ACPI's routing. Timers and console
last, because serial works now.
