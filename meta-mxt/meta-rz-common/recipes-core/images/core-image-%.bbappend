IMAGE_FEATURES:remove = " ssh-server-dropbear"
IMAGE_FEATURES:append = " ssh-server-openssh"

IMAGE_INSTALL:append = " \
	u-boot-tools \
	kernel-image \
	kernel-devicetree \
	htop \
	iperf3 \
"
