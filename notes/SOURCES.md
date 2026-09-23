# Sources: the chain of precedent

Every change is checked against this chain **in order**, and the check
is recorded with one row for each position -- including the positions
that yield nothing. An absence is a dated fact about when something
entered the code, not a blank to skip. RULES 3.10 makes the walk a
hard rule; this file says where each tree is and what it covers.

## The chain

| # | tree | where | what it covers | role |
|---|---|---|---|---|
| 1 | **MkLinux** | `nmartin0/osfmk-mklinux`; `mach_stuff/{mkunity-master, mklinux-2.0.38-pre9, DR3*}` | our `osfmk/` **is a copy of its `osfmk/`** | the same code -- first to look at |
| 2 | **later OSFMK** | `mach_stuff/osfmk*` (ten copies), `pmk1.1`, `OSF1-SRC-V2.0` | ~3,900 files each | same lineage, later |
| 3 | **OSFMK 6.1** | `nmartin0/osfmk6.1` | 748 kernel files under `kernel/src/mach_kernel/`: `intel/pmap.c`, `i386/{start.s,spl.s}`, `i386/AT386/model_dep.c`, `i386/AT386/mp/mp.c`, `kern/*`. No `mp_v1_1.c`, no `dipc`, no `xmm`; `norma` instead | the predecessor release |
| 4 | **CMU Machs** | `nmartin0/{machMK83, mach-mk42, mach-mk74, mach3, mach_us}`; `mach_stuff/{mach.kernel.mk*, default.MK84, macMach5-92src}` | Mach 3.0 as CMU shipped it | ancestor |
| 5 | **UK Machs** | `nmartin0/{mach4ALPHA, lites, lites-1.1.u3}`; `mach_stuff/{mach4-UK22, user-mach4}` | Utah Mach 4 and LITES, which is what our server is | ancestor; LITES's own base |
| 6 | **OpenMach** | `openmach/openmach` | 1,455 files: `i386/kernel/intel/pmap.c`, `i386at/model_dep.c`, `i386/spl.S`, `kern/*`, and `i386/kernel/imps/` -- the Intel MP Specification support | sibling |
| 7 | **xMach** | `nmartin0/{xMach, xMach-howtobuild}`; `mach_stuff/xMach*` (three copies) | Mach 4 and LITES together, 2,638 files | sibling; bears on the LITES work |
| 8 | **Rhapsody** | `calmsacibis995/xnu-rhapsody-53` (1,677 files); `calmsacibis995/rhapsody-reloaded` (2,184) -- distinct trees, not one mirrored twice | `machdep/i386/{pmap.c,start.s}`, `kern/*` | descendant |
| 9 | **XNU / Darwin** | `apple-oss-distributions/xnu`, from `xnu-123.5` | the same code carried forward | **APSL: read, never copy** (D21) |

## Not in the chain

`pistachio` (L4Ka) is a design reference only. GNU Mach and Linux are
GPL-2: read for design, never copied. D27 permits GPL only for Linux
drivers and their emulation layer.

## Donor roles and licence status

- **NetBSD is the code donor** (D3); the permissive donors are ACPICA
  and the BSDs (D9).
- **XNU and Rhapsody are design-only** (D3). APSL adoption is
  quarantined and a last resort (D21).
- Fragments below the threshold of copyright are credited in a comment
  and in the commit, not licensed (D30).

## Tooling, beside the kernel chain

`nmartin0/{ode, ode4linux, buildtools, Mach-patched-gcc}` for build and
era-compiler questions. `nmartin0/mach_vm_descendents` collects the
Mach VM system in several forms and bears on `pmap` and VM work.

## Open

The ten `mach_stuff/osfmk*` copies are unidentified: `sys/version.h`
reads "Mach 3.0" in all of them, so the release needs a different
marker. Identify each once and record it here, so they stop being
called `osfmk (2)2`.
