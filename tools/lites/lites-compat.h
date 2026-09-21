/*
 * Compatibility shims for building LITES 1.1u3 against OSFMK 7.3,
 * injected with -include. Each is being moved into the LITES source.
 */


/*
 * cthread_mach_msg.
 *
 * LITES supplies its own implementation in server/serv/cprocs.c with
 * the nine-argument signature old cthreads had -- the comment above its
 * declaration in ux_server_loop.c even says "These are missing from
 * cthreads". OSFMK 7.3's libcthreads does provide one, but collapsed
 * into a single struct argument:
 *
 *	kern_return_t cthread_mach_msg(struct cthread_mach_msg_struct *);
 *
 * whose members map one to one onto LITES's nine arguments. Nothing
 * calls ours here, so the two only collide as declarations.
 *
 * Pull cthreads.h in now with our name renamed out of the way. Its
 * include guard makes every later #include a no-op, so LITES's own
 * declaration and definition stand unopposed.
 */
#define cthread_mach_msg osfmk_cthread_mach_msg
#include <cthreads.h>
#undef cthread_mach_msg
