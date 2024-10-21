FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

KERNEL_DEVICETREE:append = " \
    renesas/rzv2l-smarc.dtb \
    renesas/rzv2l-smarc-imx219.dtb \
    renesas/rzv2l-smarc-imx708.dtb \
    renesas/rzv2l-smarc-ov5647.dtb \
    renesas/rzv2l-smarc-tevs.dtb \
    renesas/rzv2l-vision-ai-imx135.dtb \
    renesas/rzv2l-vision-ai-imx219.dtb \
    renesas/rzv2l-vision-ai-imx477.dtb \
    renesas/rzv2l-vision-ai-imx708.dtb \
    renesas/rzv2l-vision-ai-ov5647.dtb \
    renesas/rzv2l-vision-ai-pivariety.dtb \
    renesas/rzv2l-vision-ai-tevs.dtb \
"

SRC_URI:append = " \
    file://rzv2l-dts/ \
"

do_compile:prepend() {
    cp -rf ${WORKDIR}/rzv2l-dts/* ${S}/arch/arm64/boot/dts/renesas/
}

do_install:append() {
	# Symlink the OV5647 DT to '/boot/r9a07g054l2-smarc.dtb'
	# This way we get a booting system, even if the camera is not the same
	install -m 0755 -d ${D}/boot
	ln -s rzv2l-vision-ai-ov5647.dtb ${D}/boot/r9a07g054l2-ov5647-smarc.dtb
	ln -s rzv2l-vision-ai-ov5647.dtb ${D}/boot/r9a07g054l2-smarc.dtb
}
