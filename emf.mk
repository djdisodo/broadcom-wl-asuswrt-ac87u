#
# Makefile fragment for Linux 2.6
# Broadcom 802.11abg Networking Device Driver
#
# Copyright (C) 2015, Broadcom Corporation. All Rights Reserved.
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
# OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# $Id: Makefile_kbuild_portsrc 580354 2015-08-18 23:42:37Z $

ifneq ($(KERNELRELEASE),)

  LINUXVER_GOODFOR_CFG80211:=$(strip $(shell \
    if [ "$(VERSION)" -ge "2" -a "$(PATCHLEVEL)" -ge "6" -a "$(SUBLEVEL)" -ge "32" -o "$(VERSION)" -ge "3" ]; then \
      echo TRUE; \
    else \
      echo FALSE; \
    fi \
  ))

    LINUXVER_WEXT_ONLY:=$(strip $(shell \
    if [ "$(VERSION)" -ge "2" -a "$(PATCHLEVEL)" -ge "6" -a "$(SUBLEVEL)" -ge "17" ]; then \
      echo FALSE; \
    else \
      echo TRUE; \
    fi \
  ))

  ifneq ($(API),)
    ifeq ($(API), CFG80211)
      APICHOICE := FORCE_CFG80211
      $(info CFG80211 API specified in command line)
    else
      ifeq ($(API), WEXT)
        APICHOICE := FORCE_WEXT
        $(info Wireless Extension API specified in command line)
      else
        $(error Unknown API type)
      endif
    endif
  else
    ifeq ($(LINUXVER_GOODFOR_CFG80211),TRUE)
      APICHOICE := PREFER_CFG80211
      $(info CFG80211 API is prefered for this kernel version)
    else
      ifeq ($(LINUXVER_WEXT_ONLY),TRUE)
        APICHOICE := FORCE_WEXT
        $(info Wireless Extension is the only possible API for this kernel version)
      else
        APICHOICE := PREFER_WEXT
        $(info Wireless Extension API is prefered for this kernel version)
      endif
    endif
  endif

  ifeq ($(APICHOICE),FORCE_CFG80211)
    ifneq ($(CONFIG_CFG80211),)
      APIFINAL := CFG80211
    else
      $(error CFG80211 is specified but it is not enabled in kernel)
    endif
  endif

  ifeq ($(APICHOICE),FORCE_WEXT)
    APIFINAL := WEXT
  endif

  ifeq ($(APICHOICE),PREFER_CFG80211)
    ifneq ($(CONFIG_CFG80211),)
      APIFINAL := CFG80211
    else
      ifneq ($(CONFIG_WIRELESS_EXT),)
        APIFINAL := WEXT
      else
        $(warning Neither CFG80211 nor Wireless Extension is enabled in kernel)
      endif
    endif
  endif

  ifeq ($(APICHOICE),PREFER_WEXT)
    ifneq ($(CONFIG_WIRELESS_EXT),)
      APIFINAL := WEXT
    else
      ifneq ($(CONFIG_CFG80211),)
        APIFINAL := CFG80211
      else
        $(warning Neither CFG80211 nor Wireless Extension is enabled in kernel)
      endif
    endif
  endif

endif

#Check GCC version so we can apply -Wno-date-time if supported.  GCC >= 4.9
empty:=
space:= $(empty) $(empty)
GCCVERSIONSTRING := $(shell expr `$(CC) -dumpversion`)
#Create version number without "."
GCCVERSION := $(shell expr `echo $(GCCVERSIONSTRING)` | cut -f1 -d.)
GCCVERSION += $(shell expr `echo $(GCCVERSIONSTRING)` | cut -f2 -d.)
GCCVERSION += $(shell expr `echo $(GCCVERSIONSTRING)` | cut -f3 -d.)
# Make sure the version number has at least 3 decimals
GCCVERSION += 00
# Remove spaces from the version number
GCCVERSION := $(subst $(space),$(empty),$(GCCVERSION))
# Crop the version number to 3 decimals.
GCCVERSION := $(shell expr `echo $(GCCVERSION)` | cut -b1-3)
GE_49 := $(shell expr `echo $(GCCVERSION)` \>= 490)

EXTRA_CFLAGS :=

ifeq ($(APIFINAL),CFG80211)
  EXTRA_CFLAGS += -DUSE_CFG80211
  $(info Using CFG80211 API)
endif

ifeq ($(APIFINAL),WEXT)
  EXTRA_CFLAGS += -DUSE_IW
  $(info Using Wireless Extension API)
endif

obj-m              += emf.o

emf-objs            := src/emf/emf/emf_linux.o
emf-objs            += src/shared/linux_osl.o

emf-objs            += src/compat/compat.o
emf-objs            += src/compat/bitops.o
emf-objs            += src/compat/workqueue.o
emf-objs            += src/compat/device.o
emf-objs            += src/compat/skbuff.o
emf-objs            += src/compat/proc_fs.o
emf-objs            += src/compat/uaccess.o
emf-objs            += src/compat/netdevice.o

emf-objs            += src/shared/bcmutils.o
emf-objs            += src/shared/siutils.o
emf-objs            += src/shared/sbutils.o
emf-objs            += src/shared/hndpmu.o
emf-objs            += src/shared/hnddma.o
emf-objs            += src/shared/nicpci.o
emf-objs            += src/shared/aiutils.o
emf-objs            += src/shared/bcmsrom.o
emf-objs            += src/shared/nvram_ro.o
emf-objs            += src/shared/bcmotp.o

EXTRA_CFLAGS       += -I$(src)/src/include -I$(src)/src/common/include
EXTRA_CFLAGS       += -I$(src)/src/wl/sys -I$(src)/src/wl/phy -I$(src)/src/wl/ppr/include
EXTRA_CFLAGS       += -I$(src)/src/shared/bcmwifi/include -I$(src)/src/emf
EXTRA_CFLAGS       += -DBCMDRIVER -DWLC_LOW -nostdlib -DWLMSG_PRPKT -DCTFPOOL -DHNDCTF

#idk wtf
EXTRA_CFLAGS       += -DCONFIG_MMC_MSM7X00A

#EXTRA_CFLAGS       += -DBCMDBG_ASSERT -DBCMDBG_ERR
ifeq "$(GE_49)" "1"
EXTRA_CFLAGS       += -Wno-date-time
endif

#EXTRA_LDFLAGS      := $(src)/lib/wl_preprocessed.o

KBASE              ?= /lib/modules/`uname -r`
KBUILD_DIR         ?= $(KBASE)/build
MDEST_DIR          ?= $(KBASE)/kernel/drivers/net/wireless

# Cross compile setup.  Tool chain and kernel tree, replace with your own.
CROSS_TOOLS        = /home/sodo/openwrt/staging_dir/toolchain-arm_cortex-a9_gcc-11.2.0_musl_eabi/bin/arm-openwrt-linux-
CROSS_KBUILD_DIR   = /home/sodo/openwrt/build_dir/target-arm_cortex-a9_musl_eabi/linux-bcm53xx_generic/linux-5.10.113

all:
	KBUILD_NOPEDANTIC=1 make -C $(KBUILD_DIR) M=`pwd`

cross:
	
	KBUILD_NOPEDANTIC=1 ARCH=arm make CROSS_COMPILE=${CROSS_TOOLS} -C $(CROSS_KBUILD_DIR) M=`pwd`

clean:
	KBUILD_NOPEDANTIC=1 make -C $(KBUILD_DIR) M=`pwd` clean

install:
	install -D -m 755 wl.ko $(MDEST_DIR)
