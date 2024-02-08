/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
/*
 * NOTE: This file has been modified by Sony Corporation.
 * Modifications are Copyright 2021 Sony Corporation,
 * and licensed under the license of the file.
 */
/*
 * Copyright (C) 2004, 2007-2010, 2011-2012 Synopsys, Inc. (www.synopsys.com)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#ifndef _ASM_ARC_SIGCONTEXT_H
#define _ASM_ARC_SIGCONTEXT_H

#include <asm/ptrace.h>

/*
 * Signal context structure - contains all info to do with the state
 * before the signal handler was invoked.
 */
struct sigcontext {
	struct user_regs_struct regs;
	struct user_regs_arcv2 v2abi;
};

#endif /* _ASM_ARC_SIGCONTEXT_H */
