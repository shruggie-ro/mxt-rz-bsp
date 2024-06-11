require recipes-core/images/core-image-minimal.bb

# Basic packages
IMAGE_INSTALL:append = " \
    bonnie++ \
    util-linux \
    busybox \
    libusb1 \
    pciutils \
    iproute2 \
    i2c-tools \
    can-utils \
    ethtool \
    iperf3 \
    usbutils \
    mtd-utils \
    dosfstools \
    e2fsprogs-badblocks \
    e2fsprogs-dumpe2fs \
    e2fsprogs-e2fsck \
    e2fsprogs-e2scrub \
    e2fsprogs-mke2fs \
    e2fsprogs-resize2fs \
    e2fsprogs-tune2fs \
    minicom \
    memtester \
    alsa-utils \
    libdrm \
    libdrm-tests \
    yavta \
    kernel-modules \
    watchdog \
"

# Additional tools for support Tool develop
IMAGE_INSTALL:append = " \
    ckermit \
    connman \
    connman-client \
    connman-tools \
    connman-tests \
    connman-wait-online \
    lttng-modules \
    lttng-tools \
    lttng-ust \
    tcf-agent \
"
# Additional tools for support testing Realtime characteristic in system
IMAGE_INSTALL:append = " \
	${@oe.utils.conditional("IS_RT_BSP", "1", " rt-tests ", " ",d)} \
"
