# The chain of precedent

Where donors are looked for, in what order, what may be copied from
each, and what is ours. RULES 3.10 makes the walk a hard rule; this
file says where the trees are and which commit each is pinned at.

## Where to look, in order

| # | tree | where | pinned at |
|---|---|---|---|
| 1 | **OSFMK 7.3 itself**, every port it carries -- i386, ppc, hp_pa, sqt, Corollary | `osfmk/src` in this repository | the vendor import on `main` |
| 2 | **OSFMK 6.1** | `~/refs/osfmk6_1`, `nmartin0/osfmk6.1` | `e874fd860aee` |
| 3 | **The CMU Machs** | `~/refs/machmk83`, `mach-mk42`, `mach-mk74`, `mach3`, `mach_us`; `~/refs/mach_stuff/{mach.kernel.mk,default.MK84}` | `6d1ef9f3fb99`, `eaa9743056d0`, `fb9550c7606d`, `9c2e1a8d77f8`, `84aaf6d3cbc2`; `78cab0993cbf` |
| 4 | **Utah Mach 4 and its descendants** | `~/refs/mach_stuff/{mach4-UK22,user-mach4}`, `~/refs/openmach`, `~/refs/xmach` | `78cab0993cbf`, `a185c84f7f50`, `2283fb558392` |
| 5 | **The contemporaries of 7.3.** This tree's newest dated entry is 1998/04/21, so its contemporaries are the 1997-98 releases | NetBSD 1.3 (4 Jan 1998) `~/refs/netbsd-1-3`; FreeBSD 2.2.8 (29 Nov 1998) `~/refs/freebsd-2-2-8`; OpenBSD 2.3 (19 May 1998) `~/refs/openbsd` | `8b8d5a4d41ff`; tag `release/2.2.8`; **`4278ac51dc22`, see below** |
| 6 | **Later BSDs, in historical order**, stopping at the earliest release that has the thing | fetched when a search first needs one, and its ref recorded here | -- |
| 7 | **Rhapsody and XNU: read-only** | see below | -- |
| 8 | **Ours**, and only when 1 to 6 have nothing | labelled as ours, with the alternatives, for the maintainer to decide | -- |

**The OpenBSD caveat.** `github.com/openbsd/src` carries `master` and
no tags at all, so there is no `OPENBSD_2_3` to check out. What is on
disk is the last commit before the release date, `4278ac51dc22` of
1998-05-18, one day before OpenBSD 2.3 shipped. It is reproducible and
it is not the release tarball, and a citation says so: "OpenBSD as of
1998-05-18 (`4278ac51`)", never "OpenBSD 2.3" alone. The full history
is cloned, 247,392 commits back to 1995-10-18, so any other date is
one checkout away.

## Positions 1 to 5 on this branch

This branch finishes a period-correct OSFMK 7.3: a tree whose sources
are what OSF and its contemporaries wrote, with our changes visible as
a short annotated list. **Position 6, the later BSDs, is anachronistic
here and may not be used.** ACPI, AHCI, HPET and the rest are phase 2,
on a branch taken from the tag this one ends at; `ROADMAP.md` records
the donors and their dates so that work starts from evidence rather
than from a search repeated.

What is unavoidable is not a feature: an assembler that rejects
`movl %ss,%ax`, a compiler that needs `volatile` on a hardware
register, a linker that emits read-only program segments. Those are
the cost of building 1998 source with a 2026 toolchain. Each is
annotated where it sits and listed in `DEVIATIONS.md`, and none of
them adds a capability the original did not have.

## What may be copied

Positions 1 to 6 may be transplanted **where the licence on the file
permits it**, which is checked per file and not per project. A tree
being "BSD-licensed" says nothing about the file in hand: 1998 BSD
kernels are full of four-clause notices with the advertising
requirement, of CMU and Utah notices on Mach-derived files, and of
GPL'd Linux drivers carried in `gpl/` subdirectories -- OpenMach and
xMach both ship those. A transplant records the file, the tree, the
release, and the notice it arrived with.

Positions 7 and 8 are never copied and never transplanted.

## Rhapsody and XNU are read-only

They descend from this code and are the closest thing to a record of
how it was carried forward, so they may be read to answer *what* a
thing must do and *why* something changed. Nothing is copied from
them, and nothing written here may be derived from reading them: a
permissively licensed precedent that could have been copied is
required for anything that lands in this tree. They carry Apple's
Public Source License, which D21 quarantines.

## Every citation names a tree and a release

Not "NetBSD does it this way" but "NetBSD 1.3, `sys/dev/pci/pci.c`".
An undated citation reads as a contemporary, and the contemporaries
are position 5. A claim is written only after the file it describes
has been read in the session that writes it -- never from memory of
what a system "usually does".

## Proving an absence

A found donor proves itself: the line is shown. An absence does not.
No proposal may state that no donor exists unless every tree in
positions 1 to 5 has been searched, with the later BSDs of position 6
searched as far as the question needs, and the commit message names
them. `tools/sweep.sh` does the walk and prints a line per tree.

**A sweep is not proof either.** It reports what one pattern found.
`0xcf8` finds nothing in NetBSD 1.3, FreeBSD 2.2.8 or OpenBSD 2.3,
all of which have had PCI for years: they write `0x0cf8`, and NetBSD
calls it `PCI_MODE1_ADDRESS_REG`. Sweep for the concept in several
spellings, and say which spellings were tried.

It fails the other way too. `snames` reports hits in NetBSD 1.3,
FreeBSD 2.2.8 and OpenBSD, none of which has that server: the matches
are `classnames` and `syscallnames`. A pattern too narrow invents an
absence; a pattern too loose invents a presence. Read the hits before
reporting them.

## What is ours

Anything that comes from outside the chain is this project's own
invention, whatever suggested it -- Linux, GNU, a datasheet, a
model's training, or its own reasoning. It is labelled as such, the
alternatives are given, and the maintainer decides. That no tree in
the chain does a thing is itself the finding, and is reported rather
than dressed in a plausible-sounding source.

Running on current i386 hardware needs several things no tree in the
chain has: ACPI table parsing, discovery of processors and I/O APICs
through the MADT rather than the MP tables, AHCI, and a framebuffer
console. Later BSDs have all of them and are position 6; what will be
ours is the attachment to Mach's `autoconf` and device model.

## Adding a tree at position 6

Clone it at the release the search needs, record the ref in the table
above, add it to `tools/sweep.sh`, and say in the commit which
question made it necessary.
