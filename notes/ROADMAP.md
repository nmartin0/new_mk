# ROADMAP

**Start here for what to do next.**

Four documents hold roughly 300 KB between them. Each is right about its
own area and none can say what comes first, because the answer depends
on the others. This file is the ordering; the detail stays where it is,
and every item names its home.

- **`BACKLOG.md`** — the one list of what is open (R, K, L, U, Q).
- **`DECISIONS.md`** — why the work is shaped this way (D, P, H).
- **`FINDINGS.md`, `FINDINGS2.md`** — what was measured (G1–G180).
- **`DISTRIBUTED.md`** — the long-horizon multiserver design (X1–X26).
- **`RULES.md`** — the method everything above is done by.

**How it is ordered.** By dependency, and by what would stop the work —
not by size or by interest. An item appears after everything it needs and
before everything that needs it. Where two items could go either way, the
one that makes the other *safer* comes first.

**What this is not.** It is not a schedule and it does not estimate.
Several stages below are a week and several are a year, and saying which
would be a guess presented as a plan.

---

## Where the project actually is

**The system runs.** A cold boot reaches a login prompt unaided — `init`,
`rc`, `getty`, `login`, `csh`. The project's own acceptance table records
pipes, redirection, ownership resolution through the passwd and group
databases, shell scripts, background jobs, signals and job control, a
writable ext2 root, `sync` returning 0 with the data verified from the
host after a halt, and `e2fsck -fn` reporting no errors across 81 files.
`/kern` is mounted. It boots from an ISO. The whole stack builds with no
compiler-supplied file at all.

**Deviation from the vendor import is 16 files**, each with an `AI-ONLY
NOTE` at the site and a commit message carrying the evidence, and all
re-verified by reverting them individually against a positive control.

So the question is no longer "can this boot". It is **"how does a working
1997 microkernel become a modern, correct, distributable system without
losing what makes it worth reviving"** — and the ordering below follows
from that.

---

## Stage 0 — Trust what you have

**Nothing below is safe without this, and nothing here depends on
anything.** There are ~190 open items, one maintainer, and a working
system that can regress silently. Everything in this stage exists to make
a regression loud, to make a rebuild mean something, or to settle a
premise the later stages rest on.

| item | why it is first |
|---|---|
| **R30** CI: build matrix, boot, markers | Nothing currently stops a change breaking the boot. Highest-leverage item in the repository, and the only defence against the scope risk in **P7**. |
| **R32** replace `md` with `cc -MMD` | **Moved here from the build stage, and it belongs here.** `md` is the dependency generator; if it is wrong, a rebuild does not reflect the change you just made, and every fix in Stage 1 would be tested against a stale build. That is RULES 4.13 at the level of the build itself. It also removes a 2008 binary and **answers Q9 by construction**. |
| **K46** in-kernel test harness | Modelled on XNU's `xnupost` (G112). **Needs no userland**, so it can land now rather than after the L-series, and CI can run it from the same boot. |
| **R5** `DEVIATIONS.md` | The pristine baseline is identified: `mkunity-master/osfmk` differs from the tree in exactly the 16 files that are ours (G149). Diff against it and write the reason for each. |
| **X19** take the IPC baseline | `net-latency-tools` is public domain and measures round-trip directly (G154). **Moved here: a baseline taken after the build and the defect work has already lost what it was supposed to measure.** Feed it to CI so drift is visible. |
| **R35** import MK84's 128 manual pages | 15,006 lines, CMU permissive (G172), covering the entire external memory-manager protocol and port interface. The tree has one `.man` file. Costs a copy; gives every later argument a citable reference. |
| **R7**, **R27**, **R12** licence, `copyright.osf`, principles | Settled by G66; write them down before the tree grows. |

### The three afternoon experiments

Each is a build-and-boot, each settles a premise that later stages rest
on, and **each is far cheaper now than the work it could invalidate.**
This is RULES 2.3 — check the premise — applied at the scale of the
whole plan.

