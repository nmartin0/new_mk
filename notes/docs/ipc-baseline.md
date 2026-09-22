# IPC baseline (X19)

The cost of a Mach message round trip on this tree, taken before any of
the IPC work the design proposes, so that each change can be judged
against a number.

## How it is measured

`osfmk/src/mach_kernel/ipc/ipc_bench.c`, part of the in-kernel unit
tests (K46). Kernel threads exchange messages through
`mach_msg_overwrite()`, the `mach_msg` OSF's in-kernel servers use: it
runs the real IPC core -- `ipc_kmsg_copyin` and its rights processing,
`ipc_mqueue_send`, `ipc_mqueue_receive`, `ipc_kmsg_copyout` -- with port
names in the kernel task's space. It leaves out only the trap entry and
the copies between user space and the kernel.

A server thread receives and replies on the send-once right it was
given; the client makes combined send-and-receive calls. Each variant
runs 100 untimed round trips, then 2,000 timed ones, and reports TSC
ticks per round trip.

To reproduce:

```sh
sh build/ode.sh -here mach_kernel MACH_KERNEL_CONFIG=PRODUCTION+TEST
KERNEL=$MK_BUILD/obj/at386/mach_kernel/PRODUCTION+TEST/mach_kernel.PRODUCTION+TEST \
CONSOLE=socket-wait STARTUP_ARGS='-i /init' sh tools/boot-ide.sh
python3 tools/console.py --attach &      # the ipc_bench: lines appear in seconds
```

## Results, 22 September 2026

Tree at `f62f268` plus the benchmark. QEMU 8.2.2 **under TCG, without
KVM**, 128 MB, one CPU. Three boots:

| variant | TSC ticks per round trip, three runs | mean | spread | relative to null |
|---|---|---|---|---|
| null RPC | 10,521 · 10,104 · 10,432 | 10,352 | 4% | 1 |
| 4 KB in-line payload | 23,360 · 20,430 · 21,623 | 21,804 | 13% | 2.1 |
| null RPC, received through a port set | 10,227 · 8,822 · 10,334 | 9,794 | 15% | 0.95 |

## Reading them

- **Under TCG the absolute figures measure the emulator, not the
  kernel.** They are a baseline for regressions on the same host, not a
  statement of what the kernel costs on hardware. Only changes well
  beyond the spread -- about 15% here -- mean anything.
- **The ratios carry over better.** A 4 KB in-line payload costs about
  twice a null RPC; receiving through a port set costs no more than a
  single port, within the noise.
- **Not yet measured**, and still part of X19: out-of-line memory, the
  hash lookup with and without, figures under KVM, and the network side
  with `net-latency-tools` (G154) once the system has a network.
