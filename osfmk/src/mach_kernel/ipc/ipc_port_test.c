/*
 * ipc_port_test.c -- unit test for port send rights.
 *
 * Part of the unit tests the KERNEL_TEST framework runs at boot in the
 * PRODUCTION+TEST configuration (K46; see ddb/unit_test.c). Returns 0
 * on success or a short reason for failure.
 */

#include <ipc/ipc_port.h>
#include <ipc/ipc_space.h>

const char *
unit_test_port_rights(void)
{
	ipc_port_t	port;

	if ((port = ipc_port_alloc_kernel()) == IP_NULL)
		return "ipc_port_alloc_kernel failed";
	if (!ip_active(port))
		return "a new port is not active";
	if (port->ip_srights != 0)
		return "a new port already has send rights";
	if (ipc_port_make_send(port) != port)
		return "ipc_port_make_send returned another port";
	if (port->ip_srights != 1)
		return "ipc_port_make_send did not count a send right";
	ipc_port_release_send(port);
	if (port->ip_srights != 0)
		return "ipc_port_release_send did not drop the send right";
	ipc_port_dealloc_kernel(port);
	return 0;
}
