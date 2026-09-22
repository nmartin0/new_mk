# Mach interface manual pages, from MK84

The manual pages of CMU's MK84 kernel (`default.MK84/kernel/man`),
imported unchanged (R35, G172): 128 pages and MK84's own
`Makefile`, copied byte for byte from `mach_stuff` at `78cab0993cbf`,
the commit CI pins. They document the port interface, the whole
external memory manager protocol, processor sets and scheduling
policies, the host, task and thread interfaces, `mach_msg`, `ddb` and PC
sampling.

**Licence.** 111 pages carry Carnegie Mellon's copyright (1990, 1991)
and its permission notice, which must stay with them. The other 17 are
one-line roff `.so` redirects to another page, with no text of their
own (D30). ODE does not build these pages: nothing lists this directory,
and MK84's `Makefile` is kept only as it came.

**They describe MK84 -- Mach 3.0 -- not OSFMK 7.3.** The table below
says, for each page, whether its call still exists here. It was derived
mechanically from this tree: a `routine` in one of its `.defs` files
is **current**; an entry in `kern/syscall_sw.c`'s trap table -- named as it is, or with `_trap`, `_overwrite_trap` or `syscall_` -- is a **trap**; a `skip`
naming it in a `.defs` file means 7.3 **removed** the call and kept its
message number; anything else is **not in OSFMK 7.3**. Where a page and
this kernel disagree, the kernel is right; record the difference here.

Of the 128: **85 current** routines, **6 traps**, **3** overviews or
generated code, **9 removed** with their message slots kept, and **25
not in OSFMK 7.3** -- mostly MK84's real-time timers and periodic
threads, scheduling-policy limits, per-thread PC sampling, and the
plural special-port calls.

**A vendor defect, kept:** four redirects read `so.` instead of `.so`
and render as text instead of redirecting.

