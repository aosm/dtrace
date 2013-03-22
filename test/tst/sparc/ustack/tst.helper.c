/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */

/*
 * Copyright 2006 Sun Microsystems, Inc.  All rights reserved.
 * Use is subject to license terms.
 */

#pragma ident	"@(#)tst.helper.c	1.1	06/08/28 SMI"

#include <stdint.h>

int
baz(void)
{
	return (8);
}

static int
foo(void)
{
	/*
	 * In order to assure that our helper is properly employed to identify
	 * the frame, we're going to trampoline through data.
	 */
	uint32_t instr[] = {
	    0x9de3bfa0,		/* save %sp, -0x60, %sp	*/
	    0x40000000,		/* call baz		*/
	    0x01000000,		/* nop			*/
	    0x81c7e008,		/* ret			*/
	    0x81e80000		/* restore		*/
	};

	instr[1] |= ((uintptr_t)baz - (uintptr_t)&instr[1]) >> 2;

	return ((*(int(*)(void))instr)() + 3);
}

int
main(int argc, char **argv)
{
	for (;;) {
		foo();
	}

	return (0);
}
