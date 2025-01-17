/*
 * Timer functions used by EMFL. These Functions can be moved to
 * shared/linux_osl.c, include/linux_osl.h
 *
 * Copyright (C) 2009, Broadcom Corporation
 * All Rights Reserved.
 * 
 * This is UNPUBLISHED PROPRIETARY SOURCE CODE of Broadcom Corporation;
 * the contents of this file may not be disclosed to third parties, copied
 * or duplicated in any form, in whole or in part, without the prior
 * written permission of Broadcom Corporation.
 *
 * $Id: osl_linux.c,v 1.3.1 2010/11/22 09:05:02 Exp $
 */

#include <typedefs.h>
#include <bcmdefs.h>
#include <osl.h>
#include <emf/igs/osl_linux.h>

static void
osl_timer(struct timer_list *data)
{
	osl_timer_t *t = from_timer(t, data, timer);

	ASSERT(t->set);

	if (t->periodic) {
#if defined(BCMJTAG) || defined(BCMSLTGT)
		t->timer.expires = jiffies + t->ms*HZ/1000*htclkratio;
#else
		t->timer.expires = jiffies + t->ms*HZ/1000;
#endif /* defined(BCMJTAG) || defined(BCMSLTGT) */
		add_timer(&t->timer);
		t->set = TRUE;
		t->fn(t->arg);
	} else {
		t->set = FALSE;
		t->fn(t->arg);
#ifdef BCMDBG
		if (t->name) {
			MFREE(NULL, t->name, strlen(t->name) + 1);
		}
#endif
		MFREE(NULL, t, sizeof(osl_timer_t));
	}

	return;
}

osl_timer_t *
osl_timer_init(const char *name, void (*fn)(void *arg), void *arg)
{
	osl_timer_t *t;

	if ((t = MALLOC(NULL, sizeof(osl_timer_t))) == NULL) {
		printk(KERN_ERR "osl_timer_init: out of memory, malloced %d bytes\n",
		       sizeof(osl_timer_t));
		return (NULL);
	}

	bzero(t, sizeof(osl_timer_t));
	t->fn = fn;
	t->arg = arg;
	
#if LINUX_VERSION_CODE < KERNEL_VERSION(4,14,0)
	t->timer.function = osl_timer;
#endif
#ifdef BCMDBG
	if ((t->name = MALLOC(NULL, strlen(name) + 1)) != NULL) {
		strcpy(t->name, name);
	}
#endif
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,14,0)
	timer_setup(&t->timer, osl_timer, 0);
#else
	init_timer(&t->timer);
#endif

	return (t);
}

void
osl_timer_add(osl_timer_t *t, uint32 ms, bool periodic)
{
	ASSERT(!t->set);

	t->set = TRUE;
	t->ms = ms;
	t->periodic = periodic;
#if defined(BCMJTAG) || defined(BCMSLTGT)
	t->timer.expires = jiffies + ms*HZ/1000*htclkratio;
#else
	t->timer.expires = jiffies + ms*HZ/1000;
#endif /* defined(BCMJTAG) || defined(BCMSLTGT) */

	add_timer(&t->timer);

	return;
}

void
osl_timer_update(osl_timer_t *t, uint32 ms, bool periodic)
{
	ASSERT(t->set);

	t->ms = ms;
	t->periodic = periodic;
	t->set = TRUE;
#if defined(BCMJTAG) || defined(BCMSLTGT)
	t->timer.expires = jiffies + ms*HZ/1000*htclkratio;
#else
	t->timer.expires = jiffies + ms*HZ/1000;
#endif /* defined(BCMJTAG) || defined(BCMSLTGT) */

	mod_timer(&t->timer, t->timer.expires);

	return;
}

/*
 * Return TRUE if timer successfully deleted, FALSE if still pending
 */
bool
osl_timer_del(osl_timer_t *t)
{
	if (t->set) {
		t->set = FALSE;
		if (!del_timer(&t->timer)) {
			printk(KERN_INFO "osl_timer_del: Failed to delete timer\n");
			return (FALSE);
		}
#ifdef BCMDBG
		if (t->name) {
			MFREE(NULL, t->name, strlen(t->name) + 1);
		}
#endif
		MFREE(NULL, t, sizeof(osl_timer_t));
	}

	return (TRUE);
}
