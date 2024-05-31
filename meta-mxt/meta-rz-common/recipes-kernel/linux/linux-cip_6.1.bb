DESCRIPTION = "Linux kernel Renesas boards"

require recipes-kernel/linux/linux-yocto.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"
COMPATIBLE_MACHINE_rzg2l = "(smarc-rzg2l|rzg2l-dev|smarc-rzg2lc|rzg2lc-dev|smarc-rzg2ul|rzg2ul-dev|smarc-rzv2l|rzv2l-dev)"
COMPATIBLE_MACHINE_rzg2h = "(ek874|hihope-rzg2n|hihope-rzg2m|hihope-rzg2h)"
COMPATIBLE_MACHINE_rzfive = "(smarc-rzfive|rzfive-dev)"

KBRANCH = "${@oe.utils.conditional("IS_RT_BSP", "1", "linux-6.1.y-cip", "linux-6.1.y-cip",d)}"
SRCREV_machine = "${@oe.utils.conditional("IS_RT_BSP", "1", "a5d281b04d5bd8e58f9d1de802632ae9c5a262c8", "4e312831fe188da5bb477eeae886bcf07184f0eb",d)}"

LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"
# LINUX_VERSION ?= "${@oe.utils.conditional("IS_RT_BSP", "1", "v6.1.90-cip20-rt11", "v6.1.90-cip20",d)}"
LINUX_VERSION ?= "6.1.90"

PV = "${LINUX_VERSION}+git"

KMETA = "kernel-meta"
KCONF_BSP_AUDIT_LEVEL = "1"

SRC_URI = " \
	git://git.kernel.org/pub/scm/linux/kernel/git/cip/linux-cip.git;branch=${KBRANCH};name=machine \
	file://fragment-01-usb-ethernet.cfg \
	file://fragment-02-wifi.cfg \
	file://fragment-03-eth-phy.cfg \
	file://fragment-04-lontium-lt8912b.cfg \
"

KBUILD_DEFCONFIG = "defconfig"
KCONFIG_MODE = "alldefconfig"

# Functionality flags
KERNEL_FEATURES = ""

DEPENDS:append = " openssl-native dtc-native "
