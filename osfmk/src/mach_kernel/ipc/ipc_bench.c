/*
 * ipc_bench.c -- the IPC baseline (X19): Mach message round trips.
 *
 * Kernel threads exchange messages through mach_msg_overwrite(), the
 * mach_msg OSF's in-kernel servers use. That runs the real IPC core --
 * ipc_kmsg_copyin with its rights processing, ipc_mqueue_send and
 * ipc_mqueue_receive, ipc_kmsg_copyout -- with port names in the kernel
 * task's space, as a user task's names are in its own; it leaves out
 * only the trap entry and the user-space copies. So it needs no userland.
 *
 * A server thread receives and replies on the send-once right it was
 * given; the client -- the KERNEL_TEST thread -- makes combined send and
 * receive calls. Three variants: a null RPC, a 4 KB in-line payload, and
 * a receive through a port set instead of a single port. Each runs
 * IB_WARM untimed round trips, then IB_TRIPS timed ones, and prints the
 * cost in TSC ticks per round trip. Under emulation the absolute figure
 * measures the emulator; it is a baseline for regressions on one host,
 * and the ratios between variants are what carry over.
 *
 * Part of the unit tests (ddb/unit_test.c, K46): each variant returns 0
 * if every round trip succeeded, or the reason it did not.
 */
#include <mach/boolean.h>
#include <mach/kern_return.h>
#include <mach/message.h>
#include <mach/port.h>
#include <kern/task.h>
#include <kern/thread.h>
#include <ipc/ipc_space.h>

extern mach_msg_return_t mach_msg_overwrite(mach_msg_header_t *, mach_msg_option_t,
	mach_msg_size_t, mach_msg_size_t, mach_port_t, mach_msg_timeout_t,
	mach_port_t, mach_msg_header_t *, mach_msg_size_t);
extern kern_return_t	mach_port_allocate(ipc_space_t, mach_port_right_t, mach_port_t *);
extern kern_return_t	mach_port_move_member(ipc_space_t, mach_port_t, mach_port_t);

#define IB_TRIPS	2000
#define IB_WARM		100
#define IB_BIG		4096

struct ib_msg {
	mach_msg_header_t	h;
	char			body[IB_BIG];
	char			trailer[64];	/* room for the receive trailer */
};

static unsigned long long
ib_rdtsc(void)
{
	unsigned long long v;

	__asm__ __volatile__("rdtsc" : "=A" (v));
	return v;
}

/* One server per variant, each with its own receive name and buffer. */
static mach_port_t	ib_rcv[2];
static struct ib_msg	ib_smsg[2];

static void
ib_serve(int i)
{
	struct ib_msg *m = &ib_smsg[i];

	for (;;) {
		if (mach_msg_overwrite(&m->h, MACH_RCV_MSG, 0, sizeof *m,
		    ib_rcv[i], MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL, 0, 0)
		    != MACH_MSG_SUCCESS)
			continue;
		/* after copyout the reply right is msgh_remote_port */
		m->h.msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_MOVE_SEND_ONCE, 0);
		m->h.msgh_size = sizeof (mach_msg_header_t);
		m->h.msgh_local_port = MACH_PORT_NULL;
		(void) mach_msg_overwrite(&m->h, MACH_SEND_MSG, m->h.msgh_size, 0,
		    MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL, 0, 0);
	}
}
static void ib_serve0(void) { ib_serve(0); }
static void ib_serve1(void) { ib_serve(1); }

static mach_port_t	ib_svc[2], ib_reply;
static const char	*ib_setup_error;
static boolean_t	ib_ready;

static const char *
ib_setup(void)
{
	ipc_space_t space = current_space();
	mach_port_t pset;

	if (ib_ready || ib_setup_error)
		return ib_setup_error;
	if (mach_port_allocate(space, MACH_PORT_RIGHT_RECEIVE, &ib_svc[0]) != KERN_SUCCESS ||
	    mach_port_allocate(space, MACH_PORT_RIGHT_RECEIVE, &ib_svc[1]) != KERN_SUCCESS ||
	    mach_port_allocate(space, MACH_PORT_RIGHT_RECEIVE, &ib_reply) != KERN_SUCCESS)
		return ib_setup_error = "mach_port_allocate of a receive right failed";
	if (mach_port_allocate(space, MACH_PORT_RIGHT_PORT_SET, &pset) != KERN_SUCCESS)
		return ib_setup_error = "mach_port_allocate of a port set failed";
	if (mach_port_move_member(space, ib_svc[1], pset) != KERN_SUCCESS)
		return ib_setup_error = "mach_port_move_member failed";
	ib_rcv[0] = ib_svc[0];		/* variant 0: receive on the port */
	ib_rcv[1] = pset;		/* variant 1: receive on its set */
	(void) kernel_thread(kernel_task, ib_serve0, (void *) 0);
	(void) kernel_thread(kernel_task, ib_serve1, (void *) 0);
	ib_ready = TRUE;
	return 0;
}

static struct ib_msg ib_cmsg;

static const char *
ib_run(const char *what, int server, mach_msg_size_t size)
{
	struct ib_msg *m = &ib_cmsg;
	unsigned long long t0 = 0, t1, d;
	unsigned int each;
	const char *why;
	int i;

	if ((why = ib_setup()) != 0)
		return why;
	for (i = 0; i < IB_WARM + IB_TRIPS; i++) {
		if (i == IB_WARM)
			t0 = ib_rdtsc();
		m->h.msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_MAKE_SEND,
						MACH_MSG_TYPE_MAKE_SEND_ONCE);
		m->h.msgh_size = size;
		m->h.msgh_remote_port = ib_svc[server];
		m->h.msgh_local_port = ib_reply;
		m->h.msgh_id = i;
		if (mach_msg_overwrite(&m->h, MACH_SEND_MSG | MACH_RCV_MSG, size,
		    sizeof *m, ib_reply, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL, 0, 0)
		    != MACH_MSG_SUCCESS)
			return "a round trip failed";
	}
	t1 = ib_rdtsc();
	/*
	 * The kernel has no 64-bit division helper, and should not: divide in
	 * 32 bits, pre-shifting in the unlikely case the total needs more.
	 */
	d = t1 - t0;
	each = (d >> 32) == 0 ? (unsigned int) d / IB_TRIPS
	    : ((unsigned int) (d >> 10) / IB_TRIPS) << 10;
	printf("ipc_bench: %s: %d round trips, %u TSC ticks each\n", what,
	    IB_TRIPS, each);
	return 0;
}

const char *unit_test_ipc_null_rpc(void)
	{ return ib_run("null RPC", 0, sizeof (mach_msg_header_t)); }
const char *unit_test_ipc_inline_4k(void)
	{ return ib_run("4 KB in-line", 0, sizeof (mach_msg_header_t) + IB_BIG); }
const char *unit_test_ipc_port_set(void)
	{ return ib_run("null RPC via a port set", 1, sizeof (mach_msg_header_t)); }
