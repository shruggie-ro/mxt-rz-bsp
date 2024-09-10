FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

KERNEL_DEVICETREE:append = " \
     renesas/rzg2l-smarc.dtb \
"

SRC_URI:append = " \
    file://rzg2l-dts/ \
"

do_compile:prepend() {
    cp -rf ${WORKDIR}/rzg2l-dts/* ${S}/arch/arm64/boot/dts/renesas/
}

do_install:append() {
    install -d -m 0755 -d ${D}/boot
    cp -f ${B}/arch/arm64/boot/dts/renesas/rzg2l-smarc.dtb ${D}/boot/r9a07g044l2-smarc.dtb
}
