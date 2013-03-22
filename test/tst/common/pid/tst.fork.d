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

#pragma ident	"@(#)tst.fork.d	1.1	06/08/28 SMI"

/*
 * ASSERTION: make sure fork(2) is okay
 *
 * SECTION: pid provider
 */

#pragma D option destructive

pid$1:a.out:waiting:entry
{
	this->value = (int *)alloca(sizeof (int));
	*this->value = 1;
	copyout(this->value, arg0, sizeof (int));
}

#if !defined(__APPLE__)
syscall::forkall:return
/curpsinfo->pr_ppid == $1/
{
	child = pid;
	trace(pid);
}
#else
syscall::fork:return
/curpsinfo->pr_pid == $1/
{
	child = arg0;
	trace(arg0);
}
#endif /* __APPLE__ */

pid$1:a.out:go:
/pid == child/
{
	trace("wrong pid");
	exit(1);
}

#if !defined(__APPLE__)
syscall::rexit:entry
/pid == $1 || pid == child/
#else
proc:::lwp-exit
/pid == $1 || pid == child/
#endif /* __APPLE__ */
{
	out++;
	trace(pid);
}

#if !defined(__APPLE__)
syscall::rexit:entry
#else
proc:::lwp-exit
#endif /* __APPLE__ */
/out == 2/
{
	exit(0);
}


BEGIN
{
	/*
	 * Let's just do this for 5 seconds.
	 */
	timeout = timestamp + 5000000000;
}

profile:::tick-4
/timestamp > timeout/
{
	trace("test timed out");
	exit(1);
}