| page | in OSFMK 7.3 |
|---|---|
| `ddb` | overview: the kernel debugger |
| `host_info` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `host_ipc_statistics` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach_debug/mach_debug.defs` |
| `host_kernel_version` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `host_processor_set_priv` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `host_processor_sets` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `host_processors` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `mach_host_self` | trap: `mach_host_self` in `mach_kernel/kern/syscall_sw.c` |
| `mach_msg` | trap: `mach_msg_overwrite_trap` in `mach_kernel/kern/syscall_sw.c` |
| `mach_port_allocate` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_allocate_name` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_deallocate` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_destroy` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_extract_right` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_get_receive_status` | **not in OSFMK 7.3** |
| `mach_port_get_refs` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_get_set_status` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_insert_right` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_mod_refs` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_move_member` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_names` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_rename` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_request_notification` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_set_mscount` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_set_qlimit` | **not in OSFMK 7.3** |
| `mach_port_set_seqno` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_port_type` | current: routine in `mach_kernel/mach/mach_port.defs` |
| `mach_ports` | overview: ports |
| `mach_ports_lookup` | current: routine in `mach_kernel/mach/mach.defs` |
| `mach_ports_register` | current: routine in `mach_kernel/mach/mach.defs` |
| `mach_reply_port` | trap: `mach_reply_port` in `mach_kernel/kern/syscall_sw.c` |
| `mach_task_self` | trap: `mach_task_self` in `mach_kernel/kern/syscall_sw.c` |
| `mach_thread_self` | trap: `mach_thread_self` in `mach_kernel/kern/syscall_sw.c` |
| `memory_object_copy` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach/memory_object.defs` |
| `memory_object_create` | current: routine in `mach_kernel/mach/memory_object_default.defs` |
| `memory_object_data_error` | current: routine in `mach_kernel/mach/mach.defs` |
| `memory_object_data_initialize` | current: routine in `mach_kernel/mach/memory_object_default.defs` |
| `memory_object_data_provided` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach/mach.defs` |
| `memory_object_data_request` | current: routine in `mach_kernel/mach/memory_object.defs` |
| `memory_object_data_unavailable` | current: routine in `mach_kernel/mach/mach.defs` |
| `memory_object_data_unlock` | current: routine in `mach_kernel/mach/memory_object.defs` |
| `memory_object_data_write` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach/memory_object.defs` |
| `memory_object_destroy` | current: routine in `mach_kernel/mach/mach.defs` |
| `memory_object_get_attributes` | current: routine in `mach_kernel/mach/mach.defs` |
| `memory_object_init` | current: routine in `mach_kernel/mach/memory_object.defs` |
| `memory_object_lock_completed` | current: routine in `mach_kernel/mach/memory_object.defs` |
| `memory_object_lock_request` | current: routine in `mach_kernel/mach/mach.defs` |
| `memory_object_server` | library: the MIG-generated demultiplexer |
| `memory_object_set_attributes` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach/mach.defs` |
| `memory_object_terminate` | current: routine in `mach_kernel/mach/memory_object.defs` |
| `periodic_thread_create` | **not in OSFMK 7.3** |
| `periodic_thread_restart` | **not in OSFMK 7.3** -- redirect: `so. periodic_thread_create.2` **(vendor typo: `so.` for `.so`)** |
| `processor_assign` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_control` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_exit` | current: routine in `mach_kernel/mach/mach_host.defs` -- redirect: `.so processor_control.2` |
| `processor_get_assignment` | current: routine in `mach_kernel/mach/mach_host.defs` -- redirect: `.so processor_assign.2` |
| `processor_info` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_create` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_default` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_destroy` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_info` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_max_priority` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_policy_add` | **not in OSFMK 7.3** |
| `processor_set_policy_disable` | current: routine in `mach_kernel/mach/mach_host.defs` -- redirect: `.so processor_set_policy_enable.2` |
| `processor_set_policy_enable` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_policy_limit` | **not in OSFMK 7.3** |
| `processor_set_policy_remove` | **not in OSFMK 7.3** -- redirect: `.so processor_set_policy_add.2` |
| `processor_set_tasks` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_set_threads` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `processor_start` | current: routine in `mach_kernel/mach/mach_host.defs` -- redirect: `.so processor_control.2` |
| `task_assign` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `task_assign_default` | current: routine in `mach_kernel/mach/mach_host.defs` -- redirect: `.so task_assign.2` |
| `task_create` | current: routine in `mach_kernel/mach/mach.defs` |
| `task_disable_pc_sampling` | **not in OSFMK 7.3** -- redirect: `.so task_enable_pc_sampling.2` |
| `task_enable_pc_sampling` | **not in OSFMK 7.3** |
| `task_get_assignment` | current: routine in `mach_kernel/mach/mach_host.defs` -- redirect: `so. task_assign.2` **(vendor typo: `so.` for `.so`)** |
| `task_get_sampled_pcs` | **not in OSFMK 7.3** -- redirect: `.so task_enable_pc_sampling.2` |
| `task_get_special_ports` | **not in OSFMK 7.3** |
| `task_info` | current: routine in `mach_kernel/mach/mach.defs` |
| `task_priority` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach/mach_host.defs` |
| `task_ras_control` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_services/servers/lites/emulator/emul_mach.defs` |
| `task_resume` | current: routine in `mach_kernel/mach/mach.defs` |
| `task_set_default_policy` | **not in OSFMK 7.3** |
| `task_set_special_ports` | **not in OSFMK 7.3** -- redirect: `.so task_get_special_ports.2` |
| `task_suspend` | current: routine in `mach_kernel/mach/mach.defs` |
| `task_terminate` | current: routine in `mach_kernel/mach/mach.defs` |
| `task_threads` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_abort` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_assign` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `thread_create` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_disable_pc_sampling` | **not in OSFMK 7.3** -- redirect: `.so task_enable_pc_sampling.2` |
| `thread_enable_pc_sampling` | **not in OSFMK 7.3** -- redirect: `.so task_enable_pc_sampling.2` |
| `thread_get_periodic_timers` | **not in OSFMK 7.3** -- redirect: `so. thread_set_periodic_timers.2` **(vendor typo: `so.` for `.so`)** |
| `thread_get_sampled_pcs` | **not in OSFMK 7.3** -- redirect: `.so task_enable_pc_sampling.2` |
| `thread_get_special_port` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_get_state` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_info` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_policy` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `thread_priority` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_kernel/mach/mach_host.defs` |
| `thread_resume` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_set_periodic_timers` | **not in OSFMK 7.3** |
| `thread_set_policy` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `thread_set_policy_limit` | **not in OSFMK 7.3** -- redirect: `.so thread_set_policy_param.2` |
| `thread_set_policy_param` | **not in OSFMK 7.3** |
| `thread_set_special_port` | current: routine in `mach_kernel/mach/mach.defs` -- redirect: `so. thread_get_special_port.2` **(vendor typo: `so.` for `.so`)** |
| `thread_set_state` | current: routine in `mach_kernel/mach/mach.defs` -- redirect: `.so thread_get_state.2` |
| `thread_suspend` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_switch` | trap: `syscall_thread_switch` in `mach_kernel/kern/syscall_sw.c` |
| `thread_terminate` | current: routine in `mach_kernel/mach/mach.defs` |
| `thread_wire` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `timer_arm` | **not in OSFMK 7.3** |
| `timer_cancel` | **not in OSFMK 7.3** |
| `timer_create` | **not in OSFMK 7.3** |
| `timer_sleep` | **not in OSFMK 7.3** |
| `timer_terminate` | **not in OSFMK 7.3** |
| `vm_allocate` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_copy` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_deallocate` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_inherit` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_machine_attribute` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_map` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_protect` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_read` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_region` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_set_default_memory_manager` | current: routine in `mach_kernel/mach/mach.defs` |
| `vm_statistics` | **removed in OSFMK 7.3**; its message slot is kept as a `skip` in `mach_services/servers/lites/emulator/emul_mach.defs` |
| `vm_wire` | current: routine in `mach_kernel/mach/mach_host.defs` |
| `vm_write` | current: routine in `mach_kernel/mach/mach.defs` |