| question | what it settles |
|---|---|
| **Q15** does `DEBUG+NORMA` still build? | **Moved here from Stage 9.** Nineteen NORMA configurations exist for i386 and none has been built in this revival (G95). The answer decides whether **D20**'s premise holds, whether Stage 13 is a revival or a reimplementation, and whether L23 and K49 carry the constraint that `object->memq` is iterated inside `xmm_user.c` and `vm_copy.c` (G124). Also surfaces the `FAST_IDLE` contradiction between `config.norma` and `config.mp`. |
| **Q6**, **Q13** does `FAST+MP` boot under `-smp 2`? | **Moved here from Stage 8.** Answers whether SMP is a bring-up or a repair before the ~1,700-site lock conversion is scoped against it. |
| **Q7** is the Hurd bootstrap graft droppable? | Half-answered already: pmk1.1 has no `boot_script.c` and a 917-line `bootstrap.c`, so the graft is MkLinux-era (G71). Confirming it now keeps K11 simple. |

**Also here, because they are repository work and block nothing:**
**R1** delete the duplicate tree, **R2** vendor LITES in, **R3** + **R4**
the boot test CI feeds, **R6** `.gitignore` and generated artefacts,
**R8** `IMPORTS.md`, **R13** third-party import hygiene, **R16** the test
plan, **R17** `mkroot` determinism, **R18** host-versus-target tools,
**R19** `.gitattributes`, **R22** README accuracy, **R23** pinned
versions recorded in-tree.

**Exit condition:** a push that breaks the boot fails visibly; a rebuild
provably reflects the change; the deviation record is complete; and the
three premises are answered rather than assumed.

---

## Stage 1 — Fix what is broken now

Small, bounded, and they are what the system gets wrong *today*. **They
come before the build work**, not after: each is self-contained, each is
user-visible, and none of them needs a hermetic build — only a
trustworthy one, which Stage 0's **R32** now provides. Doing
infrastructure while known defects sit is the wrong priority.

Every item here has its diagnosis already recorded in the repository's
`docs/current-blocker.md`; none needs new instrumentation beyond
`printf`, which is why this stage does not wait for Stage 3's debugger.

| item | note |
|---|---|
| **L47** `exec_file.c:273` `&&` where `&` was meant | One character. It collapses every machine-id case to 0 or 1. Found by the project while surveying xMach, which had not fixed it either (G180). |
| **L43** console input reorders under burst | **The one real defect.** One burst in three; a displaced character once made the shell run `Esleep`. Control established, site identified (`tty_read_reply()`), first hypothesis named (replies dispatched from a pool, two buffers in `l_rint` at once). The measurement that settles it is one thread identity and one `data_count` per `printf`. |
| **L45** root cannot be unmounted at shutdown | The three held buffers are ext2's pinned group-descriptor and bitmap buffers, not unwritten data. No data is lost; the filesystem is left marked not clean. |
| **L46** console output interleaves between writers | Distinct mechanism from L43. Note the project's own correction: the earlier "two claimants" explanation was attributed to the wrong cause. |
| **L44** build `procfs` | **The largest open item.** `ps` cannot work through `libkvm` here — LITES's `struct proc` carries `p_sigport`, `p_task`, `p_req_port`, `p_thread`, `p_servers`, so a 1994 binary reading by layout finds a different structure. `kernfs` is system variables, not processes. `procfs` is type 12 and is not built. |
| userland breadth | Mechanical: the `NEED` list in `mkroot-netbsd.sh` is deliberately small. |

**Exit condition:** the acceptance table passes with no blemishes beside
it, and `ps` works.

---

## Stage 2 — Build from our own sources

**Everything downstream is more trustworthy after this.** The build
still depends on two prebuilt 2008 binaries and on the host's toolchain.
Until that is gone, "it builds" means "it builds here" — which is
tolerable while fixing known defects and not tolerable while porting a
kernel to a new architecture.

**R32 has already landed in Stage 0**, because dependency tracking is a
prerequisite for trusting *any* rebuild, not just a hermetic one. What
remains here is removing the binaries and the host dependency.

