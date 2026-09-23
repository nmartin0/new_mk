# notes/

Everything we write lives here, so the OSF source tree stays clean.

`git diff <vendor-import>..HEAD -- osfmk/` remains the complete record of
what we changed in someone else's code, and nothing in this directory
appears in it.

## The documents

| file | holds | read it when |
|---|---|---|
| **`ROADMAP.md`** | the **order**, by dependency | **start here** — what to do next, and why then |
| **`BACKLOG.md`** | the **one list** of what is open (R, K, L, U, Q) | you need the detail of an item |
| **`DECISIONS.md`** | why the work is shaped this way (D, P, H) | something looks arbitrary, or you are about to reverse it |
| **`FINDINGS.md`**, **`FINDINGS2.md`** | what was **measured** (G1–G180) | you need the evidence behind a claim |
| **`DISTRIBUTED.md`** | the long-horizon multiserver design (X1–X26) | working on anything distributed |
| **`RULES-generic.md`** | the **method**, in portable form | before touching anything |

Alongside them, the project's own working documents, moved here from the
top level: `AGENTS.md`, `WORKFLOW.md`, `PRINCIPLES.md`, `RULES.md`,
`DEBUGGING.md`, `ENVIRONMENT.md`, `HANDOFF.md`, and `docs/` with
`GIT-HYGIENE.md`, `METHODOLOGY.md`, `SHELL.md`, `current-blocker.md`,
`lites-survey.md`, `bootstrap-fork.md` and `archive/`.

## Two rules files, deliberately

`RULES.md` is this project's own, distilled from its own documents and
carrying its own worked examples. `RULES-generic.md` is the portable
version, distilled from this project *and* an unrelated one, written to
be copied to another project without carrying Mach with it. Where they
differ, **`RULES.md` wins here** — it is the local contract.

## What is authoritative

**The live state of the system is not in this directory.** It is in
`notes/docs/current-blocker.md` and `notes/HANDOFF.md`, which are
written from measurement and are authoritative. The planning documents
above plan *around* that state; when the two disagree, the state
documents are right and the planning ones need correcting.

That has already happened once: `ROADMAP.md` described the system as
blocked on a libc for some time after it was booting multi-user to a
login prompt.

## Every item has exactly one home

An item named in `ROADMAP.md` is described in `BACKLOG.md` or
`DISTRIBUTED.md`; the evidence for a claim about it is in `FINDINGS*.md`;
the decision governing it is in `DECISIONS.md`. Nothing is described
twice, because two descriptions of one thing is how they stop agreeing.
