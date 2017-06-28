README
==========================================================================
This patchset is to be the series of patches for gentoo-sources.
It is designed for cross-compatibility, fixes and stability, with performance
and additional features/driver support being a second.

Unless otherwise stated and marked as such, this kernel should be suitable for
all environments.

Patchset Numbering Scheme
==========================================================================

FIXES
-----
 - 1000-1400	linux-stable
 - 1400-1500	linux-stable queue
 - 1500-1700	security
 - 1700-1800	architecture-related
 - 1800-1900	mm/scheduling/misc
 - 1900-2000	filesystems
 - 2000-2100	networking core
 - 2100-2200	storage core
 - 2200-2300	power management (ACPI, APM)
 - 2300-2400	bus (USB, IEEE1394, PCI, PCMCIA, ...)
 - 2400-2500	network drivers
 - 2500-2600	storage drivers
 - 2600-2700	input
 - 2700-2900	media (graphics, sound, tv)
 - 2900-3000	other
 - 3000-4000	reserved

FEATURES
-----
 - 4000-4100	network
 - 4100-4200	storage
 - 4200-4300	graphics
 - 4300-4400	filesystem
 - 4400-4500   security enhancement
 - 4500-4600   other

EXPERIMENTAL
-----
 - 5000-5100   experimental patches (BFQ, ...)

Individual Patch Descriptions:
==========================================================================

**Patch:**  1000_linux-4.11.1.patch  
**From:**   http://www.kernel.org   
**Desc:**   Linux 4.11.1

**Patch:**  1001_linux-4.11.2.patch  
**From:**   http://www.kernel.org  
**Desc:**   Linux 4.11.2

**Patch:**  1002_linux-4.11.3.patch  
**From:**   http://www.kernel.org  
**Desc:**   Linux 4.11.3

**Patch:**  1003_linux-4.11.4.patch  
**From:**   http://www.kernel.org  
**Desc:**   Linux 4.11.4

**Patch:**  1004_linux-4.11.5.patch  
**From:**   http://www.kernel.org  
**Desc:**   Linux 4.11.5

**Patch:**  1005_linux-4.11.6.patch  
**From:**   http://www.kernel.org  
**Desc:**   Linux 4.11.6

**Patch:**  1006_linux-4.11.7.patch  
**From:**   http://www.kernel.org  
**Desc:**   Linux 4.11.7

**Patch:**  1500_XATTR_USER_PREFIX.patch  
**From:**   https://bugs.gentoo.org/show_bug.cgi?id=470644  
**Desc:**   Support for namespace user.pax.* on tmpfs.

**Patch:**  1510_fs-enable-link-security-restrictions-by-default.patch  
**From:**   http://sources.debian.net/src/linux/3.16.7-ckt4-3/debian/patches/debian/fs-enable-link-security-restrictions-by-default.patch/  
**Desc:**   Enable link security restrictions by default.

**Patch:**  1520_security-apparmor-Use-POSIX-compatible-printf.patch  
**From:**   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/patch/security/apparmor?id=651e54953b5d4ad103f0efa54fc6b380807fca3a  
**Desc:**   security/apparmor: Use POSIX-compatible "printf '%s'". See bug #622552

**Patch:**	1700_ia64-fix-module-loading-for-gcc-5.4.patch  
**From:**	http://www.kernel.org  
**Desc:** 	ia64: Lift the slot=2 restriction from the kernel module loader.

**Patch:**  2300_enable-poweroff-on-Mac-Pro-11.patch  
**From:**   http://kernel.ubuntu.com/git/ubuntu/ubuntu-xenial.git/patch/drivers/pci/quirks.c?id=5080ff61a438f3dd80b88b423e1a20791d8a774c  
**Desc:**   Workaround to enable poweroff on Mac Pro 11. See bug #601964.

**Patch:** 2600_hid-apple.patch  
**From:**  https://github.com/free5lot/hid-apple-patched  
**Desc:**  Allows GNU/Linux user to swap the FN and left Control keys and some other mapping tweaks on Macbook Pro, external Apple keyboards and probably other Apple devices.

**Patch:**  2900_dev-root-proc-mount-fix.patch  
**From:**   https://bugs.gentoo.org/show_bug.cgi?id=438380  
**Desc:**   Ensure that /dev/root doesn't appear in /proc/mounts when bootint without an initramfs.

**Patch:**  4200_fbcondecor.patch  
**From:**   http://www.mepiscommunity.org/fbcondecor  
**Desc:**   Bootsplash ported by Uladzimir Bely. (Bug #596126)

**Patch:**  4400_alpha-sysctl-uac.patch  
**From:**   Tobias Klausmann (klausman@gentoo.org) and http://bugs.gentoo.org/show_bug.cgi?id=217323  
**Desc:**   Enable control of the unaligned access control policy from sysctl

**Patch:**  4567_distro-Gentoo-Kconfig.patch  
**From:**   Tom Wijsman <TomWij@gentoo.org>  
**Desc:**   Add Gentoo Linux support config settings and defaults.

**Patch:**  5001_block-cgroups-kconfig-build-bits-for-BFQ-v7r11-4.11.patch  
**From:**   http://algo.ing.unimo.it/people/paolo/disk_sched/  
**Desc:**   BFQ v7r11 patch 1 for 4.10: Build, cgroups and kconfig bits

**Patch:**  5002_block-introduce-the-BFQ-v7r11-I-O-sched-for-4.11.0.patch1  
**From:**   http://algo.ing.unimo.it/people/paolo/disk_sched/  
**Desc:**   BFQ v7r11 patch 2 for 4.10: BFQ Scheduler

**Patch:**  5003_block-bfq-add-Early-Queue-Merge-EQM-to-BFQ-v7r11-for-4.11.patch  
**From:**   http://algo.ing.unimo.it/people/paolo/disk_sched/  
**Desc:**   BFQ v7r11 patch 3 for 4.10: Early Queue Merge (EQM)

**Patch:**  5004_blkck-bfq-turn-BFQ-v7r11-for-4.11.0-into-BFQ-v8r11-for-4.patch1  
**From:**   http://algo.ing.unimo.it/people/paolo/disk_sched/  
**Desc:**   BFQ v8r8 patch 4 for 4.10: Early Queue Merge (EQM)

**Patch:**  5010_enable-additional-cpu-optimizations-for-gcc.patch  
**From:**   https://github.com/graysky2/kernel_gcc_patch/  
**Desc:**   Kernel patch enables gcc >= v4.9 optimizations for additional CPUs.