| item | note |
|---|---|
| **R34** build ODE from its own source | It is in the collection: `buildtools/ode/bin` has `make` (25,032 lines), `md`, `genpath`, `makepath`, `release`, `wh`, all under the OSF Free Copyright (G139). **This unblocks R9, R20, R24 and R31 from one directory.** |
| **R9**, **R20**, **R21** `migcom` and `config` from source | Five MIG sources exist; build the in-tree one — it is the MK 7.3 branch and uniquely carries the on-stack message optimisation (G168). Four `config` sources; 6.1's is the default (G175). 22 export headers are MIG *output* and regenerate. |
| **R24** adopt `bmake` | The dialect check is done — ODE make is pmake, and every construct in the 11 `osf.*.mk` files is a bmake feature (G113). Only `.LINKS` needs verifying, and ODE's own source does not implement it. |
| **R31** start the hermetic `tools/` | Aim at NetBSD's *property*, not its 131-entry size: strict POSIX conformance does most of the work, leaving the cross-compiler, `mig`/`migcom` and `config` — three or four entries. |
| **K26** pinned cross toolchain | Needs `makedefs/osf.extra.mk`, which the tree lacks and every built export tree carries: four lines setting the compiler's own include path (G159). Take NetBSD's `common/lib/libc/quad` for the 64-bit helpers a `-nostdlib` link needs (G94). |
| **K31** `sys/tree.h` and the freestanding C utilities | The tree has no `vsnprintf`, `snprintf`, `strtoul`, `memmove`, `strlcpy`, no trees, `crc32` only inside two NIC drivers (G78). **Every subsystem added after this stops improvising around the gaps.** |

**With them:** **R25** pin the C standard — **including the generators
(P3)**, since MIG emits ANSI but `vnode_if.sh` emits K&R; **R15** history
blocks and `_t` → `struct` in headers, after R5 exists to replace what
those blocks record; **R28** import 6.1's `ipc_test`, `xptest` and the
fifteen absent commands, which are the consumers that define what a
bootstrap libc must provide; **K42** records XNU's `config` as the
fallback if 6.1's proves unbuildable.

**Exit condition:** a clean clone builds the whole system on a host with
a C compiler and a shell, and nothing in the build is a binary nobody can
rebuild.

---

## Stage 3 — Eyes

**Everything after this is harder without it.** Doing it here, rather
than when something breaks, is the difference between a diagnosis and a
week.

| item | note |
|---|---|
| **K48** remote kernel debugging via **TTD** | CMU's own, permissive: `default.MK84/kernel/ttd`, 4,454 lines, a complete protocol — connect, read, write, thread enumeration, breakpoints, single-step — over raw Ethernet, written for this kernel family (G161). **This supersedes referencing XNU's APSL `kdp`, and with it the case for writing a disassembler** (G120: no kernel disassembler in 7.3, XNU, NetBSD, FreeBSD or OpenBSD decodes SSE). |
| **K34** `ddb` symbol handling | The BSD debuggers descend from Mach's ddb but *stripped* the Mach parts — `db_sym.c` is 1,580 lines here and 489 in NetBSD (G119). xnu-123.5 shares 22 of 22 files and is the reference; the work starts from our own file. |
| **R26** assembly line numbers | Pairs with both of the above. |
| **K19**, **K23** immediate console, unique panic strings | Cheap, and they make every later failure legible. |
| **X19** in-kernel profiling | The *baseline* was taken in Stage 0. What belongs here is MK84's `pc_sample.c` (327 lines, permissive) — statistical profiling inside the kernel, which the tree has no counterpart for (G173), and which turns "IPC costs N" into "and here is where the N goes". |
| **R29** the `regress/` tree | OpenBSD's proportions — 1,119 tests from a `share/mk` of 15 files, plain make, no framework (G112). Needs a userland, which Stage 2 provides. |

**Exit condition:** a kernel fault can be attached to from a host, and
IPC cost has a recorded baseline.

---

## Stage 4 — Read before building

Cheap, and doing it afterwards wastes the work. Each of these changed a
design once already.

