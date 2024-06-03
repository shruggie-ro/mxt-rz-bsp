FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

KERNEL_DEVICETREE = " \
	renesas/r9a07g044l2-mxt-smarc.dtb \
"

SRC_URI:append =  " \
	file://dts/ \
"

do_compile:prepend() {
	cp -rf ${WORKDIR}/dts/* ${S}/arch/arm64/boot/dts/renesas/
}

do_install:append() {
	install -d -m 0755 -d ${D}/boot
	cp -f ${B}/arch/arm64/boot/dts/renesas/r9a07g044l2-mxt-smarc.dtb ${D}/boot/r9a07g044l2-smarc.dtb
}

