# new_mk

A revival of **OSF Mach Kernel 7.3** (MkLinux DR3) for i386, built on a
Linux host and run under QEMU, with the **LITES** 4.4BSD personality as a
first-class server of the tree.

## Layout

| path | what it is |
|---|---|
| `osfmk/` | verbatim vendor import of OSF MK 7.3. Modified only where necessary and always with justification. |
| `osfmk/src/mach_services/servers/lites/` | verbatim vendor import of LITES 1.1.u3, placed as a server of the tree — the same position CMU gave the UNIX server. |
| `build/` | our build scripts: sandbox setup, ODE bootstrap, environment. |
| `tools/` | our debugging and image-building helpers. |
| `notes/` | everything we write: the roadmap, the backlog, the decisions, the measured findings, and the working method. |
| `README_DR3`, `OSFMK_BUILD.README` | OSF's own documentation, kept as shipped. |

**`notes/ROADMAP.md` is the entry point** for what to do next.
**`notes/HANDOFF.md`** and **`notes/docs/current-blocker.md`** are the
authoritative record of where the system actually is.

## The record of what we changed

```sh
git diff <vendor-import>..HEAD -- osfmk/
```

is the complete record of every change to someone else's code. Nothing
we write lives under `osfmk/` except changes to OSF's and LITES's own
files, each carrying its reason at the site and in its commit message.

## Why LITES sits where it does

CMU built the UNIX server as a peer of the kernel: `usr_random/src/Makefile`
line 209 reads

```make
MACH=	mach_kernel mach_servers/ux mach_servers/mach_init
```

and UX's server used the kernel's own configuration machinery — `conf/MASTER`,
`MASTER.local`, `Makefile.template`, `files`, `copyright` — file for file.

LITES already carries the same machinery (`conf/MASTER`, `conf/files`,
`conf/i386/`, `doconfig.sh`, `gensym.awk`, `newvers.sh`), because
Helander wrote it as a Mach component. What sits on top of it is a GNU
`configure` added later. Absorbing LITES into the tree is therefore not a
conversion — it is removing that wrapper and letting the Mach machinery
underneath do the work it was written for.