| item | what it settles |
|---|---|
| **L41** POE | A complete permissive personality at 26,000 lines against LITES's 226,000 — and, because its emulator *is* UX 28's (G148), the other half of the same original conversation. Read `ufs_pager.c` before L23, `bsd_select.c` before L35, the exception path before L11. |
| **L42** the four glue layers | UX 28, POE, LITES, and MkLinux's `osfmach3/` — with `inode_pager.c` (1,064 lines) and `fake_interrupt.c` solving L23's and X12's hardest parts a fourth way (G143). Diff the two MkLinux snapshots against each other for what turned out volatile in practice (G178). |
| **L40** XNU's `bsd/` | The only existing example of a *modern* BSD attached to *this* Mach: `proc`↔`task`, `uthread`↔`thread`, signals at the AST boundary, vnode pager onto memory objects (G105). The mappings land in our emulator and RPC layer instead of direct calls. |
| **K52** MK67 | One release short of our kernel's fork point, on the direct line, **and permissive** — 235 of its files carry the full CMU grant (G144). Use wherever "what did this look like before OSF" matters. Note `ipc/` and `vm/` barely moved (G174), so the answer there is "almost exactly the same". |
| **K43**, **K40**, **K41**, **K45** the Apple lineage | Rhapsody is MK 6.1 with six years of i386 work; xnu-123.5 is *our* files six years on, still 32-bit; modern XNU is the same lineage at 64 bits; and the repository holds 155 tags, so a subsystem's evolution can be walked release by release rather than inferred from endpoints (G101, G100, G109). |
| **X21**, **X25**, **X26**, **X20** | Mach-US built this design in 1994; the netmsgserver did cross-node IPC as a *server over TCP* with authentication and byte-swapping (G106); XNU rewrote the subsystems we are about to rework; FLIPC is the in-tree prior art. |

**Exit condition:** nothing. This stage is reading, and its output is
better decisions in Stages 5–10.

---

## Stage 5 — Hardware that works

| item | note |
|---|---|
| **K24** NE2000 device-table entry | A vendor bug: `autoconf.c:594` wires the NIC's interrupt to `at3c501intr`; the correct handler is `neintr`. Then slirp with a static address. |
| **K18** Utah's `nhd.c`, LBA | |
| **R11** retire `mkminix.py` and the minix reader | |
| **K25** enable PCI | |

**Blocks:** X22's transport (KKT rides an Ethernet interface), and
anything that wants a network.

---

## Stage 6 — Platform discovery

The tree has no ACPI, no LAPIC beyond `mp_v1_1.c`'s inline setup, no
timecounter abstraction and no GPT.

| item | note |
|---|---|
| **R10** the 512 MB ceiling | |
| **K8c**, **K8d**, **K8a** ACPI tables | **Use uACPI, not ACPICA** — MIT rather than dual BSD/GPL, table-only subset ≈3,600 lines, ships its own overridable stdlib, and **avoids recursion deliberately because kernel stacks are tiny** (G81). PureDarwin integrated it into an XNU-family kernel, which is evidence it fits (G111). Size target: Haiku's 251-line boot-path version; algorithm reference: FreeBSD 6.0's `madt.c` (G75). |
| **K9a**, **K9** LAPIC, IOAPIC, MSI, x2APIC | Lift out of `mp_v1_1.c`. Register headers from NetBSD 5.0 or later — earlier ones carry the advertising clause. |
| **K11** Multiboot2 | **An upgrade, not an implementation**: `start.S:345` already emits `0x1BADB002` with the checksum, and `model_dep.c` handles `MULTIBOOT_MODS` (G167). Read Bryan Ford's original 1996 proposal first — it is in the collection, and boot modules exist in the standard *because of Mach*. |
| **K10** + **K32** deadline timers over timecounters | FreeBSD's `kern_tc.c` is the standard answer and the tree has three unconnected `rtclock.c` files with no abstraction (G78). Underpins L18 and `clock_gettime`. |
| **K33** GPT | The tree knows MBR and BSD labels only. Every modern disk image is GPT. |
| **K8**, **K8b** ACPI in the kernel, and the interpreter question | K8b only if something needs AML; the table subset is what K8d/K8a deliver. |
| **K44** Rhapsody's `boot-2/i386` | Recorded as the in-tree self-hosted bootloader alternative to Limine. Ranking unchanged: Limine first. |
| **K35** entropy, **K29** runtime code patching | K29 is 74 lines in Haiku, and both SMAP and the mitigations plug into it — so it comes before them. |

