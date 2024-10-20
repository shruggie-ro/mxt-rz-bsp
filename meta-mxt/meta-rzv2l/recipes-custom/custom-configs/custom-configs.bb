SUMMARY = "Custom configuration files for the board"
SECTION = "custom"
LICENSE = "CLOSED"

inherit systemd

SRC_URI = "file://connman_main.conf \
	file://mxt-rzv2l-camera-init.sh \
	file://mxt-rzv2l-camera-init.service \
"

do_install() {
	install -m 0755 -d ${D}/etc/connman
	install -m 0744 ${WORKDIR}/connman_main.conf ${D}/etc/connman/main.conf

	install -m 0755 -d ${D}/usr/bin
	install -m 0755 ${WORKDIR}/mxt-rzv2l-camera-init.sh ${D}/usr/bin

	install -m 0755 -d ${D}${systemd_unitdir}/system
	install -m 0744 ${WORKDIR}/mxt-rzv2l-camera-init.service ${D}${systemd_unitdir}/system/
}

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "mxt-rzv2l-camera-init.service"

FILES:${PN} = " \
	${systemd_unitdir}/* \
	/usr/bin/* \
	/etc/* \
"
