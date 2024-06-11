#
# This recipe adds DA16600 wifi module driver.
#
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

inherit module

DESCRIPTION = "Recipe for DA16600 wifi module driver"
LICENSE = "CLOSED"

SRC_URI = " \
	file://da16200_v5.2.1.2.tar.gz \
	file://lmacfw_spi.bin \
"

S = "${WORKDIR}/rswlan"

EXTRA_OEMAKE += "KDIR='${STAGING_KERNEL_DIR}'"
EXTRA_OEMAKE += "CONFIG_RS_BCN=y"
EXTRA_OEMAKE += "CONFIG_HOST_TX_MERGE=y"
EXTRA_OEMAKE += "CONFIG_MODULE_TYPE=spi"

do_install() {
	install -m 0755 -d ${D}/${nonarch_base_libdir}/firmware
	install -m 0644 ${WORKDIR}/lmacfw_spi.bin ${D}/${nonarch_base_libdir}/firmware/lmacfw_spi.bin

	install -m 0755 -d ${D}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
	install -m 0644 ${WORKDIR}/rswlan/rswlan.ko ${D}/${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/rswlan.ko
}

RPROVIDES:${PN} += "kernel-module-rswlan-${KERNEL_VERSION}"

FILES:${PN} = " \
	${nonarch_base_libdir}/firmware/lmacfw_spi.bin \
	${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/rswlan.ko \
"