---

## Stage 7 — pmap, and the one real security gap

| item | note |
|---|---|
| **K36** PAE + NX | **The only item in this document that is a security gap rather than a performance one.** On 32-bit x86 the NX bit exists *only* with PAE page tables, so these are one task — and without them W^X on i386 is unachievable. **Gates K15.** |
| **K37** pmap performance and structure | No single donor (G137): FreeBSD for superpages, pv-chunks, global pages and `pmap_kenter`; **XNU alone for PCID**; NetBSD or OpenBSD for `pmap_growkernel`. And the distributed code barely touches pmap — XMM makes four calls, DIPC one — so **this is the one major subsystem where any donor is structurally safe.** |
| **K38** TLB shootdown as its own subsystem | The difference between SMP that boots and SMP that is correct. |
| **K15** security baseline, **K51** port guards | Note the tree already has 8 bits of name generation (G135), so stale-name detection exists; guards add ownership. `immovable` matters *more* here than in XNU, because DIPC moves rights between nodes (G136). |
| **K30** speculation mitigations | Deferrable while QEMU-only; not deferrable on metal. |

---

## Stage 8 — SMP, done correctly

| item | note |
|---|---|
| **L50** convert `simple_lock` + `spl` to IPL-carrying mutexes | **Sequence *with* K14, not after**, and scoped against Q6/Q13's answer from Stage 0. ~1,700 `spl` calls and 1,177 simple-locks (G128). Take **NetBSD's model, not FreeBSD's**: fuse the IPL into the mutex, keep the `spl` calls that genuinely mean "do not interrupt me here" (G133). The reason it is mandatory: on SMP a `simple_lock` without interrupt discipline deadlocks against its own CPU's handler, and `spl` alone cannot exclude another CPU. |
| **K14a**, **K14** MP bring-up | ACPI-first with MP-table fallback, which all four reference systems use. |

---

## Stage 9 — Kernel primitives the personality needs

**Q15 was answered in Stage 0.** If it came back positive, K12 prunes
only dead architectures and the constraint on L23/K49 stands. If
negative, see "the three things that would change this order".

| item | note |
|---|---|
| **K12** prune dead ports only | **Revised by D20**: delete `hp_pa`, `ppc`, the Sequent directories. **Keep `dipc`, `xmm`, `flipc`, `uk_xkern`, `i386/kkt`.** |
| **K1**–**K7**, **K20** | |
| **K2**, **K3**, **K50** direct traps | XNU added exactly the traps planned here, then generalised them (G130). **Hard requirement from G134: each trap resolves a port *name*, and DIPC delivers to kernel objects from remote nodes — so every trap must detect a proxy and fall back to the message path.** XNU's shape is right and omits the else branch, because XNU has no remote objects. |
| **K22**, **K17**, **K21** | |
| **K39** the APSL quarantine mechanics | Only if any APSL file is adopted (D21): dedicated subtree, Exhibit A duplicated, changes dated, source published, per-file record in `IMPORTS.md`. |
| **K47** port XNU's applicable `tools/tests` | `MPMMTest` → X19's benchmark, `TLBcoherency` → K38's correctness test. |

---

## Stage 10 — The BSD core

The largest stage. Five sub-stages, each a milestone in its own right.

**10a — clear the ground.** **L38** settle rework/replace/delete before
any file-level work; **L37** delete `netiso`, `netccitt`, `netns` —
47,300 lines, 27% of the BSD half; **L39** batch the VOP changes.

**10b — the model.** **L1** exec as a new task; **L2** freeze the ABI
types — **and settle the kernel's 32-bit clock with it (P2)**, since
`time_value_t` is `integer_t seconds` and sits in `mach_host.defs`, so a
64-bit `time_t` in LITES does not save the kernel boundary; then the
thread split **L3**–**L6**.

**10c — readiness and signals.** **L35** generalise the readiness model
*before* the signal core **L7**–**L12**. XNU's `waitq.c` is the worked
version of wait-queue sets with prepost (G117); POE's `bsd_select.c` is
the small one.

**10d — threads and time.** **L13**–**L15**, **L21**, **L22**, **L25**,
**L27**; **L16** retire the
BSD scheduler — and note MK84 has a ~7,400-line **permissive pluggable
policy framework** with real-time disciplines, kernel-side hooks
included (G162, G173); **L17** retire `spl` on the LITES side; **L18**
Mach clock alarms; **L26** devfs — **donor found**: xMach's LITES carries
`devfs_vfsops.c` + `devfs_vnops.c`, 1,105 lines, Regents-licensed and
written against LITES's own VFS (G153).

**10e — the POSIX surface.** **L28** exec stack and auxv — **already
written**: xMach's `e_linux_trampoline.c` carries the full auxiliary
vector under Helander's own grant (G160, with the provenance caveat in
G180); **L29** `*at()`; **L30** `poll`; **L31** record locks; **L32**
terminals and job control; **L33** `sysctl`; **L34** `statvfs`; **L36**
errno audit; **K49** the radix trie — **only after Q15 and X22**, because
`object->memq` is iterated directly inside `xmm_user.c` and `vm_copy.c`
(G124); **L23** `MAP_SHARED` coherence, the hardest item in the project;
**L24** `shm_open`; then the imports **L19** VFS and **L20** network
stack.

---

## Stage 11 — Userland and ABI

**U1** (the NetBSD 1.0 userland) and **U2** (`mach_init`) are **done** —
`mkroot-netbsd.sh` builds the root from the real sets, and `mach_init` is
ported and committed though not on the critical path, because LITES's
`SECOND_SERVER` `-i` flag runs `/sbin/init` directly. **P1 is superseded
by that** (H11).

**U3** ELF classification (the one part of the old Phase 3 still open);
**U4** `e_netbsd_sysent` — with **P5**'s rule, modern types in the server
and translation at the emulator boundary; **U5** NetBSD libc whole;
**U6** + **U6a** libpthread and its LWP bridge; **U7** dynamic linking — **the loader half exists** in
xMach's `emul_exec.c` (`PT_INTERP`, `load_bias`, `interp_load_addr`),
where ours has none; **U8** conformance runs, the headline metric from
here on; **U9**–**U11** pkgsrc; **U12** early `bsd.port.mk` only if a
bridge is needed; **U13**, **U14** the bootstrap libc, minimum only.

**D19 governs this whole stage**: source compatibility, not binary. Skip
NetBSD's 65 versioned syscall entries, choose 64-bit types from the
start, and let libc call the routing library directly rather than trap.

---

## Stage 12 — The big ports

**K28** split x86-generic from i386-specific **before** K13 — the
difference between "add an amd64 directory" and "duplicate and diverge".
**K27** convert non-essential assembly to C: the core MD path is 33.1%
assembly against NetBSD's 15.3% and FreeBSD's 3.3% (G77), and this
pre-pays part of K13. Then **K13** x86_64, with **K41** as the reference
and **R33**'s MIG delta read first — our `migcom` contains zero
occurrences of "64". Then **K16** userland drivers — **D27** now permits
Utah's GPL Linux emulation, preferably hosted in a *separate driver
server* over Mach IPC so the kernel stays permissive; **R14** boot-module tooling, when the system first leaves the emulator, and **X1**, with
**Q4** and **Q16** spiked first, because `SECOND_SERVER` does not work on
i386 as it stands (G169).

---

## Stage 13 — Distributed

**`DISTRIBUTED.md`** holds the design and the ordering within the stage.
The sequence at a glance: read first (**X21**, **X25**, **X26**, **X20**),
then **X22** revive NORMA in CI — **porting from 6.1's `norma/`, not
CMU's MK84**, because 6.1 is a strict superset already carrying the
`svm_*` files 7.3 expects and an `ipc_ether.c` 276 lines further
developed (G171) — then **X23** the gaps NORMA does not fill (membership,
failure detection, **cross-node identity**, time), **X2**–**X18** the
server split, and **X24** the distributed filesystem, with **9P** as the
protocol and NetBSD's permissive `sys/coda` as the boundary mechanism
(G118).

---

## The open questions, and where each is answered

| question | where |
|---|---|
| **Q9** does editing a header rebuild dependents? | **Stage 0** — answered by construction once R32 lands. |
| **Q6**, **Q13** does FAST+MP boot under `-smp 2`? | **Stage 0** — an afternoon, and it scopes Stage 8. |
| **Q15** does `DEBUG+NORMA` build? | **Stage 0** — it settles D20's premise, which Stages 9, 10e and 13 all rest on. |
| **Q7** drop the Hurd bootstrap graft? | **Stage 0** — half-answered by G71; confirming it keeps K11 simple. |
| **Q1**, **Q2**, **Q3** static binary loading, pre-`main` calls, `_lwp_ctl` | Stage 11, with U4/U5. |
| **Q4**, **Q16** rump LWP bridge; how a second server gets its ports on i386 | Stage 12, **before** X1. |
| **Q5** keep migrating RPC? | Stage 13 — X8 argues yes; the benchmark decides. |
| **Q8** NetBSD subtree resync | Stage 10e, with L19/L20. |
| **Q10** stock binary packages | **Downgraded by D19**; replaced by "does pkgsrc build from source". |
| **Q11**, **Q12** routing library rtld-safety; wider trailer versus kmsg cache | Stage 13, with X9/X13 and X14. |
| **Q14** POE's internals | **Answered** (G164): real external pagers, **read-only** — no writing to disks or filesystems, no sockets. |

---

## The three things that would change this order

1. **Q15 comes back negative in Stage 0.** If `DEBUG+NORMA` cannot be
   built, **D20's premise weakens**: Stage 13 becomes a reimplementation
   rather than a revival, the constraint on L23 and K49 relaxes, and K12
   has a real argument for pruning further. Because this is now answered
   in Stage 0 rather than Stage 9, the whole back half of the plan can be
   re-shaped before any of it is built — which is the entire reason the
   question moved.
2. **The benchmark (X19) contradicts X8.** If migrating RPC is not
   measurably faster in this configuration, Q5 resolves the other way and
   K50's trap work becomes more important, not less.
3. **Real hardware enters the picture.** P6 stands: everything is tested
   against one machine model, and Stage 6 is exactly where that bites.
   K30 moves from deferrable to required the day this runs on metal, and
   Stage 6's discovery paths need their fallbacks exercised rather than
   assumed.

---

## What changed in this revision, and why

Three moves, each made on a dependency that had been missed rather than
on a preference:

**R32 moved from the build stage into Stage 0.** `md` is the dependency
generator. If it is wrong, a rebuild does not reflect the change just
made — so every fix in the defect stage would have been tested against a
possibly-stale build. Trusting a rebuild is a prerequisite for trusting
*any* fix, which makes it infrastructure of the same kind as CI rather
than part of the toolchain work.

**The defect stage moved ahead of the build stage.** The five live
defects are self-contained, user-visible, and need only a trustworthy
build — not a hermetic one. Doing toolchain work while known defects sit
is the wrong priority, and the original ordering had no dependency
justifying it.

**Three afternoon experiments moved into Stage 0.** Q15, Q6/Q13 and Q7
each settle a premise that later stages rest on, and each costs a
build-and-boot. Q15 in particular decides whether Stage 13 is a revival
or a reimplementation and whether L23 and K49 carry a constraint —
answering it at Stage 9, as originally placed, would have meant
discovering at Stage 9 that the previous four stages had been planned
around a premise that did not hold. **The cheapest thing in this
document is the experiment that invalidates a plan before it is built.**
